#!/usr/bin/env bash
#+----------------------------------------------------------------------------+
#+ ServerAdmin NodeJS 6.x Auto-Installer for Ubuntu
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

if [ "${EUID}" != 0 ];
then
    echo "ServerAdmin NodeJS Auto-Installer should be executed as the root user."
    exit
fi

cd /opt \
&& curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - \
&& apt-get install -y nodejs