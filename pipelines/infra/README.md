### Infrastructure

###### Build

`az bicep build --file pipelines/infra/orchestrator.bicep`

###### Preview

`az deployment sub what-if --location uksouth --template-file pipelines/infra/orchestrator.bicep --parameters pipelines/infra/dev.bicepparam`

###### Deploy

`az deployment sub create --location uksouth --template-file pipelines/infra/orchestrator.bicep --parameters pipelines/infra/dev.bicepparam`
