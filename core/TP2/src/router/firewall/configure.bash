#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: bash configure.bash <external-interface-name> <external-ip> <dmz-interface-name> <internal-interface-name>"
    exit 1
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
DMZ_ROUTER_IP=10.10.10.2
DMZ_MACHINE_IP=10.10.10.3

# Internal Network Variables
INTERNAL_ITF=$4
INTERNAL_NET=10.20.20.0/24
INTERNAL_ROUTER_IP=10.20.20.2
INTERNAL_MACHINE_IP=10.20.20.3

## ==== [ System Packages Installation ] ==== ##

## ==== [ System IP Forwarding ] ==== ##
sudo sysctl -w net.ipv4.ip_forward=1

## ==== [ System Interfaces Configuration ] ==== ##

sudo ifconfig $INTERNAL_ITF $INTERNAL_ROUTER_IP netmask 255.255.255.0   # Internal Network
sudo ifconfig $DMZ_ITF $DMZ_ROUTER_IP netmask 255.255.255.0             # DMZ

# IPTables Configuration 

## ==== [ Table filter ] ==== ##


# ---- FORWARD ---- #


# DNS

# Internal Network -> Internet
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -i $INTERNAL_ITF -o $EXTERNAL_ITF -p tcp --dport domain -j ACCEPT
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -i $INTERNAL_ITF -o $EXTERNAL_ITF -p udp --dport domain -j ACCEPT
# DMZ Network -> Internet
sudo iptables -t filter -A FORWARD -s $DMZ_NET -i $DMZ_ITF -o $EXTERNAL_ITF -p tcp --dport domain -j ACCEPT
sudo iptables -t filter -A FORWARD -s $DMZ_NET -i $DMZ_ITF -o $EXTERNAL_ITF -p udp --dport domain -j ACCEPT
# [Direct] Internal Network -> dns server
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p tcp --dport domain -j ACCEPT
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p udp --dport domain -j ACCEPT
# Internet -> dns server
sudo iptables -t filter -A FORWARD -d $DMZ_MACHINE_IP -i $EXTERNAL_ITF -o $DMZ_ITF -p tcp --dport domain -j ACCEPT
sudo iptables -t filter -A FORWARD -d $DMZ_MACHINE_IP -i $EXTERNAL_ITF -o $DMZ_ITF -p udp --dport domain -j ACCEPT

# DNS zone Synchronization [w/ TCP]:
#   - dns server  -> dns2 & Others  :   DONE ABOVE (DMZ -> Internet) 
#   - dns2 server -> dns server     :   DONE ABOVE (Internet -> dns server)


# SMTP

# [Direct] Internal Network -> smtp server
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p tcp --dport smtp -j ACCEPT
# Internet -> smtp server
sudo iptables -t filter -A FORWARD -d $DMZ_MACHINE_IP -i $EXTERNAL_ITF -o $DMZ_ITF -p tcp --dport smtp -j ACCEPT


# POP

# [Direct] Internal Network -> mail server
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p tcp --dport imap -j ACCEPT
# Internet -> mail server
sudo iptables -t filter -A FORWARD -d $DMZ_MACHINE_IP -i $EXTERNAL_ITF -o $DMZ_ITF -p tcp --dport imap -j ACCEPT


# IMAP

# [Direct] Internal Network -> mail server
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p tcp --dport pop -j ACCEPT
# Internet -> mail server
sudo iptables -t filter -A FORWARD -d $DMZ_MACHINE_IP -i $EXTERNAL_ITF -o $DMZ_ITF -p tcp --dport pop -j ACCEPT


# HTTP 

# [Direct] Internal Network -> www server
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p tcp --dport http -j ACCEPT
# Internet -> www server
sudo iptables -t filter -A FORWARD -d $DMZ_MACHINE_IP -i $EXTERNAL_ITF -o $DMZ_ITF -p tcp --dport http -j ACCEPT
# Internal Network -> Internet
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -i $INTERNAL_ITF -o $EXTERNAL_ITF -p tcp --dport http -j ACCEPT


# HTTPS

# [Direct] Internal Network -> www server
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_ITF -o $DMZ_ITF -p tcp --dport https -j ACCEPT
# Internet -> www server
sudo iptables -t filter -A FORWARD -d $DMZ_MACHINE_IP -i $EXTERNAL_ITF -o $DMZ_ITF -p tcp --dport https -j ACCEPT
# Internal Network -> Internet
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -i $INTERNAL_ITF -o $EXTERNAL_ITF -p tcp --dport https -j ACCEPT


# OpenVPN - https://openvpn.net/vpn-server-resources/advanced-option-settings-on-the-command-line/ 

# [Direct] Internal Network -> vpn-gw server
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_NET -o $DMZ_ITF -p udp --dport 1194 -j ACCEPT
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -d $DMZ_MACHINE_IP -i $INTERNAL_NET -o $DMZ_ITF -p tcp --dport 443 -j ACCEPT
# Internet -> vpn-gw server 
sudo iptables -t filter -A FORWARD -d $DMZ_MACHINE_IP -i $EXTERNAL_ITF -o $DMZ_ITF -p udp --dport 1194 -j ACCEPT
sudo iptables -t filter -A FORWARD -d $DMZ_MACHINE_IP -i $EXTERNAL_ITF -o $DMZ_ITF -p tcp --dport 443 -j ACCEPT


# PostgreSQL - https://www.speedguide.net/port.php?port=5432

# [Direct] VPN Clients -> datastore server
sudo iptables -t filter -A FORWARD -s $DMZ_MACHINE_IP -d $INTERNAL_MACHINE_IP -i $DMZ_ITF -o $INTERNAL_ITF -p tcp --dport 5432 -j ACCEPT


# Kerberos v5 - https://docs.oracle.com/cd/E41492_01/E41495/html/ad-auth.html

# [Direct] VPN Clients -> kerberos server
sudo iptables -t filter -A FORWARD -s $DMZ_MACHINE_IP -d $INTERNAL_MACHINE_IP -i $DMZ_ITF -o $INTERNAL_ITF -p tcp --dport 88 -m connlimit --connlimit-upto 10 -j ACCEPT
sudo iptables -t filter -A FORWARD -s $DMZ_MACHINE_IP -d $INTERNAL_MACHINE_IP -i $DMZ_ITF -o $INTERNAL_ITF -p udp --dport 88 -m connlimit --connlimit-upto 10 -j ACCEPT
sudo iptables -t filter -A FORWARD -s $DMZ_MACHINE_IP -d $INTERNAL_MACHINE_IP -i $DMZ_ITF -o $INTERNAL_ITF -p tcp --dport 464 -m connlimit --connlimit-upto 10 -j ACCEPT
sudo iptables -t filter -A FORWARD -s $DMZ_MACHINE_IP -d $INTERNAL_MACHINE_IP -i $DMZ_ITF -o $INTERNAL_ITF -p udp --dport 464 -m connlimit --connlimit-upto 10 -j ACCEPT


# FTP

# Internet -> ftp server
sudo iptables -t filter -A FORWARD -d $INTERNAL_MACHINE_IP -i $EXTERNAL_ITF -o $INTERNAL_ITF -p tcp --dport ftp -j ACCEPT
# ftp server ftp-data response -> Internet (Active mode)
sudo iptables -t filter -A FORWARD -s $INTERNAL_MACHINE_IP -i $INTERNAL_ITF -o $EXTERNAL_ITF -p tcp --sport ftp-data -j ACCEPT
# Internal Network -> Internet
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -i $INTERNAL_ITF -o $EXTERNAL_ITF -p tcp --dport ftp -j ACCEPT
# Internet ftp-data response -> "Internal Network" (Active Mode)
sudo iptables -t filter -A FORWARD -d $INTERNAL_NET -i $EXTERNAL_ITF -o $INTERNAL_ITF -p tcp --sport ftp-data -j ACCEPT

# SSH

# eden server -> datastore server
sudo iptables -t filter -A FORWARD -s $EXTERNAL_EDEN -d $INTERNAL_MACHINE_IP -o $INTERNAL_ITF -p tcp --dport ssh -j ACCEPT
# dns2 server -> datastore server
sudo iptables -t filter -A FORWARD -s $EXTERNAL_DNS2 -d $INTERNAL_MACHINE_IP -o $INTERNAL_ITF -p tcp --dport ssh -j ACCEPT  
# Internal Network -> Internet
sudo iptables -t filter -A FORWARD -s $INTERNAL_NET -i $INTERNAL_ITF -o $EXTERNAL_ITF -p tcp --dport ssh -j ACCEPT


# Allow the return of the previously communications 
sudo iptables -t filter -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

# Policy
sudo iptables -t filter -P FORWARD DROP



# ---- INPUT ---- #


# SSH - https://stackoverflow.com/questions/30616527/are-ssh-destination-and-source-ports-identical-symmetric-ports

# Internal Network -> Router
sudo iptables -t filter -A INPUT -s $INTERNAL_NET -d $INTERNAL_ROUTER_IP -i $INTERNAL_ITF -p tcp --dport ssh -j ACCEPT 
# vpn-gw machine -> Router
sudo iptables -t filter -A INPUT -s $DMZ_MACHINE_IP -d $DMZ_ROUTER_IP -i $DMZ_ITF -p tcp --dport ssh -j ACCEPT



# Policy 
sudo iptables -t filter -P INPUT DROP

# ---- OUTPUT ---- #


## ==== [ Table nat ] ==== ##

# ---- PREROUTING ---- #


# DNS

# Internet -> Router Internet IP into dns server 
sudo iptables -t nat -A PREROUTING -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --dport domain -j DNAT --to-destination $DMZ_MACHINE_IP 


# SMTP

# Internet -> Router Internet IP into smtp server
sudo iptables -t nat -A PREROUTING -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --dport smtp -j DNAT --to-destination $DMZ_MACHINE_IP 


# POP

# Internet -> Router Internet IP into mail server
sudo iptables -t nat -A PREROUTING -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --dport pop -j DNAT --to-destination $DMZ_MACHINE_IP 


# IMAP

# Internet -> Router Internet IP into mail server
sudo iptables -t nat -A PREROUTING -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --dport imap -j DNAT --to-destination $DMZ_MACHINE_IP 


# HTTP

# Internet -> Router Internet IP into www server
sudo iptables -t nat -A PREROUTING -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --dport http -j DNAT --to-destination $DMZ_MACHINE_IP 


# HTTPS

# Internet -> Router Internet IP into www server
sudo iptables -t nat -A PREROUTING -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --dport https -j DNAT --to-destination $DMZ_MACHINE_IP 


# OpenVPN

# Internet -> Router Internet IP into vpn-gw server
sudo iptables -t nat -A PREROUTING -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --dport 1194 -j DNAT --to-destination $DMZ_MACHINE_IP 
sudo iptables -t nat -A PREROUTING -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --dport 443 -j DNAT --to-destination $DMZ_MACHINE_IP 


# SSH

# eden -> Router Internet IP into datastore server
sudo iptables -t nat -A PREROUTING -s $EXTERNAL_EDEN -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --dport ssh -j DNAT --to-destination $INTERNAL_MACHINE_IP
# dns2 -> Router Internet IP into datastore server
sudo iptables -t nat -A PREROUTING -s $EXTERNAL_DNS2 -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --dport ssh -j DNAT --to-destination $INTERNAL_MACHINE_IP


# FTP

# Internet -> Router Internet IP into ftp server
sudo iptables -t nat -A PREROUTING -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --dport ftp -j DNAT --to-destination $INTERNAL_MACHINE_IP
# Internet ftp-data response -> Router Internet IP into "Internal Network" (Active Mode)
sudo iptables -t nat -A PREROUTING -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp --sport ftp-data -j DNAT --to-destination $INTERNAL_MACHINE_IP
# [ MUST BE LAST RULE ] Internet "ftp-data" follow-up -> Router Internet IP into "Internal Network" (Passive Mode)
sudo iptables -t nat -A PREROUTING -d $EXTERNAL_ROUTER_IP -i $EXTERNAL_ITF -p tcp -j DNAT --to-destination $INTERNAL_MACHINE_IP

# ---- OUTPUT ---- #

# ---- POSTROUTING ---- #


# DNS

# Internal Network into Router Internet IP -> Internet
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NET -o $EXTERNAL_ITF -p tcp --dport domain -j SNAT --to-source $EXTERNAL_ROUTER_IP
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NET -o $EXTERNAL_ITF -p udp --dport domain -j SNAT --to-source $EXTERNAL_ROUTER_IP
# DMZ Network into Router Internet IP -> Internet
sudo iptables -t nat -A POSTROUTING -s $DMZ_NET -o $EXTERNAL_ITF -p tcp --dport domain -j SNAT --to-source $EXTERNAL_ROUTER_IP
sudo iptables -t nat -A POSTROUTING -s $DMZ_NET -o $EXTERNAL_ITF -p udp --dport domain -j SNAT --to-source $EXTERNAL_ROUTER_IP


# HTTP

# Internal Network into Router Internet IP -> Internet
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NET -o $EXTERNAL_ITF -p tcp --dport http -j SNAT --to-source $EXTERNAL_ROUTER_IP


# HTTPS

# Internal Network into Router Internet IP -> Internet
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NET -o $EXTERNAL_ITF -p tcp --dport https -j SNAT --to-source $EXTERNAL_ROUTER_IP


# SSH

# Internal Network into Router Internet IP -> Internet
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NET -o $EXTERNAL_ITF -p tcp --dport ssh -j SNAT --to-source $EXTERNAL_ROUTER_IP


# FTP

# Internal Network into Router Internet IP -> Internet
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NET -o $EXTERNAL_ITF -p tcp --dport ftp -j SNAT --to-source $EXTERNAL_ROUTER_IP 
# ftp server ftp-data response into Router Internet IP -> Internet (Active mode)
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_MACHINE_IP -o $EXTERNAL_ITF -p tcp --sport ftp-data -j SNAT --to-source $EXTERNAL_ROUTER_IP
# [ MUST BE LAST RULE ] ftp server "ftp-data" follow-up into Router Internet IP -> Internet (Passive Mode)
sudo iptables -t nat -A POSTROUTING -s $INTERNAL_NET -o $EXTERNAL_ITF -p tcp -j SNAT --to-source $EXTERNAL_ROUTER_IP 


## ==== [ Other Commands ] ==== ##

# Allow FTP connections on passive mode
sudo modprobe ip_conntrack_ftp
