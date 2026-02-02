#!/bin/bash
#
#
# Dieses Skript baut intern neue persistenten Strukturen, um die API
# effizient abarbeiten zu können.
#
usage() {
  cat <<HELP

USAGE: $(basename $0) stonename registry  [stonesDataHome]

Example:
            pas_refresh_api.sh testDatabase work SMRestClass
            pas_refresh_api.sh credentials

HELP
}

#
# Are enough parameter available ?
#


if [ "$1" == "credentials" ]; then
  if [ ! -f "./credentials.sh" ]; then
    echo "credentials.sh file not available"
    exit 4
  fi
  source ./credentials.sh
  stoneName=$PAS_STONE_NAME
  registryName=$PAS_STONE_REGISTRY
  restClassClassName=$PAS_APP_RESTCALL_CLASS
  stonesDataHome=$STONES_DATA_HOME
else
   if [ $# -lt 3 ]; then
     usage; exit 1
   fi
   stoneName=$1
   registryName=$2
   restClassClassName=$3
   stonesDataHome=${4:-$STONES_DATA_HOME}
fi

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

cat << EOF | $GEMSTONE/bin/topaz -lq -T 1000000 -u pum_refresh_api
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $stoneName
iferror where
login
doit
$restClassClassName buildAPIDefinitionsStructure.
%
commit
EOF
