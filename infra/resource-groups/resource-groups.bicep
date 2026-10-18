targetScope = 'subscription'

@description('Environment name, used as the name suffix.')
param environment string

param location string

param purposes array = [
  'shared'
  'apps'
  'monitor'
]

resource groups 'Microsoft.Resources/resourceGroups@2024-03-01' = [for purpose in purposes: {
  name: 'rg-so-${purpose}-${environment}'
  location: location
}]