#!/usr/bin/env bats

setup() {
    export AGAVE_CACHE_DIR=".tenants_init_cache_dir"
}

teardown() {
    unset AGAVE_CACHE_DIR
}

@test "Check that 'tenants-init' will error out if API is unavailable" {
    export AGAVE_TENANTS_API_BASEURL="https://site.is.down"
    run tenants-init -t sd2e
    [ $status = 1 ]
    unset AGAVE_TENANTS_API_BASEURL
}

@test "Check that 'tenants-init' will set tenant to 'sd2e' and create current cache file" {
    run tenants-init -t sd2e
    [ $status = 0 ]
    [ -e "${AGAVE_CACHE_DIR}/current" ]
    tenant=$(jq .tenantid ${AGAVE_CACHE_DIR}/current | tr -d '"')
    [ "$tenant" == "sd2e" ]
}

@test "Check that 'tenants-init -b' will set tenant to 'iplantc.org' and create backup cache file" {
    run tenants-init -t iplantc.org -b
    [ $status = 0 ]
    [ -e "${AGAVE_CACHE_DIR}/current" ]
    tenant=$(jq .tenantid ${AGAVE_CACHE_DIR}/current | tr -d '"')
    [ -e "${AGAVE_CACHE_DIR}/backup" ]
    backup=$(jq .tenantid ${AGAVE_CACHE_DIR}/backup | tr -d '"')
    [ "$tenant" == "iplantc.org" ]
    [ "$backup" == "sd2e" ]
}

@test "Check that 'tenants-init -s' will set tenant to 'sd2e' and backup to 'iplantc.org'" {
    run tenants-init -s
    [ $status = 1 ]
    tenant=$(jq .tenantid ${AGAVE_CACHE_DIR}/current | tr -d '"')
    backup=$(jq .tenantid ${AGAVE_CACHE_DIR}/backup | tr -d '"')
    [ "$tenant" == "sd2e" ]
    [ "$backup" == "iplantc.org" ]
}

@test "Check that 'tenants-init -r' will set tenant to 'iplantc.org' and delete backup cache file" {
    run tenants-init -r
    [ $status = 1 ]
    [ -e "${AGAVE_CACHE_DIR}/current" ]
    tenant=$(jq .tenantid ${AGAVE_CACHE_DIR}/current | tr -d '"')
    [ "$tenant" == "iplantc.org" ]
    [ ! -e "${AGAVE_CACHE_DIR}/backup" ]
    rm -rf ${AGAVE_CACHE_DIR}
}
