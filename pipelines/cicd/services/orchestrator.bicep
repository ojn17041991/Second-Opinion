targetScope = 'resourceGroup'

@allowed(['dev', 'prod'])
@description('Environment name, used as the name suffix.')
param environment string

@allowed(['so'])
@description('Project name, shortened for resource naming.')
param projectName string

@description('Name of the Container App Environment.')
param containerAppEnvironmentName string

@description('Name of the Container Registry (without .azurecr.io suffix).')
param containerRegistryName string

@description('Name of the Service Bus namespace.')
param serviceBusName string

@description('Name of the Log Analytics Workspace.')
param logAnalyticsWorkspaceName string

@description('Name of the monitor resource group.')
param monitorResourceGroupName string

@description('Container image tag to deploy.')
param tag string = 'latest'

@description('Service definitions loaded from services.json file.')
var servicesJson = json(loadTextContent('../services.json'))

@description('Array of service definitions with API/worker classification and ingress settings.')
var services array = concat(
  map(servicesJson.apis, name => { name: name, externalIngress: true }),
  map(servicesJson.workers, name => { name: name, externalIngress: false })
)

resource cae 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: containerAppEnvironmentName
}

resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(monitorResourceGroupName)
}

module service './service/service.bicep' = [for service in services: {
  name: 'service-${service.name}'
  params: {
		environment: environment
		projectName: projectName
		serviceName: service.name
		externalIngress: service.externalIngress
		containerAppEnvironmentId: cae.id
		containerRegistryName: containerRegistryName
		logAnalyticsWorkspaceId: law.id
		serviceBusName: serviceBusName
		tag: tag
  }
}]

output servicePrincipalIds array = [for (svc, i) in services: service[i].outputs.managedIdentityPrincipalId]
output serviceContainerAppNames array = [for (svc, i) in services: service[i].outputs.containerAppName]
