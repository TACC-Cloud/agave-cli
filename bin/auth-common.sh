#!/bin/bash
# 
# auth-common.sh
# 
# author: opensource@tacc.cloud
#
# URL filter for auth services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then 
			hosturl="${devurl}"
		else
			hosturl="${baseurl}"
		fi
	fi
	
	hosturl="${hosturl%/}"
}

