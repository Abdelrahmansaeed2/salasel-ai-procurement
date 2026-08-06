#!/bin/bash
set -e

alembic upgrade head

/opt/mssql-tools18/bin/sqlcmd \
    -b \
    -S sqlserver \
    -U sa \
    -P "$SQL_SERVER_PASSWORD" \
    -C \
    -i /work/seed.sql

exec uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
