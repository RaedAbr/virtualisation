#!/bin/bash

cp /vagrant/profile /etc/profile
cp /vagrant/yum.conf /etc/yum.conf
mv /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0_old
cp /vagrant/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0

sudo service network restart

# apt-get update
# apt-get install -y apache2
# if ! [ -L /var/www ]; then
#   rm -rf /var/www
#   ln -fs /vagrant /var/www
# fi