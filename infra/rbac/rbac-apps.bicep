targetScope = 'resourceGroup'

param containerRegistryName string
param workerPrincipalIds array

var acrPullRoleDefinitionId = '7f951dda-4ed3-4680-a7ca-6e2d8995e53d'

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: containerRegistryName
}

resource workerAcrPullRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for principalId in workerPrincipalIds: {
	  name: guid(acr.id, principalId, acrPullRoleDefinitionId)
	  scope: acr
	  properties: {
	    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', acrPullRoleDefinitionId)
	    principalId: principalId
	    principalType: 'ServicePrincipal'
	  }
  }
]