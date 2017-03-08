#!/usr/bin/env bash 

# use combination of release files to determine distro and major version
function get_distro_info() {

  OS_RELEASE=/etc/os-release
  SYSTEM_RELEASE=/etc/system-release-cpe
  DISTRO=""
  VERSION=""
  SRC=""
  exp='([0-9]+)'
  # use /etc/os-release if it exists
  if [ -f $OS_RELEASE ]; then
    SRC=$OS_RELEASE
    DISTRO=$(grep "^ID=" $OS_RELEASE | tr -d ' \"' | cut -d '=' -f 2)
    VERSION=$(grep "^VERSION_ID=" $OS_RELEASE | tr -d '\"')
    # get the major version number
    [[ "$VERSION" =~ $exp ]]
    MAJOR_VERSION="${BASH_REMATCH[1]}"
  # otherwise use /etc/system-release-cpe
  elif [ -f $SYSTEM_RELEASE ]; then
    SRC=$SYSTEM_RELEASE
    LINE=$(grep "^cpe:" $SYSTEM_RELEASE)
    DISTRO=$(echo $LINE | cut -d ':' -f 3)
    VERSION=$(echo $LINE | cut -d ':' -f 5)
    [[ "$VERSION" =~ $exp ]]
    MAJOR_VERSION="${BASH_REMATCH[1]}"
    # convert the names to those used in /etc/os-release
    if [ "$DISTRO" == "redhat" ]; then
      DISTRO="rhel"
    elif [ "$DISTRO" == "oracle" ]; then
      DISTRO="ol"
    fi
  else
    echo "No more sources for version info. Could not determine distro info"
    exit 1
  fi
  #echo the results
  echo "$DISTRO:$MAJOR_VERSION:$SRC"
}
# need to be root
if ! [ $(id -u) = 0 ]; then
   echo "Must be run as root"
   exit 1
fi
# will return delimited string with distro:version
distro_info=$(get_distro_info)
if [ $? -ne 0 ]; then
  echo "error getting distro info"
  exit 1
fi
# extract distro name and version
distro=$(echo $distro_info | cut -d ':' -f 1)
version=$(echo $distro_info | cut -d ':' -f 2)
# run the commands specific to the distro/version
if [ "$distro" == "ubuntu" ]; then
   apt-get -y install software-properties-common
   apt-add-repository -y ppa:ansible/ansible
   apt-get -y update
   apt-get -y install ansible
elif [ "$distro" == "ol" ] || [ "$distro" == "rhel" ] || [ "$distro" == "centos" ]; then
   RPM_URL=https://dl.fedoraproject.org/pub/epel/epel-release-latest-${version}.noarch.rpm
   echo "using URL:$RPM_URL"
   yum install -y $RPM_URL
   yum install -y ansible
else
   echo "no distro match for $distro"
   echo 1
fi
 
