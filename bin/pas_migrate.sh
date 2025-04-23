#!/bin/bash
#
usage() {
  cat <<HELP

USAGE: $(basename $0) <stone-name> <registry> <maxWorkers> <collect-flag>
Does a complete migration with maxWorkers migrator tasks. If number of tasks is 1, then
the script is executed synchronously

EXAMPLES
  $(basename $0) stonename work 8 true

HELP
}

#
# Sind genuegend Parameter mitgegeben ...
#
if [ $# -lt 4 ]; then
  usage; exit 1
fi

if [ "$1" == "credentials" ]; then
    if [ ! -f "./credentials.sh" ]; then
        echo "credentials.sh file not available"
        exit 4
      fi
      source ./credentials.sh
      stoneName=$PAS_STONE_NAME
      registryName=$PAS_STONE_REGISTRY
      stonesDataHome=$STONES_DATA_HOME
else
  stoneName=$1
  registryName=$2
  export WCMIGRATIONINSTANCESFILE="$HOME/__temp_migration_classes.bm"
fi

echo "Migration stores instance data under $WCMIGRATIONINSTANCESFILE"

# Perhaps we need a logs sub directory
if [[ -z "logs" ]]; then
    mkdir logs
    exit 1
fi

if [ "$4" = "true" ]; then
  if [ -f $WCMIGRATIONINSTANCESFILE ]; then
    rm $WCMIGRATIONINSTANCESFILE
  fi
  echo "Calling GsBitmap Creation"
  pas_migrate_collect.sh $stoneName $registryName $WCMIGRATIONINSTANCESFILE &>logs/collect.txt
  echo "Calling GsBitmap Creation - done"
  cat logs/collect.txt
fi

if [ ! -f $WCMIGRATIONINSTANCESFILE ]; then
  echo "GsBitmap file not found. No classes to migrate or some errors have occured"
  exit 0
fi
#
# Wenn es nur einen Task gibt, dann sollte das alles synchron ablaufen
#
if [ "$3" = "1" ]; then
  echo "Migration started in a synchronous way"
  rm logs/migrator_1.txt
  pas_migrate_migrator.sh $stoneName $registryName 1 $3 &>logs/migrator_1.txt
  echo "Migration finished"
  cat logs/migrator_1.txt
else
for ((i=1;i<=$2;i++));
do
   rm logs/migrator_$i.txt
   nohup bash -c "pas_migrate_migrator.sh $stoneName $registryName $i $3 $WCMIGRATIONINSTANCESFILE &>logs/migrator_$i.txt" &
   sleep 1
done
fi



