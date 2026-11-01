param(
	[string]$servicesFile = "cicd/images/services.json",
	[string]$registry,
	[string]$tag = 'latest'
)

# Navigate to repo root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent (Split-Path -Parent $scriptDir)
Push-Location $repoRoot

if (-not $registry) {
	Write-Error "Container registry is required."
	Pop-Location
	exit 1
}

if (-not (Test-Path $servicesFile)) {
	Write-Error "Services file not found at $servicesFile"
	Pop-Location
	exit 1
}

$services = Get-Content $servicesFile | ConvertFrom-Json
$apis = $services.apis
$workers = $services.workers

$services = @() + $apis + $workers
$images = @()

foreach ($service in $services) {
	$imageName = $service.ToLower()
	$image = "$registry/$imageName`:$tag"
	$dockerfilePath = "src/$service"

	if (-not (Test-Path "$dockerfilePath/Dockerfile")) {
		Write-Error "Dockerfile not found at $dockerfilePath/Dockerfile."
		exit 1
	}

	docker build -f "$dockerfilePath/Dockerfile" -t $image .
	if ($LASTEXITCODE -ne 0) {
		Write-Error "Docker build failed for $imageName."
		Pop-Location
		exit 1
	}

	docker push $image
	if ($LASTEXITCODE -ne 0) {
		Write-Error "Docker push failed for $imageName."
		Pop-Location
		exit 1
	}

	$images += $image
}

Write-Host "`nAll images pushed successfully:" -ForegroundColor Green
$images | ForEach-Object { Write-Host "  $_" }

Pop-Location

$images | ConvertTo-Json -Compress
