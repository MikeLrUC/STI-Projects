#!/bin/bash

# configure interface
sudo ifconfig ens33 10.10.10.2 netmask 255.255.255.0
sudo route add default gw 10.10.10.1 ens33