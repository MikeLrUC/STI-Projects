#!/bin/bash

# based on: https://ulimit.nl/wp-content/uploads/2019/08/Extending-a-Debian-OpenVPN-server-with-Multi-Factor-Authentication-via-Google-Authenticator.pdf

filedir=`dirname "$0"`

if [ $# -ne 1 ]; then
    echo "usage: bash totp_user.bash <username>"
    exit 1
fi

NAME=$1

sudo useradd -d /home/$NAME -s /bin/false $NAME
sudo passwd $NAME

# gerar a informacao para a MFA
VPNNAME="VPN_$NAME"
eval "sudo su -c 'google-authenticator -t -d -r3 -R30 -f -l $VPNNAME -s /etc/openvpn/google-authenticator/$NAME' - gauth"
