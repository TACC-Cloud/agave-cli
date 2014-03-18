#!/bin/bash
# 
# common.sh
# 
# author: dooley@tacc.utexas.edu
#
# Common helper functions and global variables for all cli scripts.
# A lot of this is based on options.bash by Daniel Mills.
# @see https://github.com/e36freak/tools/blob/master/options.bash


# Preamble {{{

# Exit immediately on error
#set -e -x

# Detect whether output is piped or not.
[[ -t 1 ]] && piped=0 || piped=1

# versioning info
version="v2"
revision="${version}-r$(head -c 5 $DIR/../.git/refs/heads/master)"

os=`uname -s`;

# Defaults
force=0
quiet=0
verbose=0
veryverbose=0
interactive=0
development=0
baseurl="https://agave.iplantc.org"
devurl="http://localhost:8080"
tenantid="iplantc-org"
disable_cache=0 # set to 1 to prevent using auth cache.
args=()

# }}}
# Helpers {{{

out() {
  ((quiet)) && return

  local message="$@"
  #if ((piped)); then
  #  message=$(echo $message | sed '
  #    s/\\[0-9]\{3\}\[[0-9]\(;[0-9]\{2\}\)\?m//g;
  #    #s/✖/Error:/g;
  #    #s/✔/Success:/g;
  #  ')
  #fie
  printf '%b\n' "$message";
}
die() { out "$@"; exit 1; } >&2
err() { 
	if [[ -n $(ishtmlstring "$response") ]]; then 
		jsonresponsemessage="{\"status\":\"error\",\"message\":\"Unable to contact api server\",\"result\":null}"
		response=`echo $jsonresponsemessage | python -mjson.tool`
	elif [[ -n $(isxmlstring "$response") ]]; then
		#response=`echo "$response" | xmllint --format -`
		responsemessage=${1#*<ams:message>}
		responsemessage=${responsemessage%</ams:message>*}
		jsonresponsemessage="{\"status\":\"error\",\"message\":\"${responsemessage}\",\"result\":null}"
		response=`echo "$jsonresponsemessage" | python -mjson.tool`
	fi
	
	if (($verbose)); then 
		#out " \033[1;31m✖\033[0m  $response"
		out "\033[1;31m${response}\033[0m"
	else
		#out " \033[1;31m✖\033[0m  $@"; 
		out "\033[1;31m$@\033[0m"
	fi
} >&2
	
success() { 
	#out " \033[1;32m✔\033[0m  $@"; 
	out "\033[1;0m$@\033[0m"; 
	#out "$@"
}

version() {
	out "iPlant Agave API v${version}
Agave client command line interface (revision ${revision})
"
}

copyright() {
	out "Copyright (c) 2013, Texas Advanced Computing Center
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of the University of Texas at Austin nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS AS IS
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
"
}

disclaimer() {
	out "Documentation on the Agave API, client libaries, and developer tools is
available online at the Agave Developer Portal, http://agaveapi.co. For
localized help of the various CLI commands, run any command with the -h 
or --help option.
"
}

# Verbose logging
log() { (($verbose)) && out "$@"; }

# Notify on function success
notify() { [[ $? == 0 ]] && success "$@" || err "$@"; }

# Escape a string
escape() { echo $@ | sed 's/\//\\\//g'; }

# Unless force is used, confirm with user
confirm() {
  (($force)) && return 1;

  read -p "$1 [Y/n] " -n 1;
  [[ $REPLY =~ ^[Yy]$ ]];
}

# Set a trap for cleaning up in case of errors or when script exits.
rollback() {
	stty echo
	die
}

function jsonval {
	local __resultvar=$1
	local __temp=`echo "$2" | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $3| cut -d":" -f2| sed -e 's/^ *//g' -e 's/ *$//g'`
	eval $__resultvar=`echo '${__temp##*|}'`
}

function ishtmlstring {
	firstelement=${1:0:5}
	if [[ "$firstelement" = "<html" ]]; then
		echo 1
	fi
}

function isxmlstring {
	firstcharacter=${1:0:1}
	if [[ "$firstcharacter" = "<" ]]; then
		echo 1
	fi
}

function jsonquery {

	if [[ -n $(ishtmlstring $1) ]]; then 
		if [[ "$2" = "message" ]]; then 
			echo "Unable to contact api server"
		fi
	elif [[ -n $(isxmlstring $1) ]]; then
		if [[ "$2" = "message" ]]; then 
			responsemessage=${1#*<ams:message>}
			responsemessage=${responsemessage%</ams:message>*}
			echo $responsemessage
		fi
	else
		oIFS="$IFS"
		IFS="."
		declare -a fields=($2)
		IFS="$oIFS"
		unset oIFS
		#printf "> [%s]\n" "${fields[@]}"
	
		re='^[0-9]+$'
	
		for x in "${fields[@]}"; do
			if [ "$x" == '\*' ]; then
				patharray=${patharray}',"[^"]*"'
				escpatharray=${escpatharray}',*'
				#echo $patharray"\\n"
			elif [[ $x = '[]' ]]; then
				patharray=${patharray}',[0-9]+'
				escpatharray=${escpatharray}',[0-9]*'
			elif [[ $x =~ $re ]] ; then
				patharray=${patharray}','$x
				escpatharray=${escpatharray}','$x
				#echo $patharray"\\n"
			else
				patharray=${patharray}',"'$x'"'
				escpatharray=${escpatharray}',\"'$x'\"'
				#echo $patharray"\\n"
			fi
		done

		patharray="${patharray:1:${#patharray}-1}"
		escpatharray="${escpatharray:1:${#escpatharray}-1}"
	
		patharray='\['${patharray}'\]'
		escpatharray='\['${escpatharray}'\]'
	
		if [ -z "$3" ]; then
			echo "$1" | $DIR/json.sh -p | egrep "$patharray" | sed s/"$escpatharray"//g | sed 's/^[ \t]*//g' | sed s/\"//g
		else
			# third argument says to leave the response quoted
			echo "$1" | $DIR/json.sh -p | egrep "$patharray" | sed s/"$escpatharray"//g 
		fi
		unset patharray
		unset escpatharray
	fi
}

# }}}

# Boilerplate {{{

# Prompt the user to interactively enter desired variable values. 
prompt_options() {
  local desc=
  local val=
  if [ -f "$HOME/.agave" ]; then
	  tokenstore=`cat $HOME/.agave`
  fi
  
  for val in ${interactive_opts[@]}; do
  	
	# Skip values which already are defined
    [[ $(eval echo "\$$val") ]] && continue

    # Parse the usage description for spefic option longname.
    desc=$(usage | awk -v val=$val -v os=$os '
      BEGIN {
        # Separate rows at option definitions and begin line right before
        # longname.
        RS="\n +-([a-zA-Z0-9], )|-";
        ORS=" ";
      }
      NR > 3 {
        # Check if the option longname equals the value requested and passed
        # into awk. Adjust for bsd awk vs gnu awk
        newval="--" val;
        # print os " " $2 " = " newval "\n"
        if ( os == "Darwin" ) {
        	
        	if ($2 == newval) {
        		# Print all remaining fields, ie. the description.
				for (i=3; i <= NF; i++) print $i
        	} 
        } else {        	
			if ($1 == val) {
				# Print all remaining fields, ie. the description.
				for (i=2; i <= NF; i++) print $i
			}
		}
      }
    ')
    
    [[ ! "$desc" ]] && continue

	#echo -n "$desc: "
	
    # In case this is a password field, hide the user input
    if [[ $val == "apikey" ]]; then
    	jsonval savedapikey "${tokenstore}" "apikey" 
		echo -n "API key [$savedapikey]: "
      	eval "read $val"
      	if  [[ -z $apikey ]]; then 
      		apikey=$savedapikey
      	fi
      	#stty -echo; read apikey; stty echo
      	#echo
    elif [[ $val == "refresh_token" ]]; then
    	jsonval savedrefreshtoken "${tokenstore}" "refresh_token" 
		echo -n "Refresh token [$savedrefreshtoken]: "
      	eval "read $val"
      	if  [[ -z $refresh_token ]]; then 
      		refresh_token=$savedrefreshtoken
      	fi
      	#stty -echo; read apikey; stty echo
      	#echo
    elif [[ $val == "apisecret" ]]; then
    	jsonval savedapisecret "${tokenstore}" "apisecret" 
		echo -n "API secret [$savedapisecret]: "
    	eval "read $val"
      	if  [[ -z $apisecret ]]; then 
      		apisecret=$savedapisecret
      	fi
    elif [[ $val == "username" ]]; then
    	jsonval savedusername "${tokenstore}" "username"
		echo -n "API username [$savedusername]: "	
    	eval "read $val"
    	if  [[ -z $username ]]; then 
      		username=$savedusername
      	fi
    elif [[ $val == "password" ]]; then
    	echo -n "API password: "
    	stty -echo; read password; stty echo
    	echo -n "
";
    elif [[ $val == "apipassword" ]]; then
    	echo -n "API password: "
    	stty -echo; read apipassword; stty echo
    	echo -n "
";
	# Otherwise just read the input
    else
    	echo -n "$desc: "
		eval "read $val"
    fi
  done
}

get_auth_header() {
	if [[ "$development" -ne 1 ]]; then
		echo "Authorization: Bearer $access_token"
	else
		#echo " -u \"${username}:${password}\" "
		jwtprefix="eyJ0eXAiOiJKV1QiLCJhbGciOiJTSEEyNTZ3aXRoUlNBIiwieDV0IjoiTm1KbU9HVXhNelpsWWpNMlpEUmhOVFpsWVRBMVl6ZGhaVFJpT1dFME5XSTJNMkptT1RjMVpBPT0ifQ=="
		jwtbody=`echo "{\"iss\":\"wso2.org/products/am\",\"exp\":2384481713842,\"http://wso2.org/claims/subscriber\":\"${username}\",\"http://wso2.org/claims/applicationid\":\"5\",\"http://wso2.org/claims/applicationname\":\"DefaultApplication\",\"http://wso2.org/claims/applicationtier\":\"Unlimited\",\"http://wso2.org/claims/apicontext\":\"/apps\",\"http://wso2.org/claims/version\":\"2.0\",\"http://wso2.org/claims/tier\":\"Unlimited\",\"http://wso2.org/claims/keytype\":\"PRODUCTION\",\"http://wso2.org/claims/usertype\":\"APPLICATION_USER\",\"http://wso2.org/claims/enduser\":\"${username}\",\"http://wso2.org/claims/enduserTenantId\":\"-9999\", \"http://wso2.org/claims/emailaddress\":\"${username}@test.com\", \"http://wso2.org/claims/fullname\":\"Dev User\", \"http://wso2.org/claims/givenname\":\"Dev\", \"http://wso2.org/claims/lastname\":\"User\", \"http://wso2.org/claims/primaryChallengeQuestion\":\"N/A\", \"http://wso2.org/claims/role\":\"Internal/everyone\", \"http://wso2.org/claims/title\":\"N/A\"}" | base64 -`
		jwtsuffix="FA6GZjrB6mOdpEkdIQL/p2Hcqdo2QRkg/ugBbal8wQt6DCBb1gC6wPDoAenLIOc+yDorHPAgRJeLyt2DutNrKRFv6czq1wz7008DrdLOtbT4EKI96+mXJNQuxrpuU9lDZmD4af/HJYZ7HXg3Hc05+qDJ+JdYHfxENMi54fXWrxs="
		echo "x-jwt-assertion-${tenantid}: ${jwtprefix}.${jwtbody}.${jwtsuffix}"
	fi
}

check_response_status() {
	
	if [[ "$?" -eq 22 ]]; then
		jsonresponsemessage="{\"status\":\"error\",\"message\":\"Unable to contact api server\",\"result\":null}"
		response=`echo $jsonresponsemessage | python -mjson.tool`
	else
		local __response_status=`echo "$1" | grep '^  "status" : "success"'`
		if [[ -n $__response_status ]]; then
			eval response_status="success"
		elif [[ -n $(isxmlstring $1) ]]; then
			responsemessage=${1#*<ams:message>}
			responsemessage=${responsemessage%</ams:message>*}
			jsonresponsemessage="{\"status\":\"error\",\"message\":\"${responsemessage}\",\"result\":null}"
			response=`echo "$jsonresponsemessage" | python -mjson.tool`
		else
			local __html_check=`echo "$1" | grep '^<'`
			if [[ -z $____html_check ]]; then
				local __response_status=`echo "$1" | python -mjson.tool | grep '^    "status": "success"'`
				if [[ -n $__response_status ]]; then
					eval response_status="success"
				fi
			fi
		fi
	fi
}

get_token_remaining_time() {
	
	auth_cache=`cat ~/.agave`
	
	jsonval expires_in "$auth_cache" "expires_in" 
	jsonval created_at "$auth_cache" "created_at" 
	
	expiration_time=`expr $created_at + $expires_in`
	current_time=`date +%s`
	
	time_left=`expr $expiration_time - $current_time`
	
	echo $time_left
}
# }}}