# Tablespaces

Create a tablespace: 
```
create tablespace tablespace_name
       add datafile 'file_name'
       [initial_size [=] size]
       ENGINE [=] engine
```       

Example: 
```
create tablespace data01 
     add datafile 'data0101.ibd'
     initial_size 100M 
     engine innoDB;
```     

**Important #1**
> The extension of the datafile *MUST* be `.ibd` otherwise InnoDB will discard the file. 

**Important #2**
> Although stated otherwise in the official documentation, in MySQL 5.x the location of the datafiles will always be in the *`data_dir`* location, by default: `/var/lib/mysql`

**Important #3**
> `InnoDB` supports only one datafile, `NDB` however supports more datafiles per tablespace. 

## Query tablespace information
Issue this query to retreive tablespace information: 
```
SELECT FILE_ID, FILE_NAME, FILE_TYPE,             
       TABLESPACE_NAME, FREE_EXTENTS,
       TOTAL_EXTENTS, EXTENT_SIZE, INITIAL_SIZE, MAXIMUM_SIZE, AUTOEXTEND_SIZE, DATA_FREE
  FROM INFORMATION_SCHEMA.FILES
```       

## Adding a tablespace to a table
When creating a table, a tablespace can be added, for example: 
```
CREATE TABLE t1 ( 
    id INT NOT NULL AUTO_INCREMENT , 
    code VARCHAR(50) NOT NULL , 
    PRIMARY KEY (`id`)
) TABLESPACE data01 ENGINE = InnoDB
```

Or moved when it already exists: 
```
CREATE TABLE t2 ( 
    id INT NOT NULL AUTO_INCREMENT , 
    code VARCHAR(50) NOT NULL , 
    PRIMARY KEY (`id`)
) ENGINE = InnoDB;

ALTER TABLE t2 TABLESPACE data01;
```

**NOTE**
> You cannot specifiy a separate tablespace for indices (like Oracle).