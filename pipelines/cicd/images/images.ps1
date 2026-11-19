param(
	[string]$servicesFile = "pipelines/cicd/services.json",
	[string]$tag = 'latest'
)

# OJN: Replace the hard-coded registry with a shared naming or configuration mechanism later.
$registry = 'acrsodevpxnvm.azurecr.io'

$repoRoot = & git rev-parse --show-toplevel 2>$null
if (-not $repoRoot -or $LASTEXITCODE -ne 0) {
	Write-Error "Failed to find repository root using git. Ensure this script is run within a git repository."
	exit 1
}

Push-Location $repoRoot

Write-Host "Note: if you are not logged in with both 'az login' and 'az acr login', this script may fail." -ForegroundColor Yellow

$servicesFilePath = Join-Path -Path $repoRoot -ChildPath $servicesFile
if (-not (Test-Path $servicesFilePath)) {
	Write-Error "Services file not found at $servicesFilePath"
	Pop-Location
	exit 1
}

$services = (Get-Content $servicesFilePath -Raw | ConvertFrom-Json -ErrorAction Stop).services
$images = @()

foreach ($service in $services) {
	$serviceName = $service.name.ToLower()
	$image = "${registry}/${serviceName}:$tag"
	$serviceRoot = Join-Path -Path (Join-Path -Path $repoRoot -ChildPath "src") -ChildPath $service.name
	$dockerfileCandidates = @(
		(Join-Path -Path $serviceRoot -ChildPath "Api/Dockerfile"),
		(Join-Path -Path $serviceRoot -ChildPath "Worker/Dockerfile"),
		(Join-Path -Path $serviceRoot -ChildPath "Dockerfile")
	)
	$dockerfile = $dockerfileCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

	if (-not $dockerfile) {
		Write-Error "No Dockerfile found for $serviceName. Checked: $($dockerfileCandidates -join ', ')"
		Pop-Location
		exit 1
	}

	docker build -f $dockerfile -t $image .
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
