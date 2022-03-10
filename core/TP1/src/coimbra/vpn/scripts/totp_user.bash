#!/bin/bash


filedir=`dirname "$0"`

if [ $# -ne 1 ]; then
    echo "usage: bash totp.bash <username>"
    exit 1
fi

NAME=$1

sudo useradd -d /home/$NAME -s /bin/false $NAME
sudo passwd $NAME

# gerar a informacao para a MFA
VPNNAME="VPN_$NAME"
eval "sudo su -c 'google-authenticator -t -d -r3 -R30 -f -l $VPNNAME -s /etc/openvpn/google-authenticator/$NAME' - gauth"
