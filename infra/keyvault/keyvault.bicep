targetScope = 'resourceGroup'

@description('Object ID of the user or group allowed to manage secrets.')
param adminPrincipalId string

var uniqueSuffix string = uniqueString(resourceGroup().id)
var secretsOfficerRoleId = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
var resourceGroupSplits = split(resourceGroup().name, '-')
var environment = resourceGroupSplits[3]
var projectName = resourceGroupSplits[1]

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'kv-${projectName}-${environment}-${uniqueSuffix}'
  location: resourceGroup().location
  properties: {
    sku: { family: 'A', name: 'standard' }
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
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

output keyVaultName string = kv.name