#!/bin/bash
set -eu

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

    if [ ! -d $ETC ]; then
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

setup_aliases() {
    CONF="${PREFIX}/aliases.conf"

    for DB_PATH in ${VOLUME}/data/*.fdb
    do
        DB_NAME=$(basename -- "$DB_PATH")
        if [ "${DB_NAME}" = "security2.fdb" ]; then continue; fi

        SHORT_NAME="${DB_NAME%%.*}"
        echo "Automatically adding aliases for ${DB_NAME}"
        echo "${DB_NAME} = ${DB_PATH}
${SHORT_NAME} = ${DB_PATH}" | tee -a $CONF
    done
}

read_sysdba_password() {
    local file="$1"
    local var="ISC_PASSWD"
    echo $(source "${file}"; printf "%s" "${!var}");
}

run() {
    setup_volume
    setup_aliases

    if [ -f ${VOLUME}/data/security2.fdb ]; then
        echo "security2.fdb found in mounted volume, loading..."
        cp ${VOLUME}/data/security2.fdb ${PREFIX}/security2.fdb
        chown firebird:firebird ${PREFIX}/security2.fdb
    else
        echo "security2.fdb not found, resetting sysdba password..."

        local pwd="$(read_sysdba_password /opt/firebird/SYSDBA.password)"

        echo "SYSDBA password: ${pwd}"

        if ! [ -z "${ISC_PASSWORD}" ]; then
            setuser firebird ${PREFIX}/bin/gsec -user SYSDBA -password ${pwd} -modify SYSDBA -pw "${ISC_PASSWORD}"
            echo "SYSDBA password changed: ${ISC_PASSWORD}"
        fi

        cp ${PREFIX}/security2.fdb ${VOLUME}/data/security2.fdb
        chown firebird:firebird ${VOLUME}/data/security2.fdb

        # allow host to read
        if [ "$LIMIT_HOST_ACCESS_TO_VOLUME" = "false" ]; then
            chmod o+r ${VOLUME}/data/security2.fdb
        fi
    fi
}

run
