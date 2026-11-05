### Images

###### Login

`az login`

`az acr login --name acrsodevpxnvm`

###### Build and push

`.\cicd\images\images.ps1 -Registry acrsodevpxnvm.azurecr.io -Tag latest`

### Services

###### Build

`az bicep build --file services/orchestrator.bicep`

###### Preview

`az deployment group what-if --resource-group rg-so-apps-dev --template-file services/orchestrator.bicep --parameters environment=dev projectName=so containerAppEnvironmentName=cae-so-dev containerRegistryName=acrsodevpxnvm serviceBusName=sb-so-dev-pxnvmzgmbcxqc sharedResourceGroupName=rg-so-shared-dev tag=latest`

###### Deploy

`az deployment group create --resource-group rg-so-apps-dev --template-file services/orchestrator.bicep --parameters environment=dev projectName=so containerAppEnvironmentName=cae-so-dev containerRegistryName=acrsodevpxnvm serviceBusName=sb-so-dev-pxnvmzgmbcxqc sharedResourceGroupName=rg-so-shared-dev tag=latest`
