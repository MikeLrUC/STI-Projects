#!/bin/bash

filedir=`dirname "$0"`

if [ $# -ne 2 ]; then
    echo "Usage: bash configure.bash <TOPT-username> <server-ip>"
    exit 1
fi

NAME=$1
SERVERIP=$2

# Create Default Road-Warrior User
bash $filedir/scripts/totp.bash $NAME

# Load config and start VPN Server
bash $filedir/scripts/load_config.bash $SERVERIP