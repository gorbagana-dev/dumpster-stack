#!/usr/bin/env bash
source ${CERC_CONTAINER_BASE_DIR}/build-base.sh

# Reuse the Dockerfiles from the dumpster-docs repo so this build
# matches what CI publishes to GHCR. Avoids drift between local and
# published images.

docker build -t gorbagana-dev/dumpster-docs-base:local \
    ${build_command_args} \
    -f ${CERC_REPO_BASE_DIR}/dumpster-docs/docker/Dockerfile.base \
    ${CERC_REPO_BASE_DIR}/dumpster-docs

if [[ $? -ne 0 ]]; then
    echo "FATAL: Base container build failed"
    exit 1
fi

docker build -t gorbagana-dev/dumpster-docs:local \
    ${build_command_args} \
    -f ${CERC_REPO_BASE_DIR}/dumpster-docs/docker/Dockerfile \
    ${CERC_REPO_BASE_DIR}/dumpster-docs/docker
