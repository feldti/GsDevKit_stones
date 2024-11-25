#!/bin/bash

# Check if the database name is provided as an argument
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <database_name>"
    exit 1
fi

# Database name passed as argument
database_name=$1

# Print header for the output table
echo -e "Topaz PID\tStone Name\tTopaz Name\t\t\t\tMax Memory (MB)"

# Get all running topaz processes
topaz_processes=$(ps axf | grep "/bin/topaz" | grep -v grep)

# Loop through each topaz process
echo "$topaz_processes" | while read -r line; do
    # Skip empty lines
    if [[ -z "$line" ]]; then
        continue
    fi

    # Extract the PID of the topaz process
    pid=$(echo "$line" | awk '{print $1}')

    # Extract the full command line of the topaz process
    cmd=$(echo "$line" | cut -d' ' -f5-)

    # Extract the stone name (between "stones" and "product" in the path)
    stone_name=$(echo "$cmd" | grep -oP "(?<=stones/)[^/]+(?=/product)")

    # Extract the domain name (after "-u " parameter, up to the next space)
    domain_name=$(echo "$cmd" | grep -oP "(?<=-u\s)[^\s]+")

    # Extract the maximum memory usage (after "-T" parameter)
    max_memory=$(echo "$cmd" | grep -oP "(?<=-T\s)\d+")

    # Check if the stone name matches the database name
    if [[ "$stone_name" == "$database_name" ]]; then
        # Print the PID, stone name, domain name, and maximum memory
        echo -e "${pid}\t\t${stone_name}\t\t${domain_name}\t\t\t${max_memory:-N/A}"
    fi
done