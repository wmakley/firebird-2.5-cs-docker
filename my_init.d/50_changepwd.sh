#!/bin/bash
set -eux

fix_volume_ownership() {
    chown -R firebird:firebird /firebird
}

read_sysdba_password() {
    local file="$1"
    local var="ISC_PASSWD"
    echo $(source "${file}"; printf "%s" "${!var}");
}

run() {
    fix_volume_ownership

    local pwd="$(read_sysdba_password /opt/firebird/SYSDBA.password)"

    echo "SYSDBA password: ${pwd}"

    if ! [ -z ${ISC_PASSWORD} ]; then
        ${PREFIX}/bin/gsec -user SYSDBA -password ${pwd} -modify SYSDBA -pw ${ISC_PASSWORD}
        echo "SYSDBA password changed: ${ISC_PASSWORD}"
    fi
}

run
