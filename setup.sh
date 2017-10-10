#/usr/bin/env bash

# copy files from config dir to user's home
config_dotfiles() {
    for f in "$@" ; do
        if ! cmp $CONFIGDIR/$f ~/.$f > /dev/null 2>&1 ; then
            cp $CONFIGDIR/$f ~/.$f \
                && chmod 644 ~/.$f \
                || error "$PROGRAM: failed to configure ~/.$f"
        fi
    done
}

# download file from $1 to $2 directory
download() {
    echo -n "Downloading $(basename $1) ...   "
    if wget -qcP $2 $1
    then
        echo "Done"
        return 0
    else
        echo "Fail"
        return 1
    fi
}

error() {
    >&2 cat <<< "$@"
    exit 1
}


# variables {
BASEDIR=$(dirname $0)
CONFIGDIR="$BASEDIR/config"
DOT_FILES=(bash_aliases tmux.conf vimrc gitignore_global gitconfig)
NEL_DIR=~/.vim/colors
NEL_URL=https://raw.githubusercontent.com/EricYuzo/nel/master/colors/nel.vim
PROGRAM=$(basename $0)
# }


# main {{{
download $NEL_URL $NEL_DIR
config_dotfiles "${DOT_FILES[@]}"
# }}}
