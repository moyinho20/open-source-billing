#!/bin/bash

set -e

echo "Creating database backup before shutdown..."

DB_CONTAINER=$(docker-compose ps -q db)

if [ -z "$DB_CONTAINER" ]; then
  echo "Warning: Database container is not running. Skipping backup."
else
  docker exec "$DB_CONTAINER" /scripts/create-backup.sh
  echo "Backup completed successfully!"
fi

echo "Stopping containers..."
docker-compose down "$@"
