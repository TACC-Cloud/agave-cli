#!/bin/bash
# 
# requestbin-common.sh
# 
# author: dooley@tacc.utexas.edu
#
# URL filter for requestbin services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then 
			hosturl="http://requestbin.agaveapi.co/"
		else
			hosturl="http://requestbin.agaveapi.co/"
		fi
	fi
}

