#!/bin/bash
#
#
# This application loads the Report4PDF package
#
#
usage() {
  cat <<HELP

USAGE: $(basename $0) <stoneName> <registryName> [stonesDataHome]
Loads the Report4PDF package

HELP
}

#
# Sind genuegend Parameter mitgegeben ...
#
if [ $# -lt 2 ]; then
  usage; exit 1
fi

# Assign parameters
stoneName=$1
registryName=$2
stonesDataHome=${3:-$STONES_DATA_HOME}

export INSTALL_HOME=`pwd`
if [ ! -d ~/PDFtalk-for-Gemstone ]; then
  mkdir ~/PDFtalk-for-Gemstone
  cd ~
  git clone https://github.com/feldti/PDFtalk-for-Gemstone.git
fi
if [ -d ~/PDFtalk-for-Gemstone ]; then
  cd ~/PDFtalk-for-Gemstone
  git pull
fi
cd $INSTALL_HOME

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

if [ -d ~/PDFtalk-for-Gemstone ]; then
  echo "PDFTalk wird installiert"
  cd ~/PDFtalk-for-Gemstone
  ./load_pdftalk_stones.sh  $stoneName $registryName $stonesDataHome
  ./load_pdftalktesting_stones.sh  $stoneName $registryName $stonesDataHome
  cd $INSTALL_HOME
else
  echo "ERROR: Kein PDFTalk zu installieren !"
  exit 1
fi

cat << EOF | $GEMSTONE/bin/topaz -lq -T 4000000
set user DataCurator pass $GEMSTONE_CURATOR_PASS gems $stoneName
iferror where
login
doit
GsDeployer deploy: [
  Metacello new
    baseline: 'Report4PDF';
    repository: 'github://feldti/PDFtalk-for-Gemstone:master/repository';
    load: 'default' ].
%
commit
EOF
exit 0
