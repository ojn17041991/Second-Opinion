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

@description('Name of the resource group containing the Service Bus namespace.')
param sharedResourceGroupName string

@description('Name of the monitor resource group.')
param monitorResourceGroupName string

@description('Name of the shared Application Insights component.')
param applicationInsightsName string

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

resource ai 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
  scope: resourceGroup(monitorResourceGroupName)
}

module service './service/apps.bicep' = [for service in services: {
  name: 'service-${service.name}'
  params: {
		environment: environment
		projectName: projectName
		serviceName: service.name
		externalIngress: service.externalIngress
		containerAppEnvironmentId: cae.id
		containerRegistryName: containerRegistryName
		applicationInsightsConnectionString: ai.properties.ConnectionString
		serviceBusName: serviceBusName
		sharedResourceGroupName: sharedResourceGroupName
		tag: tag
  }
}]

output servicePrincipalIds array = [for (svc, i) in services: service[i].outputs.managedIdentityPrincipalId]
output serviceContainerAppNames array = [for (svc, i) in services: service[i].outputs.containerAppName]
