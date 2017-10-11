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
    echo "  --gui         install graphical tools"
    echo "  -h, --help    display this help and exit"
    echo
    echo "Supported groups of tools:"
    echo "  gui (X11 interface)"
}

# print usage message
usage() {
    echo "Usage: $PROGRAM [OPTION]..."
    echo "Try '$PROGRAM --help' for more information."
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

configure_aptlist() {
    echo -n "Configuring /etc/apt/sources.list components ...   "
    if egrep 'main$' /etc/apt/sources.list > /dev/null ; then
        # include contrib and non-free components
        if sed -i -e 's/ main$/ main contrib non-free/g' /etc/apt/sources.list 2> /dev/null ; then
            echo "Done"
        else
            echo "Fail"
            EXITCODE=$((EXITCODE + 1))
        fi
    else
        echo "Nothing to do"
    fi
}


# variables {
gui=no

EXITCODE=0
PROGRAM=$(basename $0)

PACKS_DIR="$(dirname $0)/packs.list"
# }


# option parsing {{
while [ $# -gt 0 ]
do
    case $1 in
        --all | -a )
            gui=yes
            ;;
        --gui )
            gui=yes
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
configure_aptlist
apt_update
apt_install $(cat $PACKS_DIR/default)
[ "$gui" = "yes" ] && apt_install $(cat $PACKS_DIR/gui)

exit $EXITCODE
# }}}
