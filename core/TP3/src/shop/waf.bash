#!/bin/bash

# Script to install and configure the Web Application Firewall (apache2 + ModSecurity)

filedir=`dirname "$0"`

sudo apt-get update -y

# Install Apache2
sudo apt-get install apache2 -y

# Install ModSecurity (also installs ModSecurity - Core Rule Set)
sudo apt-get install libapache2-mod-security2 -y

# Proxying (To connect the WAF to the Juice shop)
sudo a2enmod proxy
sudo a2enmod proxy_http
sudo a2enmod proxy_balancer
sudo a2enmod lbmethod_byrequests

# Check Modules Installation
test_modules=("security2_module" "nonexistentmodule")
for module in ${test_modules[@]}; do 
    sudo apache2ctl -M | grep "${module}" > /dev/null && echo "${module}: ✅ Available" || echo "${module}: 🚫 Unavailable"
done

# Configuration File
sudo cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
echo "SecRuleEngine On" | sudo tee -a /etc/modsecurity/modsecurity.conf

# Replace Configs
sudo cp $filedir/configs/000-default.conf /etc/apache2/sites-enabled/000-default.conf
sudo cp $filedir/configs/crs-setup.conf /etc/modsecurity/crs/crs-setup.conf

# Restart Apache2 Service
sudo apache2ctl restart

# Test Security
sudo apt-get install curl -y 
curl --silent http://localhost:80/?exec=/bin/bash | grep "403" > /dev/null && echo "Port Protected: ✅ Yes" || echo "Port Protected: 🚫 No"
curl --silent http://localhost:80/ | grep "Juice Shop" > /dev/null && echo "WAF connects to Juice Shop: ✅ Yes" || echo "WAF connects to Juice Shop: 🚫 No"