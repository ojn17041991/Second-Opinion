targetScope = 'resourceGroup'

import { getContainerAppEnvironmentName, getApplicationInsightsName, getMonitorName } from '../../helpers/naming.bicep'

@allowed(['dev', 'prod'])
@description('Environment name, used as the name suffix.')
param environment string

@allowed(['so'])
@description('Project name, shortened for resource naming.')
param projectName string

@description('Container image tag to deploy.')
param tag string = 'latest'

@description('Service definitions loaded from services.json file.')
var services = json(loadTextContent('../services.json')).services

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2024-03-01' existing = {
  name: getContainerAppEnvironmentName(projectName, environment)
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: getApplicationInsightsName(projectName, environment)
  scope: resourceGroup(getMonitorName(projectName, environment))
}

module service './service/apps.bicep' = [for service in services: {
  name: 'cicd-service-${service.name}'
  params: {
		environment: environment
		projectName: projectName
		serviceName: service.name
		serviceType: service.type
		externalIngress: service.externalIngress
		containerAppEnvironmentId: containerAppEnvironment.id
		applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
		tag: tag
  }
}]

output servicePrincipalIds array = [for (svc, i) in services: service[i].outputs.managedIdentityPrincipalId]
