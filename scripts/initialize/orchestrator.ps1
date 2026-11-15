Push-Location $PSScriptRoot

& (Join-Path $PSScriptRoot "libs.ps1")
& (Join-Path $PSScriptRoot "services.ps1")

Pop-Location