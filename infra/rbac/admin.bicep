targetScope = 'resourceGroup'

@description('Name of the Key Vault for admin access.')
param keyVaultName string

@description('Name of the Service Bus namespace.')
param serviceBusName string

@description('Principal ID (user or service principal) for admin access.')
param adminPrincipalId string

@description('Array of role assignments for admin access to shared resources.')
param serviceBusAdminAssignments array

@description('Role definition ID for Key Vault Secrets Officer.')
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