
set -e


APP_DIR="/opt/backend-dotnet/backend-dotnet"

echo "=== Salasel API Deploy Script (Docker Compose) ==="

echo "Pulling latest code..."
cd $APP_DIR
git fetch origin
git reset --hard origin/main

echo "Rebuilding and starting services..."

docker-compose up -d --build api

echo "=== Deploy complete! ==="