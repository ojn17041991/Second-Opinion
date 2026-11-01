using 'orchestrator.bicep'
param environment = 'prod'
param projectName = 'so'
param adminPrincipalId = '065bac47-ba37-47c6-bfbe-8a0ff381389a'
param serviceBusAdminAssignments = [
  {
    principalId: adminPrincipalId
    roleDefinitionId: '4f6d3b9b-027b-4f4c-9142-0e5a2a2247e0'
  }
]
param serviceBusAppAssignments = [
  {
    roleDefinitionId: '69a216fc-b8fb-44d8-bc22-1f3c2cd27a39'
  }
]
