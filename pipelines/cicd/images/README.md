###### Login

`az login --usedevicecode`

`az acr login --name acrsodevpxnvm`

###### Build and push

`.\pipelines\cicd\images\images.ps1 -Registry acrsodevpxnvm.azurecr.io -Tag latest`
