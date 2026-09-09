#!/bin/bash
#
#
# Initialisiert die persistente Datenstruktur der Anwendung, erzeugt ggfs.
# initiale Benutzer und einen Customer ... der Initialisierungscode liegt
# in der Service-Klasse und sollte als basicInitialize aufgerufen werden.
#
#
if [ ! -f "./credentials.sh" ]; then
   echo "credentials.sh file not available"
   exit 4
fi
source ./credentials.sh
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
 
cat << EOF | $GEMSTONE/bin/topaz -l
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $PAS_STONE_NAME
iferror where
login
doit
$PAS_APP_SERVICE_CLASS basicInitialize.
System commit.
%
commit
EOF
