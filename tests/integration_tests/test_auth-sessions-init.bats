#!/usr/bin/env bats

@test "Check auth-sessions-init -t tenant -u username -N client restores a session" {
    run auth-session-init -t sd2e -u xxx -N client-name
    [ $status = 0 ]
}
