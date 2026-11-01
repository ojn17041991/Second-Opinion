using 'servicebus.bicep'
param environment = 'dev'

@description('Dev admin object id')
param adminPrincipalId string

@description('Dev app managed identity object id')
param appPrincipalId string

var servicebusDataSenderRoleId = '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'
var servicebusDataReceiverRoleId = '4f6d3b9b-027b-4fbc-9140-df7de3dbf8f2'

var adminAssignments = [
  {
    principalId: adminPrincipalId
    roleDefinitionId: servicebusDataSenderRoleId
  }
  {
    principalId: adminPrincipalId
    roleDefinitionId: servicebusDataReceiverRoleId
  }
]

var appAssignments = [
  {
    principalId: appPrincipalId
    roleDefinitionId: servicebusDataSenderRoleId
  }
]