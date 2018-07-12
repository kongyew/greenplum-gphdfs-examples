# How to access external files on Hadoop
This tutorial demonstrates how to read text files from Hadoop (HDFS). Later, you will using Greenplum to write text files back to Hadoop.

# Table of Contents
1. [Pre-requisites](#Pre-requisites)
2. [Access Greenplum instance](#Access-Greenplum-instance)
3. [Access Cloudera instance](#Access-Cloudera-instance)
4. [Create sample files in Cloudera](#Create-sample-files-in-Cloudera)
5. [Read file from HDFS into Greenplum](Read-file-from-HDFS into-Greenplum)
6. [Write file into HDFS](Write-file-into-HDFS)

## Pre-requisites:
- [Completed setup](README.MD)
- Docker instances for Cloudera and Greenplum are running

## Access Greenplum instance:
You can use this command `docker exec -it gpdbsne bin/bash` to access Greenplum docker instance.

### Access Cloudera instance:
You can use this command `docker exec -it quickstart.cloudera bin/bash` to access Cloudera docker instance.

```
$ docker exec -it quickstart.cloudera bin/bash
[root@quickstart /]#
```

## Create sample file in Hadoop (Cloudera)
Perform the following procedure to create a sample text file.
1. Create an HDFS directory for example data files. For example:
```
[root@quickstart cloudera]# $ hdfs dfs -mkdir -p /data/gphdfs_examples
```
2. Create a delimited plain text data file named `gphdfs_readtextsimple1.txt`:
```
[root@quickstart cloudera]# $ echo 'Prague,Jan,101,4875.33
Rome,Mar,87,1557.39
Bangalore,May,317,8936.99
Beijing,Jul,411,11600.67' > /tmp/gphdfs_readtextsimple1.txt
```
Note the use of the comma `,` to separate the four data fields.

3. Add the data file to HDFS by using `-put`
```
[root@quickstart /]# $ hdfs dfs -put /tmp/gphdfs_readtextsimple1.txt /data/gphdfs_examples/
```
4. Verify data file by displaying the contents of the gphdfs_readtextsimple1.txt file stored in HDFS.
```
[root@quickstart /]# hdfs dfs -cat /data/gphdfs_examples/gphdfs_readtextsimple1.txt
Prague,Jan,101,4875.33
  Rome,Mar,87,1557.39
  Bangalore,May,317,8936.99
  Beijing,Jul,411,11600.67
[root@quickstart /]#
```
## Read file from HDFS into Greenplum
This section demonstrates how to use GPHDFS protocol to read file on HDFS.
1. Make sure gphdfs is enabled on Greenplum
```
gphdfs_db=# GRANT INSERT ON PROTOCOL gphdfs TO gpadmin;
GRANT
gphdfs_db=# GRANT SELECT ON PROTOCOL gphdfs TO gpadmin;
GRANT
```
2. Create external table to access files on HDFS.
Note: the gphdfs protocol specifies the HDFS location, followed by the file path or directory.

External table that is associated to file in HADOOP:
```
CREATE EXTERNAL TABLE gphdfs_readtextsimple(location text, month text, num_orders int, total_sales float8)
LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/gphdfs_readtextsimple1.txt')
   FORMAT 'TEXT' (DELIMITER ',');
```

Drop existing external table if it already exists by using this command:
```
 DROP EXTERNAL TABLE IF EXISTS gphdfs_readtextsimple;
```

For example
```
gphdfs_db=# DROP EXTERNAL TABLE IF EXISTS gphdfs_readtextsimple;
DROP EXTERNAL TABLE
gphdfs_db=# CREATE EXTERNAL TABLE gphdfs_readtextsimple(location text, month text, num_orders int, total_sales float8)
gphdfs_db-# LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/gphdfs_readtextsimple1.txt')
gphdfs_db-#    FORMAT 'TEXT' (DELIMITER ',');
CREATE EXTERNAL TABLE
```
3. Read external data on Hadoop by using sql query
```
gphdfs_db=# select * from gphdfs_readtextsimple;
 location  | month | num_orders | total_sales
-----------+-------+------------+-------------
 Prague    | Jan   |        101 |     4875.33
 Rome      | Mar   |         87 |     1557.39
 Bangalore | May   |        317 |     8936.99
 Beijing   | Jul   |        411 |    11600.67
(4 rows)
```

4. You can read the external data into a new table in Greenplum

Using `SELECT INTO` command such as `select * into new_table from gphdfs_readtextsimple;`, in order to copy external table data into a new table in Greenplum.

Now, you have a copy of the data in the table `new_table`.

Example:
```
gphdfs_db=# select * into new_table from gphdfs_readtextsimple;
NOTICE:  Table doesn't have 'DISTRIBUTED BY' clause -- Using column(s) named 'location' as the Greenplum Database data distribution key for this table.
HINT:  The 'DISTRIBUTED BY' clause determines the distribution of data. Make sure column(s) chosen are the optimal data distribution key to minimize skew.
SELECT 4
gphdfs_db=# select * from new_table;
 location  | month | num_orders | total_sales
-----------+-------+------------+-------------
 Prague    | Jan   |        101 |     4875.33
 Beijing   | Jul   |        411 |    11600.67
 Rome      | Mar   |         87 |     1557.39
 Bangalore | May   |        317 |     8936.99
(4 rows)
```


## Write file into HDFS
This section demonstrates how to use GPHDFS protocol to write file into HDFS.

1. Create external table to access files on HDFS.
Note: the gphdfs protocol specifies the HDFS location, followed by the file path or directory.

External table that is associated to file in HADOOP:
```
CREATE WRITABLE EXTERNAL TABLE gphdfs_writetextsimple1( LIKE gphdfs_readtextsimple1 )
LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/write/')
FORMAT 'TEXT' (DELIMITER ',')  DISTRIBUTED BY (num_orders);
```

Drop existing external table if it already exists by using this command:
```
DROP EXTERNAL TABLE IF EXISTS gphdfs_writetextsimple1;
```

For example
```
gphdfs_db=# DROP EXTERNAL TABLE IF EXISTS gphdfs_writetextsimple1;
DROP EXTERNAL TABLE
gphdfs_db=# CREATE WRITABLE EXTERNAL TABLE gphdfs_writetextsimple1( LIKE gphdfs_readtextsimple1 )
gphdfs_db-# LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/write/')
gphdfs_db-# FORMAT 'TEXT' (DELIMITER ',')  DISTRIBUTED BY (num_orders);
CREATE EXTERNAL TABLE
```
2. Write data into Hadoop by using sql query

Use this query to write data
```
INSERT INTO gphdfs_writetextsimple1 SELECT md5(random()::text) AS location, generate_series(1,100000) AS month,
 generate_series(1,100000) AS num_orders,
 (random()*200000)::float8 AS total_sales;
```

For example:
```
gphdfs_db=# INSERT INTO gphdfs_writetextsimple1 SELECT md5(random()::text) AS location, generate_series(1,100000) AS month,
gphdfs_db-#  generate_series(1,100000) AS num_orders,
gphdfs_db-#  (random()*200000)::float8 AS total_sales;
INSERT 0 100000
```
3. Verify those files on Hdfs
You can create a readable external table to read data that is written in the previous command.

Command to read data under `/data/gphdfs_examples/write/`
```
CREATE EXTERNAL TABLE gphdfs_readtextsimple1(location text, month text, num_orders int, total_sales float8)
LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/write/')
      FORMAT 'TEXT' (DELIMITER ',');
```

For example,
```
gphdfs_db=# DROP EXTERNAL TABLE IF EXISTS gphdfs_readtextsimple1;
DROP EXTERNAL TABLE
gphdfs_db=# CREATE EXTERNAL TABLE gphdfs_readtextsimple1(location text, month text, num_orders int, total_sales float8)
gphdfs_db-# LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/write/')
gphdfs_db-#       FORMAT 'TEXT' (DELIMITER ',');
CREATE EXTERNAL TABLE
gphdfs_db=#
gphdfs_db=#
gphdfs_db=#
gphdfs_db=# select * from gphdfs_readtextsimple1
gphdfs_db-# ;
             location             | month  | num_orders |   total_sales
----------------------------------+--------+------------+------------------
 fd27bc8df830e3239a204b622ef71659 | 1      |          1 | 142149.346321821
 fd27bc8df830e3239a204b622ef71659 | 3      |          3 | 142149.346321821
 fd27bc8df830e3239a204b622ef71659 | 5      |          5 | 142149.346321821
 fd27bc8df830e3239a204b622ef71659 | 7      |          7 | 142149.346321821
 fd27bc8df830e3239a204b622ef71659 | 9      |          9 | 142149.346321821
 fd27bc8df830e3239a204b622ef71659 | 11     |         11 | 142149.346321821
...  |   |   |  
```
4. You can verify the data is written to HDFS by checking files under Hadoop
Make sure you are using Cloudera docker instance.

Use this command `docker exec -it quickstart.cloudera bin/bash` to access Cloudera docker instance.

The files are written into the Hadoop directory `/data/gphdfs_examples/write`

Example:
```
[root@quickstart cloudera]# hdfs dfs -ls  /data/gphdfs_examples/write
Found 4 items
-rw-r--r--   3 gpadmin supergroup    3088954 2018-07-11 14:50 /data/gphdfs_examples/write/0_1531320364-0000000014
-rw-r--r--   3 gpadmin supergroup    3088954 2018-07-11 17:11 /data/gphdfs_examples/write/0_1531320364-0000000039
-rw-r--r--   3 gpadmin supergroup    3088836 2018-07-11 14:50 /data/gphdfs_examples/write/1_1531320364-0000000014
-rw-r--r--   3 gpadmin supergroup    3088836 2018-07-11 17:11 /data/gphdfs_examples/write/1_1531320364-0000000039
[root@quickstart cloudera]#
```


# Quick References for HDFS:
## How to list files under Hdfs
Command : `hdfs dfs -ls <directory`

For example,
```
$ hdfs dfs -ls  /data/gphdfs_examples
Found 3 items
-rw-r--r--   1 root supergroup        100 2018-07-11 14:14 /data/gphdfs_examples/gphdfs_readtextsimple1.txt
drwxr-xr-x   - root supergroup          0 2018-07-11 14:50 /data/gphdfs_examples/write
drwxr-xr-x   - root supergroup          0 2018-07-11 14:14 /data/gphdfs_examples/write2
xamples/gphdfs_readtextsimple1.txtfs -cat   /data/gphdfs_examples//data/gphdfs_e
```

## How to create directory under Hdfs
Command : `hdfs dfs -mkdir -p <directory>`

For example,
```
[root@quickstart cloudera]# $ hdfs dfs -mkdir -p /data/gphdfs_examples
```

## Reference: Script to create database on GPDB
The section demonstrates how to use script to create database "gphdfs_db" and sample data. The script is located at `/code/usercase1/data`.

1. Using gpadmin user, run the command '/code/usecase1/data/setupDB.sh'

For example:
```
[gpadmin@gpdbsne gphdfs]$ /code/usecase1/data/setupDB.sh           
GRANT
GRANT
CREATE EXTERNAL TABLE
```

2. Verify database and table is created
Use 'psql -U gpadmin -d gphdfs_db -c "\dE"'

3. Verify database and table is created.
Use the command `su - gpadmin`, followed by `psql -U gpadmin -d gphdfs_db -c "select count(*) from gphdfs_readtextsimple;"`.

The result shows no records are yet created.

For example:
```
root@gpdbsne:/code/usecase1/data#su - gpadmin
$ psql -U gpadmin -d gphdfs_db -c "select count(*) from gphdfs_readtextsimple;"
 count
-------
     0
(1 row)
```
## Reference: Script to create data files on Hadoop (Cloudera)
This section describes how to uses script to create data files on  Cloudera.

### Setup example data on cloudera
1. You can use this command `docker exec -it quickstart.cloudera bin/bash` to access Cloudera docker instance.
For example:
```
$ docker exec -it quickstart.cloudera bin/bash
[root@quickstart /]#
```
2. This script `setupHdfsTextSimpleExample.sh` creates sample text file.
```
[root@quickstart cloudera]#/code/usecase1/cloudera/setupHdfsTextSimpleExample.sh
Using root to run this script.
Found hadoop /data directory
Recursively delete files under /data
Deleted /data
## gphdfs_hdfs_simple.txt is created under this directory /data/gphdfs_examples/
Found 1 items
-rw-r--r--   1 root supergroup        100 2018-05-07 22:29 /data/gphdfs_examples/gphdfs_hdfs_simple.txt
[root@quickstart cloudera]#
```
## Reference: How to use PSQL on GPDB
1. Make sure you are accessing GPDB docker instance.
```
$ docker exec -it gpdbsne bin/bash
[root@gpdbsne /]#
```
2. Use gpadmin user to access PSQL.
First, use `su - gpadmin` to use gpadmin, followed by using psql to access gphdfs_db database.

```
[root@gpdbsne /]# su - gpadmin
Last login: Wed Jul 11 16:09:13 UTC 2018 on pts/1
[gpadmin@gpdbsne ~]$ psql -U gpadmin -d gphdfs_db
psql (8.3.23)
Type "help" for help.

gphdfs_db=#
```

### Reference: Use psql on GPDB docker instance
````
$ psql -U gpadmin -d gphdfs_db -c "select * from gphdfs_readtextsimple;"
location   | month | num_orders | total_sales
-------------+-------+------------+-------------
Prague      | Jan   |        101 |     4875.33
 Rome      | Mar   |         87 |     1557.39
 Bangalore | May   |        317 |     8936.99
 Beijing   | Jul   |        411 |    11600.67
(4 rows)
```

4. Verify the number of records in this table "gphdfs_readtextsimple".

```
$ psql -U gpadmin -d gphdfs_db -c "select count(*) from gphdfs_readtextsimple;"
count
-------
    4
(1 row)
```
