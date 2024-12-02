#!/bin/bash
#
# This software is owned by
#       ____ _____ ____ ____    ____         __ _
#      / ___| ____/ ___/ ___|  / ___|  ___  / _| |___      ____ _ _ __ ___
#     | |  _|  _| \___ \___ \  \___ \ / _ \| |_| __\ \ /\ / / _` | '__/ _ \
#     | |_| | |___ ___) |__) |  ___) | (_) |  _| |_ \ V  V / (_| | | |  __/
#      \____|_____|____/____/  |____/ \___/|_|  \__| \_/\_/ \__,_|_|  \___|
#
#
usage() {
  cat <<HELP

USAGE: $(basename $0) <stone-name> <path>
Migriert die Instanzen auf die aktuelle Version

EXAMPLES
  $(basename $0) webcati70 /home/...../__temp_migration_classes.bm

HELP
}

#
# Sind genuegend Parameter mitgegeben ...
#
if [ $# -ne 2 ]; then
  usage; exit 1
fi

#
# Umgebung setzen
#
cd
source $GS_HOME/bin/defGsDevKit.env
source $GS_HOME/server/stones/$1/defStone.env $1
if [ -s $GS_HOME/server/stones/$1/product/seaside/etc/gemstone.secret ]; then
    . $GS_HOME/server/stones/$1/product/seaside/etc/gemstone.secret
else
    echo 'Missing password file $GS_HOME/server/stones/$1/defStone.env'
    exit 1
fi

echo 'Creating the GsBitmap File'

cat << EOF | topaz -l -T 4000000 -u dev_migrate_collector_${1}
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $GEMSTONE_NAME
iferror where
login
doit
| domainClassesToConsider migrator|
domainClassesToConsider := GWCProject classCreated select: [ :eachClass | eachClass isSubclassOf: GWCProject projectPersistentMasterClass ].
domainClassesToConsider add: GWCProject.
migrator := MSKMigrater collector: '${2}' classes: domainClassesToConsider fastMode: true.
migrator createGsBitmapFile.
%
EOF
