#!/bin/bash

# Script to test all connections from the Internal Network to Elsewhere 

TIMEOUT=1
ROUTER_IP=10.20.20.2
DMZ_MACHINE_IP=10.10.10.3

echo "SSH to the Router:"
nc -z -w $TIMEOUT $ROUTER_IP ssh && echo "✅ Available" || echo "🚫 Unavailable"

echo "DNS request to Internet DNS servers"
nslookup -timeout=1 dei.uc.pt > /dev/null && echo "✅ Available" || echo "🚫 Unavailable"

echo "HTTP to Internet"
wget -nv google.com > /dev/null && echo "✅ Available" || echo "🚫 Unavailable"

echo "HTTPS to Internet"
wget -nv --https-only google.com > /dev/null && echo "✅ Available" || echo "🚫 Unavailable"

echo "SSH to Internet"
nc -z -w $TIMEOUT eden.dei.uc.pt ssh && echo "✅ Available" || echo "🚫 Unavailable"

echo "FTP to Internet"
nc -z -w $TIMEOUT ftp.dei.uc.pt ftp && echo "✅ Available" || echo "🚫 Unavailable"
