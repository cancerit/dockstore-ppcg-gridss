#! /bin/bash

sudo apt-get update

# set up java
sudo add-apt-repository -y ppa:webupd8team/java
sudo bash -c '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections'
sudo bash -c '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections'
sudo apt-get -yq update
sudo apt-get -yq install --no-install-recommends oracle-java8-installer

# install dependencies
sudo apt-get install -yq --no-install-recommends bwa r-base
