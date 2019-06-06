FROM phusion/baseimage:0.11

ARG PREFIX=/usr/local/firebird
ARG FBURL=https://github.com/FirebirdSQL/firebird/releases/download/R2_5_8/Firebird-2.5.8.27089-0.tar.bz2

ENV PREFIX=${PREFIX}
ENV VOLUME=/firebird
ENV DEBIAN_FRONTEND=noninteractive
ENV DBPATH=/firebird/data

# 1. Install xinetd
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      tcpd \
      xinetd \
    && apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# 2. Install firebird
# RUN apt-get update && \
#     apt-get install -y --no-install-recommends \
#         ca-certificates \
#         curl \
#         libncurses5 \
#         nano \
#         netcat && \
#     mkdir -p /firebird && \
#     cd /firebird && \
#     curl -L -o firebird.tar.gz -L "${FBURL}" && \
#     tar --strip=1 -xf firebird.tar.gz && \
#     /firebird/install.sh -silent && \
#     rm -rf /firebird && \
#     apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN apt-get update && \
    apt-get install -qy --no-install-recommends \
        bzip2 \
        ca-certificates \
        curl \
        g++ \
        gcc \
        libicu60 \
        libicu-dev \
        libncurses5-dev \
        make && \
    mkdir -p /home/firebird && \
    cd /home/firebird && \
    curl -L -o firebird-source.tar.bz2 -L \
        "${FBURL}" && \
    tar --strip=1 -xf firebird-source.tar.bz2 && \
    ./configure \
        --prefix=${PREFIX} --with-fbbin=${PREFIX}/bin --with-fbsbin=${PREFIX}/bin --with-fblib=${PREFIX}/lib \
        --with-fbinclude=${PREFIX}/include --with-fbdoc=${PREFIX}/doc --with-fbudf=${PREFIX}/UDF \
        --with-fbsample=${PREFIX}/examples --with-fbsample-db=${PREFIX}/examples/empbuild --with-fbhelp=${PREFIX}/help \
        --with-fbintl=${PREFIX}/intl --with-fbmisc=${PREFIX}/misc --with-fbplugins=${PREFIX} \
        --with-fblog=${VOLUME}/log --with-fbglock=/var/firebird/run \
        --with-fbconf=${VOLUME}/etc --with-fbmsg=${PREFIX} \
        --with-fbsecure-db=${VOLUME}/system --with-system-icu &&\
    make && \
    make silent_install && \
    cd / && \
    rm -rf /home/firebird && \
    find ${PREFIX} -name .debug -prune -exec rm -rf {} \; && \
    apt-get purge -qy --auto-remove \
        libncurses5-dev \
        bzip2 \
        ca-certificates \
        curl \
        gcc \
        g++ \
        make \
        libicu-dev && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    mkdir -p "${PREFIX}/skel" && \
    mv ${VOLUME}/system/security2.fdb ${PREFIX}/skel/security2.fdb && \
    mv "${VOLUME}/etc" "${PREFIX}/skel"

ENV PATH="${PREFIX}/bin:$PATH"

# Copy startup scripts to locations documented by phusion/baseimage
COPY service/xinetd /etc/service/xinetd
COPY xinetd.conf /etc/xinetd.conf
COPY my_init.d/*.sh /etc/my_init.d/

RUN apt-get update && apt-get install -y netcat && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
COPY docker-healthcheck.sh ${PREFIX}/docker-healthcheck.sh
HEALTHCHECK CMD ${PREFIX}/docker-healthcheck.sh || exit 1

CMD [ "/sbin/my_init" ]

EXPOSE 3050/tcp
LABEL maintainer="info@willmakley.dev" firebird="2.5.8-classic"
