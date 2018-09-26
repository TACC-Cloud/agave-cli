#!/usr/bin/env bash

# Imports shell functions from an HTTP URL that extend the local Agave
# app runtime with new functions.
#
# Current complement includes:
#
#    container_exec IMAGE COMMAND PARAMS - emulate docker run under
#        singularity and implement namespacing and resource limits w docker
#
#    auto_maxthreads - returns CPU count -1 in a platform-agnostic manner
#
#    die MESSAGE - write error to stdout, trips agave failure callback, exits w 1
#    log MESSAGE - create a simple logging message in stdout
#    utc_date - returns a UTC ISO8601 date stamp

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
curl -skL -o "${DIR}/extend-runtime.sh" \
    "https://raw.githubusercontent.com/sd2e/sd2e-cli/master/sd2e-cloud-cli/bin/libs/agave-app-runtime-extensions.sh" && \
source "${DIR}/extend-runtime.sh"
