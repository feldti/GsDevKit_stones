#!/bin/bash
#
# This script starts the stat monitor for a specific database
#
usage() {
  cat <<HELP

USAGE: $(basename $0)

EXAMPLES

  $(basename $0)

HELP
}

if [ ! -f "./credentials.sh" ]; then
  echo "credentials.sh file not available"
  exit 4
fi
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

nohup $GEMSTONE/bin/statmonitor $PAS_STONE_NAME -d "$GEMSTONE_LOGDIR" -i $ITVSTATMON


