# This script initializes shared library project structures for the Second Opinion solution.
# Only empty project structures are created along with expected project and package references. Most of the actual implementation will need to be added manually.

# Create Contracts if it doesn't already exist.
if (-not (Test-Path "..\..\src\Contracts")) {
    dotnet new sln -n Contracts -o ..\..\src\Contracts
    dotnet new classlib -n Contracts -o ..\..\src\Contracts\Contracts -f net10.0
    dotnet sln ..\..\src\Contracts\Contracts.slnx add ..\..\src\Contracts\Contracts\Contracts.csproj --solution-folder src

    # Remove the default Class1.cs file created by the class library template.
    Remove-Item "..\..\src\Contracts\Contracts\Class1.cs"
} else {
    Write-Host "Contracts already exists."
}

# Create Configuration if it doesn't already exist.
if (-not (Test-Path "..\..\src\Configuration")) {
    dotnet new sln -n Configuration -o ..\..\src\Configuration
    dotnet new classlib -n Configuration -o ..\..\src\Configuration\Configuration -f net10.0 --no-restore
    dotnet new xunit -n Configuration.UnitTests -o ..\..\src\Configuration\Configuration.UnitTests -f net10.0 --no-restore

    # Remove the default files created by the class library and xunit templates.
    Remove-Item "..\..\src\Configuration\Configuration\Class1.cs"
    Remove-Item "..\..\src\Configuration\Configuration.UnitTests\UnitTest1.cs"

    dotnet sln ..\..\src\Configuration\Configuration.slnx add ..\..\src\Configuration\Configuration\Configuration.csproj --solution-folder src
    dotnet sln ..\..\src\Configuration\Configuration.slnx add ..\..\src\Configuration\Configuration.UnitTests\Configuration.UnitTests.csproj --solution-folder tests
    dotnet add ..\..\src\Configuration\Configuration.UnitTests\Configuration.UnitTests.csproj reference ..\..\src\Configuration\Configuration\Configuration.csproj

    dotnet restore ..\..\src\Configuration\Configuration.slnx
} else {
    Write-Host "Configuration already exists."
}

# Create Messaging if it doesn't already exist.
if (-not (Test-Path "..\..\src\Messaging")) {
    dotnet new sln -n Messaging -o ..\..\src\Messaging
    dotnet new classlib -n Messaging -o ..\..\src\Messaging\Messaging -f net10.0 --no-restore
    dotnet new xunit -n Messaging.UnitTests -o ..\..\src\Messaging\Messaging.UnitTests -f net10.0 --no-restore

    # Remove the default files created by the class library and xunit templates.
    Remove-Item "..\..\src\Messaging\Messaging\Class1.cs"
    Remove-Item "..\..\src\Messaging\Messaging.UnitTests\UnitTest1.cs"

    dotnet sln ..\..\src\Messaging\Messaging.slnx add ..\..\src\Messaging\Messaging\Messaging.csproj --solution-folder src
    dotnet sln ..\..\src\Messaging\Messaging.slnx add ..\..\src\Messaging\Messaging.UnitTests\Messaging.UnitTests.csproj --solution-folder tests
    dotnet sln ..\..\src\Messaging\Messaging.slnx add ..\..\src\Configuration\Configuration\Configuration.csproj --solution-folder shared
    dotnet add ..\..\src\Messaging\Messaging.UnitTests\Messaging.UnitTests.csproj reference ..\..\src\Messaging\Messaging\Messaging.csproj
    dotnet add ..\..\src\Messaging\Messaging\Messaging.csproj reference ..\..\src\Configuration\Configuration\Configuration.csproj

    dotnet add ..\..\src\Messaging\Messaging\Messaging.csproj package Azure.Identity --no-restore
    dotnet add ..\..\src\Messaging\Messaging\Messaging.csproj package Azure.Messaging.ServiceBus --no-restore
    dotnet add ..\..\src\Messaging\Messaging\Messaging.csproj package Microsoft.Extensions.Azure --no-restore
    dotnet add ..\..\src\Messaging\Messaging\Messaging.csproj package Microsoft.Extensions.Configuration --no-restore
    dotnet add ..\..\src\Messaging\Messaging\Messaging.csproj package Microsoft.Extensions.Configuration.Binder --no-restore
    dotnet add ..\..\src\Messaging\Messaging\Messaging.csproj package Microsoft.Extensions.Hosting.Abstractions --no-restore

    dotnet restore ..\..\src\Messaging\Messaging.slnx
} else {
    Write-Host "Messaging already exists."
}

# Create Secrets if it doesn't already exist.
if (-not (Test-Path "..\..\src\Secrets")) {
    dotnet new sln -n Secrets -o ..\..\src\Secrets
    dotnet new classlib -n Secrets -o ..\..\src\Secrets\Secrets -f net10.0 --no-restore
    dotnet new xunit -n Secrets.UnitTests -o ..\..\src\Secrets\Secrets.UnitTests -f net10.0 --no-restore

    # Remove the default files created by the class library and xunit templates.
    Remove-Item "..\..\src\Secrets\Secrets\Class1.cs"
    Remove-Item "..\..\src\Secrets\Secrets.UnitTests\UnitTest1.cs"

    dotnet sln ..\..\src\Secrets\Secrets.slnx add ..\..\src\Secrets\Secrets\Secrets.csproj --solution-folder src
    dotnet sln ..\..\src\Secrets\Secrets.slnx add ..\..\src\Secrets\Secrets.UnitTests\Secrets.UnitTests.csproj --solution-folder tests
    dotnet sln ..\..\src\Secrets\Secrets.slnx add ..\..\src\Configuration\Configuration\Configuration.csproj --solution-folder shared
    dotnet add ..\..\src\Secrets\Secrets.UnitTests\Secrets.UnitTests.csproj reference ..\..\src\Secrets\Secrets\Secrets.csproj
    dotnet add ..\..\src\Secrets\Secrets\Secrets.csproj reference ..\..\src\Configuration\Configuration\Configuration.csproj

    dotnet add ..\..\src\Secrets\Secrets\Secrets.csproj package Azure.Core --no-restore
    dotnet add ..\..\src\Secrets\Secrets\Secrets.csproj package Azure.Identity --no-restore
    dotnet add ..\..\src\Secrets\Secrets\Secrets.csproj package Azure.Extensions.AspNetCore.Configuration.Secrets --no-restore
    dotnet add ..\..\src\Secrets\Secrets\Secrets.csproj package Microsoft.Extensions.Configuration --no-restore
    dotnet add ..\..\src\Secrets\Secrets\Secrets.csproj package Microsoft.Extensions.Configuration.Binder --no-restore
    dotnet add ..\..\src\Secrets\Secrets\Secrets.csproj package Microsoft.Extensions.DependencyInjection --no-restore

    dotnet restore ..\..\src\Secrets\Secrets.slnx
} else {
    Write-Host "Secrets already exists."
}

