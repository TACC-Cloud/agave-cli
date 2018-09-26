# agave-common.sh
#
# Utility functions (with cacheing) for working with the Agave API

if [[ -z "$DIR" ]]; then
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

AGAVE_USERNAME=${AGAVE_USERNAME}
function get_agave_username(){

    if [ ! -z "$AGAVE_USERNAME" ]; then
        printf "$AGAVE_USERNAME"
    else
        AGAVE_USERNAME=$(${DIR}/auth-check -v -v me | jq -r .username)
        printf "$AGAVE_USERNAME"
        export AGAVE_USERNAME
    fi
}



AGAVE_HUMAN_NAME=${AGAVE_HUMAN_NAME}
function get_agave_human_name() {

    if [ ! -z "$AGAVE_HUMAN_NAME" ]; then
        printf "$AGAVE_HUMAN_NAME"
    else
        AGAVE_HUMAN_NAME=$(${DIR}/profiles-list -v me | jq -r '"\(.first_name) \(.last_name)"')
        printf $AGAVE_HUMAN_NAME
        export AGAVE_HUMAN_NAME
    fi
}

AGAVE_EMAIL=${AGAVE_EMAIL}
function get_agave_email() {

    if [ ! -z "$AGAVE_EMAIL" ]; then
        printf "$AGAVE_EMAIL"
    else
        AGAVE_EMAIL=$(${DIR}/profiles-list -v me | jq -r .email)
        printf $AGAVE_EMAIL
        export AGAVE_EMAIL
    fi
}

TENANT_GLOBAL_CONFIG_FILE=
function get_tenant_config(){
    # The CLI ships with a global config that can be used to set globals
    if [ ! -z "$TENANT_GLOBAL_CONFIG_FILE" ]; then
        printf "$TENANT_GLOBAL_CONFIG_FILE"
    else
        TENANT_GLOBAL_CONFIG_FILE=${DIR}/../etc/tenants.d/$(get_agave_tenant)/config.rc
        if [ -f "${TENANT_GLOBAL_CONFIG_FILE}" ]; then
            printf $TENANT_GLOBAL_CONFIG_FILE
            export TENANT_GLOBAL_CONFIG_FILE
        fi
    fi
}
