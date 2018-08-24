#!/bin/bash
#
#
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export GPDB_HOSTS=/tmp/gpdb-hosts
echo "export HADOOP_USER_NAME=gpadmin"
echo "export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin"

export CURRENT_DIR=`pwd`


################################################################################
# log date format, customize it to your wishes
# see man date for help
DATE='date +%Y/%m/%d:%H:%M:%S'
# log file
LOG=${CURRENT_DIR}/script.log

function echo_log {
    echo `$DATE`" $1" >> $LOG
}
# start
# echo_log "Script running"
# # do something
# echo_log "Doing this"
# # done
# echo_log "Script ended
