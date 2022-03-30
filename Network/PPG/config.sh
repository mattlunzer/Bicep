#!/bin/bash

#Run updates
sudo apt update
sudo apt upgrade -y

#install net-tools
sudo apt install net-tools

#Ubuntu - Install Git and other helpful tools
sudo apt install build-essential -y
#    sudo apt-get install git -y -q
sudo apt install -y autotools-dev
sudo apt install -y automake
sudo apt install -y autoconf
sudo apt install -y libtool

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

cd sockperf
sudo vi config.sh