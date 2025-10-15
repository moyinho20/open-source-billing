#!/bin/bash
set -e

BACKUP_DIR="/backups"
DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"
DB_PASSWORD="${MYSQL_PASSWORD}"

echo "Waiting for MySQL to be ready..."
until mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "SELECT 1" &> /dev/null; do
  echo "MySQL is unavailable - sleeping"
  sleep 2
done

echo "MySQL is ready!"

LATEST_BACKUP=$(ls -t ${BACKUP_DIR}/*.sql 2>/dev/null | head -n 1)

if [ -z "$LATEST_BACKUP" ]; then
  echo "No backup file found in ${BACKUP_DIR}. Starting with fresh database."
else
  echo "Found backup file: $LATEST_BACKUP"
  echo "Restoring database from backup..."
  
  mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "DROP DATABASE IF EXISTS ${DB_NAME};"
  mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "CREATE DATABASE ${DB_NAME};"
  
  mysql -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$LATEST_BACKUP"
  
  echo "Database restored successfully from $LATEST_BACKUP"
fi
