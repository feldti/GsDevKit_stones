#!/bin/bash
#
#
usage() {
  cat <<HELP

USAGE: $(basename $0) <stoneName> <registryName> <version> [stonesDataHome]
Loads additional packages forming the runtime for PAS applications

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

PAS_RUNTIME_PACKAGES="http://feldtmann.ddns.net/pas-project/pas_runtime/$3/sources/"
# Extract the value of 'stone_dir' from the .ston file
stone_dir=$(pas_datadir.sh $stoneName $registryName $stonesDataHome)

# Check the return code of the script
if [[ $? -eq 0 ]]; then
    echo "The script executed successfully."
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

cat << EOF | $GEMSTONE/bin/topaz -lq -T 1000000 -u pum_runtime_loading
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $stoneName
iferror where
login
doit
  Metacello new
    baseline: 'PharoCompatibilty';
    repository: 'github://glassdb/PharoCompatibility:master/repository';
    load: 'Core'.
%
commit
EOF
exit 0
