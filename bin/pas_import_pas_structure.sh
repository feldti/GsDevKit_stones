#!/bin/bash
#
#
# Function to display usage
usage() {
    echo "Usage: $0 <stoneName> <registryName> <runtimeVersion> [stonesDataHome]"
    echo "Creates a stone useable as pas template stone"
    exit 1
}

# Check if at least two parameters (stoneName and registryName) are provided
if [[ $# -lt 3 ]]; then
    usage
fi


# Assign parameters
stoneName=$1
registryName=$2
runtimeVersion=$3
stonesDataHome=${4:-$STONES_DATA_HOME}


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