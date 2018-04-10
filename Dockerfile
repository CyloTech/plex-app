FROM ubuntu:16.04

ARG DEBIAN_FRONTEND="noninteractive"
ENV TERM="xterm" LANG="C.UTF-8" LC_ALL="C.UTF-8" DEBUG="true"

RUN \
# Update and get dependencies
    apt-get update && \
    apt-get install -y software-properties-common && \
    apt-add-repository multiverse && \
    apt-get update && \
    apt-get install -y \
    tzdata \
    curl \
    xmlstarlet \
    uuid-runtime \
    rar \
    unrar

RUN useradd -U -d /config -s /bin/false -u 1000 plex && \
    usermod -G plex plex && \
    mkdir -p \
    /config \
    /transcode \
    /data && \
    apt-get -y autoremove && \
    apt-get -y clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/* && \
    rm -rf /var/tmp/*

EXPOSE 32400/tcp 3005/tcp 8324/tcp 32469/tcp 1900/udp 32410/udp 32412/udp 32413/udp 32414/udp
VOLUME /config /transcode

ENV CHANGE_CONFIG_DIR_OWNERSHIP="true" \
    HOME="/config"

ARG TAG=beta
ARG URL=

RUN mkdir -p /scripts
ADD scripts /scripts
RUN chmod -R +x /scripts

RUN /scripts/installBinary.sh

CMD [ "/scripts/start.sh" ]