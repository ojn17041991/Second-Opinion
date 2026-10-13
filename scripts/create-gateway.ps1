# Always run from the repo root (the parent of the scripts folder).
Set-Location (Join-Path $PSScriptRoot "..")

# Fail if the Gateway already exists.
if (Test-Path "src/Gateway") {
    Write-Error "src/Gateway already exists."
    exit 1
}

# Create the solution.
dotnet new sln -n SecondOpinion

# Create the Gateway Web API.
mkdir src
dotnet new webapi -n Gateway -o src/Gateway -f net10.0

# Add the Web API to the solution.
dotnet sln add src/Gateway