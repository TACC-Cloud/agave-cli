#!/usr/bin/env bats

@test "Check that files-get will download a file" {
    run files-get -V -S some-system-id /file.txt
    [ $status = 0 ]

    rm file.txt
}


@test "Check that files-mkdir creates a new directory" {
    run files-mkdir -S system -N name /path
    [ $status = 0 ]
    
    echo "$output" | grep "Successfully created folder"
    [ "$?" -eq 0 ]

    files-mkdir -V -S system -N name /path | grep "success"
    [ "$?" -eq 0 ]
}


@test "Check that files-upload uploads a file" {
    echo "testfile" > file.txt
    run files-upload -V -S some-system-id -F file.txt /tests
    [ $status = 0 ]

    rm file.txt
}
