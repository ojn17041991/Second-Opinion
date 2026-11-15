targetScope = 'resourceGroup'

import { getKeyVaultName, getServiceBusName } from '../../helpers/naming.bicep'

@allowed(['dev', 'prod'])
@description('Environment name, used as the name suffix.')
param environment string

@allowed(['so'])
@description('Project name, shortened for resource naming.')
param projectName string

@description('Principal ID (user or service principal) for admin access.')
param adminPrincipalId string

@description('Array of role assignments for admin access to shared resources.')
param serviceBusAdminAssignments array

@description('Role definition ID for Key Vault Secrets Officer.')
var secretsOfficerRoleId = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: getKeyVaultName(subscription().id, projectName, environment)
}

resource keyVaultSecretsOfficerRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, adminPrincipalId, secretsOfficerRoleId)
  scope: keyVault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', secretsOfficerRoleId)
    principalId: adminPrincipalId
    principalType: 'User'
  }
}

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2024-01-01' existing = {
  name: getServiceBusName(subscription().id, projectName, environment)
}

resource serviceBusAdminRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [
  for a in serviceBusAdminAssignments: {
	  name: guid(serviceBusNamespace.id, a.principalId, a.roleDefinitionId)
	  scope: serviceBusNamespace
	  properties: {
	    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', a.roleDefinitionId)
	    principalId: a.principalId
	    principalType: 'User'
	  }
  }
]