#!/bin/bash
#
#
# This script is only usefull for a full performance testing
#
usage() {
  cat <<HELP

USAGE: $(basename $0) stonename registry

Example:
            pas_endless_task.sh testDatabase work

HELP
}

#
# Are enough parameter available ?
#

if [ $# -lt 2 ]; then
  usage; exit 1
fi
stoneName=$1
registryName=$2
restClassClassName=$3

# Extract the value of 'stone_dir' from the .ston file
echo $stoneName :  $registryName : $stonesDataHome
stone_dir=$(pas_datadir.sh $stoneName $registryName $stonesDataHome)
echo $stone_dir
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

cat << EOF | $GEMSTONE/bin/topaz -lq -T 50000 -u pas_endless_task
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $stoneName
iferror where
login
doit
[ true ] whileTrue: []
%
commit
EOF
