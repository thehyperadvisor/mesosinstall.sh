# Mesos Installation

# configre repo
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF
DISTRO=$(lsb_release -is | tr '[:upper:]' '[:lower:]')
CODENAME=$(lsb_release -cs)
echo "deb http://repos.mesosphere.io/${DISTRO} ${CODENAME} main" | \
  sudo tee /etc/apt/sources.list.d/mesosphere.list
# update system packages
sudo apt-get -y update
# install mesos, marathon and zookeeper
sudo apt-get install mesosphere -y
sudo apt-get install mesos -y
sudo apt-get install apparmor
# get hostname
HOSTNAME=`cat /etc/hostname`
# get host ip
IP=`ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{print $1}'`
# setup mesos master and zookeeper
sudo sh -c "echo 'zk://${IP}:2181/mesos' > /etc/mesos/zk"
sudo sh -c "echo '1' > /etc/zookeeper/conf/myid"
sudo sh -c "echo 'server.1=${IP}:2888:3888' >> /etc/zookeeper/conf/zoo.cfg"
sudo sh -c "echo '1' > /etc/mesos-master/quorum"
sudo sh -c "echo ${IP} > /etc/mesos-master/hostname"
sudo sh -c "echo ${IP} > /etc/mesos-master/ip"
# cluster name
sudo sh -c "echo ${CLUSTERNAME} > /etc/mesos-master/cluster"
# logging level
sudo sh -c "echo 'WARNING' > /etc/mesos-master/logging_level"
# setup marathon
sudo mkdir -p /etc/marathon/conf
sudo cp /etc/mesos-master/hostname /etc/marathon/conf
sudo cp /etc/mesos/zk /etc/marathon/conf/master
sudo cp /etc/marathon/conf/master /etc/marathon/conf/zk
sudo sh -c "echo 'zk://${IP}:2181/marathon' > /etc/marathon/conf/zk"
# setup meos slave
sudo sh -c "echo '${IP}' > /etc/mesos-slave/ip"
sudo cp /etc/mesos-slave/ip /etc/mesos-slave/hostname
sudo start mesos-slave
# install docker
sudo apt-get install wget -y
wget -qO- https://get.docker.com/ | sh
# configure mesos containerizer
sudo sh -c "echo 'docker,mesos' > /etc/mesos-slave/containerizers"
sudo sh -c "echo '5mins' > /etc/mesos-slave/executor_registration_timeout"
# restart services
sudo service mesos-slave restart
sudo service mesos-master restart
sudo service marathon restart
sudo service zookeeper restart

