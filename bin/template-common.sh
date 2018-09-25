# template-common.sh

if [[ -z "$DIR" ]]; then
    DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

# Expectation: DIR = bin/ directory where commands live
#    and templates is a sibling to bin/
TEMPLATES_DIR="${DIR}/../etc/templates.d"

#
# Helps add template support to any Agave CLI expecting a file upload

# global variables expected
#   DIR
#   filetoupload
#   notemplate
#   variablesfile
#   envvars

# function render_template() {

#     if ((! notemplate)); then

#         template_output=$(mktemp)
#         templateargs=""
#         if ((verbose)); then
#             templateargs="--debug"
#         fi

#         local vars=app.ini
#         if [ ! -z "$variablesfile" ]; then
#             vars=$variablesfile
#         fi
#         if [ ! -f $vars ]; then
#             warning "File $vars not found. Some template variables may not render properly."
#         else
#             templateargs="$templateargs --variables $vars"
#         fi

#         # surely there's a more elegant way to do this
#         # but everything ive tried causes wierd escaping of envvars
#         if [ ! -z "${envvars}" ]; then
#             export $envvars ; python "$DIR/libs/python/rendertemplate.py" $templateargs --blank-empty $filetoupload $template_output
#         else
#             python "$DIR/libs/python/rendertemplate.py" $templateargs --blank-empty $filetoupload $template_output
#         fi

#         if [ "?$" != 0 ]; then
#             filetoupload=$template_output
#         else
#             warning "Errors encountered in rendering $filetoupload"
#             less $template_output
#             safe_exit
#         fi
#     fi

# }


function get_ini_section_value() {

    section="$1"
    field="$2"
    override_vars="$3"
    vars=$variablesfile

    if [ ! -z "${override_vars}" ]; then
        vars=${override_vars}
    fi
    if [ ! -f $vars ]; then
        err "File ${vars} not found."
    fi

    readargs="--debug --no-empty "
    if [ ! -z "${section}" ]; then
         readargs="--section ${section}"
    fi

    result=`python "${DIR}/libs/python/readvalfromini.py" --variables ${vars} ${readargs} --field ${field}`
    if [ "$?" == 0 ]; then
        printf "${result}"
    else
        err "Error reading [${section}]:${field} from $(basename ${vars})"
    fi
}
