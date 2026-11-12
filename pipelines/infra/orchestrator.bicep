targetScope = 'subscription'

@allowed(['dev', 'prod'])
@description('Environment name, used as the name suffix.')
param environment string

@allowed(['so'])
@description('Project name, shortened for resource naming.')
param projectName string

@description('Principal ID (user or service principal) for admin access to shared resources.')
param adminPrincipalId string

@description('Array of role assignments for admin access to shared resources. Each item should contain principalId and roleDefinitionId.')
param serviceBusAdminAssignments array

@description('A unique suffix generated from subscription and project details for resource naming.')
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

module monitor 'resources/apps/monitor.bicep' = {
  name: 'monitor'
  scope: resourceGroup('rg-${projectName}-monitor-${environment}')
  params: {
    environment: environment
    projectName: projectName
  }
  dependsOn: [
    resourceGroups
  ]
}

module apps 'resources/apps/apps.bicep' = {
  name: 'apps'
  scope: resourceGroup('rg-${projectName}-apps-${environment}')
  params: {
    environment: environment
    projectName: projectName
    uniqueSuffix: uniqueSuffix
    logAnalyticsWorkspaceId: monitor.outputs.logAnalyticsWorkspaceId
  }
  dependsOn: [
    resourceGroups
  ]
}

module admin 'rbac/admin.bicep' = {
  name: 'admin'
  scope: resourceGroup('rg-${projectName}-shared-${environment}')
  params: {
    keyVaultName: keyvault.outputs.keyVaultName
    serviceBusName: servicebus.outputs.serviceBusName
    adminPrincipalId: adminPrincipalId
    serviceBusAdminAssignments: serviceBusAdminAssignments
  }
  dependsOn: [
    monitor
    apps
  ]
}

output resourceGroupNames array = resourceGroups.outputs.rgNames
output keyVaultName string = keyvault.outputs.keyVaultName
output serviceBusName string = servicebus.outputs.serviceBusName
output logAnalyticsWorkspaceName string = monitor.outputs.logAnalyticsWorkspaceName
output logAnalyticsWorkspaceId string = monitor.outputs.logAnalyticsWorkspaceId
output containerRegistryName string = apps.outputs.containerRegistryName
output containerAppEnvironmentId string = apps.outputs.containerAppEnvironmentId
