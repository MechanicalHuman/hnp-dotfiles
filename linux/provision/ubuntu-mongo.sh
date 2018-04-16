#!/bin/bash

function log () {
  echo "  ○ $1"
}


echo "---------------------------------"
echo "Provisioning script for Ubuntu 16"
echo "---------------------------------"

export DEBIAN_FRONTEND=noninteractive

log 'Installing MongoDB 3.6.x'

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 2930ADAE8CAF5059EE73BB4B58712A2291FA4AD5
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu xenial/mongodb-org/3.6 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-3.6.list
sudo apt-get -y update
sudo apt-get install -y mongodb-org

log 'Setting mongodb service'

sudo systemctl enable mongod.service
sudo systemctl start mongod.service

echo "---------------------------------"
echo "   Succesfully installed mongodb "
echo "---------------------------------"
