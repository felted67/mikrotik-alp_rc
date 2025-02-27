#
# Dockerfile for alpine-linux-rc mikrotik-docker-image
# (C) 2023-2024 DL7DET
#

ARG ALPINE_VERSION='alpine:default'
FROM $ALPINE_VERSION AS base

# Preset Metadata parameters and build-arg parameters
ARG BUILD
ARG PROD_VERSION
ARG DEVEL_VERSION
ARG ALPINE_VERSION
ARG LINUX_VERSION
ARG COMMIT_SHA
ENV HOME=/home/$USER

# Set Metadata for docker-image
LABEL org.opencontainers.image.authors="DL7DET <detlef@lampart.de>" 
LABEL org.opencontainers.image.licenses="MIT License"
LABEL org.label-schema.vendor="DL7DET <detlef@lampart.de>"
LABEL org.label-schema.name="mikrotik-alp_rc"
LABEL org.label-schema.url="https://cb3.lampart-web.de/internal/docker-projects/mikrotik-docker-images/mikrotik-alp_rc"  
LABEL org.label-schema.version=$LINUX_VERSION-$PROD_VERSION 
LABEL org.label-schema.version-prod=$PROD_VERSION 
LABEL org.label-schema.version-devel=$DEVEL_VERSION 
LABEL org.label-schema.build-date=$BUILD 
LABEL org.label-schema.version_alpine_version=$ALPINE_VERSION 
LABEL org.label-schema.vcs-url="https://cb3.lampart-web.de/internal/docker-projects/mikrotik-docker-images/mikrotik-alp_rc.git" 
LABEL org.label-schema.vcs-ref=$COMMIT_SHA 
LABEL org.label-schema.docker.dockerfile="/Dockerfile" 
LABEL org.label-schema.description="alpine-linux-rc mikrotik-docker-image" 
LABEL org.label-schema.usage="" 
LABEL org.label-schema.url="https://github.com/felted67/mikrotik-alp_rc" 
LABEL org.label-schema.schema-version="1.0"

RUN echo 'https://ftp.halifax.rwth-aachen.de/alpine/v3.20/main/' >> /etc/apk/repositories \
    && echo 'https://ftp.halifax.rwth-aachen.de/alpine/v3.20/community' >> /etc/apk/repositories \
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
    apk add --no-cache openssh openssh-keygen eudev unzip bzip2 screen wget curl iptraf-ng htop

RUN apk update && \
    apk add --no-cache mc

COPY ./config_files/auto_init /etc/init.d/
COPY ./config_files/auto_init.sh /sbin/
COPY ./config_files/first_start.sh /sbin/

RUN mkdir /root/.ssh
RUN ssh-keygen -q -t ecdsa -b 521 -f /root/.ssh/id_ecdsa && \
    ssh-keygen -q -t rsa -b 4096 -f /root/.ssh/id_rsa && \
    ssh-keygen -q -t ed25519 -f /root/.ssh/id_ed25519 
RUN touch /root/.ssh/authorized_keys
RUN cat /root/.ssh/id_ecdsa.pub >> /root/.ssh/authorized_keys
RUN cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys
RUN cat /root/.ssh/id_ed25519.pub >> /root/.ssh/authorized_keys

RUN chown root:root /etc/init.d/auto_init && chmod 0700 /etc/init.d/auto_init
RUN chown root:root /sbin/first_start.sh && chmod 0700 /sbin/first_start.sh
RUN chown root:root /sbin/auto_init.sh && chmod 0700 /sbin/auto_init.sh

RUN ln -s /etc/init.d/auto_init /etc/runlevels/default/auto_init

EXPOSE 22/tcp

CMD ["/sbin/init"]