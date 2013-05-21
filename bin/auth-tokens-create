#!/bin/bash
# 
# auth-token-get.sh
# 
# author: dooley@tacc.utexas.edu
#
# This script is part of the Agave API command line interface (CLI).
# It retrieves an authentication token from the auth service that
# can be used to authenticate to the rest of the api. A valid API 
# secret and key must be used to obtain a token.
#

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

source "$DIR/common.sh"

hosturl="$baseurl/auth/"
storetoken=0
apikey=
apisecret=

# Script logic -- TOUCH THIS {{{

# A list of all variables to prompt in interactive mode. These variables HAVE
# to be named exactly as the longname option definition in usage().
interactive_opts=(apisecret apikey)

# Print usage
usage() {
  echo -n "$(basename $0) [OPTION]...

Description of this script.

 Options:
  -s, --apisecret   API secret for authenticating
  -k, --apikey      API key for authenticating, its recommended to insert
                    this through the interactive option
  -l, --lifetime    Lifetime of the returned token in seconds
  -m, --maxUses     Maximum number of times the returned token can be used
  -u, --internalUsername  Internal user to attach to this token
  -x, --apiusername API username for whom the returned token should apply, 
                    requires admin permissions
  -S, --storetoken  Store the token for later use. This prevents you from 
                    reauthenticating with every command.
  -H, --hosturl     URL of the service
  -d, --development Run in dev mode using default dev server
  -f, --force       Skip all user interaction
  -i, --interactive Prompt for values
  -q, --quiet       Quiet (no output)
  -v, --verbose     Output more
  -h, --help        Display this help and exit
      --version     Output version information and exit
"
}

##################################################################
##################################################################
#						Begin Script Logic						 #
##################################################################
##################################################################

main() {
	#echo -n
	#set -x
	
	local post_options='';
	
	if [ -n "$internalUsername" ]; then
		post_options="internalUsername=$internalUsername"
	fi
	
	if [ -n "$apiusername" ]; then
		post_options="username=$apiusername&$post_options"
	fi
	
	if [ -n "$maxUses" ]; then
		post_options="maxUses=$maxUses&$post_options"
	fi
	
	if [ -n "$lifetime" ]; then
		post_options="lifetime=$lifetime&$post_options"
	fi
	
	cmd="curl -sku \"$apisecret:XXXXXX\" -X POST -d \"$post_options\" $hosturl"

	log "Calling $cmd"
		
	response=`curl -sku "$apisecret:$apikey" -X POST -d "$post_options" "$hosturl"`
	
	jsonval response_status "$response" "status"
	
	if [ "$response_status" = "success" ]; then
		format_api_json "$response"
	else
		jsonval response_message "$response" "message" 
		err "$response_message"
	fi
	
	
}

format_api_json() {
	
	if ((storetoken)); then
		jsonval response_token "$1" "token" 
		echo "{\"apisecret\":\"$apisecret\",\"apikey\":\"$response_token\"}" > ~/.agave
		echo "Token successfully stored";
	fi	
		
	if ((verbose)); then
		echo "$1" | python -mjson.tool
	else
		jsonval response_token "$1" "token" 
		success "$response_token"
	fi
}

##################################################################
##################################################################
#						End Script Logic						 #
##################################################################
##################################################################

# }}}
# Boilerplate {{{

# Iterate over options breaking -ab into -a -b when needed and --foo=bar into
# --foo bar
optstring=h
unset options
while (($#)); do
  case $1 in
  	# If option is of type -ab
    -[!-]?*)
      # Loop over each character starting with the second
      for ((i=1; i < ${#1}; i++)); do
      	c=${1:i:1}
		
        # Add current char to options
        options+=("-$c")

        # If option takes a required argument, and it's not the last char make
        # the rest of the string its argument
        if [[ $optstring = *"$c:"* && ${1:i+1} ]]; then
          options+=("${1:i+1}")
          break
        fi
      done
      ;;
    # If option is of type --foo=bar
    --?*=*) options+=("${1%%=*}" "${1#*=}") ;;
    # add --endopts for --
    --) options+=(--endopts) ;;
    # Otherwise, nothing special
    *) options+=("$1") ;;
  esac
  shift
done
set -- "${options[@]}"
unset options

# Set our rollback function for unexpected exits.
trap rollback INT TERM EXIT

# A non-destructive exit for when the script exits naturally.
safe_exit() {
  trap - INT TERM EXIT
  exit
}

# }}}
# Main loop {{{

# Print help if no arguments were passed.
[[ $# -eq 0 ]] && set -- "-i"

# Read the options and set stuff
while [[ $1 = -?* ]]; do
  case $1 in
    -h|--help) usage >&2; safe_exit ;;
    --version) out "$(basename $0) $version"; safe_exit ;;
    -s|--apisecret) shift; apisecret=$1 ;;
    -k|--apikey) shift; apikey=$1 ;;
    -l|--lifetime) shift; lifetime=$1 ;;
  	-m|--maxUses) shift; maxuses=$1 ;;
  	-u|--internalUsername) shift; internalusername=$1 ;;
	-x|--apiusername) shift; apiusername=$1;;
	-S|--storetoken) storetoken=1 ;;
	-H|--hosturl) shift; hosturl=$1;;
  	-d|--development) development=1 ;;
    -v|--verbose) verbose=1 ;;
    -q|--quiet) quiet=1 ;;
    -i|--interactive) interactive=1 ;;
    -f|--force) force=1 ;;
    --endopts) shift; break ;;
    *) die "invalid option: $1" ;;
  esac
  shift
done

# Store the remaining part as arguments.
args+=("$@")

# }}}
# Run it {{{

# Uncomment this line if the script requires root privileges.
# [[ $UID -ne 0 ]] && die "You need to be root to run this script"

if [ -z "$apikey" ]; then
	interactive=1
fi

if [ -z "$apisecret" ]; then
	interactive=1
fi

if ((interactive)); then
  prompt_options
fi

# You should delegate your logic from the `main` function
main

# This has to be run last not to rollback changes we've made.
safe_exit

# }}}
