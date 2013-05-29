#!/bin/bash
# 
# apps-common.sh
# 
# author: dooley@tacc.utexas.edu
#
# URL filter for apps services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then 
			hosturl="$devurl/apps-v1/apps/"
		else
			hosturl="$baseurl/apps/"
		fi
	fi
}

