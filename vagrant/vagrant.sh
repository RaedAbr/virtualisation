#!/bin/bash

if [[ $# != 6 ]]; then
    echo "Usage: ./vagrant.sh <template> <folder_name> <machine_name> <ip> <cpu> <ram>"
    echo "<folder_name> is like: debian_apache"
    echo "<machine_name> is like: vagrant_debian_client"
    echo "<ip> is like: 10.194.184.196"
    echo "<cpu> is like: 2"
    echo "<ram> is like: 512"
    exit 1
fi

TEMPLATE=$1
FOLDER_NAME=$2
MACHINE_NAME=$3
IP=$4
CPU=$5
RAM=$6

rm -rf $FOLDER_NAME
mkdir $FOLDER_NAME
cp -r debian/* $FOLDER_NAME
cd $FOLDER_NAME
./create.sh $MACHINE_NAME $IP $CPU $RAM
cd ..
rm -rf $FOLDER_NAME


##### Ansible part #####
ssh root@10.194.184.190 "ansible-playbook /etc/ansible/roles/main_service.yml -e \"service=Web port_http=80 domain=$IP\" --limit 'Debian'"
