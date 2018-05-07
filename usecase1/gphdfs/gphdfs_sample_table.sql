GRANT INSERT ON PROTOCOL gphdfs TO gpadmin;
GRANT SELECT ON PROTOCOL gphdfs TO gpadmin;

CREATE EXTERNAL TABLE gphdfs_hdfs_textsimple(location text, month text, num_orders int, total_sales float8)
LOCATION ('gphdfs://quickstart.cloudera:8020/data/gphdfs_examples/gphdfs_hdfs_simple.txt')
   FORMAT 'TEXT' (DELIMITER ',');
