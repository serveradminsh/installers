#!/usr/bin/env bash
#+----------------------------------------------------------------------------+
#+ ServerAdmin PHP 7.1.x Auto-Installer for Ubuntu
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
    echo "ServerAdmin PHP Auto-Installer should be executed as the root user."
    exit
fi

phpPackages="php7.1-cli php7.1-dev php7.1-fpm php7.1-bcmath php7.1-bz2 php7.1-common php7.1-curl php7.1-gd php7.1-gmp php7.1-imap php7.1-intl php7.1-json php7.1-mbstring php7.1-mysql php7.1-readline php7.1-recode php7.1-soap php7.1-sqlite3 php7.1-xml php7.1-xmlrpc php7.1-zip php7.1-opcache php7.1-xsl"

if ls -U /etc/apt/sources.list.d | grep ondrej > /dev/null 2>&1;
then
    echo "PHP Repository already exists. Updating/Syncing packages and then exiting."
    apt-get update
    exit;
else
    apt-get update \
    && apt-get -y upgrade \
    && add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get -y install ${phpPackages}
fi