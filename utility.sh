#
# General utility functions
#

#if [ $# -gt 0 ]; then
#    echo "Script arguments passed: $@"
#    echo "Ignoring script arguments."
#fi

declare -g flag_utility=0

# Debugging flag
declare -g flag_debug_mode=0



#
# Display warning message in yellow
#
echo_warn() {
    local color_iyellow='\033[0;93m'
    local color_off='\033[0m'
    echo -e "${color_iyellow}Error: ${@}${color_off}"
}

#
# Display error message in red
#
echo_error() {
    local color_red='\033[0;31m'
    local color_off='\033[0m'
    echo -e "${color_red}Error: ${@}${color_off}"
}

#
# Display message if debugging flag is set
#
echo_debug() {
    if [ ${flag_debug_mode} -gt 0 ]; then
        echo "Debug: ${@}"
    fi
}

#
# Silence pushd
#
pushd() {
    command pushd "$@" > /dev/null
}

#
# Silence popd
#
popd() {
    command popd "$@" > /dev/null
}

#
# Convert specified string argument to lowercase
#
to_lowercase() {
    echo "$(echo ${1} | tr 'A-Z' 'a-z')"
}
