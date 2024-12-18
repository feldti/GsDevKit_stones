#!/bin/bash
#
# Do a restore from a full backup
#
# Function to display usage
usage() {
    echo "Usage: $0 <stoneName> <registryName> <filepath> <version> [stonesDataHome]"
    echo "restores the backup into an already existing stone"
    exit 1
}

set -e

# Check if at least two parameters (stoneName and registryName) are provided
if [[ $# -lt 4 ]]; then
    usage
fi

# Assign parameters
stoneName=$1
registryName=$2
version=$4
stonesDataHome=${5:-$STONES_DATA_HOME}

pas_create_stone.sh $stoneName $registryName $version
pas_restore_data_from_fullbackup.sh $1 $2 $3 $stonesDataHome
