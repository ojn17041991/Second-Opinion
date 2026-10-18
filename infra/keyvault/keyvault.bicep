targetScope = 'resourceGroup'

@description('Object ID of the user or group allowed to manage secrets.')
param adminPrincipalId string

var secretsOfficerRoleId = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
var resourceGroupSplits = split(resourcegroup().name, '-')
var environment = resourceGroupSplits[3]
var projectName = resourceGroupSplits[1]

resource vault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv-${projectName}-${environment}'
  location: resourcegroup().location
  properties: {
    sku: { family: 'A', name: 'standard' }
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
}

resource adminRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(vault.id, adminPrincipalId, secretsOfficerRoleId)
  scope: vault
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', secretsOfficerRoleId)
    principalId: adminPrincipalId
    principalType: 'User'
  }
}