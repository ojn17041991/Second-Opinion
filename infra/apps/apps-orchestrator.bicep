targetScope = 'subscription'

param environment string

module appsMonitor 'apps-monitor.bicep' = {
  name: 'appsMonitor'
  scope: resourceGroup('rg-so-monitor-${environment}')
  params: {
    environment: environment
  }
}

module apps 'apps.bicep' = {
  name: 'apps'
  scope: resourceGroup('rg-so-apps-${environment}')
  params: {
    environment: environment
    logAnalyticsWorkspaceId: appsMonitor.outputs.logAnalyticsWorkspaceId
  }
}

module appsRbac 'apps-rbac.bicep' = {
  name: 'appsRbac'
  scope: resourceGroup('rg-so-apps-${environment}')
  params: {
    containerAppPrincipalId: apps.outputs.containerAppPrincipalId
    containerRegistryName: apps.outputs.containerRegistryName
  }
}

output logAnalyticsWorkspaceName string = appsMonitor.outputs.logAnalyticsWorkspaceName
output containerRegistryName string = apps.outputs.containerRegistryName
output containerAppEnvironmentName string = apps.outputs.containerAppEnvironmentName
output containerAppName string = apps.outputs.containerAppName