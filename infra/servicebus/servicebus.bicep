targetScope = 'resourceGroup'

var uniqueSuffix string = uniqueString(resourceGroup().id)
var resourceGroupSplits array = split(resourceGroup().name, '-')
var environment string = resourceGroupSplits[3]
var projectName string = resourceGroupSplits[1]
var topics array = [
  {
    name: 'prompt'
    subscriptions: [
      'ai'
    ]
  }
]
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
output serviceBusTopicNames array = [for i in range(0, length(topics)): sbt[i].name]
output serviceBusSubscriptionNames array = [for i in range(0, length(subscriptions)): sbts[i].name]