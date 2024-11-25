#!/bin/bash
#
# Returns a list of running netldi processes and if the corrensponding database is also running
#
# Produced by  chatgpt
#
# Marten Feldtmann, 2024
#
# Execute the ps command and filter for netldi processes
netldi_output=$(ps axf | grep sys/netldi | grep -v grep)

# Print header for the table
echo -e "Version\tPort\tNetLDI\t\t\tOwner\t\t\tDatabase Running"


# Loop through each line of the netldi output
echo "$netldi_output" | while read -r line; do

 # Skip empty lines
    if [[ -z "$line" ]]; then
        continue
    fi

    # Extract GemStone version (assuming it follows "GemStone64Bit" and is separated by "-")
    version=$(echo "$line" | grep -oP "GemStone64Bit\K[^\s/-]+")

    # Extract Port (assuming it follows "-P")
    port=$(echo "$line" | grep -oP "(?<=-P)\d+")

    # Extract NetLDI name (assuming it starts after "sys/netldid ")
    netldi_name=$(echo "$line" | grep -oP "netldid\s+\K\w+")

    # Extract Owner (value after "-a" option)
    owner=$(echo "$line" | grep -oP "(?<=-a)\w+")

    # Derive Stone name by removing "_ldi" suffix from the NetLDI name
    stone_name=$(echo "$netldi_name" | sed 's/_ldi$//')

    # Check if a database (stoned process) is running for the extracted stone name
    db_running=$(ps axf | grep -E "/stones/gemstone/GemStone64Bit${version}.*stoned.*${stone_name}" | grep -v grep > /dev/null && echo "Yes" || echo "No")

    # Print the extracted details in table format
    echo -e "${version}\t${port}\t${netldi_name}\t\t${owner}\t\t\t${db_running}"
done