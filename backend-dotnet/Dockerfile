FROM mcr.microsoft.com/dotnet/aspnet:7.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /src

COPY ["Salasel.sln", "./"]
COPY ["Salasel.Domain/Salasel.Domain.csproj", "Salasel.Domain/"]
COPY ["Salasel.Application/Salasel.Application.csproj", "Salasel.Application/"]
COPY ["Salasel.Infrastructure/Salasel.Infrastructure.csproj", "Salasel.Infrastructure/"]
COPY ["Salasel.API/Salasel.API.csproj", "Salasel.API/"]

RUN dotnet restore

COPY . .
WORKDIR "/src/Salasel.API"

RUN dotnet build "Salasel.API.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Salasel.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Salasel.API.dll"]
