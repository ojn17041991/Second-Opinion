targetScope = 'resourceGroup'

import { getContainerRegistryName, getManagedIdentityName, getContainerAppName, getContainerName, getSharedName } from '../../../helpers/naming.bicep'

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

@secure()
@description('Connection string of the shared Application Insights component.')
param applicationInsightsConnectionString string

@description('Container image tag to deploy.')
param tag string = 'latest'

@description('Container registry server FQDN.')
var containerRegistryServer string = '${getContainerRegistryName(subscription().id, projectName, environment)}.azurecr.io'

@description('Service name normalized to lowercase.')
var serviceNameNormalized = toLower(serviceName)

@description('Full container image reference with tag.')
var containerImage string = '${containerRegistryServer}/${serviceNameNormalized}:${tag}'

@description('Role definition ID for ACR Pull.')
var acrPullRoleDefinitionId = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: getContainerRegistryName(subscription().id, projectName, environment)
}

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: getManagedIdentityName(projectName, serviceName, environment)
  location: resourceGroup().location
}

resource containerRegistryAcrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerRegistry.id, managedIdentity.id, acrPullRoleDefinitionId)
  scope: containerRegistry
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleDefinitionId)
    principalId: managedIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

module sharedRoles './shared.bicep' = {
  name: 'cicd-shared-${serviceName}'
  scope: resourceGroup(getSharedName(projectName, environment))
  params: {
    environment: environment
    projectName: projectName
    principalId: managedIdentity.properties.principalId
  }
}

resource ca 'Microsoft.App/containerApps@2024-03-01' = {
  name: getContainerAppName(projectName, serviceName, environment)
  location: resourceGroup().location
  dependsOn: [
    containerRegistryAcrPullRoleAssignment
    sharedRoles
  ]
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
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
          identity: managedIdentity.id
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
          name: getContainerName(projectName, serviceName)
          env: [
            {
              name: 'AZURE_CLIENT_ID'
              value: managedIdentity.properties.clientId
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

output managedIdentityId string = managedIdentity.id
output managedIdentityPrincipalId string = managedIdentity.properties.principalId
