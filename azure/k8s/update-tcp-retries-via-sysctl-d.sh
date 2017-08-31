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

TARGET_FILE=/etc/sysctl.d/99-x-k8s-timeout-fix.conf
read -r -d '' FILE_TEXT << EOT
# This is a partial workaround to this upstream Kubernetes issue:
# https://github.com/kubernetes/kubernetes/issues/41916#issuecomment-312428731
net.ipv4.tcp_retries2=8
EOT


for node in $(kubectl get nodes -o name | sed -E 's/^nodes?\///'); do
   echo "updating node:$node ..."
   ssh $node "echo \"$FILE_TEXT\" | sudo tee $TARGET_FILE;sudo sysctl -p $TARGET_FILE;sysctl net.ipv4.tcp_retries2"
   echo "done"
done

