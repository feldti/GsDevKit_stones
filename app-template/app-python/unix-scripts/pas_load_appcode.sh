#!/bin/bash
#
#
# PAS_APP_PACKAGES="http://192.168.178.150/app-sources/surveymanager/$3/sources/"
PAS_APP_PACKAGES="http://192.168.178.170/app-sources/surveymanager/$3/sources/"

PAS_APP_MODEL_EXTENSION_PACKAGE="SurveyManagerExtension"
usage() {
  cat <<HELP

USAGE: $(basename $0) <stoneName> <registryName> <version> [stonesDataHome]
Dieses Skript lädt das aktuelleste Anwendungsmodell und den aktuellesten Anwendungscode von der Adresse $PAS_APP_PACKAGES herunter. Diese
Adresse muss entsprechend angepasst werden für die jeweilige Anwendung.

version = (e.g.) v00, v10, v76, v80, v100

HELP
}

#
# Sind genuegend Parameter mitgegeben ...
#
if [ $# -lt 3 ]; then
  usage; exit 1
fi

# Assign parameters
stoneName=$1
registryName=$2
stonesDataHome=${4:-$STONES_DATA_HOME}


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

cat << EOF | $GEMSTONE/bin/topaz -lq -T 4000000 -u pas_load_application
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $stoneName
iferror where
login
doit
Gofer new
        url: '$PAS_APP_PACKAGES' ;
        package: '$PAS_APP_MODEL_EXTENSION_PACKAGE' ;
        load.
%
commit
EOF
exit 0
