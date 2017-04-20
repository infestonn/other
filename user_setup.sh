#!/bin/sh
#Initial PC setup

if [ `id -u` -ne 0 ]; then
        echo "Please run this script with "sudo" command"
        exit 0
fi

echo -n "Enter user name:"
read USERNAME

adduser ${USERNAME}
usermod -aG sudo ${USERNAME}

echo -n "Enter hostname:"
read HOSTN
echo ${HOSTN} > /etc/hostname

apt-get -y update
apt-get -y upgrade
apt-get -y dist-upgrade

su $USERNAME

#nvdocker
curl -sL https://get.docker.com | sh -
curl -sL http://jenkins.office.local/job/nvdocker-install/lastSuccessfulBuild/artifact/scripts/install.sh | bash -s
