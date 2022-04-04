#!/bin/bash

# configure interface
sudo ifconfig ens33 10.20.20.2 netmask 255.255.255.0
sudo route add default gw 10.20.20.1 ens33