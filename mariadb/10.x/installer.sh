#!/usr/bin/env bash
#+----------------------------------------------------------------------------+
#+ ServerAdmin MariaDB Auto-Installer for Ubuntu
#+----------------------------------------------------------------------------+
#+ Author:      Jonathan Tittle
#+ Copyright:   2017 ServerAdmin.sh and Jonathan Tittle
#+ GitHub:      https://github.com/serveradminsh/serveradmin-installers
#+ Issues:      https://github.com/serveradminsh/serveradmin-installers/issues
#+ License:     GPL v3.0
#+ OS:          Ubuntu 16.04, Ubuntu 16.10
#+ Release:     1.0.0
#+ Website:     https://serveradmin.sh
#+----------------------------------------------------------------------------+
clear

#+----------------------------------------------------------------------------+
#+ Check current users ID. If user is not 0 (root), exit.
#+----------------------------------------------------------------------------+
if [ "${EUID}" != 0 ];
then
    echo "ServerAdmin MariaDB Auto-Installer should be executed as the root user."
    exit
fi

if [ ! -f "/etc/lsb-release" ];
then
    echo "ServerAdmin MariaDB Auto-Installer could not find /etc/lsb-release"
    exit
fi

source /etc/lsb-release

if [ "${DISTRIB_RELEASE}" == "16.10" ];
then
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 \
    && add-apt-repository 'deb [arch=amd64,i386] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu yakkety main' \
    && apt-get update \
    && apt-get -y install mariadb-server \
    && mysql_secure_installation
elif [ "${DISTRIB_RELEASE}" == "16.04" ];
then
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8 \
    && add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu xenial main' \
    && apt-get update \
    && apt-get -y install mariadb-server \
    && mysql_secure_installation
elif [ "${DISTRIB_RELEASE}" == "14.04" ];
then
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db \
    && add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://nyc2.mirrors.digitalocean.com/mariadb/repo/10.1/ubuntu trusty main' \
    && apt-get update \
    && apt-get -y install mariadb-server \
    && mysql_secure_installation
else
    echo "ServerAdmin MariaDB Auto-Installer currently supports Ubuntu 14.04, 16.04, and 16.10."
    echo "Ubuntu Version found was ${DISTRIB_RELEASE}"
    exit
fi