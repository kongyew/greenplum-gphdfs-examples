#!/bin/bash

set -e

current=`pwd`

cd `dirname $0`

. ./setEnv.sh

cd $current

echo "psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -d ${GREENPLUM_DB} -c \"DROP DATABASE IF EXISTS ${POSTGRES_DB}\" "

psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -d ${POSTGRES_DB} -c "DROP EXTERNAL TABLE IF EXISTS gphdfs_readtextsimple1"
psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -d ${POSTGRES_DB} -c "DROP EXTERNAL TABLE IF EXISTS gphdfs_writetextsimple1"

psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -d ${POSTGRES_DB} -c "DROP EXTERNAL TABLE IF EXISTS gphdfs_readtextsimple2"
psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -d ${POSTGRES_DB} -c "DROP EXTERNAL TABLE IF EXISTS gphdfs_writetextsimple2"

psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -d ${POSTGRES_DB} -c "DROP EXTERNAL TABLE IF EXISTS gphdfs_readfoo"
psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -d ${POSTGRES_DB} -c "DROP EXTERNAL TABLE IF EXISTS gphdfs_writefoo"


psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -d ${GREENPLUM_DB} -c "DROP DATABASE IF EXISTS ${POSTGRES_DB}"
