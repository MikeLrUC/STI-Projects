# ligar o OCSP em Coimbra
sudo openssl ocsp -index /etc/pki/CA/index.txt -port 81 -rsigner /etc/pki/CA/cacert.pem -rkey /etc/pki/CA/private/cakey.pem -CA /etc/pki/CA/cacert.pem -text -out log.txt
