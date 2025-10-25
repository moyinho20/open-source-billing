FROM postgres:15-alpine

COPY docker/db/scripts/*.sh /scripts/

RUN chmod +x /scripts/*.sh

COPY docker/db/scripts/init-db.sh /docker-entrypoint-initdb.d/
