#! /bin/bash

apt-get update
#
# # set up java
# add-apt-repository -y ppa:webupd8team/java
# bash -c '/bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections'
# bash -c '/bin/echo debconf shared/accepted-oracle-license-v1-1 seen true | /usr/bin/debconf-set-selections'
# apt-get -yq update
# apt-get -yq install --no-install-recommends oracle-java8-installer
apt install -y openjdk-8-jre-headless

# install other dependencies
apt-get install -yq bwa r-base
