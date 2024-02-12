#
# Dockerfile for alpine-linux-rc mikrotik-docker-image
# (C) 2023-2024 DL7DET
#

FROM --platform=$TARGETPLATFORM alpine:3.19.1 AS base

RUN echo 'https://ftp.halifax.rwth-aachen.de/alpine/v3.19/main/' >> /etc/apk/repositories \
    && echo 'https://ftp.halifax.rwth-aachen.de/alpine/v3.19/community' >> /etc/apk/repositories \
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

COPY ./config_files/auto_init /etc/init.d/
COPY ./config_files/auto_init.sh /sbin/
COPY ./config_files/first_start.sh /sbin/

RUN mkdir /root/.ssh
COPY ./ssh_keys/id_dsa.pub /root/.ssh/
COPY ./ssh_keys/id_rsa.pub /root/.ssh/
COPY ./ssh_keys/id_ed25519.pub /root/.ssh/
RUN touch /root/.ssh/authorized_keys
RUN cat /root/.ssh/id_dsa.pub >> /root/.ssh/authorized_keys
RUN cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
RUN cat /root/.ssh/id_ed25519.pub >> /root/.ssh/authorized_keys

RUN chown root:root /etc/init.d/auto_init && chmod 0755 /etc/init.d/auto_init
RUN chown root:root /sbin/first_start.sh && chmod 0700 /sbin/first_start.sh
RUN chown root:root /sbin/auto_init.sh && chmod 0700 /sbin/auto_init.sh

RUN ln -s /etc/init.d/auto_init /etc/runlevels/default/auto_init

EXPOSE 22/tcp

CMD ["/sbin/init"]