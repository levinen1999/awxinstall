#!/bin/bash
cd /etc/yum.repos.d
YUM=/usr/bin/yum

#enable EPEL repo for dependencies
wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm
echo "Enabling EPEL repo ... "

#install dependencies
cd
echo "Installing dependencies for awx..."
$YUM -y -q install git gcc gcc-gcc++ lvm2 bzip2 gettext nodejs yum-utils device-mapper-persistent-data ansible python-pip postgresql policycoreutils policycoreutils-python selinux-policy selinux-policy-targeted libselinux-utils setroubleshoot-server setools pip container-selinux

#installs docker-ce and docker-py
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
echo "Installing Docker-ce and Docker-py..."
$YUM -y -q install docker-ce
pip -q install docker-py

#awx and logos clone into ~
git clone https://github.com/ansible/awx
git clone https://github.com/ansible/awx-logos

echo "starting docker.service ..."
#enable and start docker.server
systemctl enable docker
systemctl start docker

#change logos to official awx-logos
cd awx/installer
echo "editing inventory file ..."
sed -i 's/# awx_official=false/awx_official=true/g' inventory

#change default admin username and password
sed -i 's/# default_admin_user=admin/default_admin_user=gemini/g' inventory
sed -i 's/# default_admin_password=password/default_admin_password=observatory/g' inventory

#changes default project file and creates it
sed -i 's/#project_data_dir=/var/lib/awx/projects/project_data_dir=/awx/projects/g' inventory
mkdir ../projects

echo "Installing AWX... "
#starts ansible playbook to install awx
cd ~/awx/installer
ansible-playbook -i inventory install.yml

echo "Please wait a few minutes for migrations to finish ... "
