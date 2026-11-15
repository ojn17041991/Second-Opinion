targetScope = 'resourceGroup'

import { getKeyVaultName } from '../../../helpers/naming.bicep'

@allowed(['dev', 'prod'])
@description('Environment name, used as the name suffix.')
param environment string

@allowed(['so'])
@description('Project name, shortened for resource naming.')
param projectName string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: getKeyVaultName(subscription().id, projectName, environment)
  location: resourceGroup().location
  properties: {
    sku: { family: 'A', name: 'standard' }
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
  }
}
