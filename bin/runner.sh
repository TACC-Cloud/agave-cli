#!/bin/bash
# 
# runner.sh
# 
# author: dooley@tacc.utexas.edu
#
# Main processing logic for the scripts

# Run it {{{

# Uncomment this line if the script requires root privileges.
# [[ $UID -ne 0 ]] && die "You need to be root to run this script"

# If either credential is missing, force interactive login
if [ -n "$apikey" ]; then
	#echo "apikey '$apikey' is not null"
	interactive=1
elif [ -n "$apisecret" ]; then
	#echo "apisecret '$apisecret' is not null"
	interactive=1
else
	#echo "Loooking for stored credentials"
	# Otherwise use the cached credentials if available
	if [ "$disable_cache" -ne 1 ]; then
		if [ -f "$HOME/.agave" ]; then
			#echo "Found for stored credentials"
			tokenstore=`cat $HOME/.agave`
			jsonval apisecret "${tokenstore}" "apisecret" 
			jsonval apikey "${tokenstore}" "apikey" 
			#echo "Using $apisecret $apikey"
		fi
	fi
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
main

# This has to be run last not to rollback changes we've made.
safe_exit

# }}}
