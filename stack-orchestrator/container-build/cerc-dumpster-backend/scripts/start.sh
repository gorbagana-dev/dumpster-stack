#!/usr/bin/env bash
set -e

if [ -n "$CERC_SCRIPT_DEBUG" ]; then
    set -x
fi

echo "Dumpster Backend starting..."

if [ -n "$DATABASE_URL" ]; then
    DB_HOST=$(echo $DATABASE_URL | sed -e 's|.*@||' -e 's|:.*||' -e 's|/.*||')
    DB_PORT=$(echo $DATABASE_URL | sed -e 's|.*@[^:]*:||' -e 's|/.*||')
    DB_PORT=${DB_PORT:-5432}

    echo "Waiting for PostgreSQL at ${DB_HOST}:${DB_PORT}..."
    counter=0
    until nc -z "$DB_HOST" "$DB_PORT" 2>/dev/null; do
        counter=$((counter + 1))
        if [ $counter -ge 60 ]; then
            echo "Error: PostgreSQL not available after 60s"
            exit 1
        fi
        sleep 1
    done
    echo "PostgreSQL ready."
fi

if [ -n "$REDIS_URL" ]; then
    REDIS_HOST=$(echo $REDIS_URL | sed -e 's|redis://||' -e 's|:.*||' -e 's|/.*||')
    REDIS_PORT=$(echo $REDIS_URL | sed -e 's|redis://[^:]*:||' -e 's|/.*||')
    if [ -z "$REDIS_PORT" ] || [ "$REDIS_PORT" = "$REDIS_HOST" ]; then
        REDIS_PORT=6379
    fi

    echo "Waiting for Redis at ${REDIS_HOST}:${REDIS_PORT}..."
    counter=0
    until nc -z "$REDIS_HOST" "$REDIS_PORT" 2>/dev/null; do
        counter=$((counter + 1))
        if [ $counter -ge 60 ]; then
            echo "Error: Redis not available after 60s"
            exit 1
        fi
        sleep 1
    done
    echo "Redis ready."
fi

if [ "${RUN_MIGRATIONS:-true}" = "true" ]; then
    echo "Running database migrations..."
    bunx drizzle-kit push 2>&1 || echo "Migration warning, continuing..."
fi

echo "Starting Dumpster Backend on port ${PORT:-3200}..."
exec bun run src/index.ts
