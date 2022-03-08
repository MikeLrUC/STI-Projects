#!/bin/bash
filedir=`dirname "$0"`

if [ $# -ne 1 ]; then
    echo "Usage: bash load_config <server-ip>"
    exit 1
fi

SERVERIP=$1

# Install and Start OpenVPN
sudo apt-get install openvpn -y
sudo systemctl start openvpn

# Add server-ip to the Coimbra server.conf file
sudo printf "\nlocal $SERVERIP" >> $filedir/../config/coimbra-gateway.conf

# Make directory for the Coimbra server.config file
sudo mkdir -p /etc/openvpn/coimbra-gateway 

# Replace config file
sudo cp -f $filedir/../config/coimbra-gateway.conf /etc/openvpn/coimbra-gateway 

# Start VPN Server
sudo openvpn --config /etc/openvpn/coimbra-gateway/coimbra-gateway.conf