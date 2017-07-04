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

# Assign IP addresses to all but the first address on the primary NIC
# Assumes incremental IP address range over the interfaces 

# For testing only.  Final deployment should use platform specific 
# network configuration files

VM_IP_PREFIX=10.0.1
NICS_PER_VM=4
IP_PER_NIC=25
NET_MASK=255.255.0.0

   for((nic=0; nic<NICS_PER_VM;++nic));do
        for((ipcfg=0; ipcfg<IP_PER_NIC;++ipcfg));do
            if [ ${ipcfg} -eq 0 ];then
                ipcfg_name=eth${nic}
            else
                ((sub_int = ipcfg-1))
                ipcfg_name=eth${nic}:${sub_int}
            fi
            ((node_ip= ((nic) * IP_PER_NIC) + ipcfg + 1))
            IP_ADDR=${VM_IP_PREFIX}.$node_ip
            if [ ! $ipcfg_name = "eth0" ]; then
               $(ifconfig $ipcfg_name $IP_ADDR netmask $NET_MASK)
            fi
        done
   done
