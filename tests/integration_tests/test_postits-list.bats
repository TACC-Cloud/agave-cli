#!/usr/bin/env bats

@test "postits-list lists all active postits" {
/usr/bin/expect <(cat <<EOF
    spawn postits-list -V
    expect "Access token :"
    send "xxxx\n"
    interact
EOF
) | grep "success"
    [ "$?" -eq 0 ]
}
