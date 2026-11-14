###### Login

`az login --use-device-code`

`az acr login --name acrsodevpxnvm`

###### Build and push

`.\pipelines\cicd\images\images.ps1 -Tag latest`
