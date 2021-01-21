# Install Galera Cluster Manager

Information: https://galeracluster.com/


## Architecture
<img src="architecture.png">

> Warning The IP addresses in  the example are for demonstration purposes only. Use the real values from your nodes and netmask in the iptables configuration for your cluster.


## Step by Step installation guide (platform independent)


## Preparation

The first steps are optional. 
1. [Disabling SELinux for mysqld](#optional-disabling-selinux-for-mysqld)
2. [Firewall Configuration](#optional-firewall-configuration)
3. [Disabling AppArmor](#optional-disabling-apparmor)

### (optional) Disabling SELinux for mysqld
If SELinux (Security-Enhanced Linux) is enabled on the servers, it may block `mysqld` from performing required operations. You must either disable SELinux for `mysqld` or configure it to allow `mysqld` to run external programs and open listen sockets on unprivileged ports—that is, operations that an unprivileged user may do.
To disable SELinux for `mysqld`, execute the following from the command-line: 
```
# semanage permissive -a mysqld_t
```
This command switches SELinux into permissive mode when it registers activity from the database server. While this is fine during the installation and configuration process, it is not in general a good policy to disable security applications.

Rather than disable SELinux, so that your may use it along with Galera Cluster, you will need to create an access policy. This will allow SELinux to understand and allow normal operations from the database server. For information on how to create such an access policy, see [SELinux](https://galeracluster.com/library/documentation/selinux.html).

### (optional) Firewall Configuration
Next, you will need to update the firewall settings on each node so that they may communicate with the cluster. How you do this varies depending upon your distribution and the particular firewall software that you use.

In general you can allow all traffic from systems/VPS's in your cluster:
```
ufw allow from 37.128.150.147
ufw allow from 37.128.150.252
ufw allow from 185.57.8.218
ufw allow from 185.57.8.198
ufw allow from 185.95.14.193
```

> Warning The IP addresses in  the example are for demonstration purposes only. Use the real values from your nodes and netmask in the iptables configuration for your cluster. 

### (optional) Disabling AppArmor
By default, some servers—for instance, Ubuntu—include AppArmor, which may prevent mysqld from opening additional ports or running scripts. You must disable AppArmor or configure it to allow mysqld to run external programs and open listen sockets on unprivileged ports.

To disable AppArmor, run the following commands:
````
$ sudo ln -s /etc/apparmor.d/usr.sbin.mysqld /etc/apparmor.d/disable/usr.sbin.mysqld
````
You will then need to tell AppArmor to reload profile:
````
$ sudo apparmor_parser -R /etc/apparmor.d/usr.sbin.mysqld
````
In some cases you may also need to restart AppArmor. If your system uses init scripts, run the following command:
````
$ sudo service apparmor restart
````
If instead, your system uses systemd, run the following command instead:
````
$ sudo systemctl restart apparmor
````

## Installing Galera Cluster