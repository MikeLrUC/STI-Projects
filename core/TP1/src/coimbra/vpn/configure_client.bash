#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: bash configure_client.bash <server-ip>"
    exit 1
fi

SERVERIP=$1

# Load config and start VPN Client
bash $filedir/scripts/load_server_config.bash $SERVERIP

#TODO: IP forwarding & Routes