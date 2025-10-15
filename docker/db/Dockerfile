FROM mysql/mysql-server:latest

# Copy backup/restore scripts
COPY docker/db/scripts/*.sh /scripts/

# Make scripts executable
RUN chmod +x /scripts/*.sh

# The init-db.sh will run after MySQL initialization
COPY docker/db/scripts/init-db.sh /docker-entrypoint-initdb.d/
