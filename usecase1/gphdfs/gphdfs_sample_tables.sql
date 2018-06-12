-- CREATE EXTENSION gphdfs;
GRANT INSERT ON PROTOCOL gphdfs TO gpadmin;
GRANT SELECT ON PROTOCOL gphdfs TO gpadmin;

-- Example #1
DROP EXTERNAL TABLE IF EXISTS gphdfs_readtextsimple;
CREATE EXTERNAL TABLE gphdfs_readtextsimple(location text, month text, num_orders int, total_sales float8)
LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/gphdfs_readtextsimple1.txt')
   FORMAT 'TEXT' (DELIMITER ',');

DROP EXTERNAL TABLE IF EXISTS gphdfs_readtextsimple1;
CREATE EXTERNAL TABLE gphdfs_readtextsimple1(location text, month text, num_orders int, total_sales float8)
LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/write/')
      FORMAT 'TEXT' (DELIMITER ',');

DROP EXTERNAL TABLE IF EXISTS gphdfs_writetextsimple1;
CREATE WRITABLE EXTERNAL TABLE gphdfs_writetextsimple1( LIKE gphdfs_readtextsimple1 )
LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/write/')
FORMAT 'TEXT' (DELIMITER ',')  DISTRIBUTED BY (num_orders);


-- Example #2
DROP EXTERNAL TABLE IF EXISTS gphdfs_readtextsimple2;
CREATE EXTERNAL TABLE gphdfs_readtextsimple1(id int, description text)
LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/gphdfs_readtextsimple2.txt')
   FORMAT 'TEXT' (DELIMITER ',');

DROP EXTERNAL TABLE IF EXISTS gphdfs_writetextsimple2;
CREATE WRITABLE EXTERNAL TABLE gphdfs_writetextsimple2( LIKE gphdfs_readtextsimple2 )
LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/write2/')
FORMAT 'TEXT' (DELIMITER ',')  DISTRIBUTED BY (id);



-- Example #3
DROP EXTERNAL TABLE IF EXISTS gphdfs_readfoo;
CREATE EXTERNAL TABLE gphdfs_readfoo(i int, bar text)
LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/gphdfs_readfoo.txt')
FORMAT 'TEXT' (DELIMITER ',');

DROP EXTERNAL TABLE IF EXISTS gphdfs_writefoo;
CREATE WRITABLE EXTERNAL TABLE gphdfs_writefoo
(i int, bar text) LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/foo') FORMAT 'text' (delimiter '|' null 'null');


-- Example #4
DROP EXTERNAL TABLE IF EXISTS gphdfs_readjson;
CREATE EXTERNAL TABLE gphdfs_readjson(id text, json text)
LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/json/json.txt')
FORMAT 'TEXT' (DELIMITER ',');

DROP EXTERNAL TABLE IF EXISTS gphdfs_writejson;
CREATE WRITABLE EXTERNAL TABLE gphdfs_writejson
(id text, json text) LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/json/json.txt') FORMAT 'text' (delimiter '|' null 'null');
