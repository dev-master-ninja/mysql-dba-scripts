# Partition Tables

Partitioning is the redistribution of data according to the content of the data. Partionining ensures that specific datasets stay in their range when queried so the number of rows queried is drastically reduced. 


<img src="./partioning.png">


On MySQL 5.x check if partitioning is enable by executing following SQL statement: 

````
SELECT
         PLUGIN_NAME as Name,
         PLUGIN_VERSION as Version,
         PLUGIN_STATUS as Status
     FROM INFORMATION_SCHEMA.PLUGINS
     WHERE PLUGIN_TYPE='STORAGE ENGINE'
````    

Or, on the server: 
`````
mysql> show plugins;
`````

The output of both commands should be something like this: 
````
mysql> SHOW PLUGINS;
+------------+----------+----------------+---------+---------+
| Name       | Status   | Type           | Library | License |
+------------+----------+----------------+---------+---------+
| binlog     | ACTIVE   | STORAGE ENGINE | NULL    | GPL     |
| partition  | ACTIVE   | STORAGE ENGINE | NULL    | GPL     |
| ARCHIVE    | ACTIVE   | STORAGE ENGINE | NULL    | GPL     |
| BLACKHOLE  | ACTIVE   | STORAGE ENGINE | NULL    | GPL     |
| CSV        | ACTIVE   | STORAGE ENGINE | NULL    | GPL     |
| FEDERATED  | DISABLED | STORAGE ENGINE | NULL    | GPL     |
| MEMORY     | ACTIVE   | STORAGE ENGINE | NULL    | GPL     |
| InnoDB     | ACTIVE   | STORAGE ENGINE | NULL    | GPL     |
| MRG_MYISAM | ACTIVE   | STORAGE ENGINE | NULL    | GPL     |
| MyISAM     | ACTIVE   | STORAGE ENGINE | NULL    | GPL     |
| ndbcluster | DISABLED | STORAGE ENGINE | NULL    | GPL     |
+------------+----------+----------------+---------+---------+
11 rows in set (0.00 sec)
````
If it's installed (and it usually is by default), it will list as `partition` and `ACTIVE`. 

In MySQL 8 these queries will produce a different output, because in MySQL 8 partitioning is implied in the `InnoDB` and `ndbcluster` storage engines.

## NOTE
> To prepare for migration to `MySQL 8.0`, any table with nonnative partitioning should be changed to use an engine that provides native partitioning, or be made nonpartitioned. For example, to change a table to `InnoDB`, execute this statement:
````
ALTER TABLE table_name ENGINE = INNODB;
````

## Partitioning Types

**NOTE**
>The primary key of partioned tables *in which form* should **ALWAYS** include the partion column!!

### RANGE partitioning
This type of partitioning assigns rows to partitions based on column values falling within a given range. 

Example: 
```
CREATE TABLE employees_range (
    id INT NOT NULL,
    fname VARCHAR(30),
    lname VARCHAR(30),
    hired DATE NOT NULL DEFAULT '1970-01-01',
    separated DATE NOT NULL DEFAULT '2021-12-31',
    job_code INT NOT NULL,
    store_id INT NOT NULL
)
PARTITION BY RANGE (store_id) (
    PARTITION p0 VALUES LESS THAN (6),
    PARTITION p1 VALUES LESS THAN (11),
    PARTITION p2 VALUES LESS THAN (16),
    PARTITION p3 VALUES LESS THAN (21)
);
```
This will produce an error when a value with `store_id = 21` is inserted.
Add a new partition: 
```
alter table employees_range ADD PARTITION (PARTITION p4 values LESS THAN MAXVALUE);
```


### LIST partitioning
Similar to partitioning by RANGE, except that the partition is selected based on columns matching one of a set of discrete values.  

Example: 
<table>
<thead>
<tr>
<th>Region</th><th>Store ID Numbers</th>
</tr>
</thead>
<tbody>
<tr><td>North</td><td>3, 5, 6, 9, 17</td></tr>
<tr><td>East</td><td>1, 2, 10, 11, 19, 20</td></tr>
<tr><td>West</td><td>4, 12, 13, 14, 18</td></tr>
<tr><td>South</td><td>7, 8, 15, 16</td></tr>
</tbody>
</table>

The table definition could be:  

```
CREATE TABLE employees_list (
    id INT NOT NULL,
    fname VARCHAR(30),
    lname VARCHAR(30),
    hired DATE NOT NULL DEFAULT '1970-01-01',
    separated DATE NOT NULL DEFAULT '2050-12-31',
    job_code INT,
    store_id INT   
)
PARTITION BY LIST(store_id) (
    PARTITION pNorth VALUES IN (3,5,6,9,17),
    PARTITION pEast VALUES IN (1,2,10,11,19,20),
    PARTITION pWest VALUES IN (4,12,13,14,18),
    PARTITION pCentral VALUES IN (7,8,15,16)
);
```

### HASH partitioning
With this type of partitioning, a partition is selected based on the value returned by a user-defined expression that operates on column values in rows to be inserted into the table. The function may consist of any expression valid in MySQL that yields a nonnegative integer value. 

Example: 
```
CREATE TABLE employees_hash (
    id INT NOT NULL,
    fname VARCHAR(30),
    lname VARCHAR(30),
    hired DATE NOT NULL DEFAULT '1970-01-01',
    separated DATE NOT NULL DEFAULT '9999-12-31',
    job_code INT,
    store_id INT
)
PARTITION BY HASH(store_id)
PARTITIONS 4;
```
or even: 
```
drop table employees_hash;

CREATE TABLE employees_hash (
    id INT NOT NULL,
    fname VARCHAR(30),
    lname VARCHAR(30),
    hired DATE NOT NULL DEFAULT '1970-01-01',
    separated DATE NOT NULL DEFAULT '9999-12-31',
    job_code INT,
    store_id INT
)
PARTITION BY HASH( YEAR(hired) )
PARTITIONS 3;
```

### KEY partitioning
This type of partitioning is similar to partitioning by HASH, except that only one or more columns to be evaluated are supplied, and the MySQL server provides its own hashing function. These columns can contain other than integer values, since the hashing function supplied by MySQL guarantees an integer result regardless of the column data type. 

Example: 
````
CREATE TABLE keypart1 (
    id INT NOT NULL PRIMARY KEY,
    name VARCHAR(20)
)
PARTITION BY KEY()
PARTITIONS 2;
````
If there is no primary key but there is a unique key, then the unique key is used for the partitioning key:
````
CREATE TABLE keypart2 (
    id INT NOT NULL,
    name VARCHAR(20),
    UNIQUE KEY (id)
)
PARTITION BY KEY()
PARTITIONS 2;
````

## Sub Partitions
You can further divide partitions into subpartitions: 
```
CREATE TABLE ts (
    id INT, 
    purchased DATE, 
    PRIMARY KEY (id, purchased))
    PARTITION BY RANGE( YEAR(purchased) )
    SUBPARTITION BY HASH( TO_DAYS(purchased) ) (
        PARTITION p0 VALUES LESS THAN (1990) (
            SUBPARTITION s0,
            SUBPARTITION s1
        ),
        PARTITION p1 VALUES LESS THAN (2000) (
            SUBPARTITION s2,
            SUBPARTITION s3
        ),
        PARTITION p2 VALUES LESS THAN MAXVALUE (
            SUBPARTITION s4,
            SUBPARTITION s5
        )
    );
```    
This is only feasible with extremely large tables.

## Adding tablespaces to partitions
Partitions can be `striped` over several tablespaces. Usually this is done to increase read/write throughput. If diskstorage is a RAID-5 SAN or NAS system, this can increase the query performance of very large tables.

Consider the RANGE partition in the first example, striped over 4 tablespaces: 

```
drop tablespace data0101;
drop tablespace data0102;
drop tablespace data0103;
drop tablespace data0104;
drop tablespace data0105;

create tablespace data0101 add datafile 'data0101.ibd';
create tablespace data0102 add datafile 'data0102.ibd';
create tablespace data0103 add datafile 'data0103.ibd';
create tablespace data0104 add datafile 'data0104.ibd';
create tablespace data0104 add datafile 'data0105.ibd';

CREATE TABLE employees_ts_range (
    id INT NOT NULL,
    fname VARCHAR(30),
    lname VARCHAR(30),
    hired DATE NOT NULL DEFAULT '1970-01-01',
    separated DATE NOT NULL DEFAULT '2021-12-31',
    job_code INT NOT NULL,
    store_id INT NOT NULL,
    primary key(id)
)
PARTITION BY RANGE (id) (
    PARTITION p0 VALUES LESS THAN (10000) tablespace data0101,
    PARTITION p1 VALUES LESS THAN (20000) tablespace data0102,
    PARTITION p2 VALUES LESS THAN (30000) tablespace data0103,
    PARTITION p3 VALUES LESS THAN (40000) tablespace data0104,
    PARTITION p3 VALUES LESS THAN (50000)tablespace data0104
);
```

## Find partitions
```
select * from information_schema.partitions  
where table_schema = '[DATABASE]'
```

