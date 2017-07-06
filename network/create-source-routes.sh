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

# Create source routes for multi-home host with multiple nics on the same subnet
# Assumes incremental IP address range over the interfaces 
# This is only needed for interfaces after the primary (e.g. eth1, eth2, ...)

# For testing only.  Final deployment should use platform specific 
# network configuration files

# Pattern for each nic is:
# ip route add default via 10.0.0.1 dev eth1 table 1
# ip rule add iif eth1 table 1
# ip rule add from 10.0.1.3 table 1
# ip rule add from 10.0.1.4 table 1
#
# Get list of network interfaces
# ip link show | grep eth[0-9] | cut -d':' -f2
# ls /sys/class/net/
# 
# ip addr show dev eth1 | grep "secondary"
# ip addr show dev eth1 |  awk '/secondary/ {print $2 "," $8}'
# parse results 
#   array = ( `myBashFuntion param1 param2` )
#   or
#   read a b c <<<$(echo 1 2 3) ; echo "$a|$b|$c"


if ! [ $(id -u) = 0 ]; then
   echo "Must be run as root"
   exit 1
fi

DEFAULT_ROUTE=10.0.0.1
VM_IP_PREFIX=10.0.1
NICS_PER_VM=4
IP_PER_NIC=25

   for((nic=1; nic<NICS_PER_VM;++nic));do
        #routResult=$(ip route add defaullt via ${DEFAULT_ROUTE} dev eth${nic} table ${nic})
        routeAddCmd="ip route add default via ${DEFAULT_ROUTE} dev eth${nic} table ${nic}"
        echo $routeAddCmd
        #devResult=$(ip rule add iif eth${nic} table ${nic})
        devAddCmd="ip rule add iif eth${nic} table ${nic}"
        echo $devAddCmd
        for((ipcfg=0; ipcfg<IP_PER_NIC;++ipcfg));do
            ((node_ip= ((nic) * IP_PER_NIC) + ipcfg + 1))
            IP_ADDR=${VM_IP_PREFIX}.$node_ip
            ipAddCmd="ip rule add from ${IP_ADDR} table ${nic}"
            echo $ipAddCmd
        done
   done

#ip route flush cache
#ip rule show
