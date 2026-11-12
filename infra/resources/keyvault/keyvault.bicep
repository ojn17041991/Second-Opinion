targetScope = 'resourceGroup'

@allowed(['dev', 'prod'])
@description('Environment name, used as the name suffix.')
param environment string

@allowed(['so'])
@description('Project name, shortened for resource naming.')
param projectName string

@description('Unique suffix for globally unique naming.')
param uniqueSuffix string

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

output keyVaultName string = kv.name
