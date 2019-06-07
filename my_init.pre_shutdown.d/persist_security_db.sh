#!/bin/bash
set -eu

SRC=$PREFIX/security2.fdb
DEST=$VOLUME/data/security2.fdb

echo "Copying ${SRC} to ${DEST}"
cp $SRC $DEST
chown firebird:firebird $DEST
if [ "$LIMIT_HOST_ACCESS_TO_VOLUME" = "false" ]; then
	chmod o+r $DEST
fi
