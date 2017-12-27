#!/bin/bash


rm /etc/network/interfaces
cp /vagrant/interfaces /etc/network/interfaces
cat /vagrant/proxy >> /etc/profile

cp /vagrant/apt.conf /etc/apt/apt.conf
cp /vagrant/resolv.conf /etc/resolv.conf

sudo apt-get update && sudo apt-get -y upgrade

sudo mv /etc/ssh/sshd_config /etc/ssh/sshd_config_old
sudo cp /vagrant/sshd_config /etc/ssh/sshd_config
