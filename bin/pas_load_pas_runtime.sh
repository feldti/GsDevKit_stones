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
    baseline: 'ZincHTTPComponents';
    repository: 'github://GsDevKit/zinc:gs_master/repository';
    load: 'REST'.
%
commit
%
doit
  Metacello new
    baseline: 'Zodiac';
    repository: 'github://GsDevKit/zodiac:gs_master/repository';
    load: 'Zodiac-Core'.
%
commit
%
doit
  Metacello new
    baseline: 'Zodiac';
    repository: 'github://GsDevKit/zodiac:gs_master/repository';
    load: 'Zodiac-GemStone-Core'.
%
doit
Gofer new
        url: '$PAS_RUNTIME_PACKAGES' ;
        package: 'MSKExtensions' ;
        load.
%
doit
Gofer new
        url: '$PAS_RUNTIME_PACKAGES' ;
        package: 'Multibase-Core' ;
        load.
Gofer new
        url: '$PAS_RUNTIME_PACKAGES' ;
        package: 'MSKUlid' ;
        load.
Gofer new
        url: '$PAS_RUNTIME_PACKAGES' ;
        package: 'MSKMigrationSupport' ;
        load.
Gofer new
        url: '$PAS_RUNTIME_PACKAGES' ;
        package: 'MSKZeroMQBase' ;
        load.
Gofer new
        url: '$PAS_RUNTIME_PACKAGES' ;
        package: 'MSKZeroMQGemstone' ;
        load.
Gofer new
        url: '$PAS_RUNTIME_PACKAGES' ;
        package: 'MSKZeroMQWrapper' ;
        load.
Gofer new
        url: '$PAS_RUNTIME_PACKAGES' ;
        package: 'MSKRESTSupport' ;
        load.
Gofer new
        url: '$PAS_RUNTIME_PACKAGES' ;
        package: 'MSKSwaggerSupport' ;
        load.
Gofer new
        url: '$PAS_RUNTIME_PACKAGES' ;
        package: 'MSKJSONSchemaSupport' ;
        load.
Gofer new
        url: '$PAS_RUNTIME_PACKAGES' ;
        package: 'MSK-ModelBaseRuntime' ;
        load.
Gofer new
        url: '$PAS_RUNTIME_PACKAGES' ;
        package: 'Neo-JSON-Core' ;
        load.
Gofer new
        url: '$PAS_RUNTIME_PACKAGES' ;
        package: 'MSKGemConnectRabbitMQExtension' ;
        load.
Gofer new
        url: '$PAS_RUNTIME_PACKAGES' ;
        package: 'MSKGemConnectPostgresExtension' ;
        load.

%
doit
ZnConstants
  defaultMaximumEntitySize: (16 * 1024 * 1024) ;
  maximumEntitySize: (16 * 1024 * 1024).
%
commit
EOF
exit 0
