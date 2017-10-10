#/usr/bin/env bash

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


# variables {
BASEDIR=$(dirname $0)
CONFIGDIR="$BASEDIR/config"
EXITCODE=0
PROGRAM=$(basename $0)

DOT_FILES=(bash_aliases tmux.conf vimrc gitignore_global gitconfig)
NEL_DIR=~/.vim/colors
NEL_URL=https://raw.githubusercontent.com/EricYuzo/nel/master/colors/nel.vim
# }


# main {{{
download $NEL_URL $NEL_DIR
config_dotfiles "${DOT_FILES[@]}"

exit $EXITCODE
# }}}
