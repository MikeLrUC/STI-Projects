#!/bin/bash
filedir=`dirname "$0"`

if [ $# -ne 1 ]; then
    echo "Usage: bash load_server_config.bash <server-ip>"
    exit 1
fi

SERVERIP=$1

# Install and Start OpenVPN
sudo apt-get install openvpn -y
sudo systemctl start openvpn

# Add server-ip to the Coimbra server.conf file
sudo printf "\nlocal $SERVERIP" >> $filedir/../config/coimbra-server.conf

# Make directory for the Coimbra server.config file
sudo mkdir -p /etc/openvpn/coimbra-server

# Replace config file
sudo cp -f $filedir/../config/coimbra-server.conf /etc/openvpn/coimbra-server
sudo cp -f $filedir/../../OCSP/ocsp_config.bash /etc/openvpn/coimbra-server

# Start VPN Server
sudo openvpn --config /etc/openvpn/coimbra-server/coimbra-server.conf
