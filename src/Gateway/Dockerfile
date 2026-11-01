FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build

WORKDIR /build
COPY src/ src/
RUN dotnet restore src/Gateway/Gateway/Gateway.csproj
RUN dotnet publish -c Release src/Gateway/Gateway/Gateway.csproj -o /app

FROM runtime
WORKDIR /app
COPY --from=build /app .
ENTRYPOINT ["dotnet", "Gateway.dll"]
