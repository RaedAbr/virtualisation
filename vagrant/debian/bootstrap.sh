#!/bin/bash

FOLDER=conf_files_vm

cp /vagrant/$FOLDER/interfaces /etc/network/interfaces
cat /vagrant/$FOLDER/proxy >> /etc/profile
cp /vagrant/$FOLDER/apt.conf /etc/apt/apt.conf
cp /vagrant/$FOLDER/resolv.conf /etc/resolv.conf

sudo apt-get update && sudo apt-get -y upgrade

mv /etc/ssh/sshd_config /etc/ssh/sshd_config_old
cp /vagrant/$FOLDER/sshd_config /etc/ssh/sshd_config
