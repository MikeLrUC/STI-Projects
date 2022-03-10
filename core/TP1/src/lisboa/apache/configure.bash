#!/bin/bash

# PARTO DO PRINCIPIO QUE OS CERTIFICADOS JA FORAM CRIADOS E ESTAO NOS FOLDERS CORRETOS

filedir=`dirname "$0"`

# instalar o apache
sudo apt-get install apache2 -y

# iniciar o apache
sudo systemctl start apache2

# dar enable ao modulo ssl
sudo a2enmod ssl

# dar load dos folders para os locais corretos
    # folders html
    sudo mkdir -p /var/www/http /var/www/ssl-http
    sudo cp -f -r $filedir/html/http/ /var/www/
    sudo cp -f -r $filedir/html/ssl-http/ /var/www/

    # folders conf do apache
    sudo cp -f $filedir/config/http.conf $filedir/config/ssl-http.conf /etc/apache2/sites-available

# dar enable aos sites no servico apache
cd /etc/apache2/sites-available
sudo a2ensite http.conf
sudo a2ensite ssl-http.conf

# Update Hosts
echo "10.10.0.1  tp1.ul.pt" | sudo tee -a /etc/hosts
echo "10.10.0.6  ocsp.server" | sudo tee -a /etc/hosts # Coimbra

# dar reload ao apache
sudo systemctl reload apache2
