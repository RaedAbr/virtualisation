# Vagrant

*14.11.2017*

Raed et moi (Steven) avons commencé à explorer [Vagrant](https://www.vagrantup.com/) avec [KVM](https://www.linux-kvm.org/page/Main_Page) sous l'impulsion du groupe Cluster KVM (Sylvain, Loïc, Nathanaël et Mayron). Ils aimeraient pouvoir déployer et configurer leurs VMs automatiquement.

## Qu'est-ce que Vagrant ?

Vagrant est un outil de gestion du cycle de vie de machines virtuelles. Il permet de créer et de lancer une ou plusieurs machines virtuelles pré-configurées selon des critères définis à l'avance dans des fichiers de configuration (Vagrantfile).

## Recherches et tests avec Vagrant

Le problème initial est que Vagrant peut déployer des machines virtuelles uniquement pour VirtualBox, Hyper-V et VMware par défaut. Nous avons alors cherché un moyen de déployer pour KVM.

Un plugin/librairie existe, [vagrant-libvirt](https://github.com/vagrant-libvirt/vagrant-libvirt) (provider pour Vagrant). Nous avons commencé la lecture de cette doc. Nous avons utilisé la version 1.9.1 de Vagrant, qui n'est pas la dernière en date et qui est compatible avec libvirt. Nous avons réalisé toutes ces manipulations sur nos machines personnelles car la plupart du temps les droits *root* étaient requis et qu'il n'y avait pas forcément les bonnes versions des softs.

Nous avons eu de la peine à utiliser Vagrant avec libvirt et KVM car Vagrant n'est pas compatible par défaut avec KVM. Nous avons cherché plusieurs tutoriels et sommes tombés sur cet unique script qui avait l'air prometteur. Avec ce script nous voulions transformer notre image `client1` existante pour la donner au groupe KVM (voir ligne 12 dans le code suivant, `centos-7-client1-disk1.vmdk`).

```bash
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
```

Ce script a fonctionné partiellement, car il ne prenait pas l'image qu'on lui a fournit, mais une image par défaut. **C'est pour cela que nous avons abandonné l'idée d'utiliser Vagrant avec KVM et libvirt.**

Nous avons toutefois remarqué (**27.11.2017**) que la librairie a été mise à jour ces derniers jours et, qu'apparemment, elle est compatible avec la dernière version de Vagrant (2.0.1).



## Commandes et scripts pour CentOS 7

Vagrant utilise des "box" comme images de base, qu'on peut lui fournir en local (typiquement des fichiers iso ou .img) ou depuis [Vagrant Cloud](https://app.vagrantup.com/boxes/search). Dans notre cas, nous avons utilisé l'image `centos/7`. Voici une marche à suivre pour utiliser Vagrant avec VirtualBox.

Tout d'abord, nous créons un dossier pour Vagrant :

```shell
$ mkdir vagrant_folder
$ cd vagrant_folder
$ vagrant init
```

`vagrant init` crée un fichier de configuration nommé `Vagrantfile`, dont voici le contenu initial :

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "base"
end
```

Ensuite, nous exécutons cette commande :

```shell
$ vagrant box add centos/7
```

Ceci télécharge la box en question et nous permet de choisir le provider avec lequel nous allons travailler. Une fois cette tâche terminée (téléchargement), devons normalement obtenir le message suivant :

```shell
==> box: Successfully added box 'centos/7' (v1710.01) for 'VirtualBox'!
```

Nous pouvons maintenant commencer à éditer notre fichier `Vagrantfile` comme ceci :

```shell
Vagrant.configure("2") do |config|
  config.vm.box = "centos/7"
end
```

Finalement, nous lançons la machine virtuelle avec la commande suivante :

```shell
$ vagrant up
```

Voici sa sortie :

```shell
Bringing machine 'default' up with 'VirtualBox' provider...
==> default: Importing base box 'centos/7'...
==> default: Matching MAC address for NAT networking...
==> default: Checking if box 'centos/7' is up to date...
==> default: Setting the name of the VM: vagrant_default_1511781695307_34658
==> default: Clearing any previously set network interfaces...
==> default: Preparing network interfaces based on configuration...
    default: Adapter 1: nat
==> default: Forwarding ports...
    default: 22 (guest) => 2222 (host) (adapter 1)
==> default: Booting VM...
==> default: Waiting for machine to boot. This may take a few minutes...
    default: SSH address: 127.0.0.1:2222
    default: SSH username: vagrant
    default: SSH auth method: private key
    default: 
    default: Vagrant insecure key detected. Vagrant will automatically replace
    default: this with a newly generated keypair for better security.
    default: 
    default: Inserting generated public key within guest...
    default: Removing insecure key from the guest if it's present...
    default: Key inserted! Disconnecting and reconnecting using new SSH key...
==> default: Machine booted and ready!
==> default: Checking for guest additions in VM...
    default: No guest additions were detected on the base box for this VM! Guest
    default: additions are required for forwarded ports, shared folders, host only
    default: networking, and more. If SSH fails on this machine, please install
    default: the guest additions and repackage the box to continue.
    default: 
    default: This is not an error message; everything may continue to work properly,
    default: in which case you may ignore this message.
==> default: Rsyncing folder: /home/raed/Bureau/vagrant/ => /vagrant
```

Nous constatons que par défaut le port pour SSH est le 2222, que l'IP est la 127.0.0.1 et que `username = vagrant` et utilise une paire de clé pour l'authentification. Finalement nous pouvons nous connecter à la machine virtuelle avec la commande suivante :

```shell
$ vagrant ssh
```





*Décembre 2017*

## Déploiement et configuration

Nous avons continué nos expériences avec Vagrant avec VirtualBox comme provider. Nous avons finalement réussi à installer, configurer et lancer une machine virtuelle sous Debian (Jessie) et pouvoir s'y connecter en SSH avec l'utilisateur `vagrant`. 



Arborescence des fichiers :

```t
.
├── apt.conf
├── bootstrap.sh
├── interfaces
├── proxy
├── resolv.conf
├── script.sh
├── sshd_config
└── Vagrantfile
```



Fichier de configuration des sources pour `apt`, `apt.conf` :

```properties
Acquire::http::proxy "http://129.194.185.57:3128/";
Acquire::https::proxy "https://129.194.185.57:3128/";
Acquire::ftp::proxy "ftp://129.194.185.57:3128/";
```



Script exécuté par Vagrant lorsque l'installation de la machine virtuelle est terminée, `bootstrap.sh` :

```bash
#!/bin/bash

cp /vagrant/interfaces /etc/network/interfaces
cat /vagrant/proxy >> /etc/profile
cp /vagrant/apt.conf /etc/apt/apt.conf
cp /vagrant/resolv.conf /etc/resolv.conf

sudo apt-get update && sudo apt-get -y upgrade

mv /etc/ssh/sshd_config /etc/ssh/sshd_config_old
cp /vagrant/sshd_config /etc/ssh/sshd_config
```



Fichier de configuration des interfaces réseau pour Debian, `interfaces` :

```properties
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
	address 10.194.184.196
	netmask 255.255.255.0
	gateway 10.194.184.1
```



Configuration du proxy (contrainte du réseau de l'hepia), `proxy` :

```properties
MY_PROXY="http://129.194.185.57:3128/"

HTTP_PROXY=$MY_PROXY
HTTPS_PROXY=$MY_PROXY
FTP_PROXY=$MY_PROXY
http_proxy=$MY_PROXY
https_proxy=$MY_PROXY
ftp_proxy=$MY_PROXY

export HTTP_PROXY HTTPS_PROXY FTP_PROXY http_proxy https_proxy ftp_proxy
```



Fichier de configuration DNS (mauvaise adresse par défaut), `resolv.conf` :

```properties
nameserver 9.9.9.9
```



Script de lancement initial, `script.sh` :

```bash
#!/bin/bash

NICTYPE="82540EM"
ADAPTER=enp0s31f6
MACHINE_NAME="vagrant_debian_client"

vagrant destroy
vagrant up
vagrant halt
VBoxManage modifyvm $MACHINE_NAME --nic1 bridged --nictype1 $NICTYPE --bridgeadapter1 $ADAPTER
VBoxManage startvm $MACHINE_NAME --type headless
```



Configuration du serveur SSH sur Debian, `sshd_config` :

```properties
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
UsePrivilegeSeparation yes
KeyRegenerationInterval 3600
ServerKeyBits 1024
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin without-password
StrictModes yes

RSAAuthentication yes
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no

X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server

UsePAM yes
UseDNS no
PasswordAuthentication yes
```



`Vagrantfile` :

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "debian/jessie64"
  config.vm.provision :shell, path: "bootstrap.sh"
  config.vm.provider :virtualbox do |vb|
    vb.name = "vagrant_debian_client"
  end
end
```












