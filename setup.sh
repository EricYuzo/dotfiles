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
    exit 1
}


# variables {
all=no
dev=no

BASEDIR=$(dirname $0)
CONFIGDIR="$BASEDIR/config"
EXITCODE=0
PROGRAM=$(basename $0)

DOT_FILES=(bash_aliases tmux.conf vimrc gitignore_global gitconfig)
NEL_DIR=~/.vim/colors
NEL_URL=https://raw.githubusercontent.com/EricYuzo/nel/master/colors/nel.vim
# }


# option parsing {{
while [ $# -gt 0 ]
do
    case $1 in
        --all | -a )
            all=yes
            ;;
        --dev )
            dev=yes
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
config_dotfiles "${DOT_FILES[@]}"

exit $EXITCODE
# }}}
