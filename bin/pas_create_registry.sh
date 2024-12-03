#!/bin/bash
#
# This script creates a registry with a specific name and adds directory informations
# for the stones data directory and the product storage directory for this registry
#
# Function to display usage
usage() {
    echo "Usage: $0 <registryName>"
    echo "Creates a registry with default values"
    exit 1
}

# Check if at least two parameters (stoneName and registryName) are provided
if [[ $# -lt 1 ]]; then
    usage
fi

# Assign parameters
registryName=$1

# notinterested, default_seaside is used to get a stone directory with subdirectories
createRegistry.solo $registryName
registerStonesDirectory.solo --registry=$registryName --stonesDirectory=$PAS_HOME_PATH/$registryName/stones
registerProductDirectory.solo --registry=$registryName --productDirectory=$PAS_HOME_PATH/$registryName/products

exit 0