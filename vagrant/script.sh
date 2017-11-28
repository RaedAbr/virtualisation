#!/bin/bash

vagrant destroy
vagrant up
vagrant halt
VBoxManage modifyvm "vagrant_client" --nic1 bridged --nictype1 "82540EM" --bridgeadapter1 eth0
#VBoxManage startvm "vagrant_client"