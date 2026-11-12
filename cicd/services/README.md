###### Build

`az bicep build --file services/orchestrator.bicep`

###### Preview

`az deployment group what-if --resource-group rg-so-apps-dev --template-file services/orchestrator.bicep --parameters environment=dev projectName=so containerAppEnvironmentName=cae-so-dev containerRegistryName=acrsodevpxnvm serviceBusName=sb-so-dev-pxnvmzgmbcxqc logAnalyticsWorkspaceName=law-so-dev monitorResourceGroupName=rg-so-monitor-dev tag=latest`

###### Deploy

`az deployment group create --resource-group rg-so-apps-dev --template-file services/orchestrator.bicep --parameters environment=dev projectName=so containerAppEnvironmentName=cae-so-dev containerRegistryName=acrsodevpxnvm serviceBusName=sb-so-dev-pxnvmzgmbcxqc logAnalyticsWorkspaceName=law-so-dev monitorResourceGroupName=rg-so-monitor-dev tag=latest`
