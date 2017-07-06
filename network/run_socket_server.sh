#!/usr/bin/env bash

IP_PREFIX=10.0.1
IP_COUNT=100

for((i=1;i<=${IP_COUNT};++i));do
  IP=${IP_PREFIX}.${i}
  echo "starting for IP $IP"
  python ./socket_server.py $IP 5000 &
done

echo "waiting ..."
wait
