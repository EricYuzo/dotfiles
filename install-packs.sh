#! /usr/bin/env bash

# print error message and exit
error() {
    echo "$@" 1>&2
    usage
    exit 1
}

# print help message
showhelp() {
    echo "Usage: $PROGRAM [OPTION] FILE..."
    echo
    echo "Install the apt packages listed in each FILE."
    echo
    echo "FILE is a text file containing the names of packages to be installed."
    echo
    echo "Available options:"
    echo "  -a, --all     install all listed tools"
    echo "  -h, --help    display this help and exit"
}

# print usage message
usage() {
    echo "Usage: $PROGRAM [OPTION]... FILE..."
    echo "Try '$PROGRAM --help' for more information."
}

# print warning message
warning(){
    echo "W: $@" 1>&2
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
all=no
groups=("default")

EXITCODE=0
PROGRAM=$(basename $0)

PACKS_DIR="$(dirname $0)/packs.list"
# }


# option parsing {{
while [ $# -gt 0 ]
do
    case $1 in
        --all | -a )
            all=yes
            groups=( $(ls -1 $PACKS_DIR) )
            ;;
        --help | -h )
            showhelp
            exit 0
            ;;
        *)
            [ "$all" = "no" ] && groups+=("$1")
            ;;
    esac
    shift
done
# }}

# main {{{
configure_aptlist
apt_update
for g in ${groups[@]}
do
    if [ -f "$PACKS_DIR/$g" ] ; then
        apt_install $(cat $PACKS_DIR/$g)
    else
        warning "File $PACKS_DIR/$g not found"
    fi
done

exit $EXITCODE
# }}}
