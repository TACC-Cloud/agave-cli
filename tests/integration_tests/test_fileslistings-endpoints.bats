#!/usr/bin/env bats

@test "Check that files-list lists files on remote system" {
    run files-list -S some-system-id /path
    [ $status = 0 ]
    [ "${lines[0]}" == "." ]
    [ "${lines[1]}" == ".slurm" ]
    [ "${lines[2]}" == "rpmbuild" ]
}
