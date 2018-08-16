#!/usr/bin/env bats

@test "Check that files-get will download a file" {
    run files-get -V -S some-system-id /file.txt
    [ $status = 0 ]

    rm file.txt
}

@test "Check that files-upload uploads a file" {
    echo "testfile" > file.txt
    run files-upload -V -S some-system-id -F file.txt /tests
    [ $status = 0 ]

    rm file.txt
}
