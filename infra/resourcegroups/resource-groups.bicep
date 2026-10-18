targetScope = 'subscription'

@description('Environment name, used as the name suffix.')
param environment string

@description('Project name, shortened for resource naming.')
param projectName string

@description('Location in which the resource should be created.')
param location string

param purposes array = [
  'shared'
  'apps'
  'monitor'
]

resource groups 'Microsoft.Resources/resourceGroups@2024-03-01' = [for purpose in purposes: {
  name: 'rg-${projectName}-${purpose}-${environment}'
  location: location
}]