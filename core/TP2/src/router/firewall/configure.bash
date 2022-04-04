#!/bin/bash

## ==== [ System Packages Installation ] ==== ##

## ==== [ System IP Forwarding ] ==== ##
sudo sysctl -w net.ipv4.ip_forward=1

## ==== [ System Interfaces Configuration ] ==== ##
# considero que a maquina tem as interfaces ens34 e ens36
sudo ifconfig ens34 10.20.20.1 netmask 255.255.255.0 # (Internal Network)
sudo ifconfig ens36 10.10.10.1 netmask 255.255.255.0 # (DMZ)

# IPTables Configuration 

## ==== [ Table filter ] ==== ##

# ---- FORWARD ---- #
sudo iptables -t filter -P FORWARD DROP

# allow dns using dns server in DMZ
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -d 10.10.10.2 -i ens34 -o ens36 -p tcp --dport domain -j ACCEPT
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -d 10.10.10.2 -i ens34 -o ens36 -p udp --dport domain -j ACCEPT
# allow smtp connections to the smtp server
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -d 10.10.10.2 -i ens34 -o ens36 -p tcp --dport smtp -j ACCEPT

# allow pop and imap connections to the mail server
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -d 10.10.10.2 -i ens34 -o ens36 -p tcp --dport imap -j ACCEPT
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -d 10.10.10.2 -i ens34 -o ens36 -p tcp --dport pop -j ACCEPT

# allow http and https connections
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -d 10.10.10.2 -i ens34 -o ens36 -p tcp --dport http -j ACCEPT
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -d 10.10.10.2 -i ens34 -o ens36 -p tcp --dport https -j ACCEPT

# allow openvpn connections
# https://openvpn.net/vpn-server-resources/advanced-option-settings-on-the-command-line/
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -d 10.10.10.2 -i ens34 -o ens36 -p udp --dport 1194 -j ACCEPT
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -d 10.10.10.2 -i ens34 -o ens36 -p tcp --dport 443 -j ACCEPT

# allow vpn clients from vpn-gw to connect to the datastore server
# https://www.speedguide.net/port.php?port=5432
sudo iptables -t filter -A FORWARD -s 10.10.10.2 -d 10.20.20.2 -i ens36 -o ens34 -p tcp --dport 5432 -j ACCEPT

# allow vpn clients from vpn-gw to connect to the kerberos v5 service
# https://www.oreilly.com/library/view/kerberos-the-definitive/0596004036/ch06s05s01.html
# HA MAIS PORTS MAS NAO SEI SE TEMOS DE OS COLOCAR TODOS...
sudo iptables -t filter -A FORWARD -s 10.10.10.2 -d 10.20.20.2 -i ens36 -o ens34 -p tcp --dport 88 -m connlimit --connlimit-upto 10 -j ACCEPT
sudo iptables -t filter -A FORWARD -s 10.10.10.2 -d 10.20.20.2 -i ens36 -o ens34 -p udp --dport 88 -m connlimit --connlimit-upto 10 -j ACCEPT

# forward the dns requests
sudo iptables -t filter -A FORWARD -s 10.10.10.2 -i ens36 -o ens33 -p tcp --dport domain -j ACCEPT # dns from dns server at DMZ
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -i ens34 -o ens33 -p tcp --dport domain -j ACCEPT # dns from internal network
sudo iptables -t filter -A FORWARD -s 10.10.10.2 -i ens36 -o ens33 -p udp --dport domain -j ACCEPT # dns from dns server at DMZ
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -i ens34 -o ens33 -p udp --dport domain -j ACCEPT # dns from internal network

# FTP connections to the server ftp
sudo iptables -t filter -A FORWARD -d 10.20.20.2 -i ens33 -o ens34 -p tcp --dport ftp -j ACCEPT
sudo iptables -t filter -A FORWARD -s 10.20.20.2 -i ens34 -o ens33 -p tcp --sport ftp-data -j ACCEPT
# allow ftp connections on passive mode
sudo modprobe ip_conntrack_ftp


# SSH to the datastore server
sudo iptables -t filter -A FORWARD -s 193.136.212.1 -d 10.20.20.2 -o ens34 -p tcp --dport ssh -j ACCEPT
sudo iptables -t filter -A FORWARD -s 193.137.16.75 -d 10.20.20.2 -o ens34 -p tcp --dport ssh -j ACCEPT

# HTTP, HTTPS and SSH from the internal network to the internet
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -i ens34 -o ens33 -p tcp --dport http -j ACCEPT
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -i ens34 -o ens33 -p tcp --dport https -j ACCEPT
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -i ens34 -o ens33 -p tcp --dport ssh -j ACCEPT

# FTP from the internal network to the internet
sudo iptables -t filter -A FORWARD -s 10.20.20.0/24 -i ens34 -o ens33 -p tcp --dport ftp -j ACCEPT
sudo iptables -t filter -A FORWARD -d 10.20.20.0/24 -i ens33 -o ens34 -p tcp --sport ftp-data -j ACCEPT

# allow the return of the previously communications
sudo iptables -t filter -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# ---- INPUT ---- #
# Drop all the communications that are not allowed by the chain rules
sudo iptables -t filter -P INPUT DROP
# allow ssh connections to the router
# TODO nao sei se temos de usar o porto de origem para identificar o vpn gw (ate porque nao sei se ele manda sempre a partir do mesmo porto ou se e dinamico)
sudo iptables -t filter -A INPUT -s 10.10.10.2 -d 10.10.10.1 -p tcp --dport ssh -j ACCEPT # originated at the vpn gw
sudo iptables -t filter -A INPUT -s 10.20.20.0/24 -d 10.20.20.1 -p tcp --dport ssh -j ACCEPT # originated at the internal network

# ---- OUTPUT ---- #
sudo iptables -t filter -P OUTPUT DROP
# allow dns requests from the router
# NAO SEI SE ISTO E NECESSARIO (NAO PERCEBI BEM)
sudo iptables -t filter -A OUTPUT -s 172.16.251.128 -p tcp --dport domain -j ACCEPT
sudo iptables -t filter -A OUTPUT -s 172.16.251.128 -p udp --dport domain -j ACCEPT


## ==== [ Table nat ] ==== ##

# ---- PREROUTING ---- #
# FTP connection to the ftp server
# active mode
sudo iptables -t nat -A PREROUTING -d 172.16.251.128 -i ens33 -p tcp --dport ftp -j DNAT --to-destination 10.20.20.2
# ssh to the datastore
sudo iptables -t nat -A PREROUTING -s 193.136.212.1 -d 172.16.251.128 -i ens33 -p tcp --dport ssh -j DNAT --to-destination 10.20.20.2
sudo iptables -t nat -A PREROUTING -s 193.137.16.75 -d 172.16.251.128 -i ens33 -p tcp --dport ssh -j DNAT --to-destination 10.20.20.2

# ftp-data from internet to internal network
sudo iptables -t nat -A PREROUTING -d 172.16.251.128 -i ens33 -p tcp --sport ftp-data -j DNAT ____________


# ---- OUTPUT ---- #

# ---- POSTROUTING ---- #
# dns from DMZ
sudo iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o ens33 -p tcp --dport domain -j SNAT --to-source 172.16.251.128
sudo iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o ens33 -p udp --dport domain -j SNAT --to-source 172.16.251.128
# dns from internal network
sudo iptables -t nat -A POSTROUTING -s 10.20.20.0/24 -o ens33 -p tcp --dport domain -j SNAT --to-source 172.16.251.128
sudo iptables -t nat -A POSTROUTING -s 10.20.20.0/24 -o ens33 -p udp --dport domain -j SNAT --to-source 172.16.251.128

# FTP active mode
sudo iptables -t nat -A POSTROUTING -s 10.20.20.2 -o ens33 -p tcp --sport ftp-data -j SNAT --to-source 172.16.251.128

# HTTP, HTTPS and SSH from internal network to the internet
sudo iptables -t nat -A POSTROUTING -s 10.20.20.0/24 -o ens33 -p tcp --dport http -j SNAT --to-source 172.16.251.128
sudo iptables -t nat -A POSTROUTING -s 10.20.20.0/24 -o ens33 -p tcp --dport https -j SNAT --to-source 172.16.251.128
sudo iptables -t nat -A POSTROUTING -s 10.20.20.0/24 -o ens33 -p tcp --dport ssh -j SNAT --to-source 172.16.251.128

# FTP from internal network to the internet
sudo iptables -t nat -A POSTROUTING -s 10.20.20.0/24 -o ens33 -p tcp --dport ftp -j SNAT --to-source 172.16.251.128 


## ==== [ Table mangle ] ==== ##

# ---- PREROUTING ---- #

# ---- FORWARD ---- #

# ---- INPUT ---- #

# ---- OUTPUT ---- #

# ---- POSTROUTING ---- #

