---  select count(*) from gphdfs_writetextsimple1;

INSERT INTO gphdfs_writetextsimple1 SELECT md5(random()::text) AS location, generate_series(1,100000) AS month,
 generate_series(1,100000) AS num_orders,
 (random()*200000)::float8 AS total_sales;
