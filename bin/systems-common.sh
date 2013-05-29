#!/bin/bash
# 
# systems-common.sh
# 
# author: dooley@tacc.utexas.edu
#
# URL filter for systems services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then 
			hosturl="$devurl/apps-v1/systems/"
		else
			hosturl="$baseurl/systems/"
		fi
	fi
}

