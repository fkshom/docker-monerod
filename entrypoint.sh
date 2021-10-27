#!/bin/bash

USER_ID=${LOCAL_UID:-1000}
GROUP_ID=${LOCAL_GID:-1000}

echo "Starting with UID : $USER_ID, GID: $GROUP_ID"
usermod -u $USER_ID -o -m -d /home/monero monero
groupmod -g $GROUP_ID monero
export HOME=/home/monero

exec /usr/sbin/gosu monero /home/monero/bin/monerod "$@"