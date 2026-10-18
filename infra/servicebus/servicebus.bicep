targetScope = 'resourceGroup'

var resourceGroupSplits = split(resourcegroup().name, '-')
var environment = resourceGroupSplits[3]
var projectName = resourceGroupSplits[1]

resource sb 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: 'sb-${projectName}-${environment}'
  location: resourcegroup().location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    minimumTlsVersion: '1.2'
    disableLocalAuth: true
    publicNetworkAccess: 'Enabled'
  }
}

resource sbt 'Microsoft.ServiceBus/namespaces/topics@2024-01-01' = {
  parent: sb
  name: 'sbt-${projectName}-${environment}'
}

output serviceBusName string = sb.name
output serviceBusTopicName string = sbt.name