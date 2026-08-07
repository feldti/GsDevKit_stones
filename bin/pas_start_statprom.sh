#!/bin/bash
#
# This script starts the statprom server based on the information found in a local credentials.sh file
#


stonesDataHome=$STONES_DATA_HOME

if [ -f "./credentials.sh" ]; then
  source ./credentials.sh
  stoneName=$PAS_STONE_NAME
  registryName=$PAS_STONE_REGISTRY
else
  echo "Error: 'credentials.sh' not found"
  exit 1
fi

if [ ! -f "./$PAS_PROMETHEUS_LOCAL_CONFIG_FILE" ]; then
  echo "Error: '$PAS_PROMETHEUS_LOCAL_CONFIG_FILE' configuration file not found"
  exit 1
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

# Dies ist der Prometheus-Adapeter von Gemtalksystems ...
nohup $GEMSTONE/bin/statprom -d -r -f $PAS_PROMETHEUS_LOCAL_CONFIG_FILE >/dev/null 2>&1 &
