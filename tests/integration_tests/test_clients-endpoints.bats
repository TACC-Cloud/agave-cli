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
) | grep "success"
    [ "$?" -eq 0 ]
}

@test "clients-create -D 'name' -N 'description' creates an Oauth client" {
/usr/bin/expect <(cat <<EOF
    spawn clients-create -V -D name -N "description"
    expect "API apiusername :"
    send "username\n"
    expect "API password:"
    send "password\n"
    interact
EOF
) | grep "success"
    [ "$?" -eq 0 ]
}
