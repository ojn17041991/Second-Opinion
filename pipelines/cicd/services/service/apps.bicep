targetScope = 'resourceGroup'

@allowed(['dev', 'prod'])
@description('Environment name, used as the name suffix.')
param environment string

@allowed(['so'])
@description('Project name, shortened for resource naming.')
param projectName string

@description('Name of the service to deploy.')
param serviceName string

@description('Whether the container app should have external ingress.')
param externalIngress bool = false

@description('Resource ID of the Container App Environment.')
param containerAppEnvironmentId string

@description('Name of the Container Registry (without .azurecr.io suffix).')
param containerRegistryName string

@description('Connection string of the shared Application Insights component.')
param applicationInsightsConnectionString string

@description('Name of the Service Bus namespace.')
param serviceBusName string

@description('Name of the resource group containing the Service Bus namespace.')
param sharedResourceGroupName string

@description('Container image tag to deploy.')
param tag string = 'latest'

@description('Container registry server FQDN.')
var containerRegistryServer string = '${containerRegistryName}.azurecr.io'

@description('Service name normalized to lowercase.')
var serviceNameNormalized = toLower(serviceName)

@description('Full container image reference with tag.')
var containerImage string = '${containerRegistryServer}/${serviceNameNormalized}:${tag}'

@description('Role definition ID for ACR Pull.')
var acrPullRoleDefinitionId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
}

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-${projectName}-${serviceNameNormalized}-${environment}'
  location: resourceGroup().location
}

resource acrRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, mi.id, acrPullRoleDefinitionId)
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleDefinitionId)
    principalId: mi.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

module sbRole './shared.bicep' = {
  name: 'servicebus-role-${serviceNameNormalized}'
  scope: resourceGroup(sharedResourceGroupName)
  params: {
    serviceBusName: serviceBusName
    principalId: mi.properties.principalId
  }
}

resource ca 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'ca-${projectName}-${serviceNameNormalized}-${environment}'
  location: resourceGroup().location
  dependsOn: [
    acrRole
    sbRole
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${mi.id}': {}
    }
  }
  properties: {
    managedEnvironmentId: containerAppEnvironmentId
    configuration: {
      ingress: {
        external: externalIngress
        targetPort: 8080
      }
      registries: [
        {
          server: containerRegistryServer
          identity: mi.id
        }
      ]
      secrets: [
        {
          name: 'appinsights-connection-string'
          value: applicationInsightsConnectionString
        }
      ]
    }
    template: {
      containers: [
        {
          image: containerImage
          name: '${projectName}-${serviceNameNormalized}-container'
          env: [
            {
              name: 'AZURE_CLIENT_ID'
              value: mi.properties.clientId
            }
            {
              name: 'ApplicationInsights__ConnectionString'
              secretRef: 'appinsights-connection-string'
            }
          ]
          resources: {
            cpu: 1
            memory: '2Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
      }
    }
  }
}

output containerAppName string = ca.name
output managedIdentityId string = mi.id
output managedIdentityPrincipalId string = mi.properties.principalId
