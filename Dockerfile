FROM ubuntu:14.04
MAINTAINER Hanfei Shen <qqshfox@gmail.com>

ENV NGINX_VERSION 1.4.6
ENV NGINX_DISTRO_VERSION 1ubuntu3.1
ENV NGINX_DISTRO_FULL_VERSION $NGINX_VERSION-$NGINX_DISTRO_VERSION
ENV NGINX_RTMP_MODULE_VERSION 1.1.6

ENV DEBIAN_FRONTEND noninteractive
RUN apt-get update && apt-get install -y \
    curl \
    dpkg-dev \
    software-properties-common \
    && \
    add-apt-repository -y ppa:nginx/stable && \
    echo 'deb http://ppa.launchpad.net/nginx/stable/ubuntu trusty main' >> nginx-stable-trusty.list && \
    echo 'deb-src http://ppa.launchpad.net/nginx/stable/ubuntu trusty main' >> nginx-stable-trusty.list && \
    apt-get update && apt-get source nginx=$NGINX_DISTRO_FULL_VERSION && apt-get build-dep -y nginx=$NGINX_DISTRO_FULL_VERSION

RUN curl -sSL https://github.com/arut/nginx-rtmp-module/archive/v$NGINX_RTMP_MODULE_VERSION.tar.gz | tar -xzC /nginx-$NGINX_VERSION/debian/modules && \
    ln -s /nginx-$NGINX_VERSION/debian/modules/nginx-rtmp-module-$NGINX_RTMP_MODULE_VERSION /nginx-$NGINX_VERSION/debian/modules/nginx-rtmp-module && \
    sed -ri '/^common_configure_flags := \\$/ a\			--add-module=$(MODULESDIR)/nginx-rtmp-module \' /nginx-$NGINX_VERSION/debian/rules && \
    cd /nginx-$NGINX_VERSION && dpkg-buildpackage -b && \
    dpkg --install /nginx-common_${NGINX_DISTRO_FULL_VERSION}_all.deb /nginx-full_${NGINX_DISTRO_FULL_VERSION}_amd64.deb && \
    sed -ri '/^	listen \[::\]:80 default_server ipv6only=on;$/d' /etc/nginx/sites-available/default && \
    mkdir -p /usr/local/nginx/logs

EXPOSE 80 443 1935

CMD ["nginx", "-c", "/etc/nginx/nginx.conf", "-g", "daemon off;"]
