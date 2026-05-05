#!/usr/bin/env bash
source ${CERC_CONTAINER_BASE_DIR}/build-base.sh

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

docker build -t gorbagana-dev/dumpster-db:local \
    ${build_command_args} \
    -f ${SCRIPT_DIR}/Dockerfile \
    ${SCRIPT_DIR}
