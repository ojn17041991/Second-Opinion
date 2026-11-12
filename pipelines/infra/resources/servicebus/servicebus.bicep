targetScope = 'resourceGroup'

@allowed(['dev', 'prod'])
@description('Environment name, used as the name suffix.')
param environment string

@allowed(['so'])
@description('Project name, shortened for resource naming.')
param projectName string

@description('Unique suffix for globally unique naming.')
param uniqueSuffix string

@description('Topic definitions with their subscriptions.')
var topics array = [
  {
    name: 'prompt'
    subscriptions: [
      'ai'
    ]
  }
]

@description('Flattened array of topic-subscription pairs for iteration.')
var subscriptions = flatten(map(range(0, length(topics)), i =>
  map(topics[i].subscriptions, s => {
    topicIndex: i
    topic: topics[i].name
    subscription: s
  })
))

resource sb 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: 'sb-${projectName}-${environment}-${uniqueSuffix}'
  location: resourceGroup().location
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

resource sbt 'Microsoft.ServiceBus/namespaces/topics@2024-01-01' = [for t in topics: {
  parent: sb
  name: 'sbt-${projectName}-${t.name}-${environment}'
}]

resource sbts 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2024-01-01' = [for s in subscriptions: {
  parent: sbt[s.topicIndex]
  name: 'sbts-${projectName}-${s.topic}-${s.subscription}-${environment}'
  properties: {
    maxDeliveryCount: 10
    deadLetteringOnMessageExpiration: true
    lockDuration: 'PT5M'
  }
}]

output serviceBusName string = sb.name
