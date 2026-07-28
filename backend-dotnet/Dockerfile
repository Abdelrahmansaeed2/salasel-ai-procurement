# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copy csproj and restore as distinct layers
COPY ["Salasel.API/Salasel.API.csproj", "Salasel.API/"]
COPY ["Salasel.Application/Salasel.Application.csproj", "Salasel.Application/"]
COPY ["Salasel.Domain/Salasel.Domain.csproj", "Salasel.Domain/"]
COPY ["Salasel.Infrastructure/Salasel.Infrastructure.csproj", "Salasel.Infrastructure/"]

RUN dotnet restore "Salasel.API/Salasel.API.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src/Salasel.API"
RUN dotnet build "Salasel.API.csproj" -c Release -o /app/build

# Publish Stage
FROM build AS publish
RUN dotnet publish "Salasel.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Runtime Stage
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
EXPOSE 80
EXPOSE 443

# Set environment variables for standard ASP.NET Core port overriding (used by Vercel/Docker hosts)
ENV ASPNETCORE_URLS=http://+:80

COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Salasel.API.dll"]
