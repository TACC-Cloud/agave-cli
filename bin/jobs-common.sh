#!/bin/bash
# 
# jobs-common.sh
# 
# author: dooley@tacc.utexas.edu
#
# URL filter for jobs services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then 
			hosturl="$devurl/apps-v1/jobs/"
		else
			hosturl="$baseurl/jobs/"
		fi
	fi
}

