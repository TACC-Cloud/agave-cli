#!/usr/bin/env bats

@test "Check that 'tenants-list' will list available tenants" {
    run tenants-list
    [ $status = 0 ]
    [ "${lines[0]}" = "3dem" ]
}

@test "Check that 'tenants-list' will error out if API is unavailable" {
    export AGAVE_TENANTS_API_BASEURL="https://site.is.down"
    run tenants-list
    [ $status = 1 ]
    unset AGAVE_TENANTS_API_BASEURL
}
