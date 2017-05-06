#!/usr/bin/env bash

CFG_PATH=/opt/mesosphere/etc
CFG_FILE=${CFG_PATH}/mesos-slave-common
SVC_NAME=dcos-mesos-slave
KEY_NAME=MESOS_ATTRIBUTES
MESOS_AGENT_INFO=/var/lib/mesos/slave/meta/slaves/latest

log() {
  logger -s "${0}:${1}"
}

if [ $EUID -ne 0 ];then
  log "Error. Must be root.  Current user id $EUID"
  exit 1
fi

# get the fault domain for the current node
FD=$(curl http://169.254.169.254/metadata/v1/InstanceInfo -s -S | sed -e 's/.*"FD":"\([^"]*\)".*/\1/')
if [[ ! $FD =~ ^-?[0-9]+$ ]];then
   log "Error. Calling metadata service returned invalid value:$FD"
  exit 1
fi
log "Calling metadata service returned:$FD"

if [ ! -f "$CFG_FILE" ];then
  log "Configuration file does not exists. Creating:$CFG_FILE"
  if [[ ! -w "$CFG_PATH" ]];then
    log "Error. No write access to path:${CFG_PATH}"
    exit 1
  fi
  echo "${KEY_NAME}=AzureFD:FD${FD}" >> $CFG_FILE
else
  log "Configuration file does exist:$CFG_FILE"
  # see if there is already a MESOS_ATTRIBUTES property
  ATTR=$(grep "^${KEY_NAME}=" ${CFG_FILE})
  if [[ -z $ATTR ]];then
    log "Key:${KEY_NAME} does not exist. Adding to end of file."
    echo "${KEY_NAME}=AzureFD:FD${FD}" >> $CFG_FILE
  else
    log "Key:${KEY_NAME} already exists value is:${ATTR}"
    # update the file with FD appended
    sed -i.bak "/^${KEY_NAME}=/ s/$/;AzureFD:FD${FD}/" $CFG_FILE
  fi
fi

# Would have exited before here on any errors, so at this point the config file was either created or updated
# Changes to the config requre removing /var/lib/mesos/slave/meta/­slaves/latest and restart.
# See:http://stackoverflow.com/questions/42465131/how-to-change-the-dcos-attributes-without-restarting-slave
# systemctl is-active dcos-mesos-slave
rm -f $MESOS_AGENT_INFO
log "Restarting service $SVC_NAME"
rc=$(systemctl restart $SVC_NAME)
log "Finished Restarting service $SVC_NAME rc was:$rc"
