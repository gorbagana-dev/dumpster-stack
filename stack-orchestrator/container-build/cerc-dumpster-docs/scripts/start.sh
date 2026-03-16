#!/usr/bin/env sh
set -e

if [ -n "$CERC_SCRIPT_DEBUG" ]; then
    set -x
fi

echo "Dumpster Docs starting..."
echo "Starting Next.js on port ${PORT:-3100}..."

exec npm run start -- -p "${PORT:-3100}" -H 0.0.0.0
