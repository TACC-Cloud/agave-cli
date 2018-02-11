#!/bin/bash
# 
# apps-common.sh
# 
# author: opensource@tacc.cloud
#
# URL filter for apps services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then
			hosturl="$devurl/apps/"
		else
			hosturl="$baseurl/apps/$version/"
		fi
	fi
}

