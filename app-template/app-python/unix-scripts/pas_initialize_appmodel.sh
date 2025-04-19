#!/bin/bash
#
# Mit diesem Skript wird die Root der Persistency der Anwendung neu initialisert. Also
# niemals mit einer vollen Datenbank machen. Das Skript ruft die Methode initializePersistencyRoot
# in der definierten Serviceklasse auf, die die Initialisierung vornehmen sollte. Diese Methode
# muß vom Entwickler geschrieben werden.
#

if [ ! -f "./credentials.sh" ]; then
  echo "credentials.sh file not available"
  exit 4
fi
source ./credentials.sh

# Extract the value of 'stone_dir' from the .ston file
stone_dir=$(pas_datadir.sh $PAS_STONE_NAME $PAS_STONE_REGISTRY $STONES_DATA_HOME)

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

cat << EOF | $GEMSTONE/bin/topaz -lq -T 100000 -u pas_initialize_data
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $PAS_STONE_NAME
iferror where
login
doit
$PAS_APP_SERVICE_CLASS initializePersistencyRoot.
%
commit
EOF
exit 0
