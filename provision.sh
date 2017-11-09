#!/bin/bash

set -euxo pipefail

######
# Java
######

sudo apt-get -y install default-jdk

########################
# Jenkins
########################
echo "Installing Jenkins"
wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update > /dev/null 2>&1
sudo apt-get -y install jenkins > /dev/null 2>&1

########################
# nginx
########################
echo "Installing nginx"
sudo apt-get -y install nginx > /dev/null 2>&1
sudo service nginx start

########################
# Configuring nginx
########################
echo "Configuring nginx"
cd /etc/nginx/sites-available
sudo rm default ../sites-enabled/default
sudo cp /vagrant/VirtualHost/jenkins /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/jenkins /etc/nginx/sites-enabled/
sudo service nginx restart
sudo service jenkins restart
echo "Success"

########
# Python
########

sudo apt-get install -y python3-dev python3-pip

sudo pip3 install --upgrade pip

sudo pip install virtualenv

mkdir selftest
cd selftest

virtualenv venv
source venv/bin/activate

cat <<EOT >> selftest.py
import pip
import sys

major, minor = sys.version_info[0:2]

assert (major, minor) >= (3, 5), "Required python version min 3.5"
version = '{}.{}'.format(major, minor)


print('Running in Python {}'.format(version))

pip.main(['install', '-I',  'requests'])
EOT

python selftest.py

