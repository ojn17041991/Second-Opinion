targetScope = 'resourceGroup'

param environment string
param projectName string
param containerAppEnvironmentName string
param containerRegistryName string
param serviceBusName string
param sharedResourceGroupName string
param tag string = 'latest'

var services = json(loadTextContent('../services.json'))
var serviceDefinitions array = concat(
  map(services.apis, name => { name: name, externalIngress: true }),
  map(services.workers, name => { name: name, externalIngress: false })
)

resource cae 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: containerAppEnvironmentName
}

module service './service.bicep' = [for definition in serviceDefinitions: {
  name: 'service-${definition.name}'
  params: {
		environment: environment
		projectName: projectName
		serviceName: definition.name
		externalIngress: definition.externalIngress
		containerAppEnvironmentId: cae.id
		containerRegistryName: containerRegistryName
		tag: tag
  }
}]

module rbac './rbac.bicep' = {
  name: 'services-rbac'
  scope: resourceGroup(sharedResourceGroupName)
  params: {
    serviceBusName: serviceBusName
    servicePrincipalIds: [for i in range(0, length(serviceDefinitions)): service[i].outputs.managedIdentityPrincipalId]
  }
}

output servicePrincipalIds array = [for i in range(0, length(serviceDefinitions)): service[i].outputs.managedIdentityPrincipalId]
output serviceContainerAppNames array = [for i in range(0, length(serviceDefinitions)): service[i].outputs.containerAppName]
