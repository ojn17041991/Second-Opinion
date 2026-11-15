targetScope = 'subscription'

import { getSharedName, getAppsName, getMonitorName } from '../../../helpers/naming.bicep'

@allowed(['dev', 'prod'])
@description('Environment name, used as the name suffix.')
param environment string

@allowed(['so'])
@description('Project name, shortened for resource naming.')
param projectName string

@description('Predefined resource group names.')
var resourceGroupNames array = [
  getSharedName(projectName, environment)
  getAppsName(projectName, environment)
  getMonitorName(projectName, environment)
]

resource resourceGroups 'Microsoft.Resources/resourceGroups@2024-03-01' = [for resourceGroupName in resourceGroupNames: {
  name: resourceGroupName
  location: deployment().location
}]
