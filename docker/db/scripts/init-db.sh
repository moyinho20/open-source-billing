#!/bin/bash
set -e

echo "Running database initialization..."

sleep 5

/scripts/restore-backup.sh
