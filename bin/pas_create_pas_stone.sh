#!/bin/bash
#
#
# Function to display usage
usage() {
    echo "Usage: $0 <stoneName> <registryName> <filepath> <gsVersion> [stonesDataHome]"
    echo "Creates a stone by using a pas template backup"
    exit 1
}

# Check if at least two parameters (stoneName and registryName) are provided
if [[ $# -lt 4 ]]; then
    usage
fi

# Assign parameters
stoneName=$1
registryName=$2
filePath=$3
gsVersion=$4
stonesDataHome=${5:-$STONES_DATA_HOME}

# notinterested, default_seaside is used to get a stone directory with subdirectories
createStone.solo --registry=$registryName --template=default_seaside $stoneName $4
pas_restore.sh $stoneName $registryName $filePath $stonesDataHome
pas_finish_restore.sh $stoneName $registryName $stonesDataHome


exit 0