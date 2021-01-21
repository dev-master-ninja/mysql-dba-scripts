# Install MySQL Cluster on RedHat


> **Note:** Login as `root` on the specified systems. 
> **This installation instruction is not verified** as there is no RedHat VPS available on my VPS service provider cloud.
> However, the functional installation is mostly the same as on the [Ubuntu](./README-ubuntu.md) environment.
  
## Architecture
<img src="architecture.png">

> Warning The IP addresses in the example are for demonstration purposes only. Use the real values from your nodes and netmask in the iptables configuration for your cluster.


## 1 — Installing the infrastructure
We’ll first begin by downloading and installing the MySQL Cluster Manager, `ndb_mgmd`
To install the Cluster Manager, we first need to fetch the appropriate .deb installer file from the the official [MySQL Cluster download page](http://dev.mysql.com/downloads/cluster/).

> Unfortunately No direct link is available, please install fetch the correct RPM file from the download page!!
> RPM: `mysql57-community-release-el7-10.noarch.rpm`

copy this file over to all server nodes in your cluster and execute (as `root`, or with `sudo`): 

````
shell> rpm -ivh mysql57-community-release-el7-10.noarch.rpm
````
This will install the required infrastructure and tell yum where to find it's additional packages. 

> Now by default this activates packages from MySQL 5.7. It does however also have packages available for MySQL 5.5, 5.6, 8.0 and also MySQL Cluster 7.5. In order to use the correct version it is necessary to edit the file:
````
vi /etc/yum.repos.d/mysql-community.repo
````
> There is a section in this file for MySQL 5.7 called `mysql57-community`, this section contains a variable called enabled that one should change from 1 to 0. Similarly the section `mysql-cluster-7.5-community` has a variable enabled that one should change from 0 to 1.


## 2 - Configuring the Cluster Manager
Installing in the VM for the NDB management server is now easy. The command is:
````
yum install mysql-cluster-community-management-server
````

We now need to configure ```ndb_mgmd``` before first running it; proper configuration will ensure correct synchronization and load distribution among the data nodes.

The Cluster Manager should be the first component launched in any MySQL cluster. It requires a configuration file, passed in as an argument to its executable. We’ll create and use the following configuration file: ```/var/lib/mysql-cluster/config.ini```.

On the Cluster Manager Server, create the ```/var/lib/mysql-cluster``` directory where this file will reside:
````
mkdir /var/lib/mysql-cluster
````

Then create and edit the configuration file using your preferred text editor:
```
vi /var/lib/mysql-cluster/config.ini
```
Paste the following text into your editor (change the IP addresses to your specific environment).
```
[ndbd default]
# Options affecting ndbd processes on all data nodes:
NoOfReplicas=2  # Number of Data Nodes

[ndb_mgmd]
# Server D Manager
hostname=185.57.8.218 
datadir=/var/lib/mysql-cluster  

[ndbd]
# Server E - Data Node 1 NodeId: 2
hostname=185.57.8.198 
NodeId=2            
datadir=/usr/local/mysql/data   

[ndbd]
# Server F - Data Node 2, NodeId: 3
hostname=185.95.14.193 
NodeId=3            
datadir=/usr/local/mysql/data  

[mysqld]
# Server B: SQL node 1:
hostname=37.128.150.147

[mysqld]
# Server C: SQL node 2:
hostname=37.128.150.252
```
After pasting in this text, being sure to replace the hostname values above with the correct IP addresses of the servers you’ve configured. Setting this hostname parameter is an important security measure that prevents other servers from connecting to the Cluster Manager.

Save the file and close your text editor.

This is a pared-down, minimal configuration file for a MySQL Cluster. You should customize the parameters in this file depending on your production needs. For a sample, fully configured ndb_mgmd configuration file, consult the [MySQL Cluster documentation](https://dev.mysql.com/doc/mysql-cluster-excerpt/5.7/en/mysql-cluster-config-starting.html).

In the above file you can add additional components like data nodes (ndbd) or MySQL server nodes (mysqld) by appending instances to the appropriate section.

We can now start the manager by executing the ndb_mgmd binary and specifying its config file using the ```-f``` flag:

```
ndb_mgmd -f /var/lib/mysql-cluster/config.ini
```

You should see the following output:
```
2021-12-29 11:58:04 [MgmtSrvr] INFO     -- The default config directory '/usr/mysql-cluster' does not exist. Trying to create it...
2021-12-29 11:58:04 [MgmtSrvr] INFO     -- Sucessfully created config directory
```
This indicates that the MySQL Cluster Management server has successfully been installed and is now running on your server.

## 3 — Installing and Configuring the Data Nodes

> **Note:** All the commands in this section should be executed on both data nodes.

In this step, we’ll install the ndbd MySQL Cluster data node daemon, and configure the nodes so they can communicate with the Cluster Manager.

To install the data node binaries we first need to fetch the appropriate .deb installer file from the [official MySQL download page](http://dev.mysql.com/downloads/cluster/).

Installing in the VMs for the NDB data nodes is also very easy. The command is:
````
yum install mysql-cluster-community-data-node
````

The data nodes pull their configuration from MySQL’s standard location, `/etc/my.cnf`. Create this file using your favorite text editor and begin editing it:
```
vi /etc/my.cnf
```

Add the following configuration parameter to the file:
```
[mysql_cluster]
# Options for NDB Cluster processes:
ndb-connectstring=185.57.8.218  # location of cluster manager
```

Specifying the location of the Cluster Manager node is the only configuration needed for `ndbd` to start. The rest of the configuration will be pulled from the manager directly.

Save and exit the file.

In our example, the data node will find out that its data directory is `/usr/local/mysql/data`, per the manager’s configuration. Before starting the daemon, we’ll create this directory on the node:
```
mkdir -p /usr/local/mysql/data
```

Now we can start the data node using the following command:
```
ndbd

#Output: 
2021-12-29 11:36:54 [ndbd] INFO     -- Angel connected to '185.57.8.218:1186'
2021-12-29 11:36:54 [ndbd] INFO     -- Angel allocated nodeid: 2
```
The NDB data node daemon has been successfully installed and is now running on your server.

We also need to allow incoming connections from other MySQL Cluster nodes over the private network.

If you did not configure the `ufw` firewall when setting up this server, you can skip ahead to setting up the systemd service for `ndbd`.

We’ll add rules to allow incoming connections from the Cluster Manager and other data nodes:
```
ufw allow from 37.128.150.147
ufw allow from 37.128.150.252
ufw allow from 185.57.8.218
ufw allow from 185.57.8.198
ufw allow from 185.95.14.193
```

After entering these commands, you should see the following output:
```
Rule added

or

Rules updated
```

Your MySQL data node can now communicate with both the Cluster Manager and other data nodes over the network. Finally, we’d also like the data node daemon to start up automatically when the server boots. We’ll follow the same procedure used for the Cluster Manager, and create a systemd service.


## 4 — Configuring and Starting the MySQL Server and Client

Installing the MySQL Server version is a bit more involved since the MySQL Cluster server package depends on some Perl parts not part of a standard Red Hat installation.

So on the VM used for MySQL Server we first need to install support for installing EPEL packages (Extra Packages for Enterprise Linux). This is performed through the command:
````
rpm -ivh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-9.noarch.rpm
````

After installing this it is straightforward to also install the MySQL Server package. This package will also download the MySQL client package that also contains the NDB management client package.
The command is:
```
yum install mysql-cluster-community-server
```
## 5 — Inserting Data into MySQL Cluster
To demonstrate the cluster’s functionality, let’s create a new table using the `NDB engine` and insert some sample data into it. 
> **Note that in order to use cluster functionality, the engine must be specified explicitly as NDB. If you use InnoDB (default) or any other engine, you will not make use of the cluster.**


First, let’s create a database called clustertest with the command:
```
CREATE DATABASE clustertest;
```

Next, switch to the new database:
```
USE clustertest;
``` 

Now, create a simple table called test_table like this:
```
CREATE TABLE test_table (name VARCHAR(20), value VARCHAR(20)) ENGINE=ndbcluster;
``` 

We have explicitly specified the engine `ndbcluster` in order to make use of the cluster.
Now, we can start inserting data using this SQL query:
```
INSERT INTO test_table (name,value) VALUES('some_name','some_value');
``` 
To verify that the data has been inserted, run the following select query:
```
SELECT * FROM test_table;
``` 

When you insert data into and select data from an `ndbcluster` table, the cluster load balances queries between all the available data nodes. This improves the stability and performance of your MySQL database installation.

Login to the second SQL Node and execute following commands: 
```
mysql -u root -p<password>

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| clustertest        |
| mysql              |
| ndbinfo            |
| performance_schema |
| sys                |
+--------------------+

use clustertest;
select * from test_table;
+-----------+------------+
| name      | value      |
+-----------+------------+
| some_name | some_value |
+-----------+------------+
1 row in set (0.00 sec)
```

You can also set the default storage engine to ndbcluster in the my.cnf file that we edited previously. If you do this, you won’t need to specify the ENGINE option when creating tables. To learn more, consult the [MySQL Reference Manual](https://dev.mysql.com/doc/refman/5.7/en/storage-engine-setting.html).