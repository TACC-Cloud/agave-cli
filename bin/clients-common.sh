#!/bin/bash
#
# clients-common.sh
#
# author: opensource@tacc.cloud
#
# URL filter for client registration services
#

filter_service_url() {
	if [[ -z $hosturl ]]; then
		if ((development)); then
			hosturl="$devurl/clients/v2"
		else
			hosturl="$baseurl/clients/v2"
		fi
	fi
}
