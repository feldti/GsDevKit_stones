#!/bin/bash
#
#
# Function to display usage
usage() {
    echo "Usage: $0 <stoneName> <registryName> <gsVersion> <runtimeVersion> [stonesDataHome]"
    echo "Creates a stone useable as pas template stone"
    exit 1
}

# Check if at least two parameters (stoneName and registryName) are provided
if [[ $# -lt 4 ]]; then
    usage
fi


# Assign parameters
stoneName=$1
registryName=$2
gsVersion=$3
runtimeVersion=$4
stonesDataHome=${5:-$STONES_DATA_HOME}

# default_seaside is used to get a stone directory with subdirectories
createStone.solo --registry=$registryName --template=default_seaside $stoneName $gsVersion

startStone.solo --registry=$registryName $stoneName

echo "Loading Third-Party libraries"
pushd `pwd`
pas_update_gemstone.sh $stoneName $registryName $stonesDataHome
popd
echo "Loading Third-Party libraries - done"

echo "Loading the PDF framework"
pas_load_report4pdf.sh $stoneName $registryName $stonesDataHome

echo "Loading GemConnect PostgreSQL"
pas_load_base_postgresql.sh $stoneName $registryName $stonesDataHome

echo "Loading GemConnect RabbitMQ"
pas_load_base_rabbitmq.sh $stoneName $registryName $stonesDataHome

echo "Loading PAS runtime"
pas_load_pas_runtime.sh $stoneName $registryName $runtimeVersion $stonesDataHome

exit 0