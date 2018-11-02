#!/usr/bin/env bats

@test "Check that files-list lists files on remote system" {
    run files-list agave://system/path
    [ $status = 0 ]
    [ "${lines[0]}" == "./         .slurm/    rpmbuild/  " ]
}
