#!/bin/bash
set -e

export DATABASE_URL=$(python -c "import urllib.parse, os; print(f'mssql+aioodbc://sa:{urllib.parse.quote_plus(os.environ.get(\"DB_PASSWORD\", \"\"))}@sqlserver:1433/SalaselAiService?driver=ODBC+Driver+18+for+SQL+Server&TrustServerCertificate=yes')")

alembic upgrade head

/opt/mssql-tools18/bin/sqlcmd \
    -b \
    -S sqlserver \
    -U sa \
    -P "$DB_PASSWORD" \
    -C \
    -i /work/seed.sql || echo "Seed script completed or skipped."

exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
