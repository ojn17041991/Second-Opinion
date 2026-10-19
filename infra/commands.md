### Resource Groups

###### Build

`az bicep build --file resourcegroups.bicep`

###### Preview

`az deployment sub what-if --location uksouth --template-file resourcegroups.bicep --parameters environment=dev projectName=so`

###### Deploy

`az deployment sub create --location uksouth --template-file resourcegroups.bicep --parameters environment=dev projectName=so`

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

`az deployment group what-if --resource-group rg-so-shared-dev --template-file servicebus.bicep`

###### Deploy

`az deployment group create --resource-group rg-so-shared-dev --template-file servicebus.bicep`
