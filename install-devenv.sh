#! /usr/bin/env bash

# print error message and exit
error() {
    echo "Error: $@" 1>&2
    usage
    exit 1
}

# print help message
showhelp() {
    echo "Usage: $PROGRAM [OPTION]..."
    echo
    echo "Install some basic development environments."
    echo
    echo "Available options:"
    echo "  -a, --all       install all available development environments"
    echo "  -h, --help      display this help and exit"
    echo "      --py        install python environment"
    echo "      --python"
}

# print usage message
usage() {
    echo "Usage: $PROGRAM [OPTION]..."
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

pip_install() {
    echo -n "Running 'pip3 install -U $@' ...   "
    if pip3 install -U "$@" > /dev/null 2>&1 ; then
        echo "Done"
    else
        echo "Fail"
        EXITCODE=$((EXITCODE + 1))
    fi
}

install_default() {
    apt_install build-essential git tor
}

install_python() {
    apt_install python3 python3-dev python3-pip
    pip_install ipython virtualenv
}

# variables {
all=no
python=no

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
        -py | --py | -python | --python )
            python=yes
            ;;
        -h | --help )
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
install_default
[ "$all" = "yes" -o "$python" = "yes" ] && install_python

exit $EXITCODE
# }}}
