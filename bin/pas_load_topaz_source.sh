#!/bin/bash
# Dieses Skript loads a topaz script produced by PUM describing a model
#
usage() {
  cat <<HELP

USAGE: $(basename $0) <stone-name> <registry-name> <softwarename> <branch> <version>

Imports new model source from topaz file
$1 = Name of target stone database
$2 = Name of registry
$3 = Name of the software application
$4 = Name of Branch (e.g. v00)
$5 = Specific Version (e.g. 0_001)


EAXMPLES
  $(basename $0) v00 0_001 gc develop|production

HELP
}
if [ $# -ne 5 ]; then
  usage; exit 1
fi

export BASEPATH="http://192.168.178.170/app-sources"
rm out.txt
echo "Retrieving data from: "$BASEPATH/$3/$4/sources/$3-modelsource-$5.sh
curl $BASEPATH/$3/$4/sources/$3-modelsource-$5.sh > $3-$2.sh
dos2unix $3-$2.sh
sudo chmod a+x $3-$2.sh
./$3-$2.sh $1 4000000 $2 &>$3-$2_out.txt
less $3-$2_out.txt
