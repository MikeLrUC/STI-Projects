#!/bin/bash

filedir=`dirname "$0"`

if [ $# == 1 ]; then

    # adicionar ao ficheiro de configuracao o ip que foi passado por argumento
    sudo printf "\nremote $1 1194" >> $filedir/config/roadwarrior.conf

    # criar a diretoria para guardar o ficheiro de configuracao
    sudo mkdir -p /etc/openvpn/roadwarrior # -p nao da erro se a diretoria existir

    # colocar os ficheiros nas respetivas diretorias
    sudo cp -f $filedir/config/roadwarrior.conf /etc/openvpn/roadwarrior # da overwrite do ficheiro se este ja existir na diretoria

    # ligar o server vpn
    sudo openvpn --config /etc/openvpn/roadwarrior/roadwarrior.conf
    
else
    echo "configure.bash <openvpn_server ip>"
fi