#!/bin/bash
#
#
usage() {
  cat <<HELP

USAGE: $(basename $0)
starts the sending of the topic messages to rabbitmq

EXAMPLES

  $(basename $0)

HELP
}

if [ ! -f ./credentials.sh ]; then
  echo 'Missing credentials.sh - copy demo_credentials.sh and make the needed changes to it'
  exit 1
fi

#
# load all the needed information
#
source ./credentials.sh

# Extract the value of 'stone_dir' from the .ston file
stone_dir=$(pas_datadir.sh $PAS_STONE_NAME $PAS_STONE_REGISTRY $STONES_DATA_HOME)

# Check the return code of the script
if [[ $? -eq 0 ]]; then
    echo "The script executed successfully."
else
    echo "The script failed with return code $?."
    exit 3
fi
# Check if stone_dir was found
if [[ -z "$stone_dir" ]]; then
    echo "Error: 'stone_dir' not found in $ston_file_path"
    exit 2
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
cat << EOF | $GEMSTONE/bin/topaz -l -T 200000 -u $PAS_TPZ_TOPIC_MSG  2>&1 >> ${GEMSTONE_LOGDIR}/${PAS_TPZ_TOPIC_MSG}_${nowTS}.log

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

"record gems pid in the pid file"

System beginTransaction.
$SERVICECLASSNAME dataRootInstance
  setMqttServerAddress: '$PAS_APP_RMQ_ADR' ;
  setMqttLogin: '$PAS_APP_RMQ_MQTT_ACCOUNT' ;
  setMqttPassword: '$PAS_APP_RMQ_MQTT_PASSWD'.
System commitTransaction.



('$PAS_APP_TLS' = 'true')
  ifTrue:[
    rabbitMQConnector := MSKRabbitMQConnector new initialize.
    rabbitMQConnector
      hostname: '$PAS_APP_RMQ_ADR' ;
      port: $PAS_APP_RMQ_PORT ;
      userID: '$PAS_APP_RMQ_ACCOUNT' ;
      password: '$PAS_APP_RMQ_PASSWD' ;
      applicationID: '$PAS_APP_SERVERTYPE' ;
      caCertPath: '$PAS_APP_RMQ_CACERT_PATH' ;
      certPath: '$PAS_APP_RMQ_CERT_PATH' ;
      privateKey: '$PAS_APP_RMQ_PRVKE' ;
      login;
      openChannel.
  ]
  ifFalse:[
    rabbitMQConnector := MSKRabbitMQConnector new initialize.
    rabbitMQConnector
      hostname: '$PAS_APP_RMQ_ADR' ;
      port: $PAS_APP_RMQ_PORT ;
      userID: '$PAS_APP_RMQ_ACCOUNT' ;
      password: '$PAS_APP_RMQ_PASSWD' ;
      applicationID: '$PAS_APP_SERVERTYPE' ;
      login;
      openChannel.
	].

$SERVICECLASSNAME
  taskStartHandleTopicMessages: rabbitMQConnector.
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
