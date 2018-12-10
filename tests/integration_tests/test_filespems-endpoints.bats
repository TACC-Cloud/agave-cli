#!/usr/bin/env bats


@test "Check that files-pems-list lists all permissions of uri" {
    run files-pems-list agave://systemid/path
    [ $status = 0 ]
}
