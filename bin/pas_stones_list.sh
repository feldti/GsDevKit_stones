#!/bin/bash
#
# Returns a list of running stones with corresponding netldis
#
# Produced by  chatgpt
#
# Marten Feldtmann, 2024
#
# Execute the ps command and filter for netldi processes
#!/bin/bash

# Print header for the output table
echo -e "Stone Name\tNetLDI Running\tNetLDI Port"

# Get all running stoned processes
stoned_output=$(ps axf | grep stoned | grep -v grep)

# Loop through each stoned process
echo "$stoned_output" | while read -r line; do
    # Skip empty lines
    if [[ -z "$line" ]]; then
        continue
    fi

    # Extract the stone name (assuming it follows "stoned " in the command)
    stone_name=$(echo "$line" | grep -oP "(?<=stoned\s)\w+")

    # Check if a corresponding netldi process is running
    netldi_output=$(ps axf | grep "netldid.*${stone_name}" | grep -v grep)

    if [[ -n "$netldi_output" ]]; then
        # Extract the port from the netldi process
        netldi_port=$(echo "$netldi_output" | grep -oP "(?<=-P)\d+")
        netldi_running="Yes"
    else
        netldi_port="N/A"
        netldi_running="No"
    fi

    # Print the stone name, netldi running status, and port
    echo -e "${stone_name}\t\t${netldi_running}\t\t${netldi_port}"
done