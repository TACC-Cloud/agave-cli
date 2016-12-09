
# APPS

_apps-list () {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -z|-n|-t|-S|-O|-l|-o|-H|-u|-N|-h|-F) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(apps-search --filter=id id.like=${cur}*)" -- $cur)) ;;
    esac

}

_apps-clone () {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -e) COMPREPLY=($(compgen -W "$(systems-search --filter=id type=EXECUTION id.like=${cur}*)" -- $cur)) ;;
        -s) COMPREPLY=($(compgen -W "$(systems-search --filter=id type=STORAGE id.like=${cur}*)" -- $cur)) ;;
        # -p
        -z|-n|-x|-H|-h) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(apps-search --filter=id id.like=${cur}*)" -- $cur)) ;;
    esac
}

_apps-pems-update () {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -u) COMPREPLY=($(compgen -W "$(profiles-list -v --filter=username -U ${cur} | grep "\"username\"" | sed 's/"//g' | sed 's/username\://g' | sed 's/ //g')" -- $cur)) ;;
        -p) COMPREPLY=($(compgen -W "READ WRITE EXECUTE READ_WRITE READ_EXECUTE WRITE_EXECUTE ALL NONE" -- $cur)) ;;
        -z|-u|-H|-h) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(apps-search --filter=id id.like=${cur}*)" -- $cur)) ;;
    esac
}

_apps-publish () {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -e) COMPREPLY=($(compgen -W "$(systems-search --filter=id type=EXECUTION id.like=${cur}*)" -- $cur)) ;;
        -z|-n|-x|-H|-h) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(apps-search --filter=id id.like=${cur}*)" -- $cur)) ;;
    esac
}

complete -F _apps-list apps-list apps-addupdate apps-delete apps-disable apps-enable apps-erase apps-history apps-pems-delete apps-pems-list jobs-template
complete -F _apps-clone apps-clone
complete -F _apps-pems-update apps-pems-update

# jobs

_jobs-search() {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -z|-s|-l|-o|-H|-h|-N|-R|-u) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(jobs-search --filter=id id.like=${cur}* | awk '{print $1}')" -- $cur)) ;;
    esac
}

_jobs-pems-update() {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -u) COMPREPLY=($(compgen -W "$(profiles-list -v --filter=username -U ${cur} | grep "\"username\"" | sed 's/"//g' | sed 's/username\://g' | sed 's/ //g')" -- $cur)) ;;
        -p) COMPREPLY=($(compgen -W "READ WRITE READ_WRITE ALL NONE" -- $cur)) ;;
        -z|-u|-H|-h) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(jobs-search --filter=id id.like=${cur}* | awk '{print $1}')" -- $cur)) ;;
    esac
}

_jobs-run-this() {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -S) COMPREPLY=($(compgen -W "$(systems-search --filter=id id.like=${cur})" -- $cur)) ;;
        *) COMPREPLY=($(compgen -f $cur)) ;;
    esac
}

complete -F _jobs-search jobs-search jobs-delete jobs-history jobs-kick jobs-output-get jobs-output-list jobs-pems-list jobs-resubmit jobs-status jobs-stop
complete -F _jobs-pems-update jobs-pems-update
complete -F _jobs-run-this jobs-run-this

# metadata

_metadata-list() {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -z|-Q|-P|-l|-o|-H|-h|-u|-F) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(metadata-list -Q '{"uuid":"${cur}.*"}')" -- $cur)) ;;
    esac
}

_metadata-pems-addupdate() {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -u) COMPREPLY=($(compgen -W "$(profiles-list -v --filter=username -U ${cur} | grep "\"username\"" | sed 's/"//g' | sed 's/username\://g' | sed 's/ //g')" -- $cur)) ;;
        -p) COMPREPLY=($(compgen -W "READ WRITE READ_WRITE ALL NONE" -- $cur)) ;;
        -z|-u|-H|-h) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(metadata-list)" -- $cur)) ;;
    esac
}

_metadata-schema-list() {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -z|-Q|-P|-l|-o|-H|-h|F|-D|-u) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(metadata-schema-list -Q '{"uuid":"${cur}.*"}')" -- $cur)) ;;
    esac
}

_metadata-schema-pems-addupdate() {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -u) COMPREPLY=($(compgen -W "$(profiles-list -v --filter=username -U ${cur} | grep "\"username\"" | sed 's/"//g' | sed 's/username\://g' | sed 's/ //g')" -- $cur)) ;;
        -p) COMPREPLY=($(compgen -W "READ WRITE READ_WRITE ALL NONE" -- $cur)) ;;
        -z|-u|-H|-h) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(metadata-schema-list -Q '{"uuid":"${cur}.*"}')" -- $cur)) ;;
    esac
}

complete -F _metadata-list metadata-list metadata-addupdate metadata-delete metadata-pems-list
complete -F _metadata-pems-addupdate metadata-pems-addupdate
complete -F _metadata-schema-list metadata-schema-list metadata-schema-addupdate metadata-schema-delete metadata-schema-pems-list
complete -F _metadata-schema-pems-addupdate metadata-schema-pems-addupdate

# monitors

_monitors-list() {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -T) COMPREPLY=($(compgen -W "$(systems-search --filter=id id.like=${cur}| awk '{print $1}')" -- $cur)) ;;
        -z|-l|-o|-H|-h) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(monitors-list --filter=id,status | awk '{print $1}')" -- $cur)) ;;
    esac
}

_monitors-checks-list() {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -M) COMPREPLY=($(compgen -W "$(monitors-list | awk '{print $1}')" -- $cur)) ;;
        -R) COMPREPLY=($(compgen -W "PASSED FAILED UNKNOWN" -- $cur)) ;;
        -T) COMPREPLY=($(compgen -W "STORAGE LOGIN" -- $cur)) ;;
        *) COMPREPLY=($(compgen -f $cur)) ;; # must have -M monitorID to list, so default to regular complete
    esac
}

_monitors-addupdate() {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -S) COMPREPLY=($(compgen -W "$(systems-search --filter=id id.like=${cur})" -- $cur)) ;;
        -z|-F|-I|-H|-h) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(monitors-list | awk '{print $1}')" -- $cur)) ;;
    esac
}

complete -F _monitors-list monitors-list monitors-delete monitors-fire monitors-history
complete -F _monitors-checks-list monitors-checks-list
complete -F _monitors-addupdate monitors-addupdate

# notifications

_notifications-list () {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -z|-U|-l|-o|-H|-h) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(notifications-search --filter=id id.like=${cur}*)" -- $cur)) ;;
    esac
}

_notifications-addupdate() {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -R) COMPREPLY=($(compgen -W "IMMEDIATE DELAYED EXPONENTIAL" -- $cur)) ;;
        -z|-F|-U|-E|-D|-L|-I|-A|-H|-h) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(notifications-search --filter=id id.like=${cur}*)" -- $cur)) ;;
    esac
}

complete -F _notifications-list notifications-list notifications-delete notifications-fire notifications-list-failures
complete -F _notifications-addupdate notifications-addupdate

# systems

_systems-list () {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -z|-U|-l|-o|-H|-h) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(systems-search --filter=id id.like=${cur})" -- $cur)) ;;
    esac
}

_systems-roles-update () {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -u) COMPREPLY=($(compgen -W "$(profiles-list -v --filter=username -U ${cur} | grep "\"username\"" | sed 's/"//g' | sed 's/username\://g' | sed 's/ //g')" -- $cur)) ;;
        -p) COMPREPLY=($(compgen -W "GUEST USER PUBLISHER ADMIN OWNER NONE" -- $cur)) ;;
        -z|-u|-H|-h) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(systems-list --filter=id id.like=${cur}*)" -- $cur)) ;;
    esac
}

complete -F _systems-list systems-list systems-addupdate systems-clone systems-delete systems-erase systems-history systems-disable systems-setdefault systems-unpublish systems-unsetdefault
complete -F _systems-roles-update systems-roles-update systems-roles-delete systems-roles-list systems-credentials-addupdate systems-credentials-list systems-credentials-delete

# profiles commands
_profiles-list () {
    COMPREPLY=()
    local prev cur
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    case "$prev" in
        -E) COMPREPLY=($(compgen -W "$(profiles-list -v --filter=email -E ${cur} | grep "\"email\"" | sed 's/"//g' | sed 's/email\://g' | sed 's/ //g')" -- $cur)) ;;
        -N) COMPREPLY=($(compgen -W "$(profiles-list -v --filter=full_name,fullName -N ${cur} | grep "\"[full_name|fullName]\"" | sed 's/"//g' | sed 's/full_name\://g' | sed 's/fullName\://g' | sed 's/ //g')" -- $cur)) ;;
        -U) COMPREPLY=($(compgen -W "$(profiles-list -v --filter=username -U ${cur} | grep "\"username\"" | sed 's/"//g' | sed 's/username\://g' | sed 's/ //g')" -- $cur)) ;;
        -z|-l|-o|-H|-h) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=($(compgen -W "$(profiles-list -v --filter=username -U ${cur} | grep "\"username\"" | sed 's/"//g' | sed 's/username\://g' | sed 's/ //g')" -- $cur)) ;;
    esac
}

complete -F _profiles-list profiles-list

# files listings
# profiles commands
_files-list () {
    source $(which common.sh)

    COMPREPLY=()
    local prev cur _searchdir _cmd _cmd
    cur=${COMP_WORDS[COMP_CWORD]}
    prev=${COMP_WORDS[COMP_CWORD-1]}

    searchdir=$(echo "${cur}" | sed 's#/$#/.#' | xargs dirname)
    cmd=$(echo ${COMP_LINE} | sed 's#--filter=[^ ]* ##g' | sed 's#-V ##g' | sed 's#-v ##g' | sed 's#-L ##g' |sed 's#-l [0-9]*##g' | sed 's#--limit [0-9]*##g' | sed 's#-o [0-9]*##g' | sed 's#-offset [0-9]*##g' | sed 's#--veryverbose ##g' | sed 's#'$cur'#-v --filter=name,path,type,_links.self '${searchdir}'#g')
    cmd="$(dirname `which files-list`)/${cmd}"

    file_filter=''
    if [[ "$searchdir" != "$cur" ]]; then
        file_filter=$(basename $cur)
    fi

#    echo -e "\nlisting $searchdir for completion options"
    case "$prev" in
        -S) COMPREPLY=($(compgen -W "$(systems-search --filter=id id.like=${cur}* | awk '{print $1}')" -- $cur)) ;;
        -z|-l|-L|-o|-H|-h) COMPREPLY=($(compgen -f $cur)) ;;
        *) COMPREPLY=( $( __dir_list "${cmd}" | grep "$cur") ) ;;
    esac

}

function __dir_list() {

    local ac_response
    ac_response="$($1)"
    file_types=($(jsonquery "$ac_response" ".[].type"))
    file_names=($(jsonquery "$ac_response" ".[].name"))
    file_paths=($(jsonquery "$ac_response" ".[]._links.self.href"))
    #set -x
    ac_index=-1
    for p in "${file_paths[@]}"; do
        ac_index=$[ac_index+1]
        # pull the path out of the canonical url
        canonical_path=$(echo "$p"| sed 's#'.*/system/[^/]*/##g)
#        if [[ -z "${file_name[$ac_index]}" ]] || [[ "${file_name[$ac_index]}" = "." ]]; then
#            file_paths[$ac_index]="${canonical_path%/}/"
#        el
#        set -x
        if [[ "${file_types[$ac_index]}" = "dir" ]]; then
            file_paths[$ac_index]="${canonical_path%/}/"
        else
            file_paths[$ac_index]="${canonical_path}"
        fi
        echo "${file_paths[$ac_index]}"
#        set +x
    done
#echo "$file_paths"
    #set +x
}

complete -F _files-list files-list
