targetScope = 'resourceGroup'

import { getServiceBusName, getServiceBusTopicName, getServiceBusSubscriptionName } from '../../../helpers/naming.bicep'

@allowed(['dev', 'prod'])
@description('Environment name, used as the name suffix.')
param environment string

@allowed(['so'])
@description('Project name, shortened for resource naming.')
param projectName string

@description('Topic definitions with their subscriptions.')
var topics array = [
  {
    name: 'prompt'
    subscriptions: [
      'ai'
    ]
  }
]

@description('Generated topic names, in the same order as the topic definitions.')
var topicNames = map(topics, topic => getServiceBusTopicName(projectName, topic.name, environment))

@description('Flattened array of topic-subscription pairs for iteration.')
var subscriptions = flatten(map(range(0, length(topics)), i =>
  map(topics[i].subscriptions, s => {
    topicIndex: i
    topic: topics[i].name
    subscription: s
  })
))

resource serviceBusNamespace 'Microsoft.ServiceBus/namespaces@2024-01-01' = {
  name: getServiceBusName(subscription().id, projectName, environment)
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

resource serviceBusTopics 'Microsoft.ServiceBus/namespaces/topics@2024-01-01' = [for (t, i) in topics: {
  parent: serviceBusNamespace
  name: topicNames[i]
}]

resource serviceBusSubscriptions 'Microsoft.ServiceBus/namespaces/topics/subscriptions@2024-01-01' = [for s in subscriptions: {
  parent: serviceBusTopics[s.topicIndex]
  name: getServiceBusSubscriptionName(projectName, s.topic, s.subscription, environment)
  properties: {
    maxDeliveryCount: 10
    deadLetteringOnMessageExpiration: true
    lockDuration: 'PT5M'
  }
}]
