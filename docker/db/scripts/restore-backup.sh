#!/bin/bash
set -e

BACKUP_DIR="/backups"
DB_NAME="${POSTGRES_DB}"
DB_USER="${POSTGRES_USER}"

echo "Waiting for PostgreSQL to be ready..."
until pg_isready -U "$DB_USER" -d "$DB_NAME" &> /dev/null; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 2
done

echo "PostgreSQL is ready!"

LATEST_BACKUP=$(ls -t ${BACKUP_DIR}/*.sql 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
  echo "No backup file found in ${BACKUP_DIR}. Starting with fresh database."
else
  echo "Found backup file: $LATEST_BACKUP"
  echo "Restoring database from backup..."
  
  psql -U "$DB_USER" -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = '$DB_NAME' AND pid <> pg_backend_pid();" || true
  
  psql -U "$DB_USER" -d postgres -c "DROP DATABASE IF EXISTS ${DB_NAME};"
  psql -U "$DB_USER" -d postgres -c "CREATE DATABASE ${DB_NAME};"
  
  psql -U "$DB_USER" -d "$DB_NAME" < "$LATEST_BACKUP"
  
  echo "Database restored successfully from $LATEST_BACKUP"
fi
