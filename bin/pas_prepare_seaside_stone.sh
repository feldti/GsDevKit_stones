#!/bin/bash
#
# script to create a Monticello/Metacello extent, ideas from Gemstone support
#
# Function to display usage
usage() {
    echo "Usage: $0 <stoneName> <gs version> [stonesDataHome]"
    echo "If stonesDataHome is not provided, the script will use the \$STONES_DATA_HOME environment variable."
    exit 1
}

# Check if at least two parameters (stoneName and registryName) are provided
if [[ $# -lt 2 ]]; then
    usage
fi

# Assign parameters
stoneName=$1
registryName="seaside-preparation"
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

# Setup Stone
createStone.solo --registry=$registryName --template=default_seaside $stoneName $2

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

pushd $PAS_HOME_PATH/$registryName/stones/$stoneName
startStone.solo -b
nowTS=`date +%Y-%m-%d-%H-%M`
cat << EOT | $GEMSTONE/bin/topaz -lq -u seaside-preparation-task
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $stoneName
display oops
iferror where

login

exec
  | gofer repositoryDir newCache |
  Transcript
    cr;
    show: '---Step 1 of bootstrap process: execute upgradeGlass.ws'.
  Transcript
    cr;
    show: '-----Install GsUpgrader-Core package '.
  gofer := Gofer new
    package: 'GsUpgrader-Core';
    yourself.

  repositoryDir := ServerFileDirectory on: '$PAS_HOME_PATH/$registryName/devkit/github-cache'.
  newCache := MCCacheRepository new directory: repositoryDir.
  MCCacheRepository setDefault: newCache.
  Transcript show: ' from http://ss3.gemtalksystems.com/ss/gsUpgrader'.
  gofer url: 'http://ss3.gemtalksystems.com/ss/gsUpgrader'.
  gofer load.
  Transcript
    cr;
    show: '-----Upgrade GLASS using GsUpgrader class>>upgradeGLASSForGsDevKit_home'.
  (Smalltalk at: #'GsUpgrader') upgradeGLASS
%

exec
 (Smalltalk at: #'GsUpgrader') batchErrorHandlingDo: [
  | greaseRepo |
  greaseRepo := 'filetree://', '$PAS_HOME_PATH/$registryName/devkit/Grease/repository'.
  Transcript
    cr;
    show: 'Lock and Load Grease (to ensure new repo is honored): ', greaseRepo printString.
  (Metacello image
    configuration: [ :spec | spec name = 'Grease' ];
    list) do: [ :greaseSpec |
      Metacello image
        configuration: 'Grease';
        unregister ].
  Metacello new
    baseline: 'Grease';
    repository: greaseRepo;
    lock.
  Metacello new
    baseline: 'Grease';
    repository: greaseRepo;
    get.
  Metacello new
    baseline: 'Grease';
    repository: greaseRepo;
    load.
  ].
%
commit
exit
EOT
popd

exit 0