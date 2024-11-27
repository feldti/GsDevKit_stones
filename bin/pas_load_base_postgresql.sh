#!/bin/bash
#
# This application loads the PostgreSQL Connection package
#
usage() {
  cat <<HELP

USAGE: $(basename $0) <stoneName> <registryName> [stonesDataHome]
Loads the PostgreSQL package

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
if [ ! -d ~/GemConnect-for-Postgres ]; then
  mkdir ~/GemConnect-for-Postgres
  cd ~
  git clone https://github.com/feldti/GemConnect-for-Postgres.git
fi
if [ -d ~/GemConnect-for-Postgres ]; then
  cd ~/GemConnect-for-Postgres
  git pull
fi
cd $INSTALL_HOME

if [ -d ~/GemConnect-for-Postgres ]; then
  echo "Installation of GemConnect for PostgreSQL"
  cd ~/GemConnect-for-Postgres
  ./load_postgresql_v2.sh  $1 $2 $stonesDataHome
  cd $INSTALL_HOME
else
  echo "ERROR: No GemConnect for Postgres found !"
  exit 1
fi


cd $INSTALL_HOME

