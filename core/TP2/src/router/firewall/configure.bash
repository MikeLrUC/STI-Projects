#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: bash configure.bash <external-interface-name> <external-ip> <dmz-interface-name> <internal-interface-name>"
    echo 1
fi

## ==== [ Configuration Variables ] ==== ##

# Internet Variables
EXTERNAL_ITF=$1
EXTERNAL_ROUTER_IP=$2
EXTERNAL_DNS2=193.137.16.75
EXTERNAL_EDEN=193.136.212.1

# DMZ Network Variables
DMZ_ITF=$3
DMZ_NET=10.10.10.0/24
DMZ_ROUTER_IP=10.10.10.1
DMZ_MACHINE_IP=10.10.10.2

# Internal Network Variables
INTERNAL_ITF=$4
INTERNAL_NET=10.20.20.0/24
INTERNAL_ROUTER_IP=10.20.20.1
INTERNAL_MACHINE_IP=10.20.20.2

## ==== [ System Packages Installation ] ==== ##

## ==== [ System IP Forwarding ] ==== ##
sudo sysctl -w net.ipv4.ip_forward=1

## ==== [ System Interfaces Configuration ] ==== ##

sudo ifconfig $INTERNAL_ITF $INTERNAL_ROUTER_IP netmask 255.255.255.0   # (Internal Network)
sudo ifconfig $DMZ_ITF $DMZ_ROUTER_IP netmask 255.255.255.0             # (DMZ)

# IPTables Configuration 

## ==== [ Table filter ] ==== ##

# ---- FORWARD ---- #
sudo iptables -t filter -P FORWARD DROP

# Allow dns using dns server in DMZ
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p tcp --dport domain -j ACCEPT
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p udp --dport domain -j ACCEPT

# Allow smtp connections to the smtp server
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p tcp --dport smtp -j ACCEPT

# Allow pop and imap connections to the mail server
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p tcp --dport imap -j ACCEPT
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p tcp --dport pop -j ACCEPT

# Allow http and https connections
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p tcp --dport http -j ACCEPT
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p tcp --dport https -j ACCEPT

# Allow OpenVpn connections
# https://openvpn.net/vpn-server-resources/advanced-option-settings-on-the-command-line/
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p udp --dport 1194 -j ACCEPT
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p tcp --dport 443 -j ACCEPT

# Allow VPN clients from vpn-gw to connect to the datastore server
# https://www.speedguide.net/port.php?port=5432
sudo iptables -t filter -A FORWARD -s $DMZ_MACHINE_IP -d $INTERNAL_MACHINE_IP -i $DMZ_ITF -o $INTERNAL_ITF -p tcp --dport 5432 -j ACCEPT

# Allow vpn clients from vpn-gw to connect to the kerberos v5 service
# https://www.oreilly.com/library/view/kerberos-the-definitive/0596004036/ch06s05s01.html
# TODO: Há mais ports mas não sei se temos de colocar todos... 
sudo iptables -t filter -A FORWARD -s $DMZ_MACHINE_IP -d $INTERNAL_MACHINE_IP -i $DMZ_ITF -o $INTERNAL_ITF -p tcp --dport 88 -m connlimit --connlimit-upto 10 -j ACCEPT
sudo iptables -t filter -A FORWARD -s $DMZ_MACHINE_IP -d $INTERNAL_MACHINE_IP -i $DMZ_ITF -o $INTERNAL_ITF -p udp --dport 88 -m connlimit --connlimit-upto 10 -j ACCEPT

# Forward the dns requests
sudo iptables -t filter -A FORWARD -s $DMZ_MACHINE_IP -i $DMZ_ITF -o $EXTERNAL_ITF -p tcp --dport domain -j ACCEPT      # DNS from dns server at DMZ
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -i $INTERNAL_ITF -o $EXTERNAL_ITF -p tcp --dport domain -j ACCEPT   # DNS from internal network
sudo iptables -t filter -A FORWARD -s $DMZ_MACHINE_IP -i $DMZ_ITF -o $EXTERNAL_ITF -p udp --dport domain -j ACCEPT      # DNS from dns server at DMZ
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -i $INTERNAL_ITF -o $EXTERNAL_ITF -p udp --dport domain -j ACCEPT   # DNS from internal network

# FTP connections to the server ftp
sudo iptables -t filter -A FORWARD -d $INTERNAL_MACHINE_IP -i $EXTERNAL_ITF -o $INTERNAL_ITF -p tcp --dport ftp -j ACCEPT
sudo iptables -t filter -A FORWARD -s $INTERNAL_MACHINE_IP -i $INTERNAL_ITF -o $EXTERNAL_ITF -p tcp --sport ftp-data -j ACCEPT
# allow ftp connections on passive mode
sudo modprobe ip_conntrack_ftp

# SSH to the datastore server
sudo iptables -t filter -A FORWARD -s $EXTERNAL_EDEN -d $INTERNAL_MACHINE_IP -o $INTERNAL_ITF -p tcp --dport ssh -j ACCEPT
sudo iptables -t filter -A FORWARD -s $EXTERNAL_DNS2 -d $INTERNAL_MACHINE_IP -o $INTERNAL_ITF -p tcp --dport ssh -j ACCEPT

# HTTP, HTTPS and SSH from the internal network to the Internet
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -i $INTERNAL_ITF -o $EXTERNAL_ITF -p tcp --dport http -j ACCEPT
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -i $INTERNAL_ITF -o $EXTERNAL_ITF -p tcp --dport https -j ACCEPT
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -i $INTERNAL_ITF -o $EXTERNAL_ITF -p tcp --dport ssh -j ACCEPT

# FTP from the Internal network to the Internet
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -i $INTERNAL_ITF -o $EXTERNAL_ITF -p tcp --dport ftp -j ACCEPT
sudo iptables -t filter -A FORWARD -d $INTERNAL_NET -i $EXTERNAL_ITF -o $INTERNAL_ITF -p tcp --sport ftp-data -j ACCEPT

# Allow the return of the previously communications
sudo iptables -t filter -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# ---- INPUT ---- #

# Policy
sudo iptables -t filter -P INPUT DROP

# Allow SSH connections to the router
# TODO: nao sei se temos de usar o porto de origem para identificar o vpn gw (ate porque nao sei se ele manda sempre a partir do mesmo porto ou se e dinamico)
sudo iptables -t filter -A INPUT -s $DMZ_MACHINE_IP -d $DMZ_ROUTER_IP -p tcp --dport ssh -j ACCEPT      # Originated at the vpn-gw
sudo iptables -t filter -A INPUT -s $INTERNAL_NET -d $INTERNAL_ROUTER_IP -p tcp --dport ssh -j ACCEPT   # Originated at the Internal Network

# ---- OUTPUT ---- #

# Policy
sudo iptables -t filter -P OUTPUT DROP

# Allow DNS requests from the router
# TODO: Não sei se isto é necessário (não percebi bem)
sudo iptables -t filter -A OUTPUT -s $EXTERNAL_ROUTER_IP -p tcp --dport domain -j ACCEPT
sudo iptables -t filter -A OUTPUT -s $EXTERNAL_ROUTER_IP -p udp --dport domain -j ACCEPT


## ==== [ Table nat ] ==== ##

# ---- PREROUTING ---- #

# FTP connection to the ftp server
# Active mode
sudo iptables -t nat -A PREROUTING -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --dport ftp -j DNAT --to-destination $INTERNAL_MACHINE_IP

# SSH to the datastore
sudo iptables -t nat -A PREROUTING -s $EXTERNAL_EDEN -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --dport ssh -j DNAT --to-destination $INTERNAL_MACHINE_IP
sudo iptables -t nat -A PREROUTING -s $EXTERNAL_DNS2 -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --dport ssh -j DNAT --to-destination $INTERNAL_MACHINE_IP

# ftp-data from Internet to Internal network
sudo iptables -t nat -A PREROUTING -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --sport ftp-data -j DNAT ____________


# ---- OUTPUT ---- #

# ---- POSTROUTING ---- #

# DNS from DMZ
sudo iptables -t nat -A POSTROUTING -s $DMZ_NET -o $EXTERNAL_ITF -p tcp --dport domain -j SNAT --to-source $EXTERNAL_ROUTER_IP
sudo iptables -t nat -A POSTROUTING -s $DMZ_NET -o $EXTERNAL_ITF -p udp --dport domain -j SNAT --to-source $EXTERNAL_ROUTER_IP

# DNS from Internal Network
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NET -o $EXTERNAL_ITF -p tcp --dport domain -j SNAT --to-source $EXTERNAL_ROUTER_IP
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NET -o $EXTERNAL_ITF -p udp --dport domain -j SNAT --to-source $EXTERNAL_ROUTER_IP

# FTP active mode
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_MACHINE_IP -o $EXTERNAL_ITF -p tcp --sport ftp-data -j SNAT --to-source $EXTERNAL_ROUTER_IP

# HTTP, HTTPS and SSH from Internal Network to the Internet
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NET -o $EXTERNAL_ITF -p tcp --dport http -j SNAT --to-source $EXTERNAL_ROUTER_IP
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NET -o $EXTERNAL_ITF -p tcp --dport https -j SNAT --to-source $EXTERNAL_ROUTER_IP
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NET -o $EXTERNAL_ITF -p tcp --dport ssh -j SNAT --to-source $EXTERNAL_ROUTER_IP

# FTP from Internal Network to the Internet
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NET -o $EXTERNAL_ITF -p tcp --dport ftp -j SNAT --to-source $EXTERNAL_ROUTER_IP 


## ==== [ Table mangle ] ==== ##

# ---- PREROUTING ---- #

# ---- FORWARD ---- #

# ---- INPUT ---- #

# ---- OUTPUT ---- #

# ---- POSTROUTING ---- #

