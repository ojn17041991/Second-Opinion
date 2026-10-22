$serviceBusName = "sb-so-dev-hbtscz5tk7adi"
$serviceBusId = azid $serviceBusName
$serviceBusPrincipal = "sp-$serviceBusName"
$role = "Azure Service Bus Data Receiver"
$vault = "kv-so-dev-hbtscz5tk7adi"

$appId = az ad app create --display-name $serviceBusPrincipal --query appId -o tsv
$spId = az ad sp create --id $appId --query id -o tsv
$secret = az ad app credential reset --id $appId --display-name dev --query password -o tsv
az keyvault secret set --vault-name $vault --name "AppRegistrations--$serviceBusPrincipal" --value $secret --output none
az role assignment create --assignee-object-id $spId --assignee-principal-type ServicePrincipal --role $role --scope $serviceBusId --output none --only-show-errors

if ($LASTEXITCODE -eq 0) {
    Write-Host "Created $serviceBusPrincipal and stored its secret in $vault." -ForegroundColor Green
} else {
    Write-Host "Role assignment failed. Check the errors above." -ForegroundColor Red
}