# This script initializes the service project structures for the Second Opinion solution.
# Only empty project structures are created along with expected project and package references. Most of the actual implementation will need to be added manually.

# Create Gateway if it doesn't already exist.
if (-not (Test-Path "..\..\src\Gateway")) {
    dotnet new sln -n Gateway -o ..\..\src\Gateway

    # Source projects.
    dotnet new web -n Gateway -o ..\..\src\Gateway\Gateway -f net10.0 --no-restore
    dotnet new classlib -n Application -o ..\..\src\Gateway\Application -f net10.0 --no-restore
    dotnet new classlib -n Domain -o ..\..\src\Gateway\Domain -f net10.0 --no-restore
    dotnet new classlib -n Infrastructure -o ..\..\src\Gateway\Infrastructure -f net10.0 --no-restore

    # Remove the default Class1.cs files created by the class library template.
    Remove-Item "..\..\src\Gateway\Application\Class1.cs"
    Remove-Item "..\..\src\Gateway\Domain\Class1.cs"
    Remove-Item "..\..\src\Gateway\Infrastructure\Class1.cs"

    # Unit test projects, one per source project.
    dotnet new xunit -n Gateway.UnitTests -o ..\..\src\Gateway\Gateway.UnitTests -f net10.0 --no-restore
    dotnet new xunit -n Application.UnitTests -o ..\..\src\Gateway\Application.UnitTests -f net10.0 --no-restore
    dotnet new xunit -n Domain.UnitTests -o ..\..\src\Gateway\Domain.UnitTests -f net10.0 --no-restore
    dotnet new xunit -n Infrastructure.UnitTests -o ..\..\src\Gateway\Infrastructure.UnitTests -f net10.0 --no-restore
    
    # Remove the default UnitTest1.cs file created by the xunit template.
    Remove-Item "..\..\src\Gateway\Gateway.UnitTests\UnitTest1.cs"
    Remove-Item "..\..\src\Gateway\Application.UnitTests\UnitTest1.cs"
    Remove-Item "..\..\src\Gateway\Domain.UnitTests\UnitTest1.cs"
    Remove-Item "..\..\src\Gateway\Infrastructure.UnitTests\UnitTest1.cs"

    # Add the projects to the solution.
    dotnet sln ..\..\src\Gateway\Gateway.slnx add ..\..\src\Gateway\Gateway\Gateway.csproj --solution-folder src
    dotnet sln ..\..\src\Gateway\Gateway.slnx add ..\..\src\Gateway\Application\Application.csproj --solution-folder src
    dotnet sln ..\..\src\Gateway\Gateway.slnx add ..\..\src\Gateway\Domain\Domain.csproj --solution-folder src
    dotnet sln ..\..\src\Gateway\Gateway.slnx add ..\..\src\Gateway\Infrastructure\Infrastructure.csproj --solution-folder src
    dotnet sln ..\..\src\Gateway\Gateway.slnx add ..\..\src\Gateway\Gateway.UnitTests\Gateway.UnitTests.csproj --solution-folder tests
    dotnet sln ..\..\src\Gateway\Gateway.slnx add ..\..\src\Gateway\Application.UnitTests\Application.UnitTests.csproj --solution-folder tests
    dotnet sln ..\..\src\Gateway\Gateway.slnx add ..\..\src\Gateway\Domain.UnitTests\Domain.UnitTests.csproj --solution-folder tests
    dotnet sln ..\..\src\Gateway\Gateway.slnx add ..\..\src\Gateway\Infrastructure.UnitTests\Infrastructure.UnitTests.csproj --solution-folder tests
    dotnet sln ..\..\src\Gateway\Gateway.slnx add ..\..\src\Configuration\Configuration\Configuration.csproj --solution-folder shared
    dotnet sln ..\..\src\Gateway\Gateway.slnx add ..\..\src\Contracts\Contracts\Contracts.csproj --solution-folder shared
    dotnet sln ..\..\src\Gateway\Gateway.slnx add ..\..\src\Messaging\Messaging\Messaging.csproj --solution-folder shared
    dotnet sln ..\..\src\Gateway\Gateway.slnx add ..\..\src\Secrets\Secrets\Secrets.csproj --solution-folder shared

    # Project references.
    dotnet add ..\..\src\Gateway\Application\Application.csproj reference ..\..\src\Gateway\Domain\Domain.csproj
    dotnet add ..\..\src\Gateway\Application\Application.csproj reference ..\..\src\Contracts\Contracts\Contracts.csproj
    dotnet add ..\..\src\Gateway\Gateway\Gateway.csproj reference ..\..\src\Gateway\Application\Application.csproj
    dotnet add ..\..\src\Gateway\Gateway\Gateway.csproj reference ..\..\src\Gateway\Infrastructure\Infrastructure.csproj
    dotnet add ..\..\src\Gateway\Gateway\Gateway.csproj reference ..\..\src\Contracts\Contracts\Contracts.csproj
    dotnet add ..\..\src\Gateway\Gateway\Gateway.csproj reference ..\..\src\Messaging\Messaging\Messaging.csproj
    dotnet add ..\..\src\Gateway\Gateway\Gateway.csproj reference ..\..\src\Secrets\Secrets\Secrets.csproj
    dotnet add ..\..\src\Gateway\Infrastructure\Infrastructure.csproj reference ..\..\src\Gateway\Application\Application.csproj
    dotnet add ..\..\src\Gateway\Infrastructure\Infrastructure.csproj reference ..\..\src\Contracts\Contracts\Contracts.csproj

    # Each unit test project references the project it tests.
    dotnet add ..\..\src\Gateway\Gateway.UnitTests\Gateway.UnitTests.csproj reference ..\..\src\Gateway\Gateway\Gateway.csproj
    dotnet add ..\..\src\Gateway\Application.UnitTests\Application.UnitTests.csproj reference ..\..\src\Gateway\Application\Application.csproj
    dotnet add ..\..\src\Gateway\Domain.UnitTests\Domain.UnitTests.csproj reference ..\..\src\Gateway\Domain\Domain.csproj
    dotnet add ..\..\src\Gateway\Infrastructure.UnitTests\Infrastructure.UnitTests.csproj reference ..\..\src\Gateway\Infrastructure\Infrastructure.csproj

    # Package references.
    dotnet add ..\..\src\Gateway\Gateway\Gateway.csproj package Azure.Extensions.AspNetCore.Configuration.Secrets --no-restore
    dotnet add ..\..\src\Gateway\Gateway\Gateway.csproj package Azure.Identity --no-restore
    dotnet add ..\..\src\Gateway\Infrastructure\Infrastructure.csproj package Azure.Identity --no-restore
    dotnet add ..\..\src\Gateway\Infrastructure\Infrastructure.csproj package Azure.Messaging.ServiceBus --no-restore
    dotnet add ..\..\src\Gateway\Infrastructure\Infrastructure.csproj package Microsoft.Extensions.Azure --no-restore

    dotnet restore ..\..\src\Gateway\Gateway.slnx
} else {
    Write-Host "Gateway already exists."
}

# Create WorkerTemplate if it doesn't already exist.
if (-not (Test-Path "..\..\src\WorkerTemplate")) {
    dotnet new sln -n WorkerTemplate -o ..\..\src\WorkerTemplate

    # Source projects.
    dotnet new worker -n Worker -o ..\..\src\WorkerTemplate\Worker -f net10.0 --no-restore
    dotnet new classlib -n Application -o ..\..\src\WorkerTemplate\Application -f net10.0 --no-restore
    dotnet new classlib -n Domain -o ..\..\src\WorkerTemplate\Domain -f net10.0 --no-restore
    dotnet new classlib -n Infrastructure -o ..\..\src\WorkerTemplate\Infrastructure -f net10.0 --no-restore

    # Remove the default Class1.cs files created by the class library template.
    Remove-Item "..\..\src\WorkerTemplate\Application\Class1.cs"
    Remove-Item "..\..\src\WorkerTemplate\Domain\Class1.cs"
    Remove-Item "..\..\src\WorkerTemplate\Infrastructure\Class1.cs"

    # Unit test projects, one per source project.
    dotnet new xunit -n Worker.UnitTests -o ..\..\src\WorkerTemplate\Worker.UnitTests -f net10.0 --no-restore
    dotnet new xunit -n Application.UnitTests -o ..\..\src\WorkerTemplate\Application.UnitTests -f net10.0 --no-restore
    dotnet new xunit -n Domain.UnitTests -o ..\..\src\WorkerTemplate\Domain.UnitTests -f net10.0 --no-restore
    dotnet new xunit -n Infrastructure.UnitTests -o ..\..\src\WorkerTemplate\Infrastructure.UnitTests -f net10.0 --no-restore

    # Remove the default UnitTest1.cs file created by the xunit template.
    Remove-Item "..\..\src\WorkerTemplate\Worker.UnitTests\UnitTest1.cs"
    Remove-Item "..\..\src\WorkerTemplate\Application.UnitTests\UnitTest1.cs"
    Remove-Item "..\..\src\WorkerTemplate\Domain.UnitTests\UnitTest1.cs"
    Remove-Item "..\..\src\WorkerTemplate\Infrastructure.UnitTests\UnitTest1.cs"

    # Add the projects to the solution.
    dotnet sln ..\..\src\WorkerTemplate\WorkerTemplate.slnx add ..\..\src\WorkerTemplate\Worker\Worker.csproj --solution-folder src
    dotnet sln ..\..\src\WorkerTemplate\WorkerTemplate.slnx add ..\..\src\WorkerTemplate\Application\Application.csproj --solution-folder src
    dotnet sln ..\..\src\WorkerTemplate\WorkerTemplate.slnx add ..\..\src\WorkerTemplate\Domain\Domain.csproj --solution-folder src
    dotnet sln ..\..\src\WorkerTemplate\WorkerTemplate.slnx add ..\..\src\WorkerTemplate\Infrastructure\Infrastructure.csproj --solution-folder src
    dotnet sln ..\..\src\WorkerTemplate\WorkerTemplate.slnx add ..\..\src\WorkerTemplate\Worker.UnitTests\Worker.UnitTests.csproj --solution-folder tests
    dotnet sln ..\..\src\WorkerTemplate\WorkerTemplate.slnx add ..\..\src\WorkerTemplate\Application.UnitTests\Application.UnitTests.csproj --solution-folder tests
    dotnet sln ..\..\src\WorkerTemplate\WorkerTemplate.slnx add ..\..\src\WorkerTemplate\Domain.UnitTests\Domain.UnitTests.csproj --solution-folder tests
    dotnet sln ..\..\src\WorkerTemplate\WorkerTemplate.slnx add ..\..\src\WorkerTemplate\Infrastructure.UnitTests\Infrastructure.UnitTests.csproj --solution-folder tests
    dotnet sln ..\..\src\WorkerTemplate\WorkerTemplate.slnx add ..\..\src\Contracts\Contracts\Contracts.csproj --solution-folder shared
    dotnet sln ..\..\src\WorkerTemplate\WorkerTemplate.slnx add ..\..\src\Messaging\Messaging\Messaging.csproj --solution-folder shared
    dotnet sln ..\..\src\WorkerTemplate\WorkerTemplate.slnx add ..\..\src\Secrets\Secrets\Secrets.csproj --solution-folder shared

    # Project references between the source projects.
    dotnet add ..\..\src\WorkerTemplate\Application\Application.csproj reference ..\..\src\WorkerTemplate\Domain\Domain.csproj
    dotnet add ..\..\src\WorkerTemplate\Application\Application.csproj reference ..\..\src\Contracts\Contracts\Contracts.csproj
    dotnet add ..\..\src\WorkerTemplate\Infrastructure\Infrastructure.csproj reference ..\..\src\WorkerTemplate\Application\Application.csproj
    dotnet add ..\..\src\WorkerTemplate\Worker\Worker.csproj reference ..\..\src\WorkerTemplate\Application\Application.csproj
    dotnet add ..\..\src\WorkerTemplate\Worker\Worker.csproj reference ..\..\src\WorkerTemplate\Infrastructure\Infrastructure.csproj
    dotnet add ..\..\src\WorkerTemplate\Worker\Worker.csproj reference ..\..\src\Messaging\Messaging\Messaging.csproj
    dotnet add ..\..\src\WorkerTemplate\Worker\Worker.csproj reference ..\..\src\Secrets\Secrets\Secrets.csproj

    # Each unit test project references the project it tests.
    dotnet add ..\..\src\WorkerTemplate\Worker.UnitTests\Worker.UnitTests.csproj reference ..\..\src\WorkerTemplate\Worker\Worker.csproj
    dotnet add ..\..\src\WorkerTemplate\Application.UnitTests\Application.UnitTests.csproj reference ..\..\src\WorkerTemplate\Application\Application.csproj
    dotnet add ..\..\src\WorkerTemplate\Domain.UnitTests\Domain.UnitTests.csproj reference ..\..\src\WorkerTemplate\Domain\Domain.csproj
    dotnet add ..\..\src\WorkerTemplate\Infrastructure.UnitTests\Infrastructure.UnitTests.csproj reference ..\..\src\WorkerTemplate\Infrastructure\Infrastructure.csproj

    # Package references.
    dotnet add ..\..\src\WorkerTemplate\Worker\Worker.csproj package Azure.Extensions.AspNetCore.Configuration.Secrets --no-restore
    dotnet add ..\..\src\WorkerTemplate\Worker\Worker.csproj package Azure.Identity --no-restore
    dotnet add ..\..\src\WorkerTemplate\Worker\Worker.csproj package Microsoft.ApplicationInsights.WorkerService --version 2.22.0 --no-restore
    dotnet add ..\..\src\WorkerTemplate\Infrastructure\Infrastructure.csproj package Azure.Identity --no-restore
    dotnet add ..\..\src\WorkerTemplate\Infrastructure\Infrastructure.csproj package Azure.Messaging.ServiceBus --no-restore

    dotnet restore ..\..\src\WorkerTemplate\WorkerTemplate.slnx
    New-Item -ItemType File -Path "..\..\src\WorkerTemplate\Worker\Dockerfile" | Out-Null
} else {
    Write-Host "WorkerTemplate already exists."
}

# Create ApiTemplate if it doesn't already exist.
if (-not (Test-Path "..\..\src\ApiTemplate")) {
    dotnet new sln -n ApiTemplate -o ..\..\src\ApiTemplate

    # Source projects.
    dotnet new webapi -n Api -o ..\..\src\ApiTemplate\Api -f net10.0 --no-restore
    dotnet new classlib -n Application -o ..\..\src\ApiTemplate\Application -f net10.0 --no-restore
    dotnet new classlib -n Domain -o ..\..\src\ApiTemplate\Domain -f net10.0 --no-restore
    dotnet new classlib -n Infrastructure -o ..\..\src\ApiTemplate\Infrastructure -f net10.0 --no-restore

    # Remove the default Class1.cs files created by the class library template.
    Remove-Item "..\..\src\ApiTemplate\Application\Class1.cs"
    Remove-Item "..\..\src\ApiTemplate\Domain\Class1.cs"
    Remove-Item "..\..\src\ApiTemplate\Infrastructure\Class1.cs"

    # Unit test projects, one per source project.
    dotnet new xunit -n Api.UnitTests -o ..\..\src\ApiTemplate\Api.UnitTests -f net10.0 --no-restore
    dotnet new xunit -n Application.UnitTests -o ..\..\src\ApiTemplate\Application.UnitTests -f net10.0 --no-restore
    dotnet new xunit -n Domain.UnitTests -o ..\..\src\ApiTemplate\Domain.UnitTests -f net10.0 --no-restore
    dotnet new xunit -n Infrastructure.UnitTests -o ..\..\src\ApiTemplate\Infrastructure.UnitTests -f net10.0 --no-restore

    # Remove the default UnitTest1.cs file created by the xunit template.
    Remove-Item "..\..\src\ApiTemplate\Api.UnitTests\UnitTest1.cs"
    Remove-Item "..\..\src\ApiTemplate\Application.UnitTests\UnitTest1.cs"
    Remove-Item "..\..\src\ApiTemplate\Domain.UnitTests\UnitTest1.cs"
    Remove-Item "..\..\src\ApiTemplate\Infrastructure.UnitTests\UnitTest1.cs"

    # Add the projects to the solution.
    dotnet sln ..\..\src\ApiTemplate\ApiTemplate.slnx add ..\..\src\ApiTemplate\Api\Api.csproj --solution-folder src
    dotnet sln ..\..\src\ApiTemplate\ApiTemplate.slnx add ..\..\src\ApiTemplate\Application\Application.csproj --solution-folder src
    dotnet sln ..\..\src\ApiTemplate\ApiTemplate.slnx add ..\..\src\ApiTemplate\Domain\Domain.csproj --solution-folder src
    dotnet sln ..\..\src\ApiTemplate\ApiTemplate.slnx add ..\..\src\ApiTemplate\Infrastructure\Infrastructure.csproj --solution-folder src
    dotnet sln ..\..\src\ApiTemplate\ApiTemplate.slnx add ..\..\src\ApiTemplate\Api.UnitTests\Api.UnitTests.csproj --solution-folder tests
    dotnet sln ..\..\src\ApiTemplate\ApiTemplate.slnx add ..\..\src\ApiTemplate\Application.UnitTests\Application.UnitTests.csproj --solution-folder tests
    dotnet sln ..\..\src\ApiTemplate\ApiTemplate.slnx add ..\..\src\ApiTemplate\Domain.UnitTests\Domain.UnitTests.csproj --solution-folder tests
    dotnet sln ..\..\src\ApiTemplate\ApiTemplate.slnx add ..\..\src\ApiTemplate\Infrastructure.UnitTests\Infrastructure.UnitTests.csproj --solution-folder tests
    dotnet sln ..\..\src\ApiTemplate\ApiTemplate.slnx add ..\..\src\Contracts\Contracts\Contracts.csproj --solution-folder shared
    dotnet sln ..\..\src\ApiTemplate\ApiTemplate.slnx add ..\..\src\Messaging\Messaging\Messaging.csproj --solution-folder shared
    dotnet sln ..\..\src\ApiTemplate\ApiTemplate.slnx add ..\..\src\Secrets\Secrets\Secrets.csproj --solution-folder shared

    # Project references between the source projects.
    dotnet add ..\..\src\ApiTemplate\Application\Application.csproj reference ..\..\src\ApiTemplate\Domain\Domain.csproj
    dotnet add ..\..\src\ApiTemplate\Application\Application.csproj reference ..\..\src\Contracts\Contracts\Contracts.csproj
    dotnet add ..\..\src\ApiTemplate\Infrastructure\Infrastructure.csproj reference ..\..\src\ApiTemplate\Application\Application.csproj
    dotnet add ..\..\src\ApiTemplate\Api\Api.csproj reference ..\..\src\ApiTemplate\Application\Application.csproj
    dotnet add ..\..\src\ApiTemplate\Api\Api.csproj reference ..\..\src\ApiTemplate\Infrastructure\Infrastructure.csproj
    dotnet add ..\..\src\ApiTemplate\Api\Api.csproj reference ..\..\src\Messaging\Messaging\Messaging.csproj
    dotnet add ..\..\src\ApiTemplate\Api\Api.csproj reference ..\..\src\Secrets\Secrets\Secrets.csproj

    # Each unit test project references the project it tests.
    dotnet add ..\..\src\ApiTemplate\Api.UnitTests\Api.UnitTests.csproj reference ..\..\src\ApiTemplate\Api\Api.csproj
    dotnet add ..\..\src\ApiTemplate\Application.UnitTests\Application.UnitTests.csproj reference ..\..\src\ApiTemplate\Application\Application.csproj
    dotnet add ..\..\src\ApiTemplate\Domain.UnitTests\Domain.UnitTests.csproj reference ..\..\src\ApiTemplate\Domain\Domain.csproj
    dotnet add ..\..\src\ApiTemplate\Infrastructure.UnitTests\Infrastructure.UnitTests.csproj reference ..\..\src\ApiTemplate\Infrastructure\Infrastructure.csproj

    # Package references.
    dotnet add ..\..\src\ApiTemplate\Api\Api.csproj package Azure.Extensions.AspNetCore.Configuration.Secrets --no-restore
    dotnet add ..\..\src\ApiTemplate\Api\Api.csproj package Azure.Identity --no-restore
    dotnet add ..\..\src\ApiTemplate\Infrastructure\Infrastructure.csproj package Azure.Identity --no-restore
    dotnet add ..\..\src\ApiTemplate\Infrastructure\Infrastructure.csproj package Azure.Messaging.ServiceBus --no-restore

    dotnet restore ..\..\src\ApiTemplate\ApiTemplate.slnx
    New-Item -ItemType File -Path "..\..\src\ApiTemplate\Api\Dockerfile" | Out-Null
} else {
    Write-Host "ApiTemplate already exists."
}
