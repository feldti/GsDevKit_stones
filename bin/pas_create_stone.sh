#!/bin/bash
#
#
# Function to display usage
usage() {
    echo "Usage: $0 <stoneName> <registryName> <gsVersion> [stonesDataHome]"
    echo "Creates a stone useable as pas template stone"
    exit 1
}

# Check if at least two parameters (stoneName and registryName) are provided
if [[ $# -lt 3 ]]; then
    usage
fi


# Assign parameters
stoneName=$1
registryName=$2
gsVersion=$3

# default_seaside is used to get a stone directory with subdirectories
createStone.solo --registry=$registryName --template=pas_seaside $stoneName $gsVersion
if cmp -s $PAS_HOME_PATH/$registryName/licenses/${gsVersion}.key $PAS_HOME_PATH/$registryName/products/GemStone64Bit${gsVersion}-x86_64.Linux/seaside/etc/gemstone.key; then
    echo "Die Dateien sind identisch."
else
    sudo cp  $PAS_HOME_PATH/$registryName/licenses/${gsVersion}.key $PAS_HOME_PATH/$registryName/products/GemStone64Bit${gsVersion}-x86_64.Linux/seaside/etc/gemstone.key
fi

exit 0