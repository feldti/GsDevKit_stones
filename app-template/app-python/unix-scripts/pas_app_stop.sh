#!/bin/bash
#
# Script to stop the complete application. You will need to adapt this script
# to your project needs
#
usage() {
  cat <<HELP

USAGE: $(basename $0)
Stops the complete application

HELP
}

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

rm $PAS_STONE_NAME

#
# We stop the network access for development
#
stopNetldi.solo  $PAS_STONE_NAME --registry=$PAS_STONE_REGISTRY

#
# Now we stop all processes - qaccessable via names
pkill -f pas_start_http_task.sh
pkill -f task_start_prometheus_application.sh
pkill -f task_start_prometheus_support.sh
pkill -f $PAS_TPZ_SESS_ACTIVITY
pkill -f $PAS_TPZ_SRV_EV_BUS_MAINT
pkill -f task_start_superset.sh
pkill -f task_start_session_activity.sh
pkill -f task_start_server_event_bus.sh
pkill -f prometheus_cfg.json
pkill -f task_start_superset.sh
pkill -f $PAS_TPZ_SUPERSET_TOKEN
#
# And at the end we stop database
#
stopStone.solo $PAS_STONE_NAME --registry=$PAS_STONE_REGISTRY
