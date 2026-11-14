###### Build

`az bicep build --file pipelines/cicd/services/orchestrator.bicep`

###### Preview

`az deployment group what-if --resource-group rg-so-apps-dev --template-file pipelines/cicd/services/orchestrator.bicep --parameters environment=dev projectName=so containerAppEnvironmentName=cae-so-dev containerRegistryName=acrsodevpxnvm serviceBusName=sb-so-dev-pxnvmzgmbcxqc sharedResourceGroupName=rg-so-shared-dev monitorResourceGroupName=rg-so-monitor-dev applicationInsightsName=ai-so-dev tag=latest`

###### Deploy

`az deployment group create --resource-group rg-so-apps-dev --template-file pipelines/cicd/services/orchestrator.bicep --parameters environment=dev projectName=so containerAppEnvironmentName=cae-so-dev containerRegistryName=acrsodevpxnvm serviceBusName=sb-so-dev-pxnvmzgmbcxqc sharedResourceGroupName=rg-so-shared-dev monitorResourceGroupName=rg-so-monitor-dev applicationInsightsName=ai-so-dev tag=latest`
