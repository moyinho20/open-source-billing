#!/bin/bash
set -e

BACKUP_DIR="/backups"
DB_NAME="${POSTGRES_DB}"
DB_USER="${POSTGRES_USER}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.sql"

mkdir -p "${BACKUP_DIR}"

echo "Creating database backup..."

pg_dump -U "$DB_USER" "$DB_NAME" > "$BACKUP_FILE"

echo "Database backup created successfully: $BACKUP_FILE"

BACKUP_COUNT=$(ls -1 ${BACKUP_DIR}/backup_*.sql 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 10 ]; then
  echo "Cleaning up old backups (keeping last 10)..."
  ls -t ${BACKUP_DIR}/backup_*.sql | tail -n +11 | xargs rm -f
fi

echo "Backup process completed."
