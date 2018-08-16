#!/usr/bin/env bats

@test "Check that files-get will download a file" {
    run files-get -V -S some-system-id /file.txt
    [ $status = 0 ]

    rm file.txt
}
