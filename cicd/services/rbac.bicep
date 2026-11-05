targetScope = 'resourceGroup'

param serviceBusName string
param servicePrincipalIds array

var serviceBusDataSenderRoleId = '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'

resource sb 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: serviceBusName
}

resource serviceBusSenderAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for principalId in servicePrincipalIds: {
    name: guid(sb.id, principalId, serviceBusDataSenderRoleId)
    scope: sb
    properties: {
      roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', serviceBusDataSenderRoleId)
      principalId: principalId
      principalType: 'ServicePrincipal'
    }
  }
]
