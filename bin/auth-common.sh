#!/bin/bash
# 
# auth-common.sh
# 
# author: dooley@tacc.utexas.edu
#
# URL filter for auth services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then 
			hosturl="$devurl/auth-v1"
		else
			hosturl="$baseurl/auth"
		fi
	fi
	
	hosturl=${hosturl%/}
}

