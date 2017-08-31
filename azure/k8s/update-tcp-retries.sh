#!/usr/bin/env bash

# Copyright (c) Microsoft.  All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#--------------------------------------------------------------------------
# 
# This is a partial workaround to this upstream Kubernetes issue:
# https://github.com/kubernetes/kubernetes/issues/41916#issuecomment-312428731

TARGET_FILE=/etc/systemd/system/kubelet.service
ADD_AFTER_LINE='^ExecStartPre=\/bin\/mount.*$'
LINES_TO_ADD='ExecStartPre=/sbin/sysctl -w net.ipv4.tcp_retries2=8'

CHECK_CMD="grep -q \"$LINES_TO_ADD\" $TARGET_FILE"
SED_CMD="sed -E -i.bak '/$ADD_AFTER_LINE/a $LINES_TO_ADD' $TARGET_FILE"

if [ -z "$1" ];then
  echo "usage $0 target-host"
  exit 1
fi

echo "updating node:$1"

ssh $1 'sudo bash -s' << EOF
echo
hostname
echo -n "current retry configuration: "
sysctl net.ipv4.tcp_retries2
if $CHECK_CMD
then
  echo "$TARGET_FILE is already updated"
else
  echo "updating $TARGET_FILE"
  if $SED_CMD
  then
    echo "$TARGET_FILE update done"
    echo "reloading systemctl ..."
    systemctl daemon-reload
    echo "restarting kubelet ..."
    systemctl restart kubelet
    echo "kubelet restart done"
    echo -n "updated retry configuration: "
    sysctl net.ipv4.tcp_retries2
  else
    echo "error updating file: $TARGET_FILE"
  fi
fi
EOF

