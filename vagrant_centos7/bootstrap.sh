#!/bin/bash

sudo localectl set-keymap ch-fr

cp /vagrant/profile /etc/profile
cp /vagrant/yum.conf /etc/yum.conf
mv /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0_old
cp /vagrant/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0

sudo yum update -y
sudo yum install -y nano net-tools.x86_64

#sudo mv /etc/ssh/sshd_config /etc/ssh/sshd_config_old
#sudo cp /vagrant/sshd_config /etc/ssh/sshd_config

cp /vagrant/id_rsa.pub /home/vagrant/.ssh/authorized_keys
