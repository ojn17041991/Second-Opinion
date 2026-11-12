### Resource Groups

###### Build

`az bicep build --file pipelines/infra/orchestrator.bicep`

###### Preview

`az deployment sub what-if --location uksouth --template-file pipelines/infra/orchestrator.bicep --parameters pipelines/infra/dev.bicepparam`

###### Deploy

`az deployment sub create --location uksouth --template-file pipelines/infra/orchestrator.bicep --parameters pipelines/infra/dev.bicepparam`

### Key Vault

###### Build

`az bicep build --file pipelines/infra/orchestrator.bicep`

###### Preview

`az deployment group what-if --resource-group rg-so-shared-dev --template-file pipelines/infra/orchestrator.bicep --parameters adminPrincipalId=065bac47-ba37-47c6-bfbe-8a0ff381389a`

###### Deploy

`az deployment group create --resource-group rg-so-shared-dev --template-file pipelines/infra/orchestrator.bicep --parameters adminPrincipalId=065bac47-ba37-47c6-bfbe-8a0ff381389a`

### Service Bus

###### Build

`az bicep build --file pipelines/infra/orchestrator.bicep`

###### Preview

`az deployment group what-if --resource-group rg-so-shared-dev --template-file pipelines/infra/orchestrator.bicep --parameters pipelines/infra/servicebus/dev.bicepparam`

###### Deploy

`az deployment group create --resource-group rg-so-shared-dev --template-file pipelines/infra/orchestrator.bicep --parameters pipelines/infra/servicebus/dev.bicepparam`

### Apps

###### Build

`az bicep build --file pipelines/infra/orchestrator.bicep`

###### Preview

`az deployment sub what-if --location uksouth --template-file pipelines/infra/orchestrator.bicep --parameters pipelines/infra/dev.bicepparam`

###### Deploy

`az deployment sub create --location uksouth --template-file pipelines/infra/orchestrator.bicep --parameters pipelines/infra/dev.bicepparam`
