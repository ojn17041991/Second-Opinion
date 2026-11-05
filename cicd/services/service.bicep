targetScope = 'resourceGroup'

param environment string
param projectName string
param serviceName string
param externalIngress bool = false
param containerAppEnvironmentId string
param containerRegistryName string
param tag string = 'latest'

var containerRegistryServer string = '${containerRegistryName}.azurecr.io'
var serviceNameNormalized = toLower(serviceName)
var containerImage string = '${containerRegistryServer}/${serviceNameNormalized}:${tag}'
var acrPullRoleDefinitionId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
}

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-${projectName}-${serviceNameNormalized}-${environment}'
  location: resourceGroup().location
}

resource role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, mi.id, acrPullRoleDefinitionId)
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleDefinitionId)
    principalId: mi.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

resource ca 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'ca-${projectName}-${serviceNameNormalized}-${environment}'
  location: resourceGroup().location
  dependsOn: [
    role
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
    }
    template: {
      containers: [
        {
          image: containerImage
          name: '${projectName}-${serviceNameNormalized}-container'
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
output containerAppPrincipalId string = mi.properties.principalId
output managedIdentityId string = mi.id
output managedIdentityPrincipalId string = mi.properties.principalId
