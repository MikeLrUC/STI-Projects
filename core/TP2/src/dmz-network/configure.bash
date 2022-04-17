#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Usage: bash configure.bash <interface-name>"
    echo 1
fi

INTERFACE=$1

# Configure Interface
sudo ifconfig $1 10.10.10.3 netmask 255.255.255.0
sudo route add default gw 10.10.10.2 $1