#!/bin/bash
#
# This script starts the stat monitor for a specific database
#
usage() {
  cat <<HELP

USAGE: $(basename $0) <stonename> <registryname> <intervall-seconds> <duration-hours>

EXAMPLES

  $(basename $0) gc election 30 168

HELP
}

#
# At least two parameters should be used
#
if [ $# -ne 4 ]; then
  usage; exit 1
fi

stoneName=$1
registryName=$2
stonesDataHome=$STONES_DATA_HOME

if [ -f "./credentials.sh" ]; then
  source ./credentials.sh
  stoneName=$PAS_STONE_NAME
  registryName=$PAS_STONE_REGISTRY
fi

# Extract the value of 'stone_dir' from the .ston file
stone_dir=$(pas_datadir.sh $stoneName $registryName $stonesDataHome)
# Check the return code of the script
if [[ $? -eq 0 ]]; then
    echo ""
else
    echo $stoneName
    echo $registryName
    echo $stonesDataHome 
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

nohup $GEMSTONE/bin/statmonitor $stoneName -a -z -d "$stone_dir/logs" -h $4 -i $3 &
