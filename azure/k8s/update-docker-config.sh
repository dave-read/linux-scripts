#!/usr/bin/env bash

FILE_TO_COPY="daemon.json"
FILE_TO_UPDATE="/etc/docker/$FILE_TO_UPDATE"
SSH_USER=azadmin

if [ -z "$1" ];then
  echo "usage $0 target-host"
  exit 1
fi

if [ ! -r "$FILE_TO_COPY" ]; then
   echo "file does not exist or can not be read"
   exit 1
fi

#backup the current file
echo "backing up $FILE_TO_UPDATE ..."
scp -l ${SSH_USER} ${1}:${FILE_TO_COPY} ${1}:${FILE_TO_COPY}.bak
if [ $? -ne 0 ];then
   echo "error backing up ${FILE_TO_UPDATE}
fi

echo "copying update ..."
#copy the new file
scp -l ${SSH_USER} ${FILE_TO_COPY} ${1:$FILE_TO_UPDATE 
if [ $? -ne 0 ];then
   echo "error copying the new file ${FILE_TO_UPDATE}
fi

echo "restarting kubelet ..."
# restart kublet
ssh -l $SSH_USER $1 "sudo service restart kubelet"

echo done"



