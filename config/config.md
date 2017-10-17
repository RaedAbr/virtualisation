- IPs : 10.194.184.190 -> 10.194.184.199
- DNS : 129.194.8.7 and 129.194.8.6
- Gateway : 10.194.184.1
- Proxy HTTP : 129.194.185.57:3128
- Server on A406-11 (129.194.184.111). Virtal IP : 10.194.184.190, username: virtu
- Clients :
	- Client 1 on A406-10 (Steven) (129.194.184.110). Virtual IP : 10.194.184.191, username: client1, password: virtualisation
	- Client 2 on A406-10 (Steven) (129.194.184.110). Virtual IP : 10.194.184.192, username: client2, password: virtualisation
	- Client 3 on A406-09 (Raed) (129.194.184.109). Virtual IP : 10.194.184.193, username: client3, password: virtualisation
	- Client 4 on A406-09 (Raed) (129.194.184.109). Virtual IP : 10.194.184.194, username: client4, password: virtualisation

To configure network in clients, see in `centos/ifcfg-enp0s3_client1`. When deployed, copy (and rename) 
`ifcfg-enp0s3_client1` to `/etc/sysconfig/network-scripts/ifcfg-enp0s3`, after do `sudo service network restart`