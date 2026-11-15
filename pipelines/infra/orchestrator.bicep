targetScope = 'subscription'

import { getSharedName, getAppsName, getMonitorName } from '../helpers/naming.bicep'

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

module resourceGroups 'resources/resourcegroups/resourcegroups.bicep' = {
  name: 'infra-resourceGroups'
  params: {
    environment: environment
    projectName: projectName
  }
}

module keyvault 'resources/keyvault/keyvault.bicep' = {
  name: 'infra-keyvault'
  scope: resourceGroup(getSharedName(projectName, environment))
  params: {
    environment: environment
    projectName: projectName
  }
  dependsOn: [
    resourceGroups
  ]
}

module servicebus 'resources/servicebus/servicebus.bicep' = {
  name: 'infra-servicebus'
  scope: resourceGroup(getSharedName(projectName, environment))
  params: {
    environment: environment
    projectName: projectName
  }
  dependsOn: [
    resourceGroups
  ]
}

module monitor 'resources/apps/monitor.bicep' = {
  name: 'infra-monitor'
  scope: resourceGroup(getMonitorName(projectName, environment))
  params: {
    environment: environment
    projectName: projectName
  }
  dependsOn: [
    resourceGroups
  ]
}

module apps 'resources/apps/apps.bicep' = {
  name: 'infra-apps'
  scope: resourceGroup(getAppsName(projectName, environment))
  params: {
    environment: environment
    projectName: projectName
    logAnalyticsWorkspaceId: monitor.outputs.logAnalyticsWorkspaceId
  }
  dependsOn: [
    resourceGroups
  ]
}

module admin 'rbac/admin.bicep' = {
  name: 'infra-admin'
  scope: resourceGroup(getSharedName(projectName, environment))
  params: {
    environment: environment
    projectName: projectName
    adminPrincipalId: adminPrincipalId
    serviceBusAdminAssignments: serviceBusAdminAssignments
  }
  dependsOn: [
    monitor
    apps
    servicebus
    keyvault
  ]
}

output logAnalyticsWorkspaceId string = monitor.outputs.logAnalyticsWorkspaceId
output containerAppEnvironmentId string = apps.outputs.containerAppEnvironmentId
