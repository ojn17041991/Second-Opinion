targetScope = 'subscription'

param environment string
param projectName string
param adminPrincipalId string
param serviceBusAdminAssignments array
param serviceBusAppAssignments array

var workerNames array = []
var uniqueSuffix string = uniqueString(subscription().id, projectName, environment)

module resourceGroups 'resources/resourcegroups/resourcegroups.bicep' = {
  name: 'resourceGroups'
  params: {
    environment: environment
    projectName: projectName
  }
}

module keyvault 'resources/keyvault/keyvault.bicep' = {
  name: 'keyvault'
  scope: resourceGroup('rg-${projectName}-shared-${environment}')
  params: {
    environment: environment
    projectName: projectName
    uniqueSuffix: uniqueSuffix
  }
  dependsOn: [
    resourceGroups
  ]
}

module servicebus 'resources/servicebus/servicebus.bicep' = {
  name: 'servicebus'
  scope: resourceGroup('rg-${projectName}-shared-${environment}')
  params: {
    environment: environment
    projectName: projectName
    uniqueSuffix: uniqueSuffix
  }
  dependsOn: [
    resourceGroups
  ]
}

module appsMonitor 'resources/apps/apps-monitor.bicep' = {
  name: 'appsMonitor'
  scope: resourceGroup('rg-${projectName}-monitor-${environment}')
  params: {
    environment: environment
    projectName: projectName
  }
  dependsOn: [
    resourceGroups
  ]
}

module appsInfra 'resources/apps/apps-infra.bicep' = {
  name: 'appsInfra'
  scope: resourceGroup('rg-${projectName}-apps-${environment}')
  params: {
    environment: environment
    projectName: projectName
    uniqueSuffix: uniqueSuffix
    logAnalyticsWorkspaceId: appsMonitor.outputs.logAnalyticsWorkspaceId
  }
  dependsOn: [
    resourceGroups
  ]
}

module worker 'workers/worker.bicep' = [for workerName in workerNames: {
  name: 'worker-${workerName}'
  scope: resourceGroup('rg-${projectName}-apps-${environment}')
  params: {
    environment: environment
    workerName: workerName
    containerAppEnvironmentId: appsInfra.outputs.containerAppEnvironmentId
    containerRegistryName: appsInfra.outputs.containerRegistryName
    containerImage: '${appsInfra.outputs.containerRegistryLoginServer}/${workerName}:latest'
  }
  dependsOn: [
    appsMonitor
    appsInfra
  ]
}]

module rbacShared 'rbac/rbac-shared.bicep' = {
  name: 'rbac'
  scope: resourceGroup('rg-${projectName}-shared-${environment}')
  params: {
    keyVaultName: keyvault.outputs.keyVaultName
    serviceBusName: servicebus.outputs.serviceBusName
    adminPrincipalId: adminPrincipalId
    workerPrincipalIds: [for i in range(0, length(workerNames)): worker[i].outputs.managedIdentityPrincipalId]
    serviceBusAdminAssignments: serviceBusAdminAssignments
    serviceBusAppAssignments: serviceBusAppAssignments
  }
  dependsOn: [
    worker
  ]
}

module rbacApps 'rbac/rbac-apps.bicep' = {
  name: 'rbac'
  scope: resourceGroup('rg-${projectName}-apps-${environment}')
  params: {
    containerRegistryName: appsInfra.outputs.containerRegistryName
    workerPrincipalIds: [for i in range(0, length(workerNames)): worker[i].outputs.managedIdentityPrincipalId]
  }
  dependsOn: [
    worker
  ]
}

output resourceGroupNames array = resourceGroups.outputs.rgNames
output keyVaultName string = keyvault.outputs.keyVaultName
output serviceBusName string = servicebus.outputs.serviceBusName
output logAnalyticsWorkspaceName string = appsMonitor.outputs.logAnalyticsWorkspaceName
output logAnalyticsWorkspaceId string = appsMonitor.outputs.logAnalyticsWorkspaceId
output containerRegistryName string = appsInfra.outputs.containerRegistryName
output containerAppEnvironmentName string = appsInfra.outputs.containerAppEnvironmentName
