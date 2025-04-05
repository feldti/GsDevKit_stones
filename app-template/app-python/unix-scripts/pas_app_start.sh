#!/bin/bash
#
# Dieses Script startet die Anwendung komplett. Es benötigt keine Parameter. Alle notwendigen
# Daten werden aus der credentials.sh entnommen
#
usage() {
  cat <<HELP

USAGE: $(basename $0) Startet die Datenbanken mit den Standardkonfigurationswerte


HELP
}

if [ ! -f "./credentials.sh" ]; then
  echo "credentials.sh file not available"
  exit 4
fi
source ./credentials.sh

# Extract the value of 'stone_dir' from the .ston file
stone_dir=$(pas_datadir.sh $PAS_STONE_NAME $PAS_STONE_REGISTRY $STONES_DATA_HOME)

# Check the return code of the script
if [[ $? -eq 0 ]]; then
    echo "The script executed successfully."
else
    echo "The script failed with return code $?."
    exit 3
fi
# Check if stone_dir was found
if [[ -z "$stone_dir" ]]; then
    echo "Error: 'stone_dir' not found in $ston_file_path"
    exit 2
fi
source $stone_dir/customenv
if [ -s $GEMSTONE/seaside/etc/gemstone.secret ]; then
    . $GEMSTONE/seaside/etc/gemstone.secret
else
    echo 'Missing password file $GEMSTONE/seaside/etc/gemstone.secret'
    exit 1
fi


#
# Die Datenbank wird gestartet
#
startStone.solo $PAS_STONE_NAME --registry=$PAS_STONE_REGISTRY

#
# Dann warten wr auf die startende Datenbank, dies ist ein reiner Gemstone-Befehl
#
$GEMSTONE/bin/waitstone $PAS_STONE_NAME >/dev/null 2>&1

#
# This file will be created to show all other tasks that the database is running
#
touch $PAS_DBNAME
nowTS=`date +%Y-%m-%d-%H-%M`

#
# Soll das Netldi Interface zwecks Entwicklung gestartet werden
#
if [ "$PAS_STONE_NETLDI" = "true" ]; then
  echoo "Netldi wurde gestartet"
  startNetldi.solo $PAS_STONE_NAME --registry=$PAS_STONE_REGISTRY
fi

#
# Soll die Statistikerfassung gestartet werden
#
if [ "$STARTSTATMONITOR" = "true" ]; then
  echo "GS Statistiksammler wurde gestartet"
  ./pas_start_statmonitor.sh
fi

#
# Now we start the sub processes of the application. You may adapt this to your needs
#
if [ "$PAS_APP_ENABLE_NORMAL_PORT" = "true" ]; then
nohup ./pas_start_http_task.sh $PAS_STONE_NAME $PAS_STONE_NORMAL_MEMORY $(($PAS_STONE_NORMAL_PORT + 00)) pas_normal.0  >/dev/null 2>&1 &
#nohup ./pas_start_http_task.sh $PAS_STONE_NAME $PAS_STONE_NORMAL_MEMORY $(($PAS_STONE_NORMAL_PORT + 10)) pas_normal.1  >/dev/null 2>&1 &
#nohup ./pas_start_http_task.sh $PAS_STONE_NAME $PAS_STONE_NORMAL_MEMORY $(($PAS_STONE_NORMAL_PORT + 20)) pas_normal.2  >/dev/null 2>&1 &
#nohup ./pas_start_http_task.sh $PAS_STONE_NAME $PAS_STONE_NORMAL_MEMORY $(($PAS_STONE_NORMAL_PORT + 30)) pas_normal.3 >/dev/null 2>&1 &
#nohup ./pas_start_http_task.sh $PAS_STONE_NAME $PAS_STONE_NORMAL_MEMORY $(($PAS_STONE_NORMAL_PORT + 40)) pas_normal.4  >/dev/null 2>&1 &
fi

if [ "$PAS_APP_ENABLE_LONG_PORT" = "true" ]; then
nohup ./pas_start_http_task.sh $PAS_STONE_NAME $PAS_STONE_LONG_MEMORY $(($PAS_STONE_LONG_PORT + 00)) pas_long.0  >/dev/null 2>&1 &
#nohup ./pas_start_http_task.sh $PAS_STONE_NAME $PAS_STONE_LONG_MEMORY $(($PAS_STONE_LONG_PORT + 10)) pas_long.1  >/dev/null 2>&1 &
fi

if [ "$PAS_APP_ENABLE_MEMORY_PORT" = "true" ]; then
nohup ./pas_start_http_task.sh $PAS_STONE_NAME $PAS_STONE_MEMORY_MEMORY $(($PAS_STONE_MEMORY_PORT + 00)) pas_memory.0  >/dev/null 2>&1 &
#nohup ./pas_start_http_task.sh $PAS_STONE_NAME $PAS_STONE_MEMORY_MEMORY $(($PAS_STONE_MEMORY_PORT + 10)) pas_memory.1  >/dev/null 2>&1 &
fi

if [ "$PAS_APP_ENABLE_LIMITED_PORT" = "true" ]; then
nohup ./pas_start_http_task.sh $PAS_STONE_NAME $PAS_STONE_LIMITED_MEMORY $(($PAS_STONE_LIMITED_PORT + 00)) pas_limited.0  >/dev/null 2>&1 &
#nohup ./pas_start_http_task.sh $PAS_STONE_NAME $PAS_STONE_LIMITED_MEMORY $(($PAS_STONE_LIMITED_PORT + 10)) pas_limited.1  >/dev/null 2>&1 &
fi

if [ "$PAS_APP_ENABLE_EXTDB_PORT" = "true" ]; then
nohup ./pas_start_http_task.sh $PAS_STONE_NAME $PAS_STONE_EXTDB_MEMORY $(($PAS_STONE_EXTDB_PORT + 00)) pas_extdb.0 >/dev/null 2>&1 &
#nohup ./pas_start_http_task.sh $PAS_STONE_NAME $PAS_STONE_EXTDB_MEMORY $(($PAS_STONE_EXTDB_PORT + 10)) pas_extdb.1  >/dev/null 2>&1 &
fi
######################################

if [ "$PAS_START_EVENT_SERVERBUS_HANDLER" = "true" ]; then
  echo  "Server EventBus Task gestartet"
  nohup ./pas_task_start_server_event_bus.sh  >/dev/null 2>&1 &
fi

if [ "$PAS_START_SESSION_ACTIVITY_HANDLER" = "true" ]; then
  echo  "Session Activity Task gestartet"
  nohup ./pas_task_start_session_activity.sh  >/dev/null 2>&1 &
fi

if [ "$PAS_START_SUPERSET_TOKEN_HANDLER" = "true" ]; then
  echo  "Apache Superset Task gestartet"
  nohup ./pas_task_start_superset.sh  >/dev/null 2>&1 &
fi

if [ "$PAS_START_PROMETHEUS_COLLECTOR" = "true" ]; then
  echo  "Prometheus Gemstone/S Task gestartet"
  nohup ./pas_task_start_prometheus_support.sh  2>&1 > $GEMSTONE_LOGDIR/prometheus_${startTS}.log &
  if [ "$PAS_START_PROMETHEUS_APP_COLLECTOR" = "true" ]; then
    echo  "Prometheus Gemstone/S Application Task gestartet"
    nohup ./pas_task_start_prometheus_application.sh  2>&1 > $GEMSTONE_LOGDIR/prometheus_app_${startTS}.log &
  fi
fi


