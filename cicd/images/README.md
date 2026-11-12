###### Login

`az login`

`az acr login --name acrsodevpxnvm`

###### Build and push

`.\cicd\images\images.ps1 -Registry acrsodevpxnvm.azurecr.io -Tag latest`
