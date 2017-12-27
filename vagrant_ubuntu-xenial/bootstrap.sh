#!/bin/bash

# sudo loadkeys fr_ch

rm /etc/network/interfaces
cp /vagrant/interfaces /etc/network/interfaces
cat /vagrant/proxy >> /etc/profile
# cp /vagrant/yum.conf /etc/yum.conf
# mv /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0_old
# cp /vagrant/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0

sudo apt-get update && sudo apt-get -y upgrade
