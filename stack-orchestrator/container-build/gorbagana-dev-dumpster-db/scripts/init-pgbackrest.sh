#!/bin/sh
set -e

# This script runs inside /docker-entrypoint-initdb.d/ during first-time
# initialization, after initdb has created the data directory and while a
# temporary postgres instance is running.

# Only attempt stanza-create if pgBackRest is configured with real credentials
if [ -z "$PGBACKREST_REPO1_S3_KEY" ] || [ -z "$PGBACKREST_REPO1_S3_KEY_SECRET" ]; then
    echo "pgBackRest: S3 credentials not set, skipping stanza-create"
    exit 0
fi

echo "pgBackRest: creating stanza 'dumpster'..."
pgbackrest --stanza=dumpster stanza-create
echo "pgBackRest: stanza created successfully"
