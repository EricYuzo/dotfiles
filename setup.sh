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

error() {
    >&2 cat <<< "$@"
    exit 1
}


# variables {
BASEDIR=${0%/*}
CONFIGDIR="$BASEDIR/config"
DOT_FILES=(bash_aliases tmux.conf vimrc gitignore_global gitconfig)
PROGRAM=${0##*/}
# }


# main {{{
config_dotfiles "${DOT_FILES[@]}"
# }}}
