#!/bin/bash

# Examples:                          File Name     Country   State & Location   Organization    Unit    Common Name

#           bash generate_crt.bash   myserver        PT         Coimbra             UC          DEI     my.server.net     
#           bash generate_crt.bash     uol           UK         London              UoL        SMCSE    smcse.ac.uk   

# Missing Parameters
if [ "$#" -ne 6 ]; then
    echo "Not enough Parameters"
    echo "1 - Name: Key file name, key password, crt file name, crt password"
    echo "2 - Country: DN Country [C]"
    echo "3 - State & Location: DN State / Province [ST] & DN City / Location [L]"
    echo "4 - Organization: DN Organization [O]"
    echo "5 - Unit: DN Organizational Unit [OU]"
    echo "6 - Common Name: DN Common Name [CN]"
    exit 2
fi

# NAME size
if [ ${#1} -le 3 ]; then
    echo "Name argument needs to have size >= 4"
    exit 1
fi

# Check if file name already exists in CA
if test -f "/etc/pki/CA/private/$1.key"; then
    echo "Name already taken"
    exit 1
fi

# Key and Certification File Name
NAME=$1

# Distinguished Name Parameters
C=$2
ST=$3
L=$3
O=$4
OU=$5
CN=$6

cd /etc/pki/CA/

# Generate key pairs
sudo openssl genrsa -des3 -out ./private/$NAME.key -passout pass:$NAME 2048 

# Generate Certificate Signing Request (CSR)
sudo openssl req -new -key ./private/$NAME.key -out $NAME.csr -subj "/C=$C/ST=$ST/L=$L/O=$O/OU=$OU/CN=$CN" -passin pass:$NAME

# Generate X.509 "Self-Signed" Certificate 
sudo openssl ca -in $NAME.csr -cert cacert.pem -keyfile ./private/cakey.pem -out ./certs/$NAME.crt -passin pass:cakey -batch

# Remove CSR
sudo rm $NAME.csr

# Convert to PKCS#12
sudo openssl pkcs12 -export -in ./certs/$NAME.crt -out ./p12/$NAME.p12 -inkey ./private/$NAME.key  -certfile cacert.pem -passin pass:$NAME -passout pass:export
sudo chmod 755 ./p12/$NAME.p12