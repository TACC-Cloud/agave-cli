#!/usr/bin/env bats


setup() {
    export AGAVE_CACHE_DIR=".tenants_init_cache_dir"
}

teardown() {
    unset AGAVE_CACHE_DIR
}


@test "Check that 'tenants-list' will list available tenants" {
    run tenants-list
    [ $status = 0 ]
}


@test "Check that 'tenants-list' will error out if API is unavailable" {
    run tenants-list -H https://site.is.down
    [ $status = 1 ]
}


@test "Check that 'tenants-init' will error out if unexistent tenant is choosen" {
    run tenants-init -t sd
    [ $status = 1 ]
}

@test "Check that 'tenants-init' will set tenant to 'sd2e' and create current cache file" {
    run tenants-init -t sd2e -c ${AGAVE_CACHE_DIR}
    [ $status = 0 ]
    [ -e "${AGAVE_CACHE_DIR}/current" ]
    tenant=$(jq .tenantid ${AGAVE_CACHE_DIR}/current | tr -d '"')
    [ "$tenant" == "sd2e" ]
}
