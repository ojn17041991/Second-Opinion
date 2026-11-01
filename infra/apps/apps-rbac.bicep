targetScope = 'resourceGroup'

param containerAppPrincipalId string
param containerRegistryName string

var acrPullRoleDefinitionId = '7f951dda-4ed3-4680-a7ca-6e2d8995e53d'

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
}

resource caAcrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, containerAppPrincipalId, 'acrpull')
  scope: acr
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleDefinitionId)
    principalId: containerAppPrincipalId
    principalType: 'ServicePrincipal'
  }
}