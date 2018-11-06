#!/usr/bin/env bats


@test "Check that files-cp copies a file on a remote system" {
    run files-cp agave://sytemid/original agave://systemid/copy
    [ $status = 0 ]
}


@test "Check that files-cp will download a file" {
    run files-cp agave://some-system-id/file.txt file.txt
    [ $status = 0 ]

    rm file.txt
}


@test "Check that files-cp uploads a file" {
    echo "testfile" > file.txt
    run files-cp file.txt agave://system/file.txt
    [ $status = 0 ]

    rm file.txt
}


@test "Check that files-delete deletes a file" {
    run files-delete -S system somefile 
    [ $status = 0 ]
}


@test "Check that files-mkdir creates a new directory" {
    run files-mkdir -S system -N name /path
    [ $status = 0 ]
    
    echo "$output" | grep "Successfully created folder"
    [ "$?" -eq 0 ]

    files-mkdir -V -S system -N name /path | grep "success"
    [ "$?" -eq 0 ]
}


@test "Check that files-move moves a file to a new path" {
    run files-move -S systemid -D new/dest.ext dest.ext
    [ $status = 0 ]
}
