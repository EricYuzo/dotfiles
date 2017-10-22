#! /usr/bin/env bash

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


# variables {
dev=no

EXITCODE=0
PROGRAM=$(basename $0)

BASEDIR="$(dirname $0)/templates"
DEFAULT_DIR="$BASEDIR/default"
DEV_DIR="$BASEDIR/dev"
NEL_DIR=~/.vim/colors
NEL_URL=https://raw.githubusercontent.com/EricYuzo/nel/master/colors/nel.vim
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
        *)
            # unknown
            ;;
    esac
    shift
done
# }}

# main {{{
download $NEL_URL $NEL_DIR
config_dotfiles "$DEFAULT_DIR"
[ "$dev" = "yes" ] && config_dotfiles "$DEV_DIR"

exit $EXITCODE
# }}}
