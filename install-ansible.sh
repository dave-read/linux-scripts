#!/usr/bin/env bash 

function get_distro_info() {
  OS_RELEASE=/etc/os-release
  SYSTEM_RELEASE=/etc/system-release-cpe
  DISTRO=""
  VERSION=""
  SRC=""

  exp='([0-9]+)'

  if [ -f $OS_RELEASE ]; then
    SRC=$OS_RELEASE
    DISTRO=$(grep "^ID=" $OS_RELEASE | tr -d ' \"' | cut -d '=' -f 2)
    VERSION=$(grep "^VERSION_ID=" $OS_RELEASE | tr -d '\"')
    #echo "DISTRO from $OS_RELEASE is:$DISTRO"
    #echo "VERSION_ID from $OS_RELEASE is:$VERSION"

    [[ "$VERSION" =~ $exp ]]
    MAJOR_VERSION="${BASH_REMATCH[1]}"
  elif [ -f $SYSTEM_RELEASE ]; then
    SRC=$SYSTEM_RELEASE
    LINE=$(grep "^cpe:" $SYSTEM_RELEASE)
    DISTRO=$(echo $LINE | cut -d ':' -f 3)
    VERSION=$(echo $LINE | cut -d ':' -f 5)
    [[ "$VERSION" =~ $exp ]]
    MAJOR_VERSION="${BASH_REMATCH[1]}"
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
set -x
if ! [ $(id -u) = 0 ]; then
   echo "Must be run as root"
   exit 1
fi

distro_info=$(get_distro_info)
if [ $? -ne 0 ]; then
  echo "error getting distro info"
  exit 1
fi
distro=$(echo $distro_info | cut -d ':' -f 1)
version=$(echo $distro_info | cut -d ':' -f 2)

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
  


