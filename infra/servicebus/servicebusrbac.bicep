targetScope = 'resourceGroup'

param serviceBusName string
param adminAssignments array
param appAssignments array

resource sb 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: serviceBusName
}

resource adminRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for a in adminAssignments: {
    name: guid(sb.id, a.principalId, a.roleDefinitionId)
    scope: sb
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', a.roleDefinitionId)
      principalId: a.principalId
      principalType: 'User'
    }
  }
]

resource appRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for a in appAssignments: {
    name: guid(sb.id, a.principalId, a.roleDefinitionId)
    scope: sb
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', a.roleDefinitionId)
      principalId: a.principalId
      principalType: 'ServicePrincipal'
    }
  }
]