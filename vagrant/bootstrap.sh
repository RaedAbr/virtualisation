#!/bin/bash

sudo localectl set-keymap ch-fr

cp /vagrant/profile /etc/profile
cp /vagrant/yum.conf /etc/yum.conf
mv /etc/sysconfig/network-scripts/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0_old
cp /vagrant/ifcfg-eth0 /etc/sysconfig/network-scripts/ifcfg-eth0

sudo yum update -y
