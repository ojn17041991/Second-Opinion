# This script initializes the project structures for the Second Opinion solution; Gateway, Contracts, and WorkerTemplate.
# Only empty project structures are created along with expected project and package references. Most of the actual implementation will need to be added manually.

# Always run from the repo root (the parent of the scripts folder).
Push-Location (Join-Path $PSScriptRoot "..")

# Create Contracts if it doesn't already exist.
if (-not (Test-Path "src/Contracts")) {
    dotnet new sln -n Contracts -o src/Contracts
    dotnet new classlib -n Contracts -o src/Contracts/Contracts -f net10.0
    dotnet sln src/Contracts/Contracts.slnx add src/Contracts/Contracts/Contracts.csproj --solution-folder src

    # Remove the default Class1.cs file created by the class library template.
    Remove-Item "src/Contracts/Contracts/Class1.cs"
} else {
    Write-Host "Contracts already exists."
}

# Create Messaging if it doesn't already exist.
if (-not (Test-Path "src/Messaging")) {
    dotnet new sln -n Messaging -o src/Messaging
    dotnet new classlib -n Messaging -o src/Messaging/Messaging -f net10.0 --no-restore
    dotnet new xunit -n Messaging.UnitTests -o src/Messaging/Messaging.UnitTests -f net10.0 --no-restore

    # Remove the default Class1.cs file created by the class library template.
    Remove-Item "src/Messaging/Messaging/Class1.cs"

    dotnet sln src/Messaging/Messaging.slnx add src/Messaging/Messaging/Messaging.csproj --solution-folder src
    dotnet sln src/Messaging/Messaging.slnx add src/Messaging/Messaging.UnitTests/Messaging.UnitTests.csproj --solution-folder tests
    dotnet add src/Messaging/Messaging.UnitTests/Messaging.UnitTests.csproj reference src/Messaging/Messaging/Messaging.csproj

    dotnet add src/Messaging/Messaging/Messaging.csproj package Azure.Identity --no-restore
    dotnet add src/Messaging/Messaging/Messaging.csproj package Azure.Messaging.ServiceBus --no-restore
    dotnet add src/Messaging/Messaging/Messaging.csproj package Microsoft.Extensions.Azure --no-restore
    dotnet add src/Messaging/Messaging/Messaging.csproj package Microsoft.Extensions.Hosting.Abstractions --no-restore

    dotnet restore src/Messaging/Messaging.slnx
} else {
    Write-Host "Messaging already exists."
}

# Create Gateway if it doesn't already exist.
if (-not (Test-Path "src/Gateway")) {
    dotnet new sln -n Gateway -o src/Gateway

    # Source projects.
    dotnet new web -n Gateway -o src/Gateway/Gateway -f net10.0 --no-restore
    dotnet new classlib -n Infrastructure -o src/Gateway/Infrastructure -f net10.0 --no-restore

    # Remove the default Class1.cs file created by the class library template.
    Remove-Item "src/Gateway/Infrastructure/Class1.cs"

    # Unit test projects, one per source project.
    dotnet new xunit -n Gateway.UnitTests -o src/Gateway/Gateway.UnitTests -f net10.0 --no-restore
    dotnet new xunit -n Infrastructure.UnitTests -o src/Gateway/Infrastructure.UnitTests -f net10.0 --no-restore

    # Add the projects to the solution.
    dotnet sln src/Gateway/Gateway.slnx add src/Gateway/Gateway/Gateway.csproj --solution-folder src
    dotnet sln src/Gateway/Gateway.slnx add src/Gateway/Infrastructure/Infrastructure.csproj --solution-folder src
    dotnet sln src/Gateway/Gateway.slnx add src/Gateway/Gateway.UnitTests/Gateway.UnitTests.csproj --solution-folder tests
    dotnet sln src/Gateway/Gateway.slnx add src/Gateway/Infrastructure.UnitTests/Infrastructure.UnitTests.csproj --solution-folder tests
    dotnet sln src/Gateway/Gateway.slnx add src/Contracts/Contracts/Contracts.csproj --solution-folder shared

    # Project references.
    dotnet add src/Gateway/Gateway/Gateway.csproj reference src/Gateway/Infrastructure/Infrastructure.csproj
    dotnet add src/Gateway/Gateway/Gateway.csproj reference src/Contracts/Contracts/Contracts.csproj
    dotnet add src/Gateway/Infrastructure/Infrastructure.csproj reference src/Contracts/Contracts/Contracts.csproj

    # Each unit test project references the project it tests.
    dotnet add src/Gateway/Gateway.UnitTests/Gateway.UnitTests.csproj reference src/Gateway/Gateway/Gateway.csproj
    dotnet add src/Gateway/Infrastructure.UnitTests/Infrastructure.UnitTests.csproj reference src/Gateway/Infrastructure/Infrastructure.csproj

    # Package references.
    dotnet add src/Gateway/Gateway/Gateway.csproj package Azure.Extensions.AspNetCore.Configuration.Secrets --no-restore
    dotnet add src/Gateway/Gateway/Gateway.csproj package Azure.Identity --no-restore
    dotnet add src/Gateway/Infrastructure/Infrastructure.csproj package Azure.Identity --no-restore
    dotnet add src/Gateway/Infrastructure/Infrastructure.csproj package Azure.Messaging.ServiceBus --no-restore
    dotnet add src/Gateway/Infrastructure/Infrastructure.csproj package Microsoft.Extensions.Azure --no-restore

    dotnet restore src/Gateway/Gateway.slnx
} else {
    Write-Host "Gateway already exists."
}

# Create WorkerTemplate if it doesn't already exist.
if (-not (Test-Path "src/WorkerTemplate")) {
    dotnet new sln -n WorkerTemplate -o src/WorkerTemplate

    # Source projects.
    dotnet new worker -n Worker -o src/WorkerTemplate/Worker -f net10.0 --no-restore
    dotnet new classlib -n Application -o src/WorkerTemplate/Application -f net10.0 --no-restore
    dotnet new classlib -n Domain -o src/WorkerTemplate/Domain -f net10.0 --no-restore
    dotnet new classlib -n Infrastructure -o src/WorkerTemplate/Infrastructure -f net10.0 --no-restore

    # Remove the default Class1.cs files created by the class library template.
    Remove-Item "src/WorkerTemplate/Application/Class1.cs"
    Remove-Item "src/WorkerTemplate/Domain/Class1.cs"
    Remove-Item "src/WorkerTemplate/Infrastructure/Class1.cs"

    # Unit test projects, one per source project.
    dotnet new xunit -n Worker.UnitTests -o src/WorkerTemplate/Worker.UnitTests -f net10.0 --no-restore
    dotnet new xunit -n Application.UnitTests -o src/WorkerTemplate/Application.UnitTests -f net10.0 --no-restore
    dotnet new xunit -n Domain.UnitTests -o src/WorkerTemplate/Domain.UnitTests -f net10.0 --no-restore
    dotnet new xunit -n Infrastructure.UnitTests -o src/WorkerTemplate/Infrastructure.UnitTests -f net10.0 --no-restore

    # Add the projects to the solution.
    dotnet sln src/WorkerTemplate/WorkerTemplate.slnx add src/WorkerTemplate/Worker/Worker.csproj --solution-folder src
    dotnet sln src/WorkerTemplate/WorkerTemplate.slnx add src/WorkerTemplate/Application/Application.csproj --solution-folder src
    dotnet sln src/WorkerTemplate/WorkerTemplate.slnx add src/WorkerTemplate/Domain/Domain.csproj --solution-folder src
    dotnet sln src/WorkerTemplate/WorkerTemplate.slnx add src/WorkerTemplate/Infrastructure/Infrastructure.csproj --solution-folder src
    dotnet sln src/WorkerTemplate/WorkerTemplate.slnx add src/WorkerTemplate/Worker.UnitTests/Worker.UnitTests.csproj --solution-folder tests
    dotnet sln src/WorkerTemplate/WorkerTemplate.slnx add src/WorkerTemplate/Application.UnitTests/Application.UnitTests.csproj --solution-folder tests
    dotnet sln src/WorkerTemplate/WorkerTemplate.slnx add src/WorkerTemplate/Domain.UnitTests/Domain.UnitTests.csproj --solution-folder tests
    dotnet sln src/WorkerTemplate/WorkerTemplate.slnx add src/WorkerTemplate/Infrastructure.UnitTests/Infrastructure.UnitTests.csproj --solution-folder tests
    dotnet sln src/WorkerTemplate/WorkerTemplate.slnx add src/Contracts/Contracts/Contracts.csproj --solution-folder shared

    # Project references between the source projects.
    dotnet add src/WorkerTemplate/Application/Application.csproj reference src/WorkerTemplate/Domain/Domain.csproj
    dotnet add src/WorkerTemplate/Application/Application.csproj reference src/Contracts/Contracts/Contracts.csproj
    dotnet add src/WorkerTemplate/Infrastructure/Infrastructure.csproj reference src/WorkerTemplate/Application/Application.csproj
    dotnet add src/WorkerTemplate/Worker/Worker.csproj reference src/WorkerTemplate/Application/Application.csproj
    dotnet add src/WorkerTemplate/Worker/Worker.csproj reference src/WorkerTemplate/Infrastructure/Infrastructure.csproj

    # Each unit test project references the project it tests.
    dotnet add src/WorkerTemplate/Worker.UnitTests/Worker.UnitTests.csproj reference src/WorkerTemplate/Worker/Worker.csproj
    dotnet add src/WorkerTemplate/Application.UnitTests/Application.UnitTests.csproj reference src/WorkerTemplate/Application/Application.csproj
    dotnet add src/WorkerTemplate/Domain.UnitTests/Domain.UnitTests.csproj reference src/WorkerTemplate/Domain/Domain.csproj
    dotnet add src/WorkerTemplate/Infrastructure.UnitTests/Infrastructure.UnitTests.csproj reference src/WorkerTemplate/Infrastructure/Infrastructure.csproj

    # Package references.
    dotnet add src/WorkerTemplate/Worker/Worker.csproj package Azure.Extensions.AspNetCore.Configuration.Secrets --no-restore
    dotnet add src/WorkerTemplate/Worker/Worker.csproj package Azure.Identity --no-restore
    dotnet add src/WorkerTemplate/Infrastructure/Infrastructure.csproj package Azure.Identity --no-restore
    dotnet add src/WorkerTemplate/Infrastructure/Infrastructure.csproj package Azure.Messaging.ServiceBus --no-restore

    dotnet restore src/WorkerTemplate/WorkerTemplate.slnx
} else {
    Write-Host "WorkerTemplate already exists."
}

# Return to the original location.
Pop-Location