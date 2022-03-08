#!/bin/bash
filedir=`dirname "$0"`

if [ $# -ne 1 ]; then
    echo "Usage: bash configure.bash <server-ip>"
    exit 1
fi

SERVERIP=$1

# Install and Start OpenVPN
sudo apt-get install openvpn -y
sudo systemctl start openvpn

# Add server-ip to the Lisboa server.conf file
sudo printf "\nlocal $SERVERIP" >> $filedir/../config/lisboa-server.conf

# Make directory for the Lisboa server.config file
sudo mkdir -p /etc/openvpn/lisboa-server

# Replace config file
sudo cp -f $filedir/../config/lisboa-server.conf /etc/openvpn/lisboa-server

# Start VPN Server
sudo openvpn --config /etc/openvpn/lisboa-server/lisboa-server.conf