#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 <stoneName> <registryName> [stonesDataHome]"
    echo "If stonesDataHome is not provided, the script will use the \$STONES_DATA_HOME environment variable."
    exit 1
}

# Check if at least two parameters (stoneName and registryName) are provided
if [[ $# -lt 2 ]]; then
    usage
fi

# Assign parameters
stoneName=$1
registryName=$2
stonesDataHome=${3:-$STONES_DATA_HOME}

# Check if stonesDataHome is set (either as a parameter or an environment variable)
if [[ -z "$stonesDataHome" ]]; then
    echo "Error: stonesDataHome is not provided and \$STONES_DATA_HOME is not set."
    exit 1
fi

# Check if stonesDataHome points to an existing directory
if [[ ! -d "$stonesDataHome" ]]; then
    echo "Error: stonesDataHome ($stonesDataHome) does not point to an existing directory."
    exit 1
fi

# Construct the path to the .ston file
ston_file_path="$stonesDataHome/gsdevkit_stones/stones/$registryName/$stoneName.ston"

# Check if the .ston file exists
if [[ ! -f "$ston_file_path" ]]; then
    echo "Error: .ston file not found at $ston_file_path"
    exit 1
fi

# Extract the value of 'stone_dir' from the .ston file
stone_dir=$(grep -oP "'stone_dir'\s*:\s*'[^']+'" "$ston_file_path" | grep -oP "(?<=:\s')[^']+")


# Check if stone_dir was found
if [[ -z "$stone_dir" ]]; then
    echo "Error: 'stone_dir' not found in $ston_file_path"
    exit 1
fi

# Output the value of stone_dir
echo $stone_dir
exit 0