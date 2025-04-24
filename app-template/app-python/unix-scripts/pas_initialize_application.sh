##!/bin/bash
#
# Dieses Skript initialisiert die Daten einer Anwendung. I.d.R. werden dann ein Customer, ein Projekt 
# oder ein Benutzer mit login und Kennwort angelegt.

if [ ! -f ./credentials.sh ]; then
  echo 'Missing credentials.sh - copy demo_credentials.sh and make the needed changes to it'
  exit 4
fi

#
# load all the needed information
#
source ./credentials.sh
# Extract the value of 'stone_dir' from the .ston file
stone_dir=$(pas_datadir.sh $PAS_STONE_NAME $PAS_STONE_REGISTRY $STONES_DATA_HOME)

# Check the return code of the script
if [[ $? -eq 0 ]]; then
    echo ""
else
    echo "The script failed with return code $?."
    exit 3
fi
# Check if stone_dir was found
if [[ -z "$stone_dir" ]]; then
    echo "Error: 'stone_dir' not found in $ston_file_path"
    exit 2
fi
source $stone_dir/customenv
if [ -s $GEMSTONE/seaside/etc/gemstone.secret ]; then
    . $GEMSTONE/seaside/etc/gemstone.secret
else
    echo 'Missing password file $GEMSTONE/seaside/etc/gemstone.secret'
    exit 1
fi

zufall=$RANDOM
echo -n 'Bitte gebe die folgende Zahl zur Überprüfung ein: '${zufall}' ->: '
read eingabe

if [ "$eingabe" != "$zufall" ]; then
  exit 1000
fi

cat << EOF | $GEMSTONE/bin/topaz -lq -T 4000000 -u pas_load_application
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $PAS_STONE_NAME
iferror where
login
doit
${PAS_APP_SERVICE_CLASS=}
        initializeFirstData.

%
commit
EOF
exit 0
