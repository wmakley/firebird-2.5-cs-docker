FROM phusion/baseimage:0.11

# This is not able to be changed when installing from pre-built binary.
ARG PREFIX=/opt/firebird

ENV PREFIX=${PREFIX}
ENV DEBIAN_FRONTEND noninteractive
ENV FBURL=https://github.com/FirebirdSQL/firebird/releases/download/R2_5_8/FirebirdCS-2.5.8.27089-0.amd64.tar.gz
ENV DBPATH=/firebird/data

# 1. Install xinetd
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      tcpd \
      xinetd \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 2. Install firebird
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        libncurses5 \
        nano && \
    mkdir -p /home/firebird && \
    cd /home/firebird && \
    curl -L -o firebird.tar.gz -L "${FBURL}" && \
    tar --strip=1 -xf firebird.tar.gz && \
    /home/firebird/install.sh -silent && \
    rm -rf /home/firebird && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 3. Install healthcheck
RUN apt-get update && apt-get install -y netcat && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY docker-healthcheck.sh ${PREFIX}/docker-healthcheck.sh
HEALTHCHECK CMD ${PREFIX}/docker-healthcheck.sh || exit 1

ENV PATH="${PREFIX}/bin:$PATH"

# Copy startup scripts to locations documented by phusion/baseimage
COPY service/xinetd /etc/service/xinetd
COPY xinetd.conf /etc/xinetd.conf
COPY my_init.d/*.sh /etc/my_init.d/

# TODO: Make volumes for all transient data, and provide script to set them up
ENV VOLUME=/firebird
RUN mkdir $VOLUME
# VOLUME /firebird

CMD [ "/sbin/my_init" ]

EXPOSE 3050/tcp
LABEL maintainer="info@willmakley.dev" firebird="2.5.8-classic"
