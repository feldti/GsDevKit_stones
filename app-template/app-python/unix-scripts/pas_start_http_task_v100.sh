#!/bin/bash
#
#
# This script starts a http response task
#
#
usage() {
  cat <<HELP

USAGE: $(basename $0) <stone-name> <memory> <http-port> <name>
starts a http response task

1 <stone-name>   - Name der Datenbank
2 <memory>       - Temp memory of this GEM
3 <http-port>    - HTTP-Port
4 <name>         - Name of this script



EXAMPLES

  $(basename $0) webcati6 75000 19000 testme

HELP
}

#
# Sind genuegend Parameter mitgegeben ...
#
if [ $# -ne 4 ]; then
  usage; exit 1
fi

if [ ! -f ./credentials.sh ]; then
  echo 'Missing credentials.sh - copy demo_credentials.sh and make the needed changes to it'
  exit 4
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


while [ -f $1 ]
do

nowTS=`date +%Y-%m-%d-%H-%M`
echo $GEMSTONE_LOGDIR
cat << EOF | nohup $GEMSTONE/bin/topaz -l -T $2 -u ${4}_${3} 2>&1 >> $GEMSTONE_LOGDIR/${4}_server_${nowTS}.log

set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $PAS_STONE_NAME

display oops
iferror where

login

run

"record gems pid in the pid file"

| file |

(GsFile isServerDirectory: '$GEMSTONE_DATADIR') ifFalse: [ ^nil ].

file := GsFile openWriteOnServer: '$GEMSTONE_DATADIR/${4}.pid'.
file nextPutAll: (System gemVersionReport at: 'processId') printString.
file cr.
file close.

(ObjectLogEntry
  info: '${4}_server: startup'
  object: 'pid: ', (System gemVersionReport at: 'processId') printString) addToLog.
System commitTransaction
    ifFalse: [
      System abortTransaction.
      nil error: 'Could not commit ObjectLog entry' ].
%
run

| count server rabbitMQConnector psqlConnectParameter psqlConnection |

GsProcess usingNativeCode not
  ifTrue: [
    "Enable remote Breakpoing handling"
    Breakpoint trappable: true.
    GemToGemAnnouncement installStaticHandler.
    System commitTransaction ifFalse: [ nil error: 'Could not commit for GemToGemSignaling' ].
  ].

System transactionMode: #manualBegin.


"This thread is needed to handle the SigAbort exception, when the primary
thread is blocked. Assuming default 60 second STN_GEM_ABORT_TIMEOUT, wake
up at 30 second intervals."

[
  [ true ] whileTrue: [ 
	(Delay forSeconds: 30) wait ].

] forkAt: Processor lowestPriority.

IndexManager sessionAutoCommit: true.

"
This statement is needed to make sure, that https request can be done within Gemstone/S
"
System beginTransaction.
GsSecureSocket useCACertificateDirectoryForClients: '$PAS_APP_SSL_CERT_PATH'.
System commit.

GsFile gciLogServer: '$1 Server started on port ', $3 printString.

('PAS_APP_RMQ_USE_RMQ' = 'true')
  ifTrue:[ 
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
      GsFile gciLogServer: '$1 RabbitMQ Setup'.
  ].

( '$PAS_APP_PSQL_USE_DATABASE' = 'true' )
  ifTrue:[ 
    psqlConnectParameter := (GsPostgresConnectionParameters new)
                                host: '$PAS_APP_PSQL_ADR';
                                port: $PAS_APP_PSQL_PORT;
                                dbname: '$PAS_APP_PSQL_DBNAME' ;
                                connect_timeout: 10;
                                user: '$PAS_APP_PSQL_ACCOUNT' ;
                                password: '$PAS_APP_PSQL_PASSWD' ;
                                yourself .
    psqlConnection := GsPostgresConnection newWithParameters: psqlConnectParameter.
    [
      psqlConnection connect
    ]
    on: Exception
    do: [ :ex  |
            GsFile mskerror: 'Connection to PostgreSQL database not possible ',ex printString.
            ex return: nil 
    ]
  ].

server := MSKRestCallServerMQ newDefaultServer.
server
 startServer: true
 httpDebug: false
 localhost: true
 port: $3 printString asNumber
 serviceClass: $PAS_APP_SERVICE_CLASS
 mqConnector: rabbitMQConnector
 psqlConnector: psqlConnection.
%

run

GemToGemAnnouncement uninstallStaticHandler.

%

EOF
#
# Wenn die Datei nicht mehr vorhanden ist -> sofort Abbruch
# ansonsten 60 sekunden warten, damit nicht zu schnell respawned wird
#
if [ ! -f $1 ]; then
   exit 0
else
   sleep 60s
fi
done
