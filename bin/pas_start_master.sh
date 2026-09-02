#!/bin/bash
#
#
# This script starts the logsender for the specific host
#
#
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

nowTS=`date +%Y-%m-%d-%H-%M`
if [ "$HOTSTANDBYBYENABLED" = "true" ]; then
  $GEMSTONE/bin/startlogsender -P $HOTSTANDBYMASTERPORT -A $HOTSTANDBYMASTERADR -s $PAS_STONE_NAME -l $GEMSTONE_LOGDIR
  # $GEMSTONE/bin/startlogsender -P $HOTSTANDBYMASTERPORT -A $HOTSTANDBYMASTERADR -s $PAS_STONE_NAME
  echo "LOGSENDER started"
fi
