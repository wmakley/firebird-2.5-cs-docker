#!/bin/bash
set -euxo pipefail

DATA="${VOLUME}/data"
CONF="${PREFIX}/aliases.conf"

setup_aliases() {
    for DB_PATH in ${DATA}/*.fdb
    do
        DB_NAME=$(basename -- "$DB_PATH")
        if [ "${DB_NAME}" = "security2.fdb" ]; then continue; fi

        SHORT_NAME="${DB_NAME%%.*}"
        echo "Automatically adding aliases for ${DB_NAME}"
        echo "${SHORT_NAME} = ${DB_PATH}
${SHORT_NAME} = ${DB_PATH}" | tee -a $CONF
    done
}

setup_aliases
