FROM phusion/baseimage:0.11

# This is not able to be changed when installing from pre-built binary.
ARG PREFIX=/opt/firebird

# Set to "false" to make it easier for host to read secure data in volume.
# Useful if you want to run as yourself instead of "sudo docker run".
# (Default is secure.)
ENV LIMIT_HOST_ACCESS_TO_VOLUME=true

ENV PREFIX=${PREFIX}
ENV DEBIAN_FRONTEND noninteractive
ENV FBURL=https://github.com/FirebirdSQL/firebird/releases/download/R2_5_8/FirebirdCS-2.5.8.27089-0.amd64.tar.gz
ENV VOLUME=/firebird
ENV DBPATH="${VOLUME}/data"

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
    mkdir -p ${VOLUME} && \
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
COPY my_init.pre_shutdown.d/*.sh /etc/my_init.pre_shutdown.d/

CMD [ "/sbin/my_init" ]

EXPOSE 3050/tcp
LABEL maintainer="info@willmakley.dev" firebird="2.5.8-classic"
