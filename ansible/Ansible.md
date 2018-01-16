# Ansible  

## Version utilisée (Ansible et OS) :

 

Pour notre projet nous avons installés un CentOS 7 avec une configuration minimale, dans laquelle nous avons par la suite ajouté :

-  EPEL release
-  Ansible (version 2.4.1.0)
-  Python (version 2.7.5)
-  Nano

**Attention**, la mise à jour d’Ansible peut fortement créer des soucis de compatibilités.

##  Format à respecter impérativement en cas de création d’un fichier YAML (.yml) :

 

·     Chaque fichier doit commencerpar  « **---** » (3 tirets normaux) hors role

·     L’indentation est très importante, utiliser uniquement des **ESPACES**.

·     Suivant l’OS, il est important de les différencier, car les commandes ne sont pas multiplateformes et entraine la nonfonctionnalité du script ansible.

 

## Principe des groupes d’utilisateurs/machines :

 

Il est à noter que le fichier se situant dans le fichier : 

```bash
/etc/ansible/hosts  
```

Se trouve les différents groupes de machines et utilisateurspour ansible.

​	1 utilisateur PEUT être dans PLUSIEURS groupes différents.

Si des problèmes de connexion en ssh arrivent , les commandes suivantes permettent de régler les problèmes

```bash
ssh-add
ssh-keygen -t rsa -C "ansible@ip_ansible"
ssh-copy id user@ipduclient
```

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

contenant toutes les informations de configuration de connexion, comme ansible_ssh_user, qui n’est autre que le nom d’utilisateur utilisé pour se connecter au groupe en question.



## Utilisation de playbooks :

Pour lancer un playbook dans Ansible il faut exécuter la commande suivante :

```bash
ansible-playbook chemin_du_fichier/Nom_du_fichier -e "nom_variable=valeur_var"
```

Valeurs importantes à mettre dans le fichier en question :

-  hosts : Qui indique  le groupe ou la machine qui exécutera nos futures taches/services
-  remote_user : nom d’utilisateur utilisé pour se exécuter les tâches en questions.
-  tasks : Indiquant le début de la liste des tâches qui vont être exécutées par la suite.

hosts a priorité sur remote_user donc si on indique un groupe , cela ne sert a rien d'avoir un remote_user

Exemple simple avec un ping :

```yaml
---
- hosts: Users
  remote_user: root

  tasks:
    - ping:
```



Dans le cadre d'un service, celui-ci doit être appelé grâce à la facon suivante :

```yaml
- service:
     name: Nom_du_service_à_exécuter
     state: Etat_futur_du_service (started, stopped, restarted, reloaded)
```



Enfin, il est possible de récupérer des variables mise avec l'option -e (voir plus haut) pour se faire le formattage du fichier se fait de la façon suivante :

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

