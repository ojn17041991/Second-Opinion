### Resource Groups

###### Build

`az bicep build --file resourcegroups.bicep`

###### Preview

`az deployment sub what-if --location uksouth --template-file resourcegroups.bicep --parameters resourcegroups/dev.bicepparam`

###### Deploy

`az deployment sub create --location uksouth --template-file resourcegroups.bicep --parameters resourcegroups/dev.bicepparam`

### Key Vault

###### Build

`az bicep build --file resourcegroups.bicep`

###### Preview

`az deployment group what-if --resource-group rg-so-shared-dev --template-file keyvault.bicep --parameters adminPrincipalId=065bac47-ba37-47c6-bfbe-8a0ff381389a`

###### Deploy

`az deployment group create --resource-group rg-so-shared-dev --template-file keyvault.bicep --parameters adminPrincipalId=065bac47-ba37-47c6-bfbe-8a0ff381389a`

### Service Bus

###### Build

`az bicep build --file servicebus.bicep`

###### Preview

`az deployment group what-if --resource-group rg-so-shared-dev --template-file servicebus.bicep --parameters servicebus/dev.bicepparam`

###### Deploy

`az deployment group create --resource-group rg-so-shared-dev --template-file servicebus.bicep --parameters servicebus/dev.bicepparam`

### Apps

###### Build

`az bicep build --file apps/apps-orchestrator.bicep`

###### Preview

`az deployment sub what-if --location uksouth --template-file apps/apps-orchestrator.bicep --parameters apps/dev.bicepparam`

###### Deploy

`az deployment sub create --location uksouth --template-file apps/apps-orchestrator.bicep --parameters apps/dev.bicepparam`
