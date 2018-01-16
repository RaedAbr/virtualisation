#!/bin/bash

FOLDER=conf_files_vm

cp /vagrant/$FOLDER/interfaces /etc/network/interfaces
cat /vagrant/$FOLDER/proxy >> /etc/profile
cp /vagrant/$FOLDER/apt.conf /etc/apt/apt.conf
cp /vagrant/$FOLDER/resolv.conf /etc/resolv.conf
cat /vagrant/$FOLDER/pub_key_server_ansible >> /home/vagrant/.ssh/authorized_keys

sudo apt update
#sudo apt -y upgrade
sudo apt -y install net-tools nano htop

mv /etc/ssh/sshd_config /etc/ssh/sshd_config_old
cp /vagrant/$FOLDER/sshd_config /etc/ssh/sshd_config
