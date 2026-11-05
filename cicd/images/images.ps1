param(
	[string]$servicesFile = "cicd/services.json",
	[string]$registry,
	[string]$tag = 'latest'
)

$repoRoot = & git rev-parse --show-toplevel 2>$null
if (-not $repoRoot -or $LASTEXITCODE -ne 0) {
	Write-Error "Failed to find repository root using git. Ensure this script is run within a git repository."
	exit 1
}

Push-Location $repoRoot

if (-not $registry) {
	Write-Error "Container registry is required."
	Pop-Location
	exit 1
}

Write-Host "Note: if you are not logged in with both 'az login' and 'az acr login', this script may fail." -ForegroundColor Yellow

$servicesFilePath = Join-Path -Path $repoRoot -ChildPath $servicesFile
if (-not (Test-Path $servicesFilePath)) {
	Write-Error "Services file not found at $servicesFilePath"
	Pop-Location
	exit 1
}

$services = Get-Content $servicesFilePath | ConvertFrom-Json
$apis = $services.apis
$workers = $services.workers

$services = @() + $apis + $workers
$images = @()

foreach ($service in $services) {
	$serviceName = $service.ToLower()
	$image = "${registry}/${serviceName}:$tag"
	$dockerfilePath = Join-Path -Path (Join-Path -Path $repoRoot -ChildPath "src") -ChildPath $service

	if (-not (Test-Path "$dockerfilePath/Dockerfile")) {
		Write-Error "Dockerfile not found at $dockerfilePath/Dockerfile."
		Pop-Location
		exit 1
	}

	docker build -f "$dockerfilePath/Dockerfile" -t $image .
	if ($LASTEXITCODE -ne 0) {
		Write-Error "Docker build failed for $serviceName."
		Pop-Location
		exit 1
	}

	docker push $image
	if ($LASTEXITCODE -ne 0) {
		Write-Error "Docker push failed for $serviceName."
		Pop-Location
		exit 1
	}

	$images += $image
}

Write-Host "`nAll images pushed successfully:" -ForegroundColor Green
$images | ForEach-Object { Write-Host "  $_" }

Pop-Location

$images | ConvertTo-Json -Compress
