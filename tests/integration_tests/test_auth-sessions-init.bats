#!/usr/bin/env bats

@test "Check auth-sessions-init -t <bad tenant> fails gracefully" {
    run auth-session-init --tenants http://localhost:5000/tenants -t abc
    [ $status = 1 ]
}
