#!/bin/bash
#
#
# Function to display usage
usage() {
    echo "Usage: $0 [stonesDataHome]"
    echo "Makes a backup from the STONES_DATA_HOME directory"
    exit 1
}


stonesDataHome=${1:-$STONES_DATA_HOME}
nowTS=`date +%Y-%m-%d-%H-%M`

tar cf $PAS_HOME_PATH/$nowTS"_stones_data_home_backup.tgz" $stonesDataHome


exit 0