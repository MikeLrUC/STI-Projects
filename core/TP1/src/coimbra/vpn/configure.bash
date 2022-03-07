#!/bin/bash

filedir=`dirname "$0"`

if [ $# == 1 ]; then

    # Instalar openvpn
    sudo apt-get install openvpn

    # Ligar a openvpn
    sudo systemctl start openvpn

    # adicionar ao ficheiro de configuracao o ip que foi passado por argumento
    sudo printf "\nlocal $1" >> $filedir/config/coimbra-gateway.conf

    # criar a diretoria para guardar o ficheiro de configuracao
    sudo mkdir -p /etc/openvpn/coimbra-gateway # -p nao da erro se a diretoria existir

    # colocar os ficheiros nas respetivas diretorias
    sudo cp -f $filedir/config/coimbra-gateway.conf /etc/openvpn/coimbra-gateway # da overwrite do ficheiro se este ja existir na diretoria

    # ligar o server vpn
    sudo openvpn --config /etc/openvpn/coimbra-gateway/coimbra-gateway.conf

else
    echo "configure.bash <server ip>"
fi