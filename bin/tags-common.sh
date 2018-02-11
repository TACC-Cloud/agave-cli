#!/bin/bash
#
# tags-common.sh
#
# author: opensource@tacc.cloud
#
# URL filter for tags services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then
			hosturl="$devurl/tags/"
		else
			hosturl="$baseurl/tags/$version/"
		fi
	fi
}
