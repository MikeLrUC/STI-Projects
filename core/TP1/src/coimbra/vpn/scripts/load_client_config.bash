#!/bin/bash
filedir=`dirname "$0"`

if [ $# -ne 1 ]; then
    echo "Usage: bash load_client_config.bash <server-ip>"
    exit 1
fi

SERVERIP=$1

# Install and Start OpenVPN
sudo apt-get install openvpn -y
sudo systemctl start openvpn

# Add server-ip to the Coimbra client.conf file
sudo printf "\nremote $SERVERIP 1194" >> $filedir/../config/coimbra-client.conf

# Make directory for the Coimbra client.config file
sudo mkdir -p /etc/openvpn/coimbra-client

# Replace config file
sudo cp -f $filedir/../config/coimbra-client.conf /etc/openvpn/coimbra-client

# Start VPN Server
sudo openvpn --config /etc/openvpn/coimbra-client/coimbra-client.conf