#!/usr/bin/env sh
set -e

if [ -n "$CERC_SCRIPT_DEBUG" ]; then
    set -x
fi

echo "Dumpster Frontend starting..."
echo "Starting Next.js on port ${PORT:-3000}..."

exec npm run start -- -p "${PORT:-3000}" -H 0.0.0.0
