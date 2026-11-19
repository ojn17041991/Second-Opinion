param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z][A-Za-z0-9]*$')]
    [string]$Name
)

$TemplateName = 'WorkerTemplate'
$RepoRootLocation = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$WorkerTemplateLocation = Join-Path $RepoRootLocation "src/$TemplateName"
$NewWorkerLocation = Join-Path $RepoRootLocation "src/$Name"

# Ensure the template exists before proceeding.
if (-not (Test-Path $WorkerTemplateLocation)) {
    Write-Host "$TemplateName is missing." -ForegroundColor Red
    return
}

# Stop before doing anything if the service already exists.
if (Test-Path $NewWorkerLocation) {
    Write-Host "$Name worker already exists." -ForegroundColor Red
    return
}

# Copy the template, skipping build output.
Get-ChildItem $WorkerTemplateLocation -Recurse -File -Force |
Where-Object { $_.FullName.Substring($WorkerTemplateLocation.Length) -notmatch '[\\/](bin|obj|\.vs)([\\/]|$)' } |
ForEach-Object {
    $relative = $_.FullName.Substring($WorkerTemplateLocation.Length).TrimStart('\', '/')
    $destination = Join-Path $NewWorkerLocation $relative
    New-Item -ItemType Directory -Path (Split-Path $destination) -Force | Out-Null
    Copy-Item $_.FullName $destination
}

# Replace the template name inside text files.
$Encoding = New-Object System.Text.UTF8Encoding($false)
Get-ChildItem $NewWorkerLocation -Recurse -File -Force |
    Where-Object { $_.Extension -in '.cs', '.csproj', '.slnx', '.sln', '.json', '.md', '.props', '.targets', '.config' } |
    ForEach-Object {
        $content = [System.IO.File]::ReadAllText($_.FullName)
        $updated = $content.Replace($TemplateName, $Name)
        if ($updated -cne $content) {
            [System.IO.File]::WriteAllText($_.FullName, $updated, $Encoding)
        }
    }

# Rename files and folders containing the template name, deepest first.
Get-ChildItem $NewWorkerLocation -Recurse -Force |
    Where-Object { $_.Name.Contains($TemplateName) } |
    Sort-Object { $_.FullName.Length } -Descending |
    ForEach-Object { Rename-Item $_.FullName $_.Name.Replace($TemplateName, $Name) }

# Inform the user that the worker has been created successfully.
Write-Host "Created $Name worker." -ForegroundColor Green