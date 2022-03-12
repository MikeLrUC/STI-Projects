#!/bin/bash

# code from https://studfile.net/preview/6009974/page:61/

ocsp_url="http://ocsp.server:81"
issuer="/etc/pki/CA/cacert.pem"

[ "$1" -ne 0 ] && exit 0

cd "/etc/openvpn"

if [ -n "{tls_serial_0}" ]; then
    status=$(openssl ocsp \
                -issuer ${issuer} \
                -CA ${issuer} \
                -url ${ocsp_url} \
                -serial "0x${tls_serial_0}" 2> /dev/null)
    if [ $? -eq 0 ]; then
        echo "OCSP status: $status"
        echo "${status}" | grep -Fq "0x${tls_serial_0}: good" && exit 0
    fi
    echo "ocsp command failled!"
fi
exit 1
