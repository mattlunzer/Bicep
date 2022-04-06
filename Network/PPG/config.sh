#!/bin/bash

#Run updates
sudo apt-get -y update
sudo apt-get -y upgrade

#install net-tools
sudo apt-get install net-tools

#Ubuntu - Install Git and other helpful tools
sudo apt-get install build-essential -y
#    sudo apt-get install git -y -q
sudo apt-get install -y autotools-dev
sudo apt-get install -y automake
sudo apt-get install -y autoconf
sudo apt-get install -y libtool

#Bash - all distros

#From bash command line (assumes Git is installed)
git clone https://github.com/mellanox/sockperf
cd sockperf/
./autogen.sh
./configure --prefix=

#make is slower, may take several minutes
make

#make install is fast
sudo make install