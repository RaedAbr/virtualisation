# Vagrant et KVM (avec libvirt)

**14.11.2017** : Raed et moi (Steven) avons commencé à explorer [Vagrant](https://www.vagrantup.com/) avec [KVM](https://www.linux-kvm.org/page/Main_Page) sous l'impulsion du groupe Cluser KVM (Sylvain, Loïc, Nathanaël et Mayron). Ils aimeraient pouvoir déployer configurer leurs VMs automatiquement.

Le problème initial est que Vagrant peut déployer des machines virtuelles uniquement pour Virtualbox, Hyper-V et VMware. Nous avons alors cherché un moyen de déployer pour KVM.

Un plugin/librairie existe, [vagrant-libvirt](https://github.com/vagrant-libvirt/vagrant-libvirt). Nous avons commencé la lecture.