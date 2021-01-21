# MySQL DBA Scripts

## DISCLAIMER
> The scripts in this repository come with **absolutely no warranty**. The scripts are purely designed and intended for **instructional purposes only**. 
> Any damage or loss of data when implementing these scripts is the **sole responsibility of the user of these scripts**.      

By cloning/downloading and using this repository you agree with above notice.


## XAMPP 
Download: https://www.apachefriends.org/index.html

## Repository
Repository with much used MySQL DBA scripts.   
Clone this repository on your server: 
```
git clone https://github.com/dev-master-ninja/mysql-dba-scripts.git
```
## SQL Scripts
- index/find_no_pk.sql
- index/non_indexed_cols.sql

- performance/long_running_v1.sql
- performance/long_running_v2.sql

- permission/user_permissions.sql

- storage/db_free.sql
- storage/db_index_usage.sql
- storage/db_size.sql
- storage/db_table_free.sql
- storage/db_table_size.sql

## Bash / Cron scripts
- cron/db_backup.sh script to run a full mysqldump
- cron/repl_backup.sh script to run a full slave mysqldump


## Granting root access to phpmyadmin on your basic installation
```
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'the-password';
```

## phpymadmin error
Edit /usr/share/phpmyadmin/libraries/sql.lib.php

search for: (function: "PMA_isRememberSortingOrder" line: 612)
```
(count($analyzed_sql_results['select_expr'] == 1)  
```
Replace it with   
```
((count($analyzed_sql_results['select_expr']) == 1)  
```
Save file and exit. 


## Completely remove MySQL on Ubuntu servers
Execute following commands (as root user, or with sudo if possible)
````
apt remove --purge mysql-server
apt purge mysql-server
apt autoremove
apt autoclean
apt remove dbconfig-mysql

apt install mysql-server
````

## Replication
see documentation [here](./replication/mysqld-modifications.md)

## Cluster
Installing a MySQL Cluster on Linux ([Ubuntu](./cluster/README-ubuntu.md) and [RedHat](./cluster/README-redhat.md)) documentation and setup guide [here](./cluster/README.md)
  
UPDATE: Added detailed installation instructions for [Galera Clustmanager](./cluster/README-galera.md)

## Upgrading to MySQL 8
How to upgrade to [MySQL 8](./mysql-8/README.md)