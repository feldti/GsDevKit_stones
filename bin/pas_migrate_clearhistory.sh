#!/bin/bash
#
usage() {
  cat <<HELP

USAGE: $(basename $0)
Entfernt von allen Projektklassen die Klassenhistorie. Dies sollte erst nach
einer erfolgreichen Migration erfolgen

EXAMPLES
  $(basename $0)

HELP
}

if [ ! -f "./credentials.sh" ]; then
    echo "credentials.sh file not available"
    exit 4
fi
source ./credentials.sh
# Extract the value of 'stone_dir' from the .ston file
stone_dir=$(pas_datadir.sh $PAS_STONE_NAME $PAS_STONE_REGISTRY $stonesDataHome)

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

cat << EOF | $GEMSTONE/bin/topaz -lq -T 4000000 -u dev_migrate_clearhistory_${PAS_STONE_NAME}
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $PAS_STONE_NAME
iferror where
login
doit
| domainClassesToConsider migrator|
domainClassesToConsider := ${PAS_APP_PROJECT_CLASS} classCreated
                               select: [ :eachClass | eachClass isSubclassOf: ${PAS_APP_TOPDOMAIN_CLASS} ].
domainClassesToConsider do:[ :eachClass |
  eachClass removeClassHistory
].
${PAS_APP_TOPAPI_CLASS} allSubclasses do:[ :eachClass |
    eachClass removeClassHistory
].
PUMGeneralProjectClass allSubclasses do:[ :eachClass |
    eachClass removeClassHistory
].
System commit
%
EOF
