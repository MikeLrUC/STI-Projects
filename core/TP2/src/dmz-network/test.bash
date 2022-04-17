#!/bin/bash

# Script to test all connections from the DMZ Network to Elsewhere 

TIMEOUT=1
ROUTER_IP=10.10.10.2

echo "SSH connection to the Router:"
nc -z -w $TIMEOUT $ROUTER_IP ssh && echo "✅ Available" || echo "🚫 Unavailable"

echo "DNS request to Internet DNS servers"
nslookup -timeout=1 dei.uc.pt > /dev/null && echo "✅ Available" || echo "🚫 Unavailable"