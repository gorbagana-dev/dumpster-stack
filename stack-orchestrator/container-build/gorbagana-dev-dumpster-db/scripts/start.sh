#!/bin/sh
set -e

# Generate pgBackRest configuration from environment variables
cat > /etc/pgbackrest/pgbackrest.conf <<EOF
[global]
repo1-type=s3
repo1-path=/pgbackrest
repo1-s3-key=${PGBACKREST_REPO1_S3_KEY}
repo1-s3-key-secret=${PGBACKREST_REPO1_S3_KEY_SECRET}
repo1-s3-bucket=${PGBACKREST_REPO1_S3_BUCKET:-dumpster-pg-backups}
repo1-s3-endpoint=${PGBACKREST_REPO1_S3_ENDPOINT:-52c20c98f552c6af17369284bd9a78b2.r2.cloudflarestorage.com}
repo1-s3-region=${PGBACKREST_REPO1_S3_REGION:-auto}
repo1-s3-uri-style=path
repo1-retention-full=2
start-fast=y
log-level-console=info

[dumpster]
pg1-path=/var/lib/postgresql/data
pg1-user=${POSTGRES_USER:-postgres}
EOF

exec /usr/local/bin/docker-entrypoint.sh "$@" \
    -c archive_mode=on \
    -c wal_level=replica \
    -c archive_command='pgbackrest --stanza=dumpster archive-push %p' \
    -c archive_timeout=60
