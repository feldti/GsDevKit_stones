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
cat << EOF | $GEMSTONE/bin/topaz -l -T 50000 -u prometheus_cis_app_data  2>&1 >> $GEMSTONE_LOGDIR/prometheus_app_data_${nowTS}.log

set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $PAS_STONE_NAME

display oops
iferror where

login

run

|   psqlConnection psqlConnectParameter |

"This thread is needed to handle the SigAbort exception, when the primary
thread is blocked. Assuming default 60 second STN_GEM_ABORT_TIMEOUT, wake
up at 30 second intervals."

[
  [ true ] whileTrue: [
	(Delay forSeconds: 30) wait ].

] forkAt: Processor lowestPriority.

"record gems pid in the pid file"

	  $PAS_APP_SERVICE_CLASS
      prometheusTask: '$PAS_PROMETHEUS_LOCAL_APPDATA_FILE'
      sampleInterval: $PAS_START_PROMETHEUS_APP_DELAY
      sampleSystemData: $PAS_START_PROMETHEUS_APP_COLLECT_SYSTEM_DATA
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
