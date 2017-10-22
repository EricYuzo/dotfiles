#! /usr/bin/env bash

# print error message and exit
error() {
    echo "Error: $@" 1>&2
    usage
    exit 1
}

# print help message
showhelp() {
    echo "Usage: $PROGRAM [OPTION]..."
    echo
    echo "Nothing here. Sorry pal. =("
}

# print usage message
usage() {
    echo "Usage: $PROGRAM [OPTION]..."
    echo "Try '$PROGRAM --help' for more information."
}

# print warning message
warning(){
    echo "Warning: $@" 1>&2
}


apt_install() {
    echo -n "Running 'apt-get install -y $@' ...   "
    if apt-get install -y "$@" > /dev/null 2>&1 ; then
        echo "Done"
    else
        echo "Fail"
        EXITCODE=$((EXITCODE + 1))
    fi
}

apt_update() {
    echo -n "Running 'apt-get update' ...   "
    if apt-get update > /dev/null 2>&1 ; then
        echo "Done"
    else
        echo "Fail"
        EXITCODE=$((EXITCODE + 1))
    fi
}

prepare() {
    apt_install build-essential git
}

# variables {
EXITCODE=0
PROGRAM=$(basename $0)
# }


# option parsing {{
while [ $# -gt 0 ]
do
    case $1 in
        -h | --help )
            showhelp
            exit 0
            ;;
        *)
            # unknown
            ;;
    esac
    shift
done
# }}

# main {{{
prepare

exit $EXITCODE
# }}}
