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
			hosturl="http://localhost/auth-v2"
		else
			hosturl="$baseurl/auth"
		fi
	fi
	
	hosturl=${hosturl}
}

