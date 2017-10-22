#! /usr/bin/env bash

# print error message and exit
error() {
    echo "Error: $@" 1>&2
    usage
    exit 1
}

# print help message
showhelp() {
    echo "Usage: $PROGRAM [OPTION]... DIR..."
    echo
    echo "Copy configuration files from each DIR to current user's home directory."
    echo
    echo "DIR is a directory containing 'dot files' (without the initial dot)."
    echo "These directories must be placed in a predefined search path."
    echo "The search path is, by default, the directory 'dotfiles'."
    echo "You can use -p option to specify a new search path."
    echo
    echo "Available options:"
    echo "  -a, --all          include all available dot files"
    echo "  -h, --help         display this help and exit"
    echo "  -p, --path=PATH    PATH is the new search path"
}

# print usage message
usage() {
    echo "Usage: $PROGRAM [OPTION]... FILE..."
    echo "Try '$PROGRAM --help' for more information."
}

# print warning message
warning() {
    echo "Warning: $@" 1>&2
}


# copy files from $1 dir to current user's home
copy_dotfiles() {
    for f in $1/*
    do
        f=$(basename $f)
        echo -n "Creating file ~/.$f ...   "
        if ! cmp $1/$f ~/.$f > /dev/null 2>&1 ; then
            if cp -r $1/$f ~/.$f 2> /dev/null ; then
                echo "Done"
            else
                echo "Fail"
                EXITCODE=$((EXITCODE + 1))
            fi
        else
            echo "Nothing to do"
        fi
    done
}


# variables {
all=no
groups=("default")
searchpath="$(dirname $0)/dotfiles"

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
for g in ${groups[@]}
do
    if [ -d "$searchpath/$g" ] ; then
        copy_dotfiles "$searchpath/$g"
    else
        warning "Directory $searchpath/$g not found"
    fi
done

exit $EXITCODE
# }}}
