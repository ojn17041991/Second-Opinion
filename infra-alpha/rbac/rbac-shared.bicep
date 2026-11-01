targetScope = 'resourceGroup'

param keyVaultName string
param serviceBusName string
param adminPrincipalId string
param workerPrincipalIds array
param serviceBusAdminAssignments array
param serviceBusAppAssignments array

var secretsOfficerRoleId = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource role 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(kv.id, adminPrincipalId, secretsOfficerRoleId)
  scope: kv
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', secretsOfficerRoleId)
    principalId: adminPrincipalId
    principalType: 'User'
  }
}

resource sb 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: serviceBusName
}

resource adminServiceBusRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for a in serviceBusAdminAssignments: {
	  name: guid(sb.id, a.principalId, a.roleDefinitionId)
	  scope: sb
	  properties: {
	    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', a.roleDefinitionId)
	    principalId: a.principalId
	    principalType: 'User'
	  }
  }
]

var appServiceBusRoleAssignmentsFlattened = flatten(
  map(serviceBusAppAssignments, a => 
    map(workerPrincipalIds, principalId => {
      roleDefinitionId: a.roleDefinitionId
      principalId: principalId
    })
  )
)

resource appServiceBusRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for item in appServiceBusRoleAssignmentsFlattened: {
  name: guid(sb.id, item.principalId, item.roleDefinitionId)
  scope: sb
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', item.roleDefinitionId)
    principalId: item.principalId
    principalType: 'ServicePrincipal'
  }
}]