#!/bin/bash

# Script to install and run docker JuiceShop

cd ~/Desktop

# Install docker: https://docs.docker.com/engine/install/debian/

# Update the apt package index and install packages to allow apt to use a repository over HTTPS:
sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release -y

# Add Docker’s official GPG key:
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Use the following command to set up the repository:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the apt package index, and install the latest version of Docker Engine, containerd, and Docker Compose
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y

# Docker JuiceShop Image pull and run
if [[ $(uname -p) == 'x86_64' ]]; then
    sudo docker pull bkimminich/juice-shop
    sudo docker run --rm -p 3000:3000 bkimminich/juice-shop
else
    sudo docker pull bkimminich/juice-shop:snapshot-arm
    sudo docker run --rm -p 3000:3000 bkimminich/juice-shop:snapshot-arm
fi