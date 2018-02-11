#!/bin/bash
# 
# requestbin-common.sh
# 
# author: opensource@tacc.cloud
#
# URL filter for requestbin services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then 
			hosturl="https://requestbin.agaveapi.co/"
		else
			hosturl="https://requestbin.agaveapi.co/"
		fi
	fi
}

