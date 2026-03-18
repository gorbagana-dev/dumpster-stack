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
        # ipfs daemon requires datastore_spec to match Datastore.Spec exactly.
        # Kubo's on-disk format flattens each mount's .child into the mount
        # entry (adding .mountpoint), strips internal fields (prefix,
        # compression, workers, regionEndpoint, accessKey, secretKey), and
        # removes .type for s3ds mounts. Keys are sorted alphabetically.
        jq -Sc '{type: .Datastore.Spec.type, mounts: [.Datastore.Spec.mounts[] |
          {mountpoint} + (.child |
            del(.regionEndpoint, .accessKey, .secretKey, .workers, .prefix, .compression) |
            if .type == "s3ds" then del(.type) else . end
          )]}' \
          "$IPFS_PATH/config" > "$IPFS_PATH/datastore_spec"
        echo "R2 datastore configured: bucket=$R2_IPFS_BUCKET"
    else
        echo "WARNING: R2 credentials not set, using local storage only"
    fi
fi

echo "Starting kubo daemon..."
exec ipfs daemon --migrate
