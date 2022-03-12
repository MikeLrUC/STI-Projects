#!/bin/bash

if [ $# -ne 1 ]; then
    echo "Usage: bash revoke_cert.bash <certificate name>"
    exit 1
fi

NAME=$1

# go to the CA's directory
cd /etc/pki/CA
pwd

#revoke the certificate
sudo openssl ca -revoke certs/"$NAME.crt" -keyfile private/cakey.pem -cert cacert.pem

# Create CRL file
sudo openssl ca -gencrl -keyfile private/cakey.pem -cert cacert.pem -out cacrl.pem
