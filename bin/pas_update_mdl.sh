#!/bin/bash
#
#
# Dieses Skript lädt nur das aktuelle Modell in die Datenbank
#



if [ ! -f "./credentials.sh" ]; then
    echo "Aborted: credentials.sh file not available. Start the script within the unix-scripts directory of your application"
    exit 4
fi

source ./credentials.sh

if [ -z "$PAS_APP_PACKAGES" ]; then
    echo "Aborted: Variable PAS_APP_PACKAGES should be defined in your credentials.sh file. The value points to an URL, where the Monticello Packages are available"
fi

if [ -z "$PAS_APP_MDL_PACKAGE" ]; then
    echo "Aborted: Variable 'PAS_APP_MDL_PACKAGE' should be defined in your credentials.sh file. The value holds the Monticello filename of the model extension at the location 'PAS_APP_PACKAGES'"
fi

stoneName=$PAS_STONE_NAME
registryName=$PAS_STONE_REGISTRY
stonesDataHome=$STONES_DATA_HOME

if [ -z "$PAS_STONE_NAME" ]; then
    echo "Aborted: Variable 'PAS_STONE_NAME' should be defined in your credentials.sh file. Its the name of the database"
fi
if [ -z "$PAS_STONE_REGISTRY" ]; then
    echo "Aborted: Variable 'PAS_STONE_REGISTRY' should be defined in your credentials.sh file. The value holds the Monticello filename of the model extension at the location 'PAS_APP_PACKAGES'"
fi

# Extract the value of 'stone_dir' from the .ston file
#echo $stoneName :  $registryName : $stonesDataHome
stone_dir=$(pas_datadir.sh $stoneName $registryName $stonesDataHome)
#echo $stone_dir

# Check the return code of the script
if [[ $? -eq 0 ]]; then
    echo ""
else
    echo "Aborted: The script pas_datadir.sh failed with return code $?."
fi

# Check if stone_dir was found
if [[ -z "$stone_dir" ]]; then
    echo "Aborted: 'stone_dir' not defined by script 'pas_datadir.sh'"
    exit 1
fi
source $stone_dir/customenv
if [ -z "$PAS_STONE_REGISTRY" ]; then
    echo "Aborted: Variable 'GEMSTONE' not defined. The database '$PAS_STONE_NAME' in registry '$PAS_STONE_REGISTRY' could not be found"
fi

if [ -s $GEMSTONE/seaside/etc/gemstone.secret ]; then
    . $GEMSTONE/seaside/etc/gemstone.secret
else
    echo 'Aborted: Missing password file $GEMSTONE/seaside/etc/gemstone.secret'
    exit 1
fi

cat << EOF | $GEMSTONE/bin/topaz -lq -T 1000000 -u pas_update_mdl_extension
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $stoneName
iferror where
login
doit
Gofer new
        url: '$PAS_APP_PACKAGES' ;
        package: '$PAS_APP_MDL_PACKAGE' ;
        load.
%
commit
EOF
