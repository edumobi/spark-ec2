#!/bin/bash

pushd /root > /dev/null

if [ -d "ephemeral-hdfs" ]; then
  echo "Ephemeral HDFS seems to be installed. Exiting."
  return 0
fi

case "$HADOOP_MAJOR_VERSION" in
  1)
    wget http://s3.amazonaws.com/spark-related-packages/hadoop-1.0.4.tar.gz
    echo "Unpacking Hadoop"
    tar xvzf hadoop-1.0.4.tar.gz > /tmp/spark-ec2_hadoop.log
    rm hadoop-*.tar.gz
    mv hadoop-1.0.4/ ephemeral-hdfs/
    sed -i 's/-jvm server/-server/g' /root/ephemeral-hdfs/bin/hadoop
    cp /root/hadoop-native/* /root/ephemeral-hdfs/lib/native/
    ;;
  2) 
    wget http://s3.amazonaws.com/spark-related-packages/hadoop-2.0.0-cdh4.2.0.tar.gz  
    echo "Unpacking Hadoop"
    tar xvzf hadoop-*.tar.gz > /tmp/spark-ec2_hadoop.log
    rm hadoop-*.tar.gz
    mv hadoop-2.0.0-cdh4.2.0/ ephemeral-hdfs/

    # Have single conf dir
    rm -rf /root/ephemeral-hdfs/etc/hadoop/
    ln -s /root/ephemeral-hdfs/conf /root/ephemeral-hdfs/etc/hadoop
    cp /root/hadoop-native/* /root/ephemeral-hdfs/lib/native/
    ;;
  yarn)
    case "$SPARK_VERSION" in
      1.6.*)
        HADOOP_VERSION=2.6.3
        wget http://mirrors.ocf.berkeley.edu/apache/hadoop/common/hadoop-2.6.3/hadoop-2.6.3.tar.gz
        echo "Unpacking Hadoop"
        tar xvzf hadoop-*.tar.gz > /tmp/spark-ec2_hadoop.log
        rm hadoop-*.tar.gz
        mv hadoop-${HADOOP_VERSION}/ ephemeral-hdfs/
        wget http://central.maven.org/maven2/org/apache/hadoop/hadoop-aws/2.7.0/hadoop-aws-2.7.0.jar
        mv hadoop-aws-2.7.0.jar ephemeral-hdfs/share/hadoop/hdfs/lib/
        wget http://central.maven.org/maven2/com/amazonaws/aws-java-sdk/1.7.4/aws-java-sdk-1.7.4.jar
        mv aws-java-sdk-1.7.4.jar ephemeral-hdfs/share/hadoop/hdfs/lib/
	;;
      *)
        HADOOP_VERSION=2.4.0
	    wget http://s3.amazonaws.com/spark-related-packages/hadoop-${HADOOP_VERSION}.tar.gz
        echo "Unpacking Hadoop"
        tar xvzf hadoop-*.tar.gz > /tmp/spark-ec2_hadoop.log
        rm hadoop-*.tar.gz
        mv hadoop-${HADOOP_VERSION}/ ephemeral-hdfs/
	;;
    esac

    # Have single conf dir
    rm -rf /root/ephemeral-hdfs/etc/hadoop/
    ln -s /root/ephemeral-hdfs/conf /root/ephemeral-hdfs/etc/hadoop
    ;;

  *)
     echo "ERROR: Unknown Hadoop version"
     return 1
esac
/root/spark-ec2/copy-dir /root/ephemeral-hdfs

popd > /dev/null
