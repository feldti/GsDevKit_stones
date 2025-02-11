#!/bin/bash

#
# export PATH=`pwd`/superDoit/bin:`pwd`/GsDevKit_stones/bin:$PATH
#
# Function to display usage
usage() {
    echo "Usage: $0 <stoneName> <registryName> <backup-directory> [stonesDataHome]"
    echo "If stonesDataHome is not provided, the script will use the \$STONES_DATA_HOME environment variable."
    exit 1
}

# Check if at least two parameters (stoneName and registryName) are provided
if [[ $# -lt 3 ]]; then
    usage
fi

# Assign parameters
stoneName=$1
registryName=$2
backupDirectoryPath=$3
stonesDataHome=${4:-$STONES_DATA_HOME}


# Check if stonesDataHome points to an existing directory
if [[ ! -d "$backupDirectoryPath" ]]; then
    echo "Error: BackupDirectory Target ($backupDirectoryPath) does not point to an existing directory."
    exit 1
fi

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

GSDEVKITHOME=$(dirname "$(readlink -f "$0")")
cd $GSDEVKITHOME
cd ..
GSDEVKITHOME=`pwd`
cd ../superDoit
SUPERDOITHOME=`pwd`

export PATH=$SUPERDOITHOME/bin:$GSDEVKITHOME/bin:$PATH

# Extract the value of 'stone_dir' from the .ston file
stone_dir=$(pas_datadir.sh $stoneName $registryName $stonesDataHome)

# Check the return code of the script
if [[ $? -eq 0 ]]; then
    echo ""
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

cat << EOF | $GEMSTONE/bin/topaz -lq -u backup_task_v3
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $stoneName
display oops
iferror where

login

run
| rc oldestLogID now fileName fileNameStream path |
now := DateAndTime now asUTC.
System beginTransaction.
oldestLogID := SystemRepository oldestLogFileIdForRecovery.

fileNameStream := WriteStream on: String new.
fileNameStream
 nextPutAll: now year asString ;
 nextPutAll: '_'.

now month asString size = 1 ifTrue:[ fileNameStream nextPutAll: '0' ].
fileNameStream
  nextPutAll: now month asString;
  nextPutAll: '_'.

now dayOfMonth asString size = 1 ifTrue:[ fileNameStream nextPutAll: '0' ].
fileNameStream
  nextPutAll: now dayOfMonth  asString;
  nextPutAll: '_'.

now hour24 asString size = 1 ifTrue:[ fileNameStream nextPutAll: '0' ].
fileNameStream
  nextPutAll: now hour24  asString;
  nextPutAll: '_'.

now minute asString size = 1 ifTrue:[ fileNameStream nextPutAll:'0' ].
fileNameStream
  nextPutAll: now minute asString;
  nextPutAll: '-logid-';
  nextPutAll: oldestLogID asString;
  nextPutAll:  '-' ;
  nextPutAll: '$stoneName' asLowercase ;
  nextPutAll: '-' ;
  nextPutAll: System _gemVersionNum asString.

path := '$backupDirectoryPath'.
path last = $/
  ifFalse: [ path := path,'/' ].

fileName := fileNameStream contents.
System commitTransaction.
(SystemRepository fullBackupGzCompressedTo: path,fileName)
        ifTrue:[
                Transcript cr ; show: 'Backup ended with success'.
        ]
        ifFalse:[
                Transcript cr ; show: 'Backup NOT ended with success'.
        ].
%
EOF



exit 0