#!/usr/bin/env bash
set -e
# Proxy signals
sp_processes=("namecoind" "namecoin-cli")
. /signalproxy.sh

# Overload Traps
  #none

# Configure Stuff
for CONF in ${CONFS[@]}
do
  if ! [ -f /data/"$CONF" ]; then
    echo "Copying /etc/$CONF to /data/$CONF"
    mkdir -p /data/$CONF && rmdir /data/$CONF
    cp /etc/$CONF /data/$CONF
  fi
done

# Run application
namecoind -conf=/data/$NMCCORE_CONF & \
wait -n
