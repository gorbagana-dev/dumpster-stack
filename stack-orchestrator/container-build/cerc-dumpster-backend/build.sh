#!/usr/bin/env bash
source ${CERC_CONTAINER_BASE_DIR}/build-base.sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

docker build -t cerc/dumpster-backend-base:local \
    ${build_command_args} \
    -f ${SCRIPT_DIR}/Dockerfile.base \
    ${CERC_REPO_BASE_DIR}/dumpster-backend

if [[ $? -ne 0 ]]; then
    echo "FATAL: Base container build failed"
    exit 1
fi

docker build -t cerc/dumpster-backend:local \
    ${build_command_args} \
    -f ${SCRIPT_DIR}/Dockerfile \
    ${SCRIPT_DIR}
