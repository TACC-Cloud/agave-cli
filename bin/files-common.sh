#!/bin/bash
# 
# files-common.sh
# 
# author: dooley@tacc.utexas.edu
#
# URL filter for file services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then 
			hosturl="$devurl/io-v1/files/"
		else
			hosturl="$baseurl/files/"
		fi
	fi
}

