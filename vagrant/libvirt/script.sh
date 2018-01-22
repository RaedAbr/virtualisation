BOX_NAME=vagrant-build
BASE_DIR="`pwd`/machines"
BOX_DIR="${BASE_DIR}/${BOX_NAME}"

mkdir -p ${BASE_DIR}

VBoxManage createvm --name "${BOX_NAME}" --ostype RedHat_64 --basefolder ${BASE_DIR}
VBoxManage registervm "${BOX_DIR}/${BOX_NAME}.vbox"

mkdir -p tmp
rm -rf tmp/clone.vdi
VBoxManage clonehd centos-7-client1-disk1.vmdk tmp/clone.vdi --format vdi
VBoxManage modifyhd tmp/clone.vdi --resize 20480
VBoxManage clonehd tmp/clone.vdi "${BOX_DIR}/${BOX_NAME}.vmdk" --format vmdk
VBoxManage -q closemedium disk tmp/clone.vdi
rm -f tmp/clone.vdi

VBoxManage storagectl "${BOX_NAME}" --name LsiLogic --add scsi --controller LsiLogic
VBoxManage storageattach "${BOX_NAME}" --storagectl LsiLogic --port 0 --device 0 --type hdd --medium "${BOX_DIR}/${BOX_NAME}.vmdk"

VBoxManage setextradata "${BOX_NAME}" "VBoxInternal/Devices/e1000/0/LUN#0/Config/SSH/Protocol" TCP
VBoxManage setextradata "${BOX_NAME}" "VBoxInternal/Devices/e1000/0/LUN#0/Config/SSH/GuestPort" 22
VBoxManage setextradata "${BOX_NAME}" "VBoxInternal/Devices/e1000/0/LUN#0/Config/SSH/HostPort" 22222

VBoxManage modifyvm "${BOX_NAME}" --usb on --usbehci on
VBoxManage modifyvm "${BOX_NAME}" --memory 512

VBoxManage startvm "${BOX_NAME}" #--type headless

echo "Sleeping to give machine time to boot"
sleep 240

echo "Uploading ssh key & creating vagrant user"
cat ~/.ssh/id_rsa.pub | ssh -p 22222 root@localhost "umask 077; test -d .ssh || mkdir .ssh ; cat >> .ssh/authorized_keys"  
ssh -p 22222 root@localhost <<EOT
  useradd vagrant 
  echo vagrant | passwd vagrant --stdin
  umask 077 
  test -d /home/vagrant/.ssh || mkdir -p /home/vagrant/.ssh
  cp ~/.ssh/authorized_keys /home/vagrant/.ssh
  chown -R vagrant:vagrant /home/vagrant/.ssh
EOT
scp -P 22222 templates/sudoers root@localhost:/etc/sudoers

echo -n "Waiting for machine to shutdown"
VBoxManage controlvm ${BOX_NAME} acpipowerbutton
while [ `VBoxManage showvminfo --machinereadable ${BOX_NAME} | grep VMState=` != 'VMState="poweroff"' ]; do
  echo -n .
  sleep 1
done
echo "Done"
vagrant package --base ${BOX_NAME} --output ${BOX_NAME}.box