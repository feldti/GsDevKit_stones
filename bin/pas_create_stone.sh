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
stonesDataHome=${4:-$STONES_DATA_HOME}

# default_seaside is used to get a stone directory with subdirectories
createStone.solo --registry=$registryName --template=pas_seaside $stoneName $gsVersion

# Extract the value of 'stone_dir' from the .ston file
stone_dir=$(pas_datadir.sh $stoneName $registryName $stonesDataHome)

# we correct the setting of the just created stone: GEMSTONE_SYS_CONF must be set
updateCustomEnv.solo $stoneName --registry=$registryName --addKey=GEMSTONE_STONE_DIR --value='$stone_dir'
updateCustomEnv.solo $stoneName --registry=$registryName --addKey=GEMSTONE_DATADIR --value='$stone_dir/extents'
updateCustomEnv.solo $stoneName --registry=$registryName --addKey=GEMSTONE_SYS_CONF --value='$stone_dir/system.conf'
updateCustomEnv.solo $stoneName --registry=$registryName --addKey=GEMSTONE_LOGDIR --value='$stone_dir/logs'


if [[ ! -f "$PAS_HOME_PATH/$registryName/licenses/${gsVersion}.key" ]]; then
    echo "Error: License file for that specific Gemstone/S product '"${gsVersion}"' does not exists in registry '"${registryName}"' "
    exit 1
fi
if cmp -s $PAS_HOME_PATH/$registryName/licenses/${gsVersion}.key $PAS_HOME_PATH/$registryName/products/GemStone64Bit${gsVersion}-x86_64.Linux/seaside/etc/gemstone.key; then
    echo "Produce License file copied"
else
    sudo cp  $PAS_HOME_PATH/$registryName/licenses/${gsVersion}.key $PAS_HOME_PATH/$registryName/products/GemStone64Bit${gsVersion}-x86_64.Linux/seaside/etc/gemstone.key
fi

exit 0