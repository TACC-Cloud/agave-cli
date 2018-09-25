# cli-common.sh
#
# Usage: source this first, as it containts functions that are used in
# <command>-common.sh and other dependencies

if [[ -z "$DIR" ]]; then
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi
PYDIR="${DIR}/libs/python"

# TACC-namespaced key=value support
source ${DIR}/tacc-kv-bash

# Detect if script is being piped
[[ -t 1 ]] && piped=0 || piped=1
# Determine which flavor of awk is being used (e.g. GNU gawk or BSD nawk)
awk=$(awk -Wversion &>/dev/null && echo gawk || echo nawk)
# Detect operating system type
os=`uname -s`;

# Functional variables
quiet=0
verbose=0
veryverbose=0
force=0

# User interaction functions

function confirm() {
  (($force)) && return 1;

  read -p "$1 [Y/n] " -n 1;
  [[ $REPLY =~ ^[Yy]$ ]];
}

# Auth cache functions

# keystore filenames
AGAVE_STORE="current"
if [ -z "${GITLAB_STORE}" ]; then
    GITLAB_STORE="gitlab"
fi
if [ -z "${REGISTRY_STORE}" ]; then
    REGISTRY_STORE="registry"
fi

# Set Agave and TACC cloud directory
if [ -z "$AGAVE_CACHE_DIR" ]; then
    AGAVE_CACHE_DIR="$HOME/.agave"
fi

if [ -z "$TACCLAB_CACHE_DIR" ]; then
    if [ -z "$AGAVE_CACHE_DIR" ]; then
        TACCLAB_CACHE_DIR="$HOME/.agave"
    else
        TACCLAB_CACHE_DIR="$AGAVE_CACHE_DIR"
    fi
fi

# Check existence of keystores
# NOTE: Does not validate them!!!
if [ -f "${AGAVE_CACHE_DIR}/${AGAVE_STORE}" ]; then
    export has_agave_store=1
fi
if [ -f "${TACCLAB_CACHE_DIR}/${REGISTRY_STORE}" ]; then
    export has_tacc_registry_store=1
fi
if [ -f "${TACCLAB_CACHE_DIR}/${GITLAB_STORE}" ]; then
    export has_tacc_gitlab_store=1
fi

# Oauth functions

# function get_token_remaining_time() {

#   local TOKENSTORE="${1}"
#   if [ -z "${TOKENSTORE}" ]; then
#     # Default to Agave store for now
#     TOKENSTORE="current"
#   fi

#   auth_cache=$(tacc.kvget ${TOKENSTORE})
#   # stderr "cli-common/get_token_remaining_time $TOKENSTORE"

#   jsonval expires_in "$auth_cache" "expires_in"
#   jsonval created_at "$auth_cache" "created_at"

#   if [ "${expires_in}" == "null" ] || [[ -z "$expires_in" ]] || [[ -z "$created_at" ]] || [[ "$created_at" == "null" ]]; then
#     echo "0"
#   else
#     created_at=${created_at%.*}
#     expires_in=${expires_in%.*}
#     expiration_time=$(( $created_at + $expires_in ))
#     current_time=$(date +%s)
#     time_left=$(( $expiration_time - $current_time ))
#     echo "${time_left}"
#   fi
# }

function maskpass() {
  # Mask a sensitive string with * chars
  local sensitive="${1}"
  printf "%s\n" "${sensitive//?/*}"
}

# Agave helper functions

source ${DIR}/agave-common.sh

AGAVE_TENANTID=${AGAVE_TENANTID}
function get_agave_tenant(){

    if [ ! -z "$AGAVE_TENANTID" ]; then
        printf "$AGAVE_TENANTID"
    else
        AGAVE_TENANTID=$(${DIR}/auth-check -v | jq -r .tenantid)
        printf "$AGAVE_TENANTID"
        export AGAVE_TENANTID
    fi
}

TENANT_GLOBAL_CONFIG_FILE=
function get_tenant_config(){
    # The CLI ships with a global config that can be used to set globals
    local tenant=$(get_agave_tenant)

    # hard code till I fix this
    if [[ "${tenant}" == "null" ]] || [ -z "$tenant" ]; then
      tenant="sd2e"
    fi

    if [ ! -z "$TENANT_GLOBAL_CONFIG_FILE" ]; then
        printf "$TENANT_GLOBAL_CONFIG_FILE"
    else
        TENANT_GLOBAL_CONFIG_FILE=${DIR}/../etc/tenants.d/${tenant}/config.rc
        if [ -f "${TENANT_GLOBAL_CONFIG_FILE}" ]; then
            printf $TENANT_GLOBAL_CONFIG_FILE
            export TENANT_GLOBAL_CONFIG_FILE
        fi
    fi
}

# Logging and messaging functions

function stderr(){
  # Prints to STDERR. Ignores quiet but won't clog your pipes (ha-ha)
    (>&2 echo "[NOTE] $@")
}

function out() {
  ((quiet)) && return

  local message="$@"
  #if ((piped)); then
  #  message=$(echo $message | sed '
  #    s/\\[0-9]\{3\}\[[0-9]\(;[0-9]\{2\}\)\?m//g;
  #    #s/✖/Error:/g;
  #    #s/✔/Success:/g;
  #  ')
  #fie
  if (( pipe )); then
    echo "$@"
  else
    printf '%b\n' "$message";
  fi
}

function die() { out "$@"; exit 1; } >&2

function err() {
    if [[ -n $(ishtmlstring "$response") ]]; then
        response=$(get_html_message "$response")
        response=`json_prettyify $(to_json_error_message "$response")`
    elif [[ -n $(isxmlstring "$response") ]]; then
        response=$(get_xml_message "$1")
        response=`json_prettyify $(to_json_error_message "$response")`
    else
        response=$@
    fi

    if (($verbose)); then
        if ((piped)); then
            die "${response}"
        else
            die "\033[1;31m${response}\033[0m"
        fi
    else
        if ((piped)); then
            die "$@"
        else
            die "\033[1;31m${@}\033[0m"
        fi
    fi
} >&2

function success() {
  # Prints pretty green text on success
  if ((piped)); then
    out "$@"
  else
    out "\033[1;0m$@\033[0m";
  fi
}

# Warning
function warning() { out "$@"; }

# Verbose logging
function log() { (($verbose)) && out "$@"; }

# Notify on function success
function notify() { [[ $? == 0 ]] && success "$@" || err "$@"; }


# Documentation functions

function copyright() {
    out "LICENSE\n"
  cat $DIR/../docs/LICENSE
}

function disclaimer() {
  cat $DIR/../docs/DISCLAIMER
}

function docs() {
    cat $DIR/../docs/DOCUMENTATION
}

function terms() {
    copyright
    disclaimer
}

function version() {
  # Meant to be overridden by command-common.sh
  echo ""
}

# JSON functions
# Todo - Add support for a JSON linter

# Configure which json parser to use for Agave core CLI
if [[ -z "$AGAVE_JSON_PARSER" ]]; then
    AGAVE_JSON_PARSER='jq'
fi
# Configure which json parser to use for TACC add-ons
if [[ -z "$TACC_JSON_PARSER" ]]; then
    TACC_JSON_PARSER=${AGAVE_JSON_PARSER}
fi

function jsonval {
  local __resultvar=$1
  local __temp=`echo "$2" | sed 's/\\\\\//\//g' | sed 's/[{}]//g' | awk -v k="text" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' | sed 's/\"\:\"/\|/g' | sed 's/[\,]/ /g' | sed 's/\"//g' | grep -w $3| cut -d":" -f2| sed -e 's/^ *//g' -e 's/ *$//g'`
  eval $__resultvar=`echo '${__temp##*|}'`
}

function json_prettyify {
  # Pretty printer
  echo "$@" | jq -r '.'
}

# Query JSON with one of several parsers
# TODO: Restrict choices :-)
function jsonquery {
    # set -x
    if [[ -z "$1" ]]; then
      if [[ "$2" = "message" ]]; then
          echo "Unable to contact api server at $hosturl"
      fi
    elif [[ -n "$(echo $1 | grep '^{"fault":{"code"')" ]]; then
      if [[ "$2" = "message" ]]; then
        if (( $veryverbose )); then
          echo "$1"
        else
          apimerr=$(echo "$1" | grep -om1 '"message":"[^"]*"' | sed -e 's/"message":"//' | sed -e 's/"//')
          echo "$apimerr"
        fi
      fi
    elif [[ -n $(ishtmlstring "$1") ]]; then
      if [[ "$2" = "message" ]]; then
        if (( $veryverbose )); then
          echo "$1"
        else
          echo $(get_html_message "$1")
          # echo "Unexpected response from the API server."
        fi
      fi
    elif [[ -n $(isxmlstring "$1") ]]; then
      if [[ "$2" = "message" ]]; then

        echo $(get_xml_message "$1")

      # echo $(echo "$1" | grep -oPm1 "(?<=<ams:message>)[^<]+")

#     responsemessage=${1#*<ams:message>}
#     responsemessage=${responsemessage%</ams:message>*}
#     echo $responsemessage
    fi
  else
    # Look for custom json parsers
    if [[ -n "$TACC_JSON_PARSER" ]]; then

      if [[ 'json-mirror' == "$TACC_JSON_PARSER" ]]; then

        $DIR/json-mirror.sh "${1}" "$2" "$3"

      elif [[ 'jq' == "$TACC_JSON_PARSER" ]]; then

        jpath=".${2}"

        if [[ -n "$3" ]]; then

                if [[ "$jpath" =~ \[\] ]]; then
            oIFS="$IFS"
            IFS="[]" read fbefore fmiddle fafter <<< "$jpath"
            IFS="$oIFS"
            unset oIFS
            fbefore_noperiod="${fbefore%?}"

            if [[ -z "$fbefore_noperiod" ]]; then
                          echo "$1" | jq ".[] | $fafter"
            else
                          echo "$1" | jq "$fbefore_noperiod | .[] | $fafter"
            fi
                else
                        echo "$1" | jq "$jpath"
                fi
        else

                if [[ "$jpath" =~ \[\] ]]; then
            oIFS="$IFS"
            IFS="[]" read fbefore fmiddle fafter <<< "$jpath"
            IFS="$oIFS"
            unset oIFS
            fbefore_noperiod="${fbefore%?}"

            if [[ -z "$fbefore_noperiod" ]]; then
                          echo "$1" | jq -r ".[] | $fafter"
            else
                          echo "$1" | jq -r "$fbefore_noperiod | .[] | $fafter"
            fi
                else
                        echo "$1" | jq -r "$jpath"
                fi
        fi

      elif [[ 'python' == "$TACC_JSON_PARSER" ]]; then

        [[ -z "$3" ]] && stripquotes='-s'

        echo "${1}" | python $DIR/libs/python/pydotjson.py -q ${2} $stripquotes

      elif [[ 'native' == "$TACC_JSON_PARSER" ]]; then

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


# String functions

function slugify {
  echo "${1}" | tr -c -d [\.0-9A-Za-z\ _-] | tr ' ' '_' | tr '[:upper:]' '[:lower:]'
}

function join {
  local IFS="$1"; shift; echo "$*";
}

# Escape a string
function escape() { echo $@ | sed 's/\//\\\//g'; }

# Trim whitespace
function trim() {
  local var="$*"
  var="${var#"${var%%[![:space:]]*}"}"   # remove leading whitespace characters
  var="${var%"${var##*[![:space:]]}"}"   # remove trailing whitespace characters
  echo -n "$var"
}

function ishtmlstring {
  if [[ -n "$1" ]]; then
    firstelement=${1:0:5}
    if [[ "$firstelement" = "<html" ]] || [[ "$firstelement" = "<!DOC" ]]; then
      echo 1
    fi
  fi
}

function isxmlstring {
  if [[ -n "$1" ]]; then
    if hash xmllint 2>/dev/null; then
      xmllint - >> /dev/null 2>&1 <<< "$1"
      [ $? -eq 0 ] && echo 1
    else
      firstcharacter=$(trim "$1")
      firstcharacter=${firstcharacter:0:1}
      [ "$firstcharacter" = '<' ] && echo 1
    fi
  fi
}

function get_html_message() {
  if [[ -n $(echo "$1" | grep "<title") ]]; then
    echo "$1" | grep -om1 "<title>[^<]*" | sed -e 's/<title>//'
  elif [[ -n $(echo "$1" | grep "<p") ]]; then
    echo "$1" | grep -om1 "<p>[^<]*" | sed -e 's/<p>//'
  else
    echo "Unexpected response from the API server."
  fi
}

function get_xml_message() {
  #set -x
  if [[ -n $(echo "$1" | grep -om1 "<ams:message>[^<]*") ]]; then
    echo "$1" | grep -om1 "<ams:message>[^<]*" | sed -e 's/<ams:message>//'
  elif [[ -n $(echo "$1" | grep -om1 "<am:description>[^<]*") ]]; then
    echo "$1" | grep -om1 "<am:description>[^<]*" | sed -e 's/<am:description>//'
  elif [[ -n $(echo "$1" | grep "<title") ]]; then
    echo "$1" | grep -om1 "<title>[^<]*" | sed -e 's/<title>//'
  else
    echo "$1"
  fi
  #set +x
}

function to_json_error_message() {
  printf '{"status":"error","message":"%s","result":null}' "$(echo "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\"/g')"

}

# Time and Date functions

function timestamp() {
  # return current epoch (local time zone)
  printf $(date +%s)
}

function format_iso8601_date_and_time() {

  # Parses ISO8601 datetime to human readable formats
  # default:        Jan 11, 1977 00:00 format
  # with second argument: Jan  1, 1977 12:00 am

  local thisyear iso8601 format_12_hour_clock moddate tmon tday modtime
  thisyear=$(date +%Y)
  iso8601="$1"
  [[ -n "$2" ]] && format_12_hour_clock=1

  moddate=( $(echo "$iso8601" | sed 's/T.*//' | sed 's/-/ /g' | xargs -n 1) )
  tmon=$(month_of_year ${moddate[1]})
  tday=$(echo ${moddate[2]} | sed -e 's/^0/ /')
  tyear=${moddate[0]}

  if (( format_12_hour_clock )); then

    modtime=$(format_iso8601_time "$iso8601" 1)
    echo "${tmon} ${tday}, ${tyear}  ${modtime}"

  elif [[ $thisyear = "${tyear}" ]]; then

    modtime=$(format_iso8601_time "$iso8601" 1)
    echo "${tmon} ${tday} ${modtime}"

  else

    echo "${tmon} ${tday} ${tyear}"
  fi

}

function format_iso8601_time() {
  local iso8601_date format_12_hour_clock iso8601_time modtime hours minutes
  iso8601_date="$1"
  [[ -n "$2" ]] && format_12_hour_clock=1

  # strip iso8601 time out, removing everything after minute place
  iso8601_time=$(echo "$1" | sed -e 's/.*T//' -e 's/\:..\....-..\:..//')
  modtime=( $( echo "$iso8601_time" | sed 's/\:/ /' | xargs -n 1) )
  hours=${modtime[0]#0}
  minutes=${modtime[1]}
  if (( format_12_hour_clock )); then

    if [[ $hours -eq 0 ]]; then
      meridian="am"
      hours=12
    elif [[ $hours -gt 12 ]]; then
      hours=$(expr $hours - 12 )
      meridian="pm"
    else
      meridian="am"
    fi

    if [[ $hours -gt 9 ]]; then
      echo "$hours:$minutes $meridian"
    else
      echo " $hours:$minutes $meridian"
    fi

  else
    echo "$iso8601_time"
  fi
}

function month_of_year() {
  if [[ "$1" = "01" ]]; then
    echo 'Jan';
  elif [[ "$1" = "02" ]]; then
    echo 'Feb';
  elif [[ "$1" = "03" ]]; then
    echo 'Mar';
  elif [[ "$1" = "04" ]]; then
    echo 'Apr';
  elif [[ "$1" = "05" ]]; then
    echo 'May';
  elif [[ "$1" = "06" ]]; then
    echo 'Jun';
  elif [[ "$1" = "07" ]]; then
    echo 'Jul';
  elif [[ "$1" = "08" ]]; then
    echo 'Aug';
  elif [[ "$1" = "09" ]]; then
    echo 'Sep';
  elif [[ "$1" = "10" ]]; then
    echo 'Oct';
  elif [[ "$1" = "11" ]]; then
    echo 'Nov';
  elif [[ "$1" = "12" ]]; then
    echo 'Dec';
  else
    echo ''
  fi
}

# Generai utility functions

function getIpAddress() {
    curl http://myip.dnsomatic.com
}

function is_valid_url() {
  regex='(\b(https?|ftp|file)://)?[-A-Za-z0-9+&@#/%?=~_|!:,.;]+[-A-Za-z0-9+&@#/%=~_|]'
  if [[ "$1" =~ $regex ]]
  then
    echo 1
  fi
}

function progress() {
  [[ -z "$1" ]] && err "Not currently moving data"

  local _bytesTotal _bytesMoved _rate

  _bytesTotal=$( humanizeBytes $(jsonquery "$1" "totalBytes") )
  _bytesMoved=$( humanizeBytes $(jsonquery "$1" "totalBytesTransferred") )
  _rate=$( humanizeTransferRate $(jsonquery "$1" "averageRate") )

  echo "{\"averageRate\":\"${_rate}\",\"totalBytesTransferred\":\"${_bytesMoved}\",\"totalBytes\":\"${_bytesTotal}\"}"
}

function humanizeTransferRate() {
  echo "$(humanizeBytes $1 )/s"
}

function humanizeBytes() {
  echo $1 | awk '
    function readable( input,     v,s )
      {
      split( "KB MB GB TB" , v )
      # confirms that the input is a number
      if( input + 0.0 == input )
         {
        while( input > 1024 ) { input /= 1024 ; s++ }
        return sprintf( "%0.3f%s" , input , v[s] )
         }
      else
         {
        return input
         }
      }
    {sub(/^[0-9]+/, readable($1)); print}'
}

# Depdendency management functions

function check_dependencies() {

  if [ -z "$TACC_NO_CHECK_DEPS" ]; then
    source ${DIR}/check-dependencies.sh
  fi

}

# Error handling functions

# Set a trap for cleaning up in case of errors or when script exits.
function rollback() {
    stty echo
    die
}

# Set our rollback function for unexpected exits.
trap rollback INT TERM EXIT

# A non-destructive exit for when the script exits naturally.
safe_exit() {
  trap - INT TERM EXIT
  exit
}
