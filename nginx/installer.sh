#!/usr/bin/env bash
#+----------------------------------------------------------------------------+
#+ ServerAdmin NGINX (Mainline) Auto-Installer for Ubuntu
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

#+----------------------------------------------------------------------------+
#+ The purpose of this script is to automate a source compile and install of
#+ NGINX's Mainline release. Included with this script configuration examples
#+ for SSL, Proxy, PHP, and Standard HTTP. You'll find those in:
#+
#+ ./nginx/examples
#+
#+ NGINX is compiled against the latest releases of OpenSSL, PCRE, and ZLIB
#+ as a part of the compile process. Additionally, the following modules are
#+ also statically compiled in with NGINX:
#+
#+ NGINX Devel Kit
#+ - https://github.com/simpl/ngx_devel_kit
#+
#+ NGINX Headers More
#+ - https://github.com/openresty/headers-more-nginx-module
#+
#+ NGINX VTS Module
#+ - https://github.com/vozlt/nginx-module-vts
#+
#+ NGINX Brotli
#+ - https://github.com/google/ngx_brotli
#+----------------------------------------------------------------------------+
clear

#+----------------------------------------------------------------------------+
#+ Check current users ID. If user is not 0 (root), exit.
#+----------------------------------------------------------------------------+
if [ "${EUID}" != 0 ];
then
    echo "ServerAdmin NGINX Auto-Installer should be executed as the root user."
    exit
fi

#+----------------------------------------------------------------------------+
#+ Pre-Configuration
#+----------------------------------------------------------------------------+
cpuCount=$(nproc --all)
currentPath="${PWD}"
dhparamBits="4096"
nginxUser="nginx"
openSslVers="1.0.2k"
pagespeedVers="1.12.34.2"
pcreVers="8.40"
zlibVers="1.2.11"

#+----------------------------------------------------------------------------+
#+ Setup
#+----------------------------------------------------------------------------+
nginxSetup()
{
    #+------------------------------------------------------------------------+
    #+ 1). Update/Sync Repositories
    #+ 2). Upgrading Existing Packages
    #+ 3). Install Packages for Build Environment
    #+------------------------------------------------------------------------+
    apt-get update \
    && apt-get -y upgrade \
    && apt-get -y install autoconf automake bc bison build-essential ccache cmake curl dh-systemd flex gcc geoip-bin google-perftools g++ icu-devtools letsencrypt libacl1-dev libbz2-dev libcap-ng-dev libcap-ng-utils libcurl4-openssl-dev libdmalloc-dev libenchant-dev libevent-dev libexpat1-dev libfontconfig1-dev libfreetype6-dev libgd-dev libgeoip-dev libghc-iconv-dev libgmp-dev libgoogle-perftools-dev libice-dev libice6 libicu-dev libjbig-dev libjpeg-dev libjpeg-turbo8-dev libjpeg8-dev libluajit-5.1-2 libluajit-5.1-common libluajit-5.1-dev liblzma-dev libmhash-dev libmhash2 libmm-dev libncurses5-dev libnspr4-dev libpam0g-dev libpcre3 libpcre3-dev libperl-dev libpng-dev libpng12-dev libpthread-stubs0-dev libreadline-dev libselinux1-dev libsm-dev libsm6 libssl-dev libtidy-dev libtiff5-dev libtiffxx5 libtool libunbound-dev libvpx-dev libvpx3 libwebp-dev libx11-dev libxau-dev libxcb1-dev libxdmcp-dev libxml2-dev libxpm-dev libxslt1-dev libxt-dev libxt6 make nano perl pkg-config software-properties-common systemtap-sdt-dev unzip webp wget xtrans-dev zip zlib1g-dev zlibc

    #+------------------------------------------------------------------------+
    #+ Check whether a user named nginx exists
    #+------------------------------------------------------------------------+
    local nginxUserExists=$(id -u ${nginxUser} > /dev/null 2>&1; echo $?)

    #+------------------------------------------------------------------------+
    #+ If the error code from nginxUserExists is not 0, we'll create the nginx
    #+ user, set the home directory (-d), and set the shell (-s).
    #+------------------------------------------------------------------------+
    if [ "${nginxUserExists}" != "0" ];
    then
        useradd -d /etc/nginx -s /bin/false nginx
    fi

    #+------------------------------------------------------------------------+
    #+ Create directories used to build NGINX, as well as NGINX's core.
    #+------------------------------------------------------------------------+
    mkdir -p /home/nginx/htdocs/public \
    && mkdir -p /usr/local/src/{github,packages/{openssl,pcre,zlib}} \
    && mkdir -p /etc/nginx/cache/{client,fastcgi,proxy,uwsgi,scgi} \
    && mkdir -p /etc/nginx/config/{php,proxy,sites,ssl} \
    && mkdir -p /etc/nginx/{lock,logs/{domains,server/{access,error}}} \
    && mkdir -p /etc/nginx/{modules,pid,sites,ssl}

    #+------------------------------------------------------------------------+
    #+ Clone required repositories from GitHub
    #+------------------------------------------------------------------------+
    #+ 1). NGINX
    #+ 2). NGINX Dev. Kit (Module)
    #+ 3). NGINX Headers More (Module)
    #+ 4). NGINX VTS (Module)
    #+ 5). Brotli (for Brotli Compression)
    #+ 6). LibBrotli
    #+ 7). NGINX Brotli (Module)
    #+ 8). NAXSI (Module)
    #+------------------------------------------------------------------------+
    cd /usr/local/src/github \
    && git clone https://github.com/nginx/nginx.git \
    && git clone https://github.com/simpl/ngx_devel_kit.git \
    && git clone https://github.com/openresty/headers-more-nginx-module.git \
    && git clone https://github.com/vozlt/nginx-module-vts.git \
    && git clone https://github.com/google/brotli.git \
    && git clone https://github.com/bagder/libbrotli \
    && git clone https://github.com/google/ngx_brotli \
    && git clone https://github.com/nbs-system/naxsi.git

    #+------------------------------------------------------------------------+
    #+ Google Pagespeed for NGINX
    #+ https://modpagespeed.com/doc/build_ngx_pagespeed_from_source
    #+------------------------------------------------------------------------+
    cd /usr/local/src/github \
    && wget https://github.com/pagespeed/ngx_pagespeed/archive/v${pagespeedVers}-beta.zip \
    && unzip v${pagespeedVers}-beta.zip \
    && cd ngx_pagespeed-${pagespeedVers}-beta \
    && export psol_url=https://dl.google.com/dl/page-speed/psol/${pagespeedVers}.tar.gz \
    && [ -e scripts/format_binary_url.sh ] && psol_url=$(scripts/format_binary_url.sh PSOL_BINARY_URL) \
    && wget ${psol_url} \
    && tar -xzvf $(basename ${psol_url})

    #+------------------------------------------------------------------------+
    #+ Install Brotli
    #+------------------------------------------------------------------------+
    cd /usr/local/src/github \
    && python setup.py install

    #+------------------------------------------------------------------------+
    #+ Configure & Make LibBrotli
    #+------------------------------------------------------------------------+
    cd /usr/local/src/github/libbrotli \
    && ./autogen.sh \
    && ./configure \
    && make -j ${cpuCount} \
    && make install

    #+------------------------------------------------------------------------+
    #+ Initialize NGINX Brotli Module
    #+------------------------------------------------------------------------+
    cd /usr/local/src/github/ngx_brotli \
    && git submodule update --init

    #+------------------------------------------------------------------------+
    #+ Download & Extract PCRE, OpenSSL, and ZLIB for NGINX Compile
    #+------------------------------------------------------------------------+
    cd /usr/local/src/packages \
    && wget https://www.openssl.org/source/openssl-${openSslVers}.tar.gz \
    && wget https://ftp.pcre.org/pub/pcre/pcre-${pcreVers}.tar.gz \
    && wget http://www.zlib.net/zlib-${zlibVers}.tar.gz \
    && tar xvf openssl-${openSslVers}.tar.gz --strip-components=1 -C /usr/local/src/packages/openssl \
    && tar xvf pcre-${pcreVers}.tar.gz --strip-components=1 -C /usr/local/src/packages/pcre \
    && tar xvf zlib-${zlibVers}.tar.gz --strip-components=1 -C /usr/local/src/packages/zlib

    #+------------------------------------------------------------------------+
    #+ Generate dhparam.pem File -- Store to /etc/nginx/ssl
    #+------------------------------------------------------------------------+
    #+ This process may take a while depending on CPU availbility and speed.
    #+------------------------------------------------------------------------+
    openssl dhparam -out /etc/nginx/ssl/dhparam.pem ${dhparamBits}
}

nginxCompile()
{
    #+------------------------------------------------------------------------+
    #+ Configure & Compile NGINX
    #+------------------------------------------------------------------------+
    cd /usr/local/src/github/nginx \
    && ./auto/configure --prefix=/etc/nginx \
                        --sbin-path=/usr/sbin/nginx \
                        --conf-path=/etc/nginx/config/nginx.conf \
                        --lock-path=/etc/nginx/lock/nginx.lock \
                        --pid-path=/etc/nginx/pid/nginx.pid \
                        --error-log-path=/etc/nginx/logs/error.log \
                        --http-log-path=/etc/nginx/logs/access.log \
                        --http-client-body-temp-path=/etc/nginx/cache/client \
                        --http-proxy-temp-path=/etc/nginx/cache/proxy \
                        --http-fastcgi-temp-path=/etc/nginx/cache/fastcgi \
                        --http-uwsgi-temp-path=/etc/nginx/cache/uwsgi \
                        --http-scgi-temp-path=/etc/nginx/cache/scgi \
                        --user=nginx \
                        --group=nginx \
                        --with-poll_module \
                        --with-threads \
                        --with-file-aio \
                        --with-http_ssl_module \
                        --with-http_v2_module \
                        --with-http_realip_module \
                        --with-http_addition_module \
                        --with-http_xslt_module \
                        --with-http_image_filter_module \
                        --with-http_sub_module \
                        --with-http_dav_module \
                        --with-http_flv_module \
                        --with-http_mp4_module \
                        --with-http_gunzip_module \
                        --with-http_gzip_static_module \
                        --with-http_auth_request_module \
                        --with-http_random_index_module \
                        --with-http_secure_link_module \
                        --with-http_degradation_module \
                        --with-http_slice_module \
                        --with-http_stub_status_module \
                        --with-stream \
                        --with-stream_ssl_module \
                        --with-stream_realip_module \
                        --with-stream_geoip_module \
                        --with-stream_ssl_preread_module \
                        --with-google_perftools_module \
                        --with-pcre=/usr/local/src/packages/pcre \
                        --with-pcre-jit \
                        --with-zlib=/usr/local/src/packages/zlib \
                        --with-openssl=/usr/local/src/packages/openssl \
                        --add-module=/usr/local/src/githu/naxsi/naxsi_src \
                        --add-module=/usr/local/src/github/ngx_devel_kit \
                        --add-module=/usr/local/src/github/nginx-module-vts \
                        --add-module=/usr/local/src/github/ngx_brotli \
                        --add-module=/usr/local/src/github/headers-more-nginx-module \
                        --add-module=/usr/local/src/github/ngx_pagespeed-${pagespeedVers}-beta \
    && make -j ${cpuCount} \
    && make install
}

nginxConfigure()
{
    #+------------------------------------------------------------------------+
    #+ Remove *.default files from configuration directory.
    #+------------------------------------------------------------------------+
    rm -rf /etc/nginx/config/*.default

    #+------------------------------------------------------------------------+
    #+ Remove default NGINX configuration file.
    #+------------------------------------------------------------------------+
    rm /etc/nginx/config/nginx.conf

    #+------------------------------------------------------------------------+
    #+ Remove default FastCGI Configuration
    #+------------------------------------------------------------------------+
    rm /etc/nginx/config/fastcgi.conf \
    && rm /etc/nginx/config/fastcgi_params

    #+------------------------------------------------------------------------+
    #+ Copy new configuration
    #+------------------------------------------------------------------------+
    cp -R ${currentPath}/html/index.html /home/nginx/htdocs/public/index.html \
    && cp -R ${currentPath}/nginx/* /etc/nginx \
    && cp -R ${currentPath}/systemd/nginx.service /lib/systemd/system/nginx.service

    #+------------------------------------------------------------------------+
    #+ Set correct permissions and ownership
    #+------------------------------------------------------------------------+
    chown -R nginx:nginx /home/nginx

    #+------------------------------------------------------------------------+
    #+ Create systemd service script and start NGINX
    #+------------------------------------------------------------------------+
    systemctl enable nginx \
    && systemctl start nginx
}

nginxCleanup()
{
    #+------------------------------------------------------------------------+
    #+ Remove GitHub and downloaded packages
    #+------------------------------------------------------------------------+
    rm -rf /usr/local/src/github \
    && rm -rf /usr/local/src/packages
}

nginxSetup \
&& nginxCompile \
&& nginxConfigure \
&& nginxCleanup