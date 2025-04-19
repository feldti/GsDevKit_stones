#!/bin/bash
#
# Dieses Skript liest den aktuellen Keyfile des benutzten Gemstone/S Produktes erneut ein für die entsprechende
# Datenbank
#
usage() {
  cat <<HELP

USAGE: $(basename $0) stonename registry [stonesDataHome]

Example:  pas_apply_keyfile stoneName work

HELP
}

#
# Are enough parameter available ?
#
if [ $# -lt 2 ]; then
  usage; exit 1
fi

# Assign parameters
stoneName=$1
registryName=$2
stonesDataHome=${3:-$STONES_DATA_HOME}

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

cat << EOF | $GEMSTONE/bin/topaz -lq  -u pas_apply_keyfile
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $stoneName
iferror where
login
doit
System applyKeyfileNamed: nil.
%
commit
EOF
