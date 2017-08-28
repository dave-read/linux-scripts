#!/usr/bin/env bash

FILE_TO_COPY="daemon.json"
FILE_TO_UPDATE="/etc/docker/$FILE_TO_COPY"
TMP_FILE="/tmp/$FILE_TO_COPY"

SSH_USER=azadmin

if [ -z "$1" ];then
  echo "usage $0 target-host"
  exit 1
fi

if [ ! -r "$FILE_TO_COPY" ]; then
   echo "file does not exist or can not be read"
   exit 1
fi

# copy the new file to temp file on target
scp ${FILE_TO_COPY} ${SSH_USER}@${1}:${TMP_FILE}
if [ $? -ne 0 ];then
   echo "error copying the new file to $TMP_FILE"
   exit 1
fi

# back,copy, then restart kubelet
NOW=$(date -u "+%Y.%m.%d-%H.%M.%S")
ssh -l $SSH_USER $1 "sudo cp $FILE_TO_UPDATE $FILE_TO_UPDATE.${NOW}.bak; sudo cp $TMP_FILE $FILE_TO_UPDATE; sudo systemctl restart kubelet"

echo "done"



