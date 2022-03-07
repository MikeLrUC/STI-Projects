#!/bin/bash

# fonte
# https://amilstead.com/blog/openvpn-with-google-authenticator-totp/

if [ $# == 1 ]; then
    $NAME=$1

    # instalar o autenticador
    sudo apt-get install -y libpam-google-authenticator

    # criar grupo para os roadwarriors
    sudo addgroup warrior

    # criar o user
    sudo useradd -g warrior $NAME

    # 
    sudo mkdir /etc/openvpn/google-authenticator

    # 
    sudo chown warrior:$NAME /etc/openvpn/google-authenticator

    sudo chmod 0700 /etc/openvpn/google-authenticator


    # make a google-authenticator token for the user
    sudo su -c "google-authenticator -t -d -r3 -R30 -f -l \"My VPN\" -s /etc/openvpn/google-authenticator/test-user" - $NAME

    ##### NOT DONE
    # add the file openvpn
    ##########

else
    echo "totp.bash <user name>"
fi
