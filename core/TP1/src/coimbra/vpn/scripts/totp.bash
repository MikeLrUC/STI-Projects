#!/bin/bash
# Based On https://sparklabs.com/support/kb/article/totp-two-factor-authentication-with-openvpn-and-viscosity/

filedir=`dirname "$0"`

if [ $# -ne 1 ]; then 
    echo "usage: bash totp.bash <username>"
    exit 1
fi

NAME=$1


# Install and Start OpenVPN
sudo apt-get install openvpn -y
sudo systemctl start openvpn

# Install Python3
sudo apt install python3 python3-pip -y

# Install Python3 Libraries
sudo pip3 install python-pam pyotp
sudo pip3 install qrcode

cd /etc/openvpn

# Download two-factor-authentication script from thesparklabs@github
sudo wget https://raw.githubusercontent.com/thesparklabs/openvpn-two-factor-extensions/master/TOTP/openvpn_pam_totp.py

# Give it executable permission
sudo chmod +x /etc/openvpn/openvpn_pam_totp.py

# Back to folder
cd -

# Generate TOTP qrcode for user
sudo /etc/openvpn/openvpn_pam_totp.py --genkey $NAME > $filedir/../$NAME.txt