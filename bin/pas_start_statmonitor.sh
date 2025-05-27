#!/bin/bash
#
# This script starts the stat monitor for a specific database
#
usage() {
  cat <<HELP

USAGE: $(basename $0) <stonename> <registryname> <intervall-seconds>

EXAMPLES

  $(basename $0) gc election 30

HELP
}

#
# At least two parameters should be used
#
if [ $# -ne 3 ]; then
  usage; exit 1
fi

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

nohup $GEMSTONE/bin/statmonitor $PAS_STONE_NAME -d "$stone_dir/logs" -i $3


