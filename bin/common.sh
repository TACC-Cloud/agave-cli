#!/bin/bash
#
# common.sh
#
# author: dooley@tacc.utexas.edu
#
# Common helper functions and global variables for all cli scripts.
# A lot of this is based on options.bash by Daniel Mills.
# @see https://github.com/e36freak/tools/blob/master/options.bash

# add keyvalue support
source $DIR/kv-bash

# update the old cache to the new key-value format if present
if [ -f "$HOME/.agave" ]; then
  oldcache=$(cat $HOME/.agave)
  rm $HOME/.agave
  mkdir $HOME/.agave
  kvset current "$oldcache"
fi

# Preamble {{{

# Exit immediately on error
#set -e -x

# Detect whether output is piped or not.
[[ -t 1 ]] && piped=0 || piped=1

# versioning info
version="v2"
release="2.1.4"
if [ -e "$DIR/../.git/refs/heads/master" ];
then
  revision="${version}-r$(head -c 5 $DIR/../.git/refs/heads/master)"
else
  revision="${version}"
fi

os=`uname -s`;

# Defaults
force=0
quiet=0
verbose=0
veryverbose=0
interactive=0
development=0

disable_cache=0 # set to 1 to prevent using auth cache.
args=()

# Configure which json parser to use
if [[ -z "$AGAVE_JSON_PARSER" ]]; then
	# If no parser is specified, look for python in the local path
	# and fall back on the native json.sh implementation.
	if hash python 2>/dev/null; then
		AGAVE_JSON_PARSER='python'
	else
		AGAVE_JSON_PARSER='native'
	fi
fi

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

	else

		response=$@

	fi

  	if (($verbose)); then
		if ((piped)); then
      		out "${response}"
    	else
      		#out " \033[1;31m✖\033[0m  $response"
		  	out "\033[1;31m${response}\033[0m"
    	fi
	else
		if ((piped)); then
      		out "$@"
    	else
      		#out " \033[1;31m✖\033[0m  $@";
		  	out "\033[1;31m$@\033[0m"
    	fi
	fi

	exit 1;

} >&2

success() {
	#out " \033[1;32m✔\033[0m  $@";
  if ((piped)); then
	  out "$@"
  else
	  out "\033[1;0m$@\033[0m";
  fi
	#out "$@"
}

version() {
	out "iPlant Agave API ${release}
Agave CLI (revision ${revision})
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

getIpAddress() {
    curl http://myip.dnsomatic.com
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

function getpagination {
  pagination=''
  re='^[0-9]+$'
  if [[ $limit =~ $re ]] ; then
    pagination="&limit=$limit"
  fi

  if [[ $offset =~ $re ]] ; then
    pagination="${pagination}&offset=$offset"
  fi

  echo $pagination
}

function pagination {
  getpagination $limit $offset
}

function jsonquery {

  	if [[ -z "$1" ]]; then
		if [[ "$2" = "message" ]]; then
		  echo "Unable to contact api server at $hosturl"
		fi
  	elif [[ -n $(ishtmlstring $1) ]]; then
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

		# Look for custom json parsers
		if [[ -n "$AGAVE_JSON_PARSER" ]]; then

			if [[ 'json-mirror' == "$AGAVE_JSON_PARSER" ]]; then

				$DIR/json-mirror.sh "${1}" "$2" "$3"

			elif [[ 'jq' == "$AGAVE_JSON_PARSER" ]]; then

				jpath = ".${2}"

				if [[ -n "$3" ]]; then
					echo "$1" | jq --raw-output ${jpath}
				else
					echo "$1" | jq ${jpath}
				fi

			elif [[ 'json' == "$AGAVE_JSON_PARSER" ]]; then

				if [[ -n "$3" ]]; then
					echo "$1" | json -j $2
				else
					echo "$1" | json $2
				fi

			elif [[ 'python' == "$AGAVE_JSON_PARSER" ]]; then

				[[ -z "$3" ]] && stripquotes='-s'

				echo "${1}" | python $DIR/python2/pydotjson.py -q ${2} $stripquotes

			elif [[ 'native' == "$AGAVE_JSON_PARSER" ]]; then

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
		fi
	fi
}

# }}}

# Boilerplate {{{

# Prompt the user to interactively enter desired variable values.
prompt_options() {
  local desc=
  local val=
  tokenstore=$(kvget current)
  # if [ ! -z "$(kvget current)" ]; then
	#   tokenstore=$(kvget current)
  # fi

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
      if [[ -n "$force" ]]; then
        apikey=$savedapikey
      else
  	    echo -n "API key [$savedapikey]: "
      	eval "read $val"
      	if  [[ -z $apikey ]]; then
      		apikey=$savedapikey
      	fi
      	#stty -echo; read apikey; stty echo
      	#echo
      fi
    elif [[ $val == "refresh_token" ]]; then
    	jsonval savedrefreshtoken "${tokenstore}" "refresh_token"
      if [[ -n "$force" ]]; then
        refresh_token=$savedrefreshtoken
      else
        echo -n "Refresh token [$savedrefreshtoken]: "
      	eval "read $val"
      	if  [[ -z $refresh_token ]]; then
      		refresh_token=$savedrefreshtoken
      	fi
      	#stty -echo; read apikey; stty echo
      	#echo
      fi
    elif [[ $val == "apisecret" ]]; then
    	jsonval savedapisecret "${tokenstore}" "apisecret"
      if [[ -n "$force" ]]; then
        apisecret=$savedapisecret
      else
  		  echo -n "API secret [$savedapisecret]: "
      	eval "read $val"
      	if  [[ -z $apisecret ]]; then
      		apisecret=$savedapisecret
      	fi
      fi
    elif [[ $val == "username" ]]; then
    	jsonval savedusername "${tokenstore}" "username"
		  if [[ -n "$force" ]]; then
        username=$savedusername
      else
        echo -n "API username [$savedusername]: "
      	eval "read $val"
      	if  [[ -z $username ]]; then
        		username=$savedusername
      	fi
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
    if [[ -f "$DIR/auth-filter.sh" ]]; then
      echo $(source $DIR/auth-filter.sh);
    else
      echo " -u \"${username}:${password}\" "
    fi
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

	auth_cache=`kvget current`

	jsonval expires_in "$auth_cache" "expires_in"
	jsonval created_at "$auth_cache" "created_at"

  if [[ -z "$expires_in" ]] || [[ -z "$created_at" ]]; then
    echo 0
  else
  	expiration_time=`expr $created_at + $expires_in`
  	current_time=`date +%s`

  	time_left=`expr $expiration_time - $current_time`

  	echo $time_left
  fi
}

is_valid_url() {
	regex='(\b(https?|ftp|file)://)?[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]'
	if [[ "$1" =~ $regex ]]
	then
		echo 1
	fi
}

to_json_error() {
  if ((veryverbose)); then
	response="{ \"status\":\"error\",\"message\":\"$1\",\"result\":null }"
	response=`echo "$response" | python -mjson.tool`
  else
	response="$1"
  fi
}

# load tenant-specific settings
calling_cli_command=$(basename $0)
currentconfig=$(kvget current)

if [[ "tenants-init" != "$calling_cli_command" ]] && [[ "tenants-list" != "$calling_cli_command" ]]; then
  if [[ -z $currentconfig ]]; then
    err "Please run $DIR/tenants-init to initialize your client before attempting to interact with the APIs."
    exit
  fi

  baseurl=$(jsonquery "$currentconfig" "baseurl")
  if  [[ -z $baseurl ]]; then
    err "Please run $DIR/tenants-init to configure your client endpoints before attempting to interact with the APIs."
    exit
  else
    baseurl="${baseurl%/}"
  fi

  devurl=$(jsonquery "$currentconfig" "devurl")
  if [[ -z "devurl" ]]; then
    err "Please run $DIR/tenants-init to configure your development endpoints before attempting to interact with the APIs."
    exit
  else
    devurl="${devurl%/}"
  fi

  tenantid=$(jsonquery "$currentconfig" "tenantid")
  if [[ -z "tenantid" ]]; then
    err "Please run $DIR/tenants-init to configure your client id before attempting to interact with the APIs."
    exit
  fi
fi
# }}}

function join {
  local IFS="$1"; shift; echo "$*";
}

function json_prettyify {

	# Look for custom json parsers
	if [[ 'python' == "$AGAVE_JSON_PARSER" ]]; then

		echo "$@" | python $DIR/python2/pydotjson.py

	elif [[ 'jq' == "$AGAVE_JSON_PARSER" ]]; then

		echo "$@" | jq -r '.'

	elif [[ 'json' == "$AGAVE_JSON_PARSER" ]]; then

		echo "$@" | json

	# If all else fails, we can use the jsonparser api
	#elif [[ -z "$AGAVE_JSON_PARSER" -o 'json-mirror' == "$AGAVE_JSON_PARSER" ]]; then
	else

		jsonparserresponse=$(curl -sk -H "ContentType: application/json" -F @- "http://agaveapi.co/jsonparser?pretty=true&q=.")

		if [ $? ]; then
			echo $jsonparserresponse
		else
			echo "$@"
		fi
	fi
}