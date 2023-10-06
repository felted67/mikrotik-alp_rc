#
# Dockerfile for alpine-linux-rc mikrotik-docker-image
# (C) 2023 DL7DET
#

FROM --platform=$TARGETPLATFORM alpine:3.18.4 AS base

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

COPY ./config_files/first_start.sh /sbin/

RUN chown root:root /sbin/first_start.sh && chmod 0700 /sbin/first_start.sh

CMD ["/sbin/init"]
