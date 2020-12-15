# Check dependencies

CURL_MIN_VERSION=7.50.0  # Support TLS1.2 - TODO - Add explicit TLSv2 check
DOCKER_MIN_VERSION=17.05
GIT_MIN_VERSION=2.10.0
GITLAB_CLI_MIN_VERSION=1.3.0
JQ_MIN_VERSION=1.5
PYTHON_MIN_VERSION=2.7.14

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
function warning() { out "$@"; }
function log() { (($verbose)) && out "$@"; }
function die() { out "$@"; exit 1; } >&2

function version {
  # Turns semantic, numbered version into an integer
  # for the purposes of comparison
  vers=$1
  major=$(echo "$vers" | awk -F. '{ print $1 }')
  minor=$(echo "$vers" | awk -F. '{ print $2 }')
  patch=$(echo "$vers" | awk -F. '{ print $3 }')
  major=$((major * 100000000))
  minor=$((minor * 100000))
  patch=$((patch * 100))
  vers=$((major + minor + patch))
  echo -n $vers
}

function dep_required() {
  cmdname="$1"
  die "Error: This CLI requires $1 to be installed and in \$PATH."
}

function dep_warning() {
  cmdname="$1"
  warning "Warning: Some CLI features rely in $1 and it does not seem to be installed"
}

function dep_version_too_low(){
  cmdname="$1"
  cmdversion="$2"
  minversion="$3"
  die "Error: $cmdname version $cmdversion < required version $minversion."
}

function dep_version_too_high(){
  cmdname="$1"
  cmdversion="$2"
  maxversion="$3"
  die "Error: $cmdname version $cmdversion > max version $maxversion."
}

if [ -z "$CHECKED_DEPS" ]; then

    hascurl=0
    hasdocker=0
    hasjq=0
    haspython=0
    hasgitlab=0
    haspython=0

    log "Verifying dependencies..."

    # Basically, a Mac OS checker
    # Can be fooled by presence of brew-install coreutils but then
    # the box doesn't act like a Mac so much any longer
    command date --version >/dev/null 2>&1 && is_gnu=1 || true

    # Curl
    # This code block throws up a warning on curl versions that are too
    # low for comfort but does not fail them
    command -v curl >/dev/null 2>&1 && has_curl=1 || { dep_required "curl"; }
    CURL_VERSION=$(curl --version | head -n 1 | awk '{print $2}')
    if [ $(version ${CURL_VERSION}) -ge $(version ${CURL_MIN_VERSION}) ]; then
      log "Found curl ${CURL_VERSION}"
    else
      log "curl version ${CURL_VERSION} < ${CURL_MIN_VERSION}, which may cause issues. Consider upgrading."
    fi

    # Alternative implementation that fails on low curl version
    # command -v curl >/dev/null 2>&1 || { dep_required "curl"; }
    # CURL_VERSION=$(curl --version | head -n 1 | awk '{print $2}')
    # if [ $(version ${CURL_VERSION}) -ge $(version ${CURL_MIN_VERSION}) ]; then
    #   hascurl=1
    #   log "Found curl ${CURL_VERSION}"
    # else
    #   dep_version_too_low "curl" ${CURL_VERSION} ${CURL_MIN_VERSION}
    # fi

    # Python
    command -v python >/dev/null 2>&1 && haspython=1 || { dep_required "python"; }
    if ((haspython)); then
      PYTHON_VERSION=$(python -V 2>&1 | awk '{ print $2 }')
      log "Found Python ${PYTHON_VERSION}"
    fi
    # Python modules
    for mod in agavepy configparser requests
    do
        python -c "import $mod" >/dev/null 2>&1
        if [ "$?" != 0 ];
        then
            dep_required "Python module ${mod}"
        else
          log "Found Python module ${mod}"
        fi
    done
    # JQ parser
    command -v jq >/dev/null 2>&1 && hasjq=1 || { dep_required "jq"; }
    if ((hasjq)); then
      JQ_VERSION=$(jq --version | cut -f 2 -d '-')
      log "Found jq ${JQ_VERSION}"
    fi
    # Docker (optional)
    command -v docker >/dev/null 2>&1 && DOCKER_VERSION="$(docker --version | awk '{print $3}' | tr -d ,)" || { dep_warning "Docker"; }
    if egrep -v -q "^(17\.|18\.|19\.|20\.)" <<< ${DOCKER_VERSION}; then
        dep_warning "Docker ${DOCKER_MIN_VERSION}"
    else
        hasdocker=1
        log "Found Docker ${DOCKER_VERSION}"
    fi
    # Git (optional, warn)
    #
    # TODO: Allow use of hub or alternatives
    command -v git >/dev/null 2>&1 && hasgit=1 || { dep_warning "git"; }
    if ((hasgit)); then
      GIT_VERSION=$(git --version | awk '{print $3}')
      log "Found git ${GIT_VERSION}"
    fi

    # Gitlab CLI (optional)
    command -v gitlab >/dev/null 2>&1 && hasgitlab=1 || true
    if ((hasgitlab)); then
      GITLAB_CLI_VERSION=$(gitlab --version)
      log "Found gitlab Python library ${GITLAB_CLI_VERSION}"
    fi

    # Only run once, no matter how many times its sourced
    # This is important because the process is kind of slow due to
    # all the subshells and command invocations
    CHECKED_DEPS=1


fi
