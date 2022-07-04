#!/bin/bash
set -euxo pipefail

DATA="${VOLUME}/data"
LOG="${VOLUME}/log"
LOG_FILE="${LOG}/firebird.log"
ORIGINAL_LOG="${PREFIX}/firebird.log"
ETC="${VOLUME}/etc"

setup_volume() {
    if [ ! -d $DATA ]; then
        echo "Creating ${DATA}..."
        mkdir -p $DATA
    fi

    if [ ! -d $LOG ]; then
        echo "Creating ${LOG}..."
        mkdir -p $LOG
    fi
    if [ ! -f $LOG_FILE ]; then
        echo "Creating ${LOG_FILE}..."
        touch $LOG_FILE
    fi

    ln -s $DATA $PREFIX
    
    if [ -f $ORIGINAL_LOG ]; then
        rm $ORIGINAL_LOG
    fi
    ln -s $LOG_FILE $ORIGINAL_LOG

    if [ ! -e $ETC ]; then
        mkdir -p $ETC
    fi
    if [ ! -f "${ETC}/docker-healthcheck.conf" ]; then
        touch "${ETC}/docker-healthcheck.conf"
    fi
    
    chown -R firebird:firebird $DATA
    chown -R firebird:firebird $LOG

    # Allow docker host to read firebird data
    if [ "$LIMIT_HOST_ACCESS_TO_VOLUME" = "false" ]; then
        chmod -R o+r $DATA
        chmod -R o+r $LOG
    fi
}

setup_volume
