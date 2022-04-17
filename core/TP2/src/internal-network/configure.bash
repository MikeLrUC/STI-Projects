#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: bash configure.bash <interface-name>"
    echo 1
fi

INTERFACE=$1

# Configure Interface
sudo ifconfig $1 10.20.20.3 netmask 255.255.255.0
sudo route add default gw 10.20.20.2 $1