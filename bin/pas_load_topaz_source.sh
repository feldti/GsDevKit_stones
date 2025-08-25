#!/bin/bash
# Dieses Skript loads a topaz script produced by PUM describing a model
#
if [ -f ./credentials.sh ]; then
  source ./credentials.sh
  export BASEPATH=$PAS_APP_PACKAGES
  export DOWNLOADPATH=$PAS_APP_PACKAGES/$PAS_APP_MODEL_TOPAZ_FILE-modelsource-$5.sh
else 
 export BASEPATH="http://localhost/app-sources"
 export DOWNLOADPATH=$BASEPATH/$3/$4/sources/$3-modelsource-$5.sh
fi 

usage() {
  cat <<HELP

USAGE: $(basename $0) <stone-name> <registry-name> <softwarename> <branch> <version>

Imports new model source from topaz file located at host $DOWNLOADPATH
$1 = Name of target stone database
$2 = Name of registry (e.g. work)
$3 = Name of the software application (e.g. sm)
$4 = Name of Branch (e.g. v00)
$5 = Specific Version (e.g. 0_001)


EAXMPLES
  $(basename $0) testv100 work sm v00 0_001

HELP
}
if [ $# -ne 5 ]; then
  usage; exit 1
fi


rm out.txt
echo "Retrieving data from: "$DOWNLOADPATH
curl $DOWNLOADPATH > $3-$2.sh
dos2unix $3-$2.sh
sudo chmod a+x $3-$2.sh
./$3-$2.sh $1 4000000 $2 &>$3-$2_out.txt
less $3-$2_out.txt
