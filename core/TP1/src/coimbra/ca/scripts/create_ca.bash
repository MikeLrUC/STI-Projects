#!/bin/bash

# Create CA folder and Subfolders
cd /etc/pki/
sudo mkdir CA
cd CA
sudo mkdir certs newcerts private

# Generate key pairs
sudo openssl genrsa -des3 -out ./private/cakey.pem -passout pass:cakey 2048 

# Generate Certificate Signing Request (CSR)
sudo openssl req -new -key ./private/cakey.pem -out ca.csr -subj "/C=PT/ST=Coimbra/L=Coimbra/O=UC/OU=DEI/CN=MyPrivateCA" -passin pass:cakey

# Generate X.509 "Self-Signed" Certificate 
sudo openssl x509 -req -in ca.csr -out cacert.pem -signkey ./private/cakey.pem  -passin pass:cakey

# Remove CSR
sudo rm ca.csr

# Create index.txt and serial files for the CA to function properly
sudo touch index.txt
echo 01 | sudo tee serial