# Firebird 2.5.8 Classic Docker Image

## Environment Variables

* `ISC_PASSWORD` is required if you do not provide your own security2.fdb, and will be used to set the sysdba password on startup and create security2.fdb.
* `LIMIT_HOST_ACCESS_TO_VOLUME=true` Set to "false" to allow "docker run" to read all persistent data without "sudo". (Will run `chmod o+r` on databases and logs on startup and when copying data to the persistent volume.)

## Persistent Storage

This image stores persistent data in /firebird.
Databases (including security2.fdb) go in "/firebird/data", and logs go in "/firebird/log".

* If these directories do not exist on container startup, they will be created.
* Their permissions will always be reset on container startup to ensure firebird can read and write to them. TODO: add flag to disable?

## Healthcheck

Healthcheck based on https://github.com/jacobalberty/firebird-docker. Configure a username, password, and database to check by exporting the following environment variables in `/firebird/etc/docker-healthcheck.conf`:

* HC_USER
* HC_PASS
* HC_DB

## Other Notes

Based on [jacobalberty/firebird-docker](https://github.com/jacobalberty/firebird-docker) and [betonetotbo/docker-firebird-cs](https://github.com/betonetotbo/docker-firebird-cs)