#!/bin/bash
#
# runner.sh
#
# author: dooley@tacc.utexas.edu
#
# Main processing logic for the scripts
#set -x
# Run it {{{

# Uncomment this line if the script requires root privileges.
# [[ $UID -ne 0 ]] && die "You need to be root to run this script"

# use the cached credentials if available
if [ "$disable_cache" -ne 1 ] && [ -z "$access_token" ]; then # user did not specify an access_token as an argument
	tokenstore=$(kvget current)
	if [ -n "$tokenstore" ]; then
		jsonval apisecret "${tokenstore}" "apisecret"
		jsonval apikey "${tokenstore}" "apikey"
		jsonval username "${tokenstore}" "username"
		jsonval access_token "${tokenstore}" "access_token"
		jsonval refresh_token "${tokenstore}" "refresh_token"

		# Mechanism to auto-refresh expired bearer tokens
		if [ -n "$refresh_token" ]; then
			#jsonval created_at "${tokenstore}" "created_at"
			#jsonval expires_in "${tokenstore}" "expires_in"
			# next line sh
			if [ $(get_token_remaining_time)  -lt  60 ]; then
				echo "Token has expired. Automatically refreshing..."
				auto_auth_refresh
				jsonval access_token "$(kvget current)" "access_token"
				jsonval refresh_token "$(kvget current)" "refresh_token"
			fi
		fi
	fi
fi

if [ -z "$access_token" ]; then
	interactive=1
fi

if ((interactive)); then
  prompt_options
fi

# Adjust the service url for development
filter_service_url

# Force a trailing slash if they didn't specify one in the custom url
hosturl=${hosturl%/}
hosturl="$hosturl/"

# Delegate logic from the `main` function
authheader=$(get_auth_header)
main

# This has to be run last not to rollback changes we've made.
safe_exit

# }}}
