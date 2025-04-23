#!/bin/bash
#
usage() {
  cat <<HELP

USAGE: $(basename $0) <index> <total> <path>
Startet einen Migrator-Task

EXAMPLES
  $(basename $0)  1 8 /home/...../__temp_migration_classes.bm

HELP
}

#
# Sind genuegend Parameter mitgegeben ...
#
if [ $# -ne 3 ]; then
  usage; exit 1
fi

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


cat << EOF | $GEMSTONE/bin/topaz -l -T 500000 -u dev_migrate_migrator_${1}_${2}_${3}
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $PAS_STONE_NAME
iferror where
login
doit
|  migrator|
migrator := MSKMigrater
                migrator: '${3}'
                workerIndexOneBased: ${1}
                workerTotal: ${2}
                transactionStepSize: 500.
migrator migrate
%
EOF
