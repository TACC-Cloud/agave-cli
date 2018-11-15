#!/usr/bin/env bats

@test "clients-list lists all clients for a user" {
/usr/bin/expect <(cat <<EOF
    spawn clients-list
    expect "API password:"
    send "password\n"
    interact
EOF
)
    [ "$?" -eq 0 ]
}

@test "clients-create -D 'name' -N 'description' creates an Oauth client" {
/usr/bin/expect <(cat <<EOF
    spawn clients-create -V -D "client_name" -N "description"
    expect "API apiusername :"
    send "username\n"
    expect "API password:"
    send "password\n"
    interact
EOF
) | grep "success"
    [ "$?" -eq 0 ]
}

@test "clients-delete 'name' deletes an Oauth client" {
/usr/bin/expect <(cat <<EOF
    spawn clients-delete "client_name"
    expect "API password:"
    send "password\n"
    interact
EOF
)
    [ "$?" -eq 0 ]
}

@test "clients-subscriptions-update subscribes the current client to an api" {
/usr/bin/expect <(cat <<EOF
    spawn clients-subscriptions-update -a PublicKeys -r v2 -p admin
    expect "API password:"
    send "password\n"
    interact
EOF
)
    [ "$?" -eq 0 ]
}

@test "clients-subscriptions-list lists the client's subscriptions" {
/usr/bin/expect <(cat <<EOF
    spawn clients-subscriptions-list
    expect "API password:"
    send "password\n"
    interact
EOF
)
    [ "$?" -eq 0 ]
}
