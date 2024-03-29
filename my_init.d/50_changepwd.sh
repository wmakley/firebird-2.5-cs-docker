#!/bin/bash
set -euxo pipefail

DATA="${VOLUME}/data"
LOG="${VOLUME}/log"
LOG_FILE="${LOG}/firebird.log"
ORIGINAL_LOG="${PREFIX}/firebird.log"
ETC="${VOLUME}/etc"

read_sysdba_password() {
  local file="$1"
  local var="ISC_PASSWD"
  echo $(source "${file}"; printf "%s" "${!var}");
}

run() {
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
