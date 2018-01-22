#!/bin/bash

if [[ $# != 4 ]]; then
    echo "Usage: ./create.sh <machine_name> <ip> <cpu> <ram>"
    echo "<machine_name> is like: vagrant_debian_client"
    echo "<ip> is like: 10.194.184.196"
    echo "<cpu> is like: 2"
    echo "<ram> is like: 512"
    exit 1
fi

NICTYPE="82540EM"
ADAPTER=enp0s31f6
FOLDER=conf_files_vm

MACHINE_NAME=$1
IP=$2
CPU=$3
RAM=$4

sed -i -e "s/\(address \).*/\1$IP/" $FOLDER/interfaces
sed -i -e "s/\(vb.name = \).*/\1\"$MACHINE_NAME\"/" Vagrantfile
sed -i -e "s/\(vb.memory = \).*/\1\"$RAM\"/" Vagrantfile
sed -i -e "s/\(vb.cpus = \).*/\1\"$CPU\"/" Vagrantfile

vagrant destroy
vagrant up
vagrant halt
VBoxManage modifyvm $MACHINE_NAME --nic1 bridged --nictype1 $NICTYPE --bridgeadapter1 $ADAPTER
VBoxManage startvm $MACHINE_NAME --type headless