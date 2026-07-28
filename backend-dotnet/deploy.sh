#!/bin/bash
set -e

APP_DIR="/opt/backend-dotnet/backend-dotnet"
SERVICE_NAME="salasel-api"

echo "=== Salasel API Deploy Script ==="
echo "Stopping service..."
systemctl stop $SERVICE_NAME || true

echo "Pulling latest code..."
cd $APP_DIR
git pull origin main

echo "Restoring and building..."
dotnet restore Salasel.API/Salasel.sln
dotnet publish Salasel.API/Salasel.API/Salasel.API.csproj -c Release -o /opt/backend-dotnet/publish --no-restore

echo "Running database migrations..."
export ASPNETCORE_ENVIRONMENT=Production
./efbundle --connection "$ConnectionStrings__DefaultConnection"

echo "Starting service..."
systemctl start $SERVICE_NAME

echo "=== Deploy complete! ==="
systemctl status $SERVICE_NAME --no-pager
