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

# Define Healthchecks

_health_namecoind () {
    local interval=15
    local delay=30
    local limit=600
    while true;
    do
        sleep $interval

        block_status=$(namecoin-cli getblockchaininfo)
        net_status=$(namecoin-cli getnetworkinfo)
        connections=$(echo  "$net_status" | grep '"connections":' | grep -o '[0-9]\+')

        if [ $limit -gt 0 ]; then
            limit=$(($limit - $interval))
            if [ $connections -eq 0 ]; then
                echo "Waiting for namecoind to connect."
            fi
        else
            if [ $connections -eq 0 ]; then
                echo "You have failed to connect to the namecoin network.  Add peers manually."
                break
            fi

        if echo $block_status | grep -q '"initialblockdownload": true'; then
            echo "Namecoin-Core is still syncing with the blockchain."
            # TODO: print the blocks remaining
        fi

        if [ $delay -gt 0 ]; then
            delay=$(($delay - $interval))
        else
            if [ $connections -gt 0 ]; then
                echo "The Namecoin-Core HealthCheck is running! You are connected."
            else
                echo "The Namecoin-Core HealthCheck is running, but you are NOT connected."
            fi
        fi
    done
}

# Run application
namecoind -conf=/data/$NMCCORE_CONF & \
_health_namecoind & \
wait -n
