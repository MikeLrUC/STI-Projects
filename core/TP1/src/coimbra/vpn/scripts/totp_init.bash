#!/bin/bash

filedir=`dirname "$0"`

# instalar o google authenticator
sudo apt-get install -y libqrencode4 libpam-google-authenticator


# criar o user que vai autenticar os outros "gauth"
sudo addgroup gauth
sudo useradd -g gauth gauth
sudo mkdir /etc/openvpn/google-authenticator
sudo chown gauth:gauth /etc/openvpn/google-authenticator
sudo chmod 0700 /etc/openvpn/google-authenticator


# criar o openvpn no /etc/pam.d/
sudo cp -f $filedir/../config/openvpn /etc/pam.d/
