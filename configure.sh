#! /usr/bin/env bash

# download file from $1 to $2 directory
download() {
    echo -n "Downloading $(basename $1) ...   "
    if wget -qcP $2 $1 ; then
        echo "Done"
    else
        echo "Fail"
        EXITCODE=$((EXITCODE + 1))
    fi
}

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
    echo "Create configuration files for some programs according to chosen environments."
    echo
    echo "Available options:"
    echo "  -a, --all     include all available files"
    echo "  -d, --dev     include files for development environment"
    echo "  -h, --help    display this help and exit"
    echo
    echo "Supported environments:"
    echo "  default (always created)"
    echo "  dev (development)"
}

# print usage message
usage() {
    echo "Usage: $PROGRAM [--all] [--dev] [--help]"
}

# print warning message
warning() {
    echo "Warning: $@" 1>&2
}

# copy files from $1 dir to current user's home
config_dotfiles() {
    for f in $1/*
    do
        f=$(basename $f)
        echo -n "Creating file ~/.$f ...   "
        if ! cmp $1/$f ~/.$f > /dev/null 2>&1 ; then
            if cat $1/$f > ~/.$f 2> /dev/null ; then
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

NEL_DIR=~/.vim/colors
NEL_URL=https://raw.githubusercontent.com/EricYuzo/nel/master/colors/nel.vim
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
download $NEL_URL $NEL_DIR
for g in ${groups[@]}
do
    if [ -d "$searchpath/$g" ] ; then
        config_dotfiles "$searchpath/$g"
    else
        warning "Directory $searchpath/$g not found"
    fi
done

exit $EXITCODE
# }}}
