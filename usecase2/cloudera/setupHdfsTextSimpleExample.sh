#/bin/bash

# Usage: hadoop fs -test -[defsz] URI
#
# Options:
#
# -d: f the path is a directory, return 0.
# -e: if the path exists, return 0.
# -f: if the path is a file, return 0.
# -s: if the path is not empty, return 0.
# -z: if the file is zero length, return 0.
# Example:
#
# hadoop fs -test -e filename

# Debugging
#set -x

set -e
[[ ${DEBUG} == true ]] && set -x


ROOT_UID=0
export OUTPUTFILE=gphdfs_readtextsimple1.txt
export OUTPUTFILE2=gphdfs_readtextsimple2.txt

# Run as root, of course. (this might not be necessary, because we have to run the script somehow with root anyway)
if [ "$UID" -ne "$ROOT_UID" ]
then
  echo 'Prague,Jan,101,4875.33
  Rome,Mar,87,1557.39
  Bangalore,May,317,8936.99
  Beijing,Jul,411,11600.67' > /tmp/$OUTPUTFILE
  chown -R gpadmin:gpadmin /tmp/$OUTPUTFILE

  hdfs dfs -test -d /data
  if [ $? -eq 0 ]
  then
     echo "Found hadoop /data directory"
     echo "Recursively delete files under /data"
     hdfs dfs -rm -R /data
  fi

  sudo -u hdfs hadoop fs -mkdir -p /data
  sudo -u hdfs hadoop fs -mkdir -p /data/gphdfs_examples


  hdfs dfs -test -f /data/gphdfs_examples/$OUTPUTFILE
  if [ $? -eq 0 ]
  then
     echo "Found hadoop /data/gphdfs_examples/$OUTPUTFILE"
     echo "Recursively delete files under /data/gphdfs_examples/$OUTPUTFILE"
     hdfs dfs -rm  /data/gphdfs_examples/$OUTPUTFILE
  fi
  sudo -u hdfs hadoop fs -put /tmp/$OUTPUTFILE /data/gphdfs_examples/
  sudo -u hdfs hadoop fs -ls /data/gphdfs_examples/


else
  echo "Using root to run this script."
  echo 'Prague,Jan,101,4875.33
  Rome,Mar,87,1557.39
  Bangalore,May,317,8936.99
  Beijing,Jul,411,11600.67' > /tmp/$OUTPUTFILE

  # hdfs dfs -test -d /data
  # if [ $? -eq 0 ]
  # then
  #    echo "Found hadoop /data directory"
  #    echo "Recursively delete files under /data"
  #    hdfs dfs -rm -R /data
  #    hdfs dfs -mkdir -p /data
  # else
    hdfs dfs -mkdir -p /data/gphdfs_examples
    hdfs dfs -mkdir -p /data/gphdfs_examples/write
    hdfs dfs -mkdir -p /data/gphdfs_examples/write2
    hdfs dfs -put /tmp/$OUTPUTFILE /data/gphdfs_examples/
    echo "## $OUTPUTFILE is created under this directory /data/gphdfs_examples/"
    hdfs dfs -ls /data/gphdfs_examples/
  #
  # fi


fi
