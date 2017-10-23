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
    echo "IMPORTANT: As this script globally install packages,"
    echo "           it requires root permissions."
    echo
    echo "Available options:"
    echo "  -a, --all               setup all available environments"
    echo "  -h, --help              display this help and exit"
    echo "      --gis               install GIS tools"
    echo "      --java              install Java environment"
    echo "      --node              setup NodeJS environment"
    echo "      --nodejs"
    echo "      --py                setup python environment"
    echo "      --python"
    echo "      --R                 setup R environment"
    echo "      --vbox              install VirtualBox"
    echo "      --virtualbox"
    echo "      --user=USERNAME     if set, add USERNAME into group 'vboxusers'"
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


# only root can run this script
check_root() {
    if [ $(whoami) != 'root' ] ; then
        error "This script requires root permissions!"
    fi
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


prepare() {
    apt_install build-essential gfortran libopenblas-base libopenblas-dev git tor dirmngr
}

install_python() {
    apt_install python3 python3-dev python3-pip
    pip_install ipython virtualenv
}

config_R_list() {
    # Instructions:
    # https://cran.r-project.org/bin/linux/debian/

    echo -n "Configuring R repository ...   "
    if echo "deb     http://vps.fmvz.usp.br/CRAN/bin/linux/debian stretch-cran34/" | tee /etc/apt/sources.list.d/cran.list > /dev/null 2>&1 \
            && echo "deb-src http://vps.fmvz.usp.br/CRAN/bin/linux/debian stretch-cran34/" | tee -a /etc/apt/sources.list.d/cran.list > /dev/null 2>&1 \
            && apt-key adv --keyserver keys.gnupg.net --recv-key E19F5F87128899B192B1A2C2AD5F960A256A04AF > /dev/null 2>&1 ; then
        echo "Done"
    else
        echo "Fail"
        EXITCODE=$((EXITCODE + 1))
    fi
}

install_R() {
    apt_install r-base r-base-dev
}

config_java_list() {
    # Instructions:
    # http://www.webupd8.org/2015/02/install-oracle-java-9-in-ubuntu-linux.html

    echo -n "Configuring Java repository ...   "
    if echo "deb     http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee /etc/apt/sources.list.d/java.list > /dev/null 2>&1 \
            && echo "deb-src http://ppa.launchpad.net/webupd8team/java/ubuntu xenial main" | tee -a /etc/apt/sources.list.d/java.list > /dev/null 2>&1 \
            && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys EEA14886 > /dev/null 2>&1 ; then
        echo "Done"
    else
        echo "Fail"
        EXITCODE=$((EXITCODE + 1))
    fi
}

install_java() {
    echo oracle-java9-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
    apt_install oracle-java9-installer
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

add_vboxuser() {
    echo -n "Adding user '$user' to group 'vboxusers' ...   "
    if adduser $user vboxusers > /dev/null 2>&1 ; then
        echo "Done"
    else
        echo "Fail"
        EXITCODE=$((EXITCODE + 1))
    fi
}

# variables {
all=no
python=no
rstat=no
java=no
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
        -java | --java )
            java=yes
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
        -user | --user )
            user=$2
            shift
            ;;
        -user=* | --user=* )
            user="${1#*=}"
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

check_root
# }}

# main {{{
prepare

# configure 3rd-party repositories
[ "$all" = "yes" -o  "$rstat" = "yes" ]  && config_R_list
[ "$all" = "yes" -o   "$java" = "yes" ]  && config_java_list
[ "$all" = "yes" -o "$nodejs" = "yes" ]  && config_nodejs_list
[ "$all" = "yes" -o   "$vbox" = "yes" ]  && config_vbox_list

# update apt list
apt_update

# install packages
[ "$all" = "yes" -o "$python" = "yes" ] && install_python
[ "$all" = "yes" -o  "$rstat" = "yes" ] && install_R
[ "$all" = "yes" -o   "$java" = "yes" ] && install_java
[ "$all" = "yes" -o "$nodejs" = "yes" ] && install_nodejs
[ "$all" = "yes" -o    "$gis" = "yes" ] && install_gis
[ "$all" = "yes" -o   "$vbox" = "yes" ] && install_vbox

# additional configuration
if [ -n "$user" ] ; then
    if getent passwd $user > /dev/null 2>&1 ; then
        add_vboxuser
    else
        warning "User '$user' was not found"
    fi
fi

exit $EXITCODE
# }}}
