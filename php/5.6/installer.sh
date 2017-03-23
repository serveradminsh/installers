#!/usr/bin/env bash
#+----------------------------------------------------------------------------+
#+ ServerAdmin PHP 5.6.x Auto-Installer for Ubuntu
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

phpPackages="php5.6-cli php5.6-fpm php5.6-dev php5.6-common php5.6-curl php5.6-gd php5.6-imap php5.6-intl php5.6-mysql php5.6-pspell php5.6-recode php5.6-sqlite3 php5.6-tidy php5.6-opcache php5.6-json php5.6-bz2 php5.6-mcrypt php5.6-readline php5.6-xmlrpc php5.6-enchant php5.6-gmp php5.6-xsl php5.6-bcmath php5.6-mbstring php5.6-soap php5.6-xml php5.6-zip"

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