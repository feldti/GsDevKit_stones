#!/bin/bash
#
#
# This script starts the session activity handler
#
#
usage() {
  cat <<HELP

USAGE: $(basename $0)
starts the session activity handler

EXAMPLES

  $(basename $0)

HELP
}

if [ ! -f "./credentials.sh" ]; then
    echo "credentials.sh file not available"
    exit 4
fi
source ./credentials.sh
stoneName=$PAS_STONE_NAME
registryName=$PAS_STONE_REGISTRY
stonesDataHome=$STONES_DATA_HOME

# Extract the value of 'stone_dir' from the .ston file
stone_dir=$(pas_datadir.sh $stoneName $registryName $stonesDataHome)
# Check the return code of the script
if [[ $? -eq 0 ]]; then
    echo ""
else
    echo "The script failed with return code $?."
fi
# Check if stone_dir was found
if [[ -z "$stone_dir" ]]; then
    echo "Error: 'stone_dir' not found in $ston_file_path"
    exit 1
fi
source $stone_dir/customenv
if [ -s $GEMSTONE/seaside/etc/gemstone.secret ]; then
    . $GEMSTONE/seaside/etc/gemstone.secret
else
    echo 'Missing password file $GEMSTONE/seaside/etc/gemstone.secret'
    exit 1
fi
while [ -f $PAS_STONE_NAME ]
do

nowTS=`date +%Y-%m-%d-%H-%M`
cat << EOF | $GEMSTONE/bin/topaz -l -T 5000 -u pum_connector  2>&1 >> $GEMSTONE_LOGDIR/pum_connector_${nowTS}.log

set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $PAS_STONE_NAME

display oops
iferror where

login

run

|   rabbitMQConnector |

"This thread is needed to handle the SigAbort exception, when the primary
thread is blocked. Assuming default 60 second STN_GEM_ABORT_TIMEOUT, wake
up at 30 second intervals."

[
  [ true ] whileTrue: [
	(Delay forSeconds: 30) wait ].

] forkAt: Processor lowestPriority.


rabbitMQConnector := MSKRabbitMQConnector new initialize.
rabbitMQConnector
  hostname: '$PAS_APP_RMQ_ADR' ;
  port: $PAS_APP_RMQ_PORT ;
  userID: '$PAS_APP_RMQ_ACCOUNT' ;
  password: '$PAS_APP_RMQ_PASSWD' ;
  applicationID: '' ;
  caCertPath: '' ;
  certPath: '' ;
  privateKey: '' ;
  vhost: '$PAS_APP_RMQ_VHOST' ;
  login;
  openChannel.


PUMConnector
  taskPUMConnect: rabbitMQConnector fromQueueNamed: '$PUMCONNECTORQUEUE'
%
EOF
#
# Wenn die Datei nicht mehr vorhanden ist -> sofort Abbruch
# ansonsten 60 sekunden warten, damit nicht zu schnell respawned wird
#
if [ ! -f $PAS_STONE_NAME ]; then
   exit 0
else
   sleep 60s
fi
done
