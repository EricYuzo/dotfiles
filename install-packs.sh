#! /usr/bin/env bash

# print error message and exit
error() {
    echo "Error: $@" 1>&2
    usage
    exit 1
}

# print help message
showhelp() {
    echo "Usage: $PROGRAM [OPTION]... FILE..."
    echo
    echo "Install the apt packages listed in each FILE."
    echo
    echo "FILE is a text file containing the names of packages to be installed."
    echo "These files must be placed in a predefined search path."
    echo "The search path is, by default, the directory 'packs.list'."
    echo "You can use -p option to specify a new search path."
    echo
    echo "Available options:"
    echo "  -a, --all          install the packages listed in all files"
    echo "  -h, --help         display this help and exit"
    echo "  -p, --path=PATH    PATH is the new search path"
}

# print usage message
usage() {
    echo "Usage: $PROGRAM [OPTION]... FILE..."
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
searchpath="$(dirname $0)/packs.list"

EXITCODE=0
PROGRAM=$(basename $0)
# }


# option parsing {{
while [ $# -gt 0 ]
do
    case $1 in
        -a | --all )
            all=yes
            ;;
        -p | --path )
            searchpath=$2
            shift
            ;;
        --path=* )
            searchpath="${1#*=}"
            ;;
        -h | --help )
            showhelp
            exit 0
            ;;
        *)
            [ "$all" = "no" ] && groups+=("$1")
            ;;
    esac
    shift
done

if ! [ -d "$searchpath" ] ; then
    error "Cannot access search path: '$searchpath'"
fi

[ "$all" = "yes" ] && groups=( $(ls -1 $searchpath) )
# }}

# main {{{
configure_aptlist
apt_update
for g in ${groups[@]}
do
    if [ -f "$searchpath/$g" ] ; then
        apt_install $(cat $searchpath/$g)
    else
        warning "File $searchpath/$g not found"
    fi
done

exit $EXITCODE
# }}}
