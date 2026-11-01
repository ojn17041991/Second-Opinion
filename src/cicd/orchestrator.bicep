targetScope = 'resourceGroup'

param environment string
param projectName string
param containerAppEnvironmentId string
param containerRegistryName string
param workerNames array
param workerImages array

module worker 'workers/worker.bicep' = [for (workerName, i) in workerNames: {
  name: 'worker-${workerName}'
  params: {
	environment: environment
	workerName: workerName
	containerAppEnvironmentId: containerAppEnvironmentId
	containerRegistryName: containerRegistryName
	containerImage: i < length(workerImages) ? workerImages[i] : null
  }
}]

output workerPrincipalIds array = [for i in range(0, length(workerNames)): worker[i].outputs.managedIdentityPrincipalId]
output workerContainerAppNames array = [for i in range(0, length(workerNames)): worker[i].outputs.containerAppName]
