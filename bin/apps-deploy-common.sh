#!/bin/bash
#
# apps-deploy-common.sh
#
# author: vaughn@tacc.utexas.edu
#

if [[ -z "$DIR" ]]; then
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

# Command build on apps-deploy leverages multiple external dependencies:
# Return an error if essentials are missing!
check_dependencies

cliauthopt=
if [ ! -z "$auth_token" ]; then
    cliauthopt="-z $auth_token"
fi

function filter_service_url() {
    true
}

function prompt_options() {
    # We don't support interactive mode
    true
}

## TODO: not sure what to do with this yet.
# Import auth functions for Docker registry
#  - Allows the *deploy* apps to use the
#    registry keystore
#source ${DIR}/taccreg-auth.sh
