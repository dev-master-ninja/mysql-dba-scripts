# MySQLd Modifications

File: /etc/mysql/mysql.conf.d/mysqld.cnf

## Master
```
[mysqld]
log-bin=mysql-bin 
server-id=1  

#bind-address=127.0.0.1  
```

## Slave
```
[mysqld]  
server-id=2  

#bind-address=127.0.0.1  
```

## Replication user
```
CREATE USER 'repl'@'%' IDENTIFIED BY 'password';  
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';  
```

## Status 
```
FLUSH TABLE WITH READ LOCK;  
SHOW MASTER STATUS;  
```

## Release lock
``` 
UNLOCK TABLES;
```

## Slave config
```
CHANGE MASTER TO   
  MASTER_HOST='master_server_ip', 
  MASTER_USER='repl',   
  MASTER_PASSWORD='password',  
  MASTER_LOG_FILE='mysql-bin.001',  
  MASTER_LOG_POS=123;  
```