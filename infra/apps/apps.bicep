targetScope = 'resourceGroup'

param environment string
param logAnalyticsWorkspaceId string

var uniqueSuffix string = uniqueString(resourceGroup().id)
var resourceGroupSplits array = split(resourceGroup().name, '-')
var projectName string = resourceGroupSplits[1]

resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: 'acr${projectName}${environment}${uniqueSuffix}'
  location: resourceGroup().location
  sku: {
	name: 'Basic'
  }
  properties: {
	adminUserEnabled: false
	publicNetworkAccess: 'Enabled'
	networkRuleBypassOptions: 'AzureServices'
  }
}

resource cae 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: 'cae-${projectName}-${environment}'
  location: resourceGroup().location
  properties: {
	appLogsConfiguration: {
	  destination: 'log-analytics'
	  logAnalyticsConfiguration: {
		customerId: reference(logAnalyticsWorkspaceId, '2023-09-01').customerId
		sharedKey: listKeys(logAnalyticsWorkspaceId, '2023-09-01').primarySharedKey
	  }
	}
  }
}

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-${projectName}-${environment}'
  location: resourceGroup().location
}

resource ca 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'ca-${projectName}-${environment}'
  location: resourceGroup().location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${mi.id}': {}
    }
  }
  properties: {
	managedEnvironmentId: cae.id
	configuration: {
	  ingress: {
		external: false
		targetPort: 8080
	  }
	  registries: [
		{
		  server: acr.properties.loginServer
		  identity: mi.id
		}
	  ]
	}
	template: {
	  containers: [
		{
		  image: '${acr.properties.loginServer}/placeholder:latest'
		  name: '${projectName}-container'
		  resources: {
			cpu: '0.25'
			memory: '0.5Gi'
		  }
		}
	  ]
	  scale: {
		minReplicas: 0
		maxReplicas: 2
	  }
	}
  }
}

output containerRegistryName string = acr.name
output containerAppEnvironmentName string = cae.name
output containerAppName string = ca.name
output containerAppPrincipalId string = mi.properties.principalId
