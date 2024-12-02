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
    if [ ! -d "$HOME/wc_python" ]; then
        echo "Es gibt kein wc_python Verzeichnis"
        exit 1
    fi
    if [ ! -d "$HOME/wc_python/unix-scripts" ]; then
        echo "Es gibt kein wc_python/unix-scripts Verzeichnis"
        exit 1
    fi
    if [ ! -f "$HOME/wc_python/unix-scripts/credentials.sh" ]; then
        echo "credentials.sh file not available"
        exit 1
    fi
    source $HOME/wc_python/unix-scripts/credentials.sh
else
  export WCMIGRATIONINSTANCESFILE="$HOME/__temp_migration_classes.bm"
fi

echo "Migration stores instance data under $WCMIGRATIONINSTANCESFILE"

if [ "$3" = "true" ]; then
  if [ -f $WCMIGRATIONINSTANCESFILE ]; then
    rm $WCMIGRATIONINSTANCESFILE
  fi
  echo "Calling GsBitmap Creation"
  ./wc_migrate_collect.sh $1 $WCMIGRATIONINSTANCESFILE &>logs/collect.txt
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
if [ "$2" = "1" ]; then
  echo "Migration started in a synchronous way"
  rm logs/migrator_1.txt
  ./wc_migrate_migrator.sh $1 1 $2 &>logs/migrator_1.txt
  echo "Migration finished"
  cat logs/migrator_1.txt
else
for ((i=1;i<=$2;i++));
do
   rm logs/migrator_$i.txt
   nohup bash -c "./wc_migrate_migrator.sh $1 $i $2 $WCMIGRATIONINSTANCESFILE &>logs/migrator_$i.txt" &
   sleep 1
done
fi



