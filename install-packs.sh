#! /usr/bin/env bash

# print error message and exit
error() {
    echo "$@" 1>&2
    usage
    exit 1
}

# print help message
showhelp() {
    echo "Usage: $PROGRAM [OPTION]..."
    echo
    echo "Install a bunch of tools according to chosen groups."
    echo
    echo "Available options:"
    echo "  -a, --all     install all listed tools"
    echo "  -d, --dev     install development tools"
    echo "  -h, --help    display this help and exit"
    echo
    echo "Supported groups of tools:"
    echo "  dev (development)"
}

# print usage message
usage() {
    echo "Usage: $PROGRAM [--all] [--dev] [--help]"
}


# variables {
dev=no

EXITCODE=0
PROGRAM=$(basename $0)
# }


# option parsing {{
while [ $# -gt 0 ]
do
    case $1 in
        --all | -a )
            dev=yes
            ;;
        --dev | -d )
            dev=yes
            ;;
        --help | -h )
            showhelp
            exit 0
            ;;
        -*)
            error "Unrecognized option: $1"
            ;;
        *)
            break
            ;;
    esac
    shift
done
# }}

# main {{{
# do some stuff here

exit $EXITCODE
# }}}
