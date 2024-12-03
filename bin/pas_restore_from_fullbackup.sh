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

set -x

# Check if at least two parameters (stoneName and registryName) are provided
if [[ $# -lt 4 ]]; then
    usage
fi

# Assign parameters
stoneName=$1
registryName=$2
version=$4
stonesDataHome=${5:-$STONES_DATA_HOME}

createStone.solo $stoneName $version --registry=$registryName --template=default_seaside
# we correct the setting of the just created stone: GEMSTONE_SYS_CONF must be set
updateCustomEnv.solo $stoneName --registry=$registryName --addKey=GEMSTONE_STONE_DIR --value='$stone_dir'
updateCustomEnv.solo $stoneName --registry=$registryName --addKey=GEMSTONE_DATADIR --value='$stone_dir/extents'
updateCustomEnv.solo $stoneName --registry=$registryName --addKey=GEMSTONE_SYS_CONF --value='$stone_dir/system.conf'
updateCustomEnv.solo $stoneName --registry=$registryName --addKey=GEMSTONE_LOGDIR --value='$stone_dir/logs'

# Check if stonesDataHome is set (either as a parameter or an environment variable)
if [[ -z "$stonesDataHome" ]]; then
    echo "Error: stonesDataHome is not provided and \$STONES_DATA_HOME is not set."
    exit 1
fi

# Check if stonesDataHome points to an existing directory
if [[ ! -d "$stonesDataHome" ]]; then
    echo "Error: stonesDataHome ($stonesDataHome) does not point to an existing directory."
    exit 1
fi

# Extract the value of 'stone_dir' from the .ston file
stone_dir=$(pas_datadir.sh $stoneName $registryName $stonesDataHome)

# Check the return code of the script
if [[ $? -eq 0 ]]; then
    echo A
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

if [ -f  $stone_dir/extents/extent0.dbf ]; then
  rm  $stone_dir/extents/extent0.dbf
fi

$GEMSTONE/bin/copydbf $GEMSTONE/bin/extent0.dbf $stone_dir/extents/extent0.dbf
chmod u+w $stone_dir/extents/extent0.dbf

$GEMSTONE/bin/startstone  $stoneName  -R -l $stone_dir/logs/$stoneName.log
cat << EOF | $GEMSTONE/bin/topaz -l -u restore_task
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $stoneName
display oops
iferror where

login
printit
SystemRepository restoreFromBackup: '$3'
%
EOF

cat << EOF2 | $GEMSTONE/bin/topaz -l -u restore_task
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $stoneName
display oops
iferror where

login
printit
SystemRepository commitRestore
%
EOF2


exit 0