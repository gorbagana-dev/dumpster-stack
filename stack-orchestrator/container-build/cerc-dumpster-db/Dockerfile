FROM postgres:14-alpine

RUN apk add --no-cache pgbackrest

# pgBackRest needs its config dir and log dir
RUN mkdir -p /etc/pgbackrest /var/log/pgbackrest \
    && chown postgres:postgres /var/log/pgbackrest

COPY scripts/start.sh /scripts/start.sh
COPY scripts/init-pgbackrest.sh /docker-entrypoint-initdb.d/50-init-pgbackrest.sh
RUN chmod +x /scripts/start.sh /docker-entrypoint-initdb.d/50-init-pgbackrest.sh

ENTRYPOINT ["/scripts/start.sh"]
CMD ["postgres"]
