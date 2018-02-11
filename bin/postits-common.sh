#!/bin/bash
# 
# postits-common.sh
# 
# author: opensource@tacc.cloud
#
# URL filter for profiles services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then 
			hosturl="$devurl/postits/"
		else
			hosturl="$baseurl/postits/$version/"
		fi
	fi
}

