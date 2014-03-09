#!/bin/bash
# 
# clients-common.sh
# 
# author: dooley@tacc.utexas.edu
#
# URL filter for client registration services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then 
			hosturl="$devurl/clients"
		else
			hosturl="$baseurl/clients"
		fi
	fi
}

