***

# Ansible  

## Introduction
### Qu'est-ce que Ansible ?

Ansible est un logiciel libre d'automatisation des applications et de l'infrastructure informatique. Déploiement d'application, gestion de Configuration et livraison en continue.

### But final
Gaetan et moi (Jean-Etienne) avons commencé à explorer ansible et ces possibilités pour pouvoir déployer des installations, mises à jour, ... automatiquement dans un réseau pour pouvoir l'intégrer avec Vagrant (Read et Steven).
Au final nous devons déployer une machine virtuelle avec un service et des paramètres donner.


### Version utilisée (Ansible et OS) :


Pour notre projet nous avons installés un CentOS 7 avec une configuration minimale, dans laquelle nous avons par la suite ajouté :

-  EPEL release
-  Ansible (version 2.4.1.0)
-  Python (version 2.7.5)
-  Nano

**Attention**, la mise à jour d’Ansible peut fortement créer des soucis de compatibilités.



### Format a respecté impérativement en cas de création d’un fichier YAML (.yml) :

 

·     Chaque fichier doit commencer par  « **---** » (3 tirets normaux) hors rôle

·     L’indentation est très importante, utiliser uniquement des **ESPACES**.

·     Suivant l’OS, il est important de les différencier, car les commandes ne sont pas multiplateformes et entraine la non-fonctionnalité du script ansible.



## Accès SSH sur les machines :

Si des problèmes de connexion en ssh arrivent , utiliser les commandes suivantes : 

```bash
ssh-add
ssh-keygen -t rsa -C "ansible@ip_ansible"
ssh-copy-id user@ipduclient
```

​	Permettent de régler les problèmes en créant puis copiant des clés SSH afin de par la suite, ne pas avoir de problèmes d'identification.

​	**A noter** : la génération de clés n'est pas nécessaires si déjà effectué une fois.

 

## Principe des groupes d’utilisateurs/machines :

 

Il est à noter que le fichier se situant dans le fichier : 

```bash
/etc/ansible/hosts  
```

Se trouve les différents groupes de machines et utilisateurs pour ansible.

​	un utilisateur PEUT-être dans PLUSIEURS groupes différents.

Lors d’une commande ansible, il est possible de faire appel à un certain groupe, en rajoutant celui-ci à la fin de la commande ansible. Exemple avec le groupe **Users** :

```bash
ansible -m ping Users
```

 

Afin de rajouter un groupe, il faut reprendre la syntaxe suivante :

```properties
[nom_groupe]
nom_host1 ansible_ssh_host= addresse ip 1 
nom_host2 ansible_ssh_host= addresse ip 2
nom_host3 ansible_ssh_host= addresse ip 3
```

 Mais attention, il faut penser à créer le fichier

```bash
/etc/ansible/group_vars/nom_groupe
```

Il contient toutes les informations de configuration de connexion, comme ansible_ssh_user, qui n’est autre que le nom d’utilisateur utilisé pour se connecter au groupe en question.



## Utilisation de playbooks :

Pour lancer un playbook dans Ansible il faut exécuter la commande suivante :

```bash
ansible-playbook chemin_du_fichier/Nom_du_fichier -e "nom_variable=valeur_var"
```

Valeurs importantes à mettre dans le fichier en question :

-  hosts : Qui indique  le groupe ou la machine qui exécutera nos futures tâches/services
-  remote_user : nom d’utilisateur utilisé pour exécuter les tâches en question.
-  tasks : Indiquant le début de la liste des tâches qui vont être exécutées par la suite.

/!\ hosts a priorité sur remote_user !

Exemple simple avec un ping :

```yaml
---
- hosts: Users
  remote_user: root

  tasks:
    - ping:
```



Dans le cadre d'un service, celui-ci doit être appelé grâce à la façon suivante :

```yaml
- service:
     name: Nom_du_service_à_exécuter
     state: Etat_futur_du_service (started, stopped, restarted, reloaded)
```



Il est possible de récupérer des variables mises avec l'option -e (voir plus haut) pour ce faire le formatage du fichier se fait de la façon suivante :

- Nom_variable: "{{ Nom_variable }}" = peut recuperer une liste/tableau
- Nom_variable: "Nom_variable" = recuperer une string 

```yaml
---
  vars:
      Nom_variable: "{{ Nom_variable }}"
      
  tasks:
- include: tasks1.yml
when: 1

- include: tasks2.yml
when: 2
```

### Condition When dans ansible

Avec une condition when on peut faire un "if" avec une condition, ce qui permet d'appelle des roles/playbook , de faire des tâches et etc selon une condition.

### Pourquoi on l'utilise ?

Ont à utilisé la condition "ansible_os_family" (intégrer dans les services d'ansible) pour différencier par rapport à la famille de l'OS pour utiliser les bonnes commandes liées à celui-ci.
Ont à aussi utilisé pour notre variable "service" qui permet de savoir quel service installer (Web,dhcp,..).


##Rôles (extrait de buzut.fr):

Les rôles représentent une manière d’abstraire les directives includes.
Grâce aux rôles, il n’est plus utile de préciser les divers includes dans le playbook, ni les paths des fichiers de variables etc.
Le playbook n’a qu’à lister les différents rôles à appliquer.
En outre, depuis les tasks du rôle, l’ensemble des chemins sont relatifs. Inutile donc de préciser
Le nom du fichier suffit, Ansible s’occupe du reste.

### Pourquoi un/des rôle(s)
Car cela nous permet de généraliser une installation par service (web,dhcp,..) plus facilement et réutilisable par d'autres personnes !

### Génération du rôle
Pour générer un rôle , il faut utiliser "ansible-galaxy + nom + init".
Il va générer les dossiers/fichiers de base pour notre rôle. Notre dossier contiendra les dossiers/fichiers suivants :

```bash
- Roles
	- "Nom du role"
		- Defaults : les variables par défaut qui seront à disposition du rôle.
			- main.yml
		- Vars : Variables à disposition du rôle cependant elles ont vocation à être modifiées par l’utilisateur et elles prennent le dessus sur celle du dossier « defaults » si elles sont renseignées.
			- main.yml
		- Tasks : ici on renseigne nos taches (comme dans un playbooks normal).
			- main.yml
		- Meta : Sert à renseigner les dépendances liées à nos rôles (ssl, et etc).
			- main.yml
		- README : renseigne sur comment utilisé les rôles, variables à définir et etc.
```

 On appelle un rôle de la façon suivante:

```yaml
---
  tasks:
- include_role: role.yml
```



Bibliographie :

https://www.digitalocean.com/community/tutorials/how-to-install-and-configure-ansible-on-centos-7
https://github.com/ansible/ansible/issues/19584
https://docs.ansible.com/ansible/latest/yum_module.html
https://docs.ansible.com/ansible/latest/service_module.html
https://docs.ansible.com/ansible/latest/apt_module.html
https://docs.ansible.com/ansible/latest/apt_repository_module.html
https://serversforhackers.com/c/an-ansible-tutorial
https://buzut.fr/tirer-toute-puissance-dansible-roles/