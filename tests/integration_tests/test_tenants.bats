#!/usr/bin/env bats

@test "Check that 'tenants-list' will list available tenants" {
    run tenants-list
    [ $status = 0 ]
}

@test "Check that 'tenants-list' will error out if API is unavailable" {
    run tenants-list -H https://site.is.down
    [ $status = 1 ]
}
