#!/bin/bash

pushd /root > /dev/null

if [ -d "alluxio" ]; then
  echo "alluxio seems to be installed. Exiting."
  return 0
fi

# Github tag:
if [[ "$TACHYON_VERSION" == *\|* ]]
then
  # Not yet supported
  echo "alluxio git hashes are not yet supported. Please specify a alluxio release version."
# Pre-package alluxio version
else
  case "$TACHYON_VERSION" in
    1.*)
      if [[ "$HADOOP_MAJOR_VERSION" == "1" ]]; then
        wget http://alluxio.org/downloads/files/$TACHYON_VERSION/alluxio-$TACHYON_VERSION-bin.tar.gz
      elif [[ "$HADOOP_MAJOR_VERSION" == "2" ]]; then
        wget http://alluxio.org/downloads/files/$TACHYON_VERSION/alluxio-$TACHYON_VERSION-cdh4-bin.tar.gz
      else
        case "$SPARK_VERSION" in
              1.6.*)
                wget http://alluxio.org/downloads/files/$TACHYON_VERSION/alluxio-$TACHYON_VERSION-hadoop2.6-bin.tar.gz
                ;;
              *)
                wget http://alluxio.org/downloads/files/$TACHYON_VERSION/alluxio-$TACHYON_VERSION-hadoop2.4-bin.tar.gz
                ;;
        esac
      fi
      if [ $? != 0 ]; then
        echo "ERROR: Unknown alluxio version"
        return -1
      fi
      ;;
   *) 
        echo "ERROR: alluxio version should start with 1.0"
        return -1

  esac

  echo "Unpacking alluxio"
  tar xvzf alluxio-*.tar.gz > /tmp/spark-ec2_alluxio.log
  rm alluxio-*.tar.gz
  mv `ls -d alluxio-*` alluxio
fi

popd > /dev/null
