#!/usr/bin/env bash

# This file contains environment variables required to run Alluxio. Copy it as tachyon-env.sh and
# edit that to configure Alluxio for your site. At a minimum,
# the following variables should be set:
#
# - JAVA_HOME, to point to your JAVA installation
# - ALLUXIO_MASTER_ADDRESS, to bind the master to a different IP address or hostname
# - ALLUXIO_UNDERFS_ADDRESS, to set the under filesystem address.
# - ALLUXIO_WORKER_MEMORY_SIZE, to set how much memory to use (e.g. 1000mb, 2gb) per worker
# - ALLUXIO_RAM_FOLDER, to set where worker stores in memory data
#
# The following gives an example:

if [[ `uname -a` == Darwin* ]]; then
  # Assuming Mac OS X
  export JAVA_HOME=$(/usr/libexec/java_home)
  export ALLUXIO_RAM_FOLDER=/Volumes/ramdisk
  export ALLUXIO_JAVA_OPTS="-Djava.security.krb5.realm= -Djava.security.krb5.kdc="
else
  # Assuming Linux
  if [ -z "$JAVA_HOME" ]; then
    export JAVA_HOME=/usr/lib/jvm/java-1.7.0
  fi
  export ALLUXIO_RAM_FOLDER=/mnt/ramdisk
fi

export JAVA="$JAVA_HOME/bin/java"
export ALLUXIO_MASTER_ADDRESS={{active_master}}
export ALLUXIO_UNDERFS_ADDRESS=hdfs://{{active_master}}:9000
#export ALLUXIO_UNDERFS_ADDRESS=hdfs://localhost:9000
export ALLUXIO_WORKER_MEMORY_SIZE={{default_tachyon_mem}}
export ALLUXIO_UNDERFS_HDFS_IMPL=org.apache.hadoop.hdfs.DistributedFileSystem

CONF_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

export ALLUXIO_JAVA_OPTS+="
  -Dlog4j.configuration=file:$CONF_DIR/log4j.properties
  -Dalluxio.debug=false
  -Dalluxio.underfs.address=$ALLUXIO_UNDERFS_ADDRESS
  -Dalluxio.underfs.hdfs.impl=$ALLUXIO_UNDERFS_HDFS_IMPL
  -Dalluxio.data.folder=$ALLUXIO_UNDERFS_ADDRESS/alluxio/data
  -Dalluxio.workers.folder=$ALLUXIO_UNDERFS_ADDRESS/alluxio/workers
  -Dalluxio.worker.memory.size=$ALLUXIO_WORKER_MEMORY_SIZE
  -Dalluxio.worker.data.folder=$ALLUXIO_RAM_FOLDER/alluxioworker/
  -Dalluxio.master.worker.timeout.ms=60000
  -Dalluxio.master.hostname=$ALLUXIO_MASTER_ADDRESS
  -Dalluxio.master.journal.folder=$ALLUXIO_HOME/journal/
  -Dalluxio.master.pinlist=/pinfiles;/pindata
"

# Master specific parameters. Default to ALLUXIO_JAVA_OPTS.
export ALLUXIO_MASTER_JAVA_OPTS="$ALLUXIO_JAVA_OPTS"

# Worker specific parameters that will be shared to all workers. Default to ALLUXIO_JAVA_OPTS.
export ALLUXIO_WORKER_JAVA_OPTS="$ALLUXIO_JAVA_OPTS"
