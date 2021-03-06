#!/bin/bash
set -e
#set -x

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

DOWNLOAD_DIR="./HADOOP"
VERSION="2.7.6"  # RHEL, SLES, UBUNTU

if [ -d $DOWNLOAD_DIR ]; then
  echo "Using $DOWNLOAD_DIR"
else
  echo  "Cannot find $DOWNLOAD_DIR"
  exit 1
fi

################################################################################
function CreateHadoopDir()
{
  echo "CreateHadoopDir:  $1"
  hadoop_tar_gz="${1}"

  if [ -e "$hadoop_tar_gz" ]
  then
    tar -zxf $hadoop_tar_gz -C ${DOWNLOAD_DIR}
  else
    echo "$hadoop_tar_gz is not found."
  fi

  if [ "$(whoami)" == "gpadmin" ]; then
    if [ -d "/usr/local/hadoop" ]; then
        echo "Found /usr/local/hadoop"
    else
        sudo mkdir -p /usr/local/hadoop
    fi
    sudo mv ${DOWNLOAD_DIR}/hadoop-${VERSION} /usr/local/hadoop
    echo "ls -al /usr/local/hadoop"

  elif [ "$(whoami)" == "root" ]; then
    if [ -d "/usr/local/hadoop" ]; then
        echo "Found /usr/local/hadoop"
    else
        mkdir -p /usr/local/hadoop
    fi
    mv ${DOWNLOAD_DIR}/hadoop-${VERSION} /usr/local/hadoop
    echo "ls -al /usr/local/hadoop"
  else
    echo "Cannot run as this user: $(whoami)"
    exit -1
  fi


  # if [ -d "/usr/local/hadoop/hadoop-${VERSION}" ]; then
  #     echo "Using /usr/local/hadoop/hadoop-${VERSION}"
  # else
  #     echo "Error: Cannot find directory /usr/local/hadoop/hadoop-${VERSION}"
  # fi

}
function AddHadoopHome()
{
  echo "Hadoop HOME:  $1"
  HADOOP_HOME="${1}"

  if [ -d ${HADOOP_HOME} ]; then
    if [ -e "/home/gpadmin/.bash_profile" ]
    then
    echo  "export HADOOP_HOME=${HADOOP_HOME}" >> /home/gpadmin/.bash_profile
    else
      echo "${HADOOP_HOME} is not found."
    fi
  else
    echo "Error: Please specify the variable $HADOOP_HOME"
    exit 1
  fi

}

function ConfigureGPHDFS()
{
  echo "ConfigureGPHDFS:  $1"
  HADOOP_TARGET_VERSION="${1}"
  HADOOP_HOME="${2}"

  if [ "$(whoami)" == "gpadmin" ]; then
    gpconfig -c gp_hadoop_target_version -v  ${HADOOP_TARGET_VERSION}
    gpconfig -c gp_hadoop_home -v ${HADOOP_HOME}
    gpstop -u
    gpconfig -s gp_hadoop_target_version

  elif [ "$(whoami)" == "root" ]; then
    runuser -l gpadmin -c "gpconfig -c gp_hadoop_target_version -v  ${HADOOP_TARGET_VERSION}"
    runuser -l gpadmin -c "gpconfig -c gp_hadoop_home -v ${HADOOP_HOME}"
    runuser -l gpadmin -c "gpstop -u"
    runuser -l gpadmin -c "gpconfig -s gp_hadoop_target_version "
  else
    echo "Cannot run as this user: $(whoami)"
    exit -1
  fi
}



###############################################################################
# main
###############################################################################
if [ "$VERSION" == "" ]; then
  echo "Error: Please specify the variable $VERSION"
  exit 1
else
  HADOOP_FILE=${DOWNLOAD_DIR}/hadoop-${VERSION}.tar.gz
  CreateHadoopDir ${HADOOP_FILE}
  AddHadoopHome "/usr/local/hadoop/hadoop-${VERSION}"
  ConfigureGPHDFS "hdp2" "/usr/local/hadoop/hadoop-${VERSION}"


fi
