#!/bin/sh
set -e
rm -f "$IPFS_PATH/repo.lock"
exec ipfs daemon --migrate
