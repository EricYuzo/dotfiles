#! /usr/bin/env bash

# copy files from config dir to user's home
config_dotfiles() {
    for f in "$@"
    do
        echo -n "Creating file ~/.$f ...   "
        if ! cmp $CONFIGDIR/$f ~/.$f > /dev/null 2>&1 ; then
            if cat $CONFIGDIR/$f > ~/.$f 2> /dev/null ; then
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
    echo "  -a, --all     include all available configuration files"
    echo "  -d, --dev     include files for development environment"
    echo "  -h, --help    display this help and exit"
    echo
    echo "Available configuration files (by environment):"
    echo "  default    (~/.bash_aliases, ~/.vimrc, ~/.tmux.conf)"
    echo "  dev        (~/.gitconfig, ~/.gitignore_global)"
}

# print usage message
usage() {
    echo "Usage: $PROGRAM [--all] [--dev] [--help]"
}


# variables {
dev=no

BASEDIR=$(dirname $0)
CONFIGDIR="$BASEDIR/config"
EXITCODE=0
PROGRAM=$(basename $0)

DOTFILES=(\
    bash_aliases\
    tmux.conf\
    vimrc\
)
DEV_DOTFILES=(\
    gitconfig\
    gitignore_global\
)
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
download $NEL_URL $NEL_DIR
config_dotfiles "${DOTFILES[@]}"
[ "$dev" = "yes" ] && config_dotfiles "${DEV_DOTFILES[@]}"

exit $EXITCODE
# }}}
