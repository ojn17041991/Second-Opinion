targetScope = 'resourceGroup'

param environment string

var resourceGroupSplits array = split(resourceGroup().name, '-')
var projectName string = resourceGroupSplits[1]
var retentionInDays int = 30

resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: 'law-${projectName}-${environment}'
  location: resourceGroup().location
  properties: {
	sku: {
	  name: 'PerGB2018'
	}
	retentionInDays: retentionInDays
	publicNetworkAccessForIngestion: 'Enabled'
	publicNetworkAccessForQuery: 'Enabled'
  }
}

output logAnalyticsWorkspaceName string = law.name
output logAnalyticsWorkspaceId string = law.id
