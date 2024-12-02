#!/bin/bash
#
#
# This script publishes the OpenAPI specification at the file location
#    /var/www/html/api/<interface>/<version>/openapi.json
#
usage() {
  cat <<HELP

USAGE: $(basename $0) stonename registry interface  [stonesDataHome]
writes the file of the OpenAPI specification of the interface
to the following file location:
      /var/www/html/openapi/<interface>/openapi.json

Example:  pas_publich_openapi.sh testDatabase cati WCATIServiceClass

produces a file
        /var/www/html/openapi/wcatiserviceclass/openapi.json
HELP
}

#
# Are enough parameter available ?
#
if [ $# -lt 3 ]; then
  usage; exit 1
fi

# Assign parameters
stoneName=$1
registryName=$2
stonesDataHome=${4:-$STONES_DATA_HOME}

EXPORTPATH="/var/www/html/openapi"



if [ ! -d $EXPORTPATH ]; then
  sudo mkdir $EXPORTPATH
  sudo chown -R $USER.$GRPNAME $EXPORTPATH
  sudo chmod a+wrx $EXPORTPATH
fi

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

cat << EOF | $GEMSTONE/bin/topaz -lq -T 1000000 -u pum_publish_openapi
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $stoneName
iferror where
login
doit
$2 exportOpenAPISpecification.
%
commit
doit
%
EOF
