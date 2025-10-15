#!/bin/bash
set -e

BACKUP_DIR="/backups"
DB_NAME="${MYSQL_DATABASE}"
DB_USER="${MYSQL_USER}"
DB_PASSWORD="${MYSQL_PASSWORD}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/backup_${TIMESTAMP}.sql"

mkdir -p "${BACKUP_DIR}"

echo "Creating database backup..."

mysqldump -u"$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" > "$BACKUP_FILE"

echo "Database backup created successfully: $BACKUP_FILE"

BACKUP_COUNT=$(ls -1 ${BACKUP_DIR}/backup_*.sql 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 10 ]; then
  echo "Cleaning up old backups (keeping last 10)..."
  ls -t ${BACKUP_DIR}/backup_*.sql | tail -n +11 | xargs rm -f
fi

echo "Backup process completed."
