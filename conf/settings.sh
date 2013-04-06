#!/bin/bash
# This file contains configuration properties for interacting with the iPlant Foundation API.
# For use with other Agave instances, simply change the API base and user authentication
# values.

# order of checking for credentials should be
# 1. $HOME/.fapi
# 2. environment
# 3. this file
# 4. prompt

API_BASE_URL=https://foundation.iplantcollaborative.org
API_USERNAME=
API_PASSWORD=
API_TOKEN=
#API_KEY=
#API_SECRET=

# Do not edit the values below this line
API_VERSION=1

if [ -z $API_USERNAME ]; then
	if [ -z $IPLANT_USERNAME ]; then
		read -p "Please enter your iPlant username:" API_USERNAME
	else
		API_USERNAME=$IPLANT_USERNAME;
	fi
fi

if [ -z $API_PASSWORD ]; then
	if [ -z $IPLANT_PASSWORD ]; then
		read -p "Please enter your iPlant username:" API_USERNAME
	else
		API_PASSWORD=$IPLANT_PASSWORD;
	fi
fi
