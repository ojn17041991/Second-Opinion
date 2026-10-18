# Always run from the repo root (the parent of the scripts folder).
Set-Location (Join-Path $PSScriptRoot "..")

# Create Contracts if it doesn't already exist.
if (-not (Test-Path "src/Contracts")) {
    dotnet new sln -n Contracts -o src/Contracts
    dotnet new classlib -n Contracts -o src/Contracts -f net10.0
    dotnet sln src/Contracts/Contracts.slnx add src/Contracts/Contracts.csproj

    # Remove the default Class1.cs file created by the class library template.
    Remove-Item "src/Contracts/Class1.cs"
}

# Create Gateway if it doesn't already exist.
if (-not (Test-Path "src/Gateway")) {
    dotnet new sln -n Gateway -o src/Gateway
    dotnet new web -n Gateway -o src/Gateway -f net10.0 --no-restore
    dotnet sln src/Gateway/Gateway.slnx add src/Gateway/Gateway.csproj
    dotnet sln src/Gateway/Gateway.slnx add src/Contracts/Contracts.csproj --solution-folder shared
    dotnet add src/Gateway/Gateway.csproj reference src/Contracts/Contracts.csproj
    dotnet restore src/Gateway/Gateway.csproj
}