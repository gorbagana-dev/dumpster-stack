#!/bin/sh
set -e

if [ -n "$CERC_SCRIPT_DEBUG" ]; then
    set -x
fi

# Remove stale lock file from previous unclean shutdown.
# We are the only process in this container — if the lock exists at
# boot, it's stale by definition.
rm -f "$IPFS_PATH/repo.lock"

# Initialize kubo if not already done
if [ ! -f "$IPFS_PATH/config" ]; then
    echo "Initializing kubo..."
    ipfs init --profile=server

    # Configure S3 datastore for R2 if credentials are provided
    if [ -n "$R2_IPFS_BUCKET" ] && [ -n "$R2_ACCOUNT_ID" ]; then
        echo "Configuring R2-backed datastore..."
        jq \
          --arg endpoint "https://${R2_ACCOUNT_ID}.r2.cloudflarestorage.com" \
          --arg bucket "$R2_IPFS_BUCKET" \
          '.Datastore.Spec = {
            "mounts": [
              {
                "child": {
                  "type": "s3ds",
                  "region": "auto",
                  "bucket": $bucket,
                  "rootDirectory": "blocks",
                  "regionEndpoint": $endpoint,
                  "accessKey": "",
                  "secretKey": "",
                  "workers": 8
                },
                "mountpoint": "/blocks",
                "prefix": "s3.datastore",
                "type": "measure"
              },
              {
                "child": {
                  "compression": "none",
                  "path": "datastore",
                  "type": "levelds"
                },
                "mountpoint": "/",
                "prefix": "leveldb.datastore",
                "type": "measure"
              }
            ],
            "type": "mount"
          }' \
          "$IPFS_PATH/config" > "$IPFS_PATH/config.tmp" && \
          mv "$IPFS_PATH/config.tmp" "$IPFS_PATH/config"

        # Regenerate datastore_spec from the modified config.
        # ipfs daemon requires datastore_spec to match Datastore.Spec in config.
        # The spec format strips internal fields (child, prefix, compression,
        # workers, etc.) — only keeps mountpoint, path, type, and s3-specific
        # fields (bucket, region, rootDirectory).
        jq -c '.Datastore.Spec | .mounts = [.mounts[] | {
          mountpoint,
          type: (if .child.type == "s3ds" then null else .child.type end),
          path: .child.path,
          bucket: .child.bucket,
          region: .child.region,
          rootDirectory: .child.rootDirectory
        } | with_entries(select(.value != null))]' \
          "$IPFS_PATH/config" > "$IPFS_PATH/datastore_spec"
        echo "R2 datastore configured: bucket=$R2_IPFS_BUCKET"
    else
        echo "WARNING: R2 credentials not set, using local storage only"
    fi
fi

echo "Starting kubo daemon..."
exec ipfs daemon --migrate
