#!/bin/bash
#
#
usage() {
  cat <<HELP

USAGE: $(basename $0) <path>
Migriert die Instanzen auf die aktuelle Version. Weitere Informationen werden aus einem
vorher ausgelesenen credentials.sh ausgelesen

EXAMPLES
  $(basename $0) /home/...../__temp_migration_classes.bm

HELP
}

#
# Sind genuegend Parameter mitgegeben ...
#
if [ $# -ne 1 ]; then
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
echo 'Creating the GsBitmap File'

cat << EOF | topaz -l -T 4000000 -u dev_migrate_collector_${1}
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $stoneName
iferror where
login
doit
| domainClassesToConsider migrator|
domainClassesToConsider := ${PAS_APP_PROJECT_CLASS} classCreated select: [ :eachClass | eachClass isSubclassOf: ${PAS_APP_PROJECT_CLASS} projectPersistentMasterClass ].
domainClassesToConsider add: ${PAS_APP_PROJECT_CLASS}.
migrator := MSKMigrater collector: '${1}' classes: domainClassesToConsider fastMode: true.
migrator createGsBitmapFile.
%
EOF
