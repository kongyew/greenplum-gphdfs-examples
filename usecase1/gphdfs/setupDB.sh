#!/bin/bash

set -e

current=`pwd`

cd `dirname $0`

. ./setEnv.sh

# Determine greenplum installation
if ([ -d "/usr/local/gpdb" ] || [ -d "/usr/local/greenplum-db" ] || [ -d "/opt/gpdb" ])
then
  createdb -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} ${POSTGRES_DB}
  psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -d ${POSTGRES_DB} -f ./gphdfs_sample_tables.sql
fi

cd $current
