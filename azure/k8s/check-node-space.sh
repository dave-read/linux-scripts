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
# Example for getting space used on k8s nodes
#
# Note: assumes ssh key forwarding/agent is enabled
#
# Usage: 
#    1. Change the array of master nodes to contain the master node DNS names
#    2. Change the SSH_USER to the user that owns the k8s installation
#

# Array of master node external DNS names
MASTER_NODES=(dr-acs-k8s-uswest.westus.cloudapp.azure.com dr-acs-k8s-uswest.westus.cloudapp.azure.com)
# The linux OS user that owns the k8s installation
SSH_USER=azadmin

for master in "${MASTER_NODES[@]}"
do
   echo "-------"
   echo "master: ${master}"
   echo "-------"
   ssh -A -l ${SSH_USER} ${master} "kubectl get nodes -o name | sed 's/^nodes\///' | xargs -L 1 -I {} ssh {} 'hostname;df -h;echo;sudo du -hc -d 1 /var/lib/docker;echo;sudo du -hc -d1 /var/log;echo'"
   echo ""
done


