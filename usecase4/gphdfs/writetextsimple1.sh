#!/bin/bash

set -e

current=`pwd`

cd `dirname $0`

. ./setEnv.sh
. ./config.sh

# Determine greenplum installation
if ([ -d "/usr/local/gpdb" ] || [ -d "/usr/local/greenplum-db" ] || [ -d "/opt/gpdb" ])
then
  echo_log "psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -d ${POSTGRES_DB} -f ./gphdfs_write_textsimple_table.sql"
  psql -h ${GREENPLUM_HOST} -U ${GREENPLUM_USER} -d ${POSTGRES_DB} -f ./gphdfs_writetextsimple1.sql
else
      echo "Error: Directory greenplum-db does not exists."
fi

cd $current
