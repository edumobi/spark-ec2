#!/bin/bash

/root/spark-ec2/copy-dir /root/alluxio

/root/alluxio/bin/alluxio format

sleep 1

/root/alluxio/bin/alluxio-start.sh all Mount
