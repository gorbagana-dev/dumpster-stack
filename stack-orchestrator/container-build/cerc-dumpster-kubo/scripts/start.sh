#!/bin/sh
set -e
rm -f "$IPFS_PATH/repo.lock"

# Inject R2/S3 credentials into ipfs datastore config.
# The go-ds-s3 plugin reads credentials from the ipfs config file,
# not from environment variables.
if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
  ipfs config --json Datastore.Spec.mounts "$(
    ipfs config --json Datastore.Spec.mounts | \
    sed "s|\"accessKey\": \"[^\"]*\"|\"accessKey\": \"$AWS_ACCESS_KEY_ID\"|" | \
    sed "s|\"secretKey\": \"[^\"]*\"|\"secretKey\": \"$AWS_SECRET_ACCESS_KEY\"|"
  )"
  echo "Injected S3 credentials into ipfs datastore config"
fi

exec ipfs daemon --migrate
