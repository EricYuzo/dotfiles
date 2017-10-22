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
    echo "Setup some basic development environments."
    echo
    echo "Available options:"
    echo "  -a, --all       setup all available development environments"
    echo "  -h, --help      display this help and exit"
    echo "      --node      setup NodeJS environment"
    echo "      --nodejs"
    echo "      --py        setup python environment"
    echo "      --python"
    echo "      --R         setup R environment"
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
    apt_install build-essential gfortran libopenblas-base libopenblas-dev git tor
}

install_python() {
    apt_install python3 python3-dev python3-pip
    pip_install ipython virtualenv
}

install_R() {
    apt_install r-base r-base-dev
}

config_nodejs_repo() {
    # Instructions:
    # https://nodejs.org/en/download/package-manager/

    echo -n "Configuring NodeJS repository ...   "
    if \curl -sL https://deb.nodesource.com/setup_8.x | bash - > /dev/null 2>&1 ; then
        echo "Done"
    else
        echo "Fail"
        EXITCODE=$((EXITCODE + 1))
    fi
}

install_nodejs() {
    apt_install nodejs
}

# variables {
all=no
python=no
rstat=no
nodejs=no

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
        -R | --R )
            rstat=yes
            ;;
        -node | --node | -nodejs | --nodejs )
            nodejs=yes
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
[ "$all" = "yes" -o "$nodejs" = "yes" ]  && config_nodejs_repo
apt_update

install_default
[ "$all" = "yes" -o "$python" = "yes" ] && install_python
[ "$all" = "yes" -o  "$rstat" = "yes" ] && install_R
[ "$all" = "yes" -o "$nodejs" = "yes" ] && install_nodejs

exit $EXITCODE
# }}}
