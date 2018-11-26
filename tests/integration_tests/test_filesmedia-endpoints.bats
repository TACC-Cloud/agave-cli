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


@test "Check that files-rm deletes a file" {
    run files-rm agave://system/somefile 
    [ $status = 0 ]
}


@test "Check that files-mkdir creates a new directory" {
    run files-mkdir agave://system/path/name
    [ $status = 0 ]
}


@test "Check that files-mv moves a file to a new path" {
    run files-mv agave://systemid/dest.ext agave://systemid/new/dest.ext
    [ $status = 0 ]
}
