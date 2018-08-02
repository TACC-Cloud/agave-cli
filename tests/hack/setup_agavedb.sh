#!/usr/bin/env bash


mkdir -p ~/.agave                                                             

echo '{"tenantid":"sd2e","baseurl":"","devurl":"","apisecret":"xxx","apikey":"xxx","username":"xxx","access_token":"xxx","refresh_token":"xxx","created_at":"1533215424","expires_in":"14400",         "expires_at":"Thu Aug  2 12:10:24 CDT 2018"}' | jq '.baseurl = "https://localhost:5000"' > ~/.agave/current
