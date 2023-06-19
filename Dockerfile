#
# Dockerfile for alpine-linux-rc-apache2-php81 mikrotik-docker-image
# (C) 2023 DL7DET
#

FROM --platform=$TARGETPLATFORM alpine:3.18.0 AS base

RUN echo 'https://ftp.halifax.rwth-aachen.de/alpine/v3.18/main/' >> /etc/apk/repositories \
    && echo 'https://ftp.halifax.rwth-aachen.de/alpine/v3.18/community' >> /etc/apk/repositories \
    && apk add --no-cache --update --upgrade su-exec ca-certificates

FROM base AS openrc

RUN apk add --no-cache openrc \
    # Disable getty's
    && sed -i 's/^\(tty\d\:\:\)/#\1/g' /etc/inittab \
    && sed -i \
        # Change subsystem type to "docker"
        -e 's/#rc_sys=".*"/rc_sys="docker"/g' \
        # Allow all variables through
        -e 's/#rc_env_allow=".*"/rc_env_allow="\*"/g' \
        # Start crashed services
        -e 's/#rc_crashed_stop=.*/rc_crashed_stop=NO/g' \
        -e 's/#rc_crashed_start=.*/rc_crashed_start=YES/g' \
        # Define extra dependencies for services
        -e 's/#rc_provide=".*"/rc_provide="loopback net"/g' \
        /etc/rc.conf \
    # Remove unnecessary services
    && rm -f /etc/init.d/hwdrivers \
            /etc/init.d/hwclock \
            /etc/init.d/hwdrivers \
            /etc/init.d/modules \
            /etc/init.d/modules-load \
            /etc/init.d/modloop \
    # Can't do cgroups
    && sed -i 's/\tcgroup_add_service/\t#cgroup_add_service/g' /lib/rc/sh/openrc-run.sh \
    && sed -i 's/VSERVER/DOCKER/Ig' /lib/rc/sh/init.sh

RUN apk update && \
    apk add --no-cache openssh mc unzip bzip2 screen wget curl iptraf-ng htop

RUN apk update && \
    apk add --no-cache bash build-base gcc wget git autoconf libmcrypt-dev libzip-dev zip \
    g++ make openssl-dev \
    php81 php81-fpm php81-common \
    php81-openssl \
    php81-pdo_mysql \
    php81-mbstring
    
RUN apk update && \
    apk --no-cache add apache2 apache2-proxy apache-mod-fcgid tzdata

COPY ./config_files/first_start.sh /sbin/
COPY ./config_files/php_configure.sh /sbin/
COPY ./config_files/httpd.new.conf /etc/apache2/
COPY ./config_files/php-fpm.new.conf /etc/php81/
COPY ./config_files/www.new.conf /etc/php81/php-fpm.d/
COPY ./config_files/php-fpm81.sh /etc/profile.d/
COPY ./config_files/index.html /root/
COPY ./config_files/index.php /root/
COPY ./config_files/phpinfo.php /root/

RUN chown root:root /sbin/first_start.sh && chmod 0700 /sbin/first_start.sh
RUN chown root:root /sbin/php_configure.sh && chmod 0700 /sbin/php_configure.sh

CMD ["/sbin/init"]
