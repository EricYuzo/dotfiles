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
    echo "  -a, --all           setup all available development environments"
    echo "  -h, --help          display this help and exit"
    echo "      --gis           install GIS tools"
    echo "      --node          setup NodeJS environment"
    echo "      --nodejs"
    echo "      --py            setup python environment"
    echo "      --python"
    echo "      --R             setup R environment"
    echo "      --vbox          install VirtualBox"
    echo "      --virtualbox"
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

npm_install() {
    echo -n "Running 'npm install -g $@' ...   "
    if npm install -g "$@" > /dev/null 2>&1 ; then
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

config_nodejs_list() {
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

install_gis() {
    apt_install gdal-bin libgdal-dev
    npm_install topojson mapshaper
}

config_vbox_list() {
    # Instructions:
    # https://www.virtualbox.org/wiki/Linux_Downloads
    # https://wiki.debian.org/VirtualBox

    echo -n "Configuring VirtualBox repository ...   "
    if echo "deb http://download.virtualbox.org/virtualbox/debian stretch contrib" | tee /etc/apt/sources.list.d/vbox.list > /dev/null 2>&1 \
            && wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add - > /dev/null 2>&1 ; then
        echo "Done"
    else
        echo "Fail"
        EXITCODE=$((EXITCODE + 1))
    fi
}

install_vbox() {
    #apt_install virtualbox-4.3 dkms
    apt_install virtualbox-5.1 dkms
}

# variables {
all=no
python=no
rstat=no
nodejs=no
gis=no
vbox=no

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
        -gis | --gis )
            gis=yes
            nodejs=yes # require npm
            ;;
        -vbox | --vbox | -virtualbox | --virtualbox )
            vbox=yes
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
[ "$all" = "yes" -o "$nodejs" = "yes" ]  && config_nodejs_list
[ "$all" = "yes" -o   "$vbox" = "yes" ]  && config_vbox_list
apt_update

install_default
[ "$all" = "yes" -o "$python" = "yes" ] && install_python
[ "$all" = "yes" -o  "$rstat" = "yes" ] && install_R
[ "$all" = "yes" -o "$nodejs" = "yes" ] && install_nodejs
[ "$all" = "yes" -o    "$gis" = "yes" ] && install_gis
[ "$all" = "yes" -o   "$vbox" = "yes" ] && install_vbox

exit $EXITCODE
# }}}
