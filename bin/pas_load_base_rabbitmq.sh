#!/bin/bash
#
#
# This application loads the RabbitMQ  package
#
#
usage() {
  cat <<HELP

USAGE: $(basename $0) <stoneName> <registryName> [stonesDataHome]
Loads the RabbitMQ package. The base package is load from github

HELP
}

#
# Sind genuegend Parameter mitgegeben ...
#
if [ $# -lt 2 ]; then
  usage; exit 1
fi

# Assign parameters
stoneName=$1
registryName=$2
stonesDataHome=${3:-$STONES_DATA_HOME}

export INSTALL_HOME=`pwd`
if [ ! -d ~/GemConnectForRabbitMQ ]; then
  mkdir ~/GemConnectForRabbitMQ
  cd ~
  git clone https://github.com/feldti/GemConnectForRabbitMQ.git
fi
if [ -d ~/GemConnectForRabbitMQ ]; then
  cd ~/GemConnectForRabbitMQ
  git pull
fi
cd $INSTALL_HOME

if [ -d ~/GemConnectForRabbitMQ ]; then
  echo "Installation of GemConnect for RabbitMQ"
  cd ~/GemConnectForRabbitMQ
  ./load_rabbitmq_v2.sh  $stoneName $registryName $stonesDataHome
  cd $INSTALL_HOME
else
  echo "ERROR: No GemConnect for RabbitMQ found !"
  exit 1
fi
cd $INSTALL_HOME


