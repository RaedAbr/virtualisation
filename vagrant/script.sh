#!/bin/bash

NICTYPE="82540EM"
ADAPTER=enp0s31f6
MACHINE_NAME="vagrant_client"

vagrant destroy
vagrant up
vagrant halt
VBoxManage modifyvm $MACHINE_NAME --nic1 bridged --nictype1 $NICTYPE --bridgeadapter1 $ADAPTER
VBoxManage startvm $MACHINE_NAME --type headless
