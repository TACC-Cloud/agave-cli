#!/usr/bin/env bats

@test "apps-list lists all apps for a user" {
/usr/bin/expect <(cat <<EOF
    spawn apps-list -V
    expect "Access token :"
    send "xxxx\n"
    interact
EOF
) | grep "success"
    [ "$?" -eq 0 ]
}
