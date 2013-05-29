#!/bin/bash
# 
# auth-token-delete.sh
# 
# author: dooley@tacc.utexas.edu
#
# Common helper functions and global variables for all cli scripts.
# A lot of this is based on options.bash by Daniel Mills.
# @see https://github.com/e36freak/tools/blob/master/options.bash


# Preamble {{{

# Exit immediately on error
#set -e

# Detect whether output is piped or not.
[[ -t 1 ]] && piped=0 || piped=1

# versioning info
version="v0.1"
api_release="v2"

os=`uname -s`;

# Defaults
force=0
quiet=0
verbose=0
interactive=0
development=0
baseurl="https://iplant-dev.tacc.utexas.edu/v2"
devurl="http://localhost:8080"
disable_cache=0 # set to 1 to prevent using auth cache.
args=()

# }}}
# Helpers {{{

out() {
  ((quiet)) && return

  local message="$@"
  if ((piped)); then
    message=$(echo $message | sed '
      s/\\[0-9]\{3\}\[[0-9]\(;[0-9]\{2\}\)\?m//g;
      s/✖/Error:/g;
      s/✔/Success:/g;
    ')
  fi
  printf '%b\n' "$message";
}
die() { out "$@"; exit 1; } >&2
err() { out " \033[1;31m✖\033[0m  $@"; } >&2
success() { out " \033[1;32m✔\033[0m  $@"; }

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


# }}}

# Boilerplate {{{

# Prompt the user to interactively enter desired variable values. 
prompt_options() {
  local desc=
  local val=
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

    echo -n "$desc: "

    # In case this is a password field, hide the user input
    if [[ $val == "apikey" ]]; then
      stty -echo; read apikey; stty echo
      echo
    # Otherwise just read the input
    else
      eval "read $val"
    fi
  done
}

check_response_status() {
	local __response_status=`echo "$1" | python -mjson.tool | grep '^    "status": "success"'`
	if [[ -n $__response_status ]]; then
		eval response_status="success"
	fi
}

# }}}