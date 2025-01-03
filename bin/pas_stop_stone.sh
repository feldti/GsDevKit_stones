#!/bin/bash
#
#
# Function to display usage
usage() {
    echo "Usage: $0 <stoneName> <registryName> [stonesDataHome]"
    echo "Stops a stone useable as pas template stone"
    exit 1
}

# Check if at least two parameters (stoneName and registryName) are provided
if [[ $# -lt 2 ]]; then
    usage
fi

# Assign parameters
stoneName=$1
registryName=$2
stonesDataHome=${3:-$STONES_DATA_HOME}

# default_seaside is used to get a stone directory with subdirectories
stopStone.solo --registry=$registryName $stoneName

exit 0