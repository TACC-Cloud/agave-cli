#!/bin/bash
#
# monitors-common.sh
#
# author: opensource@tacc.cloud
#
# URL filter for monitors services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then
			hosturl="$devurl/monitors/"
		else
			hosturl="$baseurl/monitors/$version/"
		fi
	fi
}
