#!/bin/bash
#
#
#
usage() {
  cat <<HELP

USAGE: $(basename $0) <stoneName> <registryName> [stonesDataHome]
sets the database timezone to the OS timezone

EXAMPLES
  $(basename $0) webcati6
 
HELP
}

#
# Sind genuegend Parameter mitgegeben ...
#
if [ $# -lt 2 ]; then
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

cat << EOF | $GEMSTONE/bin/topaz -l
set user SystemUser pass $GEMSTONE_CURATOR_PASS gems $stoneName
iferror where
login
run
| osTZ |
System beginTransaction.
osTZ := TimeZone fromOS.
osTZ installAsCurrentTimeZone.
TimeZone default: osTZ.
TimeZoneInfo default: osTZ.
System commitTransaction.
%

logout
errorCount
EOF
