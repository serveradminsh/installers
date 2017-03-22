#!/usr/bin/env bash
#+----------------------------------------------------------------------------+
#+ ServerAdmin PHP 7.0.x Auto-Installer for Ubuntu
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

phpPackages="php7.0-cli php7.0-common php7.0-curl php7.0-dev php7.0-gd php7.0-gmp php7.0-json php7.0-mysql php7.0-opcache php7.0-pspell php7.0-readline php7.0-recode php7.0-sqlite3 php7.0-tidy php7.0-xml php7.0-xmlrpc php7.0-bcmath php7.0-bz2 php7.0-enchant php7.0-fpm php7.0-imap php7.0-interbase php7.0-intl php7.0-mbstring php7.0-mcrypt php7.0-soap php7.0-xsl php7.0-zip"

if ls -U /etc/apt/sources.list.d | grep ondrej > /dev/null 2>&1;
then
    echo "PHP Repository already exists. Updating/Syncing packages and then exiting."
    apt-get update
    exit;
else
    add-apt-repository -y ppa:ondrej/php \
    && apt-get update \
    && apt-get -y install "${phpPackages}"
fi