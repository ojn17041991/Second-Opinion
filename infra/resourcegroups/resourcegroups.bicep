targetScope = 'subscription'

@allowed(['dev', 'prod'])
@description('Environment name, used as the name suffix.')
param environment string

@allowed(['so'])
@description('Project name, shortened for resource naming.')
param projectName string

var purposes array = [
  'shared'
  'apps'
  'monitor'
]

resource rgs 'Microsoft.Resources/resourceGroups@2024-03-01' = [for purpose in purposes: {
  name: 'rg-${projectName}-${purpose}-${environment}'
  location: deployment().location
}]

output rgNames array = [for i in range(0, length(purposes)): rgs[i].name]