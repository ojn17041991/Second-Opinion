targetScope = 'resourceGroup'

param environment string
param workerName string
param containerAppEnvironmentId string
param containerRegistryName string
param containerImage string?

var resourceGroupSplits array = split(resourceGroup().name, '-')
var projectName string = resourceGroupSplits[1]
var containerRegistryLoginServer string = '${containerRegistryName}.azurecr.io'

resource mi 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: 'mi-${projectName}-${workerName}-${environment}'
  location: resourceGroup().location
}

resource ca 'Microsoft.App/containerApps@2024-03-01' = {
  name: 'ca-${projectName}-${workerName}-${environment}'
  location: resourceGroup().location
  identity: {
	type: 'UserAssigned'
	userAssignedIdentities: {
	  '${mi.id}': {}
	}
  }
  properties: {
	managedEnvironmentId: containerAppEnvironmentId
	configuration: {
	  ingress: {
		external: false
		targetPort: 8080
	  }
	  registries: [
		{
		  server: containerRegistryLoginServer
		  identity: mi.id
		}
	  ]
	}
	template: {
	  containers: containerImage != null ? [
		{
		  image: containerImage
		  name: '${projectName}-${workerName}-container'
		  resources: {
			cpu: '0.25'
			memory: '0.5Gi'
		  }
		}
	  ] : []
	  scale: {
		minReplicas: 0
		maxReplicas: 2
	  }
	}
  }
}

output containerAppName string = ca.name
output containerAppPrincipalId string = mi.properties.principalId
output managedIdentityId string = mi.id
output managedIdentityPrincipalId string = mi.properties.principalId
