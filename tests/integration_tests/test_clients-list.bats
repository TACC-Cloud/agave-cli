#!/usr/bin/env bats

@test "clients-list lists all clients for a user" {
/usr/bin/expect <(cat <<EOF
    spawn clients-list -V 
    expect "API apiusername :"
    send "username\n"
    expect "API password:"
    send "password\n"
    interact
EOF
)
    [ "$?" -eq 0 ]
}
