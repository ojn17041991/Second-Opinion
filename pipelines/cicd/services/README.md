###### Build

`az bicep build --file pipelines/cicd/services/orchestrator.bicep`

###### Preview

`az deployment group what-if --resource-group rg-so-apps-dev --template-file pipelines/cicd/services/orchestrator.bicep --parameters environment=dev projectName=so tag=latest`

###### Deploy

`az deployment group create --resource-group rg-so-apps-dev --template-file pipelines/cicd/services/orchestrator.bicep --parameters environment=dev projectName=so tag=latest`
