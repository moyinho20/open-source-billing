# Docker PostgreSQL Database Backup and Restore

This document describes the automatic database backup and restore functionality for the Open Source Billing application using PostgreSQL.

## Overview

The Docker setup now includes automatic PostgreSQL database backup and restore capabilities:

- **On startup (`docker-compose up`)**: Automatically restores from the latest backup if available
- **On shutdown**: Creates a full backup before stopping containers

## Usage

### Starting the Application (with automatic restore)

```bash
docker-compose up --build
```

When the database container starts:
1. PostgreSQL initializes
2. The system looks for the latest backup file in `/backups`
3. If a backup exists, it automatically restores the database
4. If no backup exists, it starts with a fresh database

### Stopping the Application (with automatic backup)

Instead of using `docker-compose down` directly, use the provided backup script:

```bash
./docker-backup.sh
```

This script:
1. Creates a full database backup with timestamp
2. Saves it to the `db_backups` volume
3. Keeps the last 10 backups (older ones are automatically removed)
4. Stops all containers

You can also pass docker-compose down options:

```bash
./docker-backup.sh -v    # Also remove volumes
./docker-backup.sh --remove-orphans
```

### Manual Backup

To create a backup while the containers are running:

```bash
docker exec $(docker-compose ps -q db) /scripts/create-backup.sh
```

### Manual Restore

To restore from a specific backup:

```bash
# Copy your backup file to the container
docker cp your_backup.sql $(docker-compose ps -q db):/backups/

# Run the restore script
docker exec $(docker-compose ps -q db) /scripts/restore-backup.sh
```

### Accessing Backups

Backups are stored in a Docker volume named `db_backups`. To access them:

```bash
# List all backups
docker run --rm -v open-source-billing_db_backups:/backups alpine ls -lh /backups

# Copy a backup to your host machine
docker run --rm -v open-source-billing_db_backups:/backups -v $(pwd):/host alpine cp /backups/backup_YYYYMMDD_HHMMSS.sql /host/
```

Replace `open-source-billing_db_backups` with your actual volume name (check with `docker volume ls`).

## File Structure

```
docker/
├── db/
│   ├── Dockerfile              # Custom PostgreSQL image with backup scripts
│   └── scripts/
│       ├── create-backup.sh    # Creates a database backup using pg_dump
│       ├── restore-backup.sh   # Restores from latest backup using psql
│       └── init-db.sh          # Runs on container initialization
└── ...

docker-backup.sh                # Helper script for backup on shutdown
```

## Backup File Naming

Backup files are named with timestamps: `backup_YYYYMMDD_HHMMSS.sql`

Example: `backup_20250115_143022.sql`

## Important Notes

1. **Backup Retention**: The system automatically keeps only the last 10 backups to save disk space
2. **First Run**: On first run, no backup exists, so the database starts fresh
3. **Volume Persistence**: Backups are stored in a Docker volume (`db_backups`) which persists even when containers are removed
4. **Always Use docker-backup.sh**: To ensure your data is backed up, always use `./docker-backup.sh` instead of `docker-compose down`

## Troubleshooting

### No backup created on shutdown

Make sure you're using `./docker-backup.sh` instead of `docker-compose down`

### Restore fails

Check that:
- The backup file exists in `/backups`
- The backup file is a valid PostgreSQL SQL dump (created with pg_dump)
- PostgreSQL has enough disk space
- Database encoding matches between backup and restore

### View container logs

```bash
docker-compose logs db
```
