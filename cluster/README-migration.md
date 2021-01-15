# Migrating a database to the cluster

The best approach is to start with a completely fresh cluster ([Ubuntu](./README-ubuntu.md) or [RedHat](.README-redhat.md))

## 1 - make a full dump of the database
Create a full dump of the schema you wish to migrate: 
```
mysqldump -u [user]  -p[password] [database] > data.sql
```

The big plus of using `mysqldump` is, first it list the `CREATE TABLE` and the `PRIMAY KEY` for that table, then it inserts the data and at the very end of the script it adds the `FOREIGN KEY` contraints. 
The NBD cluster engine has some trouble with converting the PK/FK relation directly inline.

## 2 - Change the storage engine
Now you can edit the file and set the `ENGINE`-parameter for each table, or you can utilize the `sed` command to do it all at once (in this example the ENGINE is **InnoDB** but it could be some other as well):
```
sed  's/ENGINE=InnoDB/ENGINE=nbdcluster/g'  data.sql > migration.sql
```

## 3 - Import into the cluster
The final step is to import the data into the cluster schema: 
````
mysql -u [user] -p[password] < migration.sql
````
You should be good to go now!