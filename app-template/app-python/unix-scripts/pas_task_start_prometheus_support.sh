#!/bin/bash
#
#
# This script starts den Prometheus Support
#
#
usage() {
  cat <<HELP

USAGE: $(basename $0)
starts the session activity handler

EXAMPLES

  $(basename $0)

HELP
}

if [ ! -f ./credentials.sh ]; then
  echo 'Missing credentials.sh - copy demo_credentials.sh and make the needed changes to it'
  exit 1
fi

#
# load all the needed information
#
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


# Dies ist der Prometheus-Adapter von Gemtalksystems ...
$GEMSTONE/bin/statprom -d -r -f $PAS_PROMETHEUS_LOCAL_CONFIG_FILE >/dev/null 2>&1 &

# Die Schleife läuft solange bis die Datei mit dem Stone-Namen nicht mehr vorhanden ist
while [ -f $PAS_STONE_NAME ]
do

  # Zuerst wird der lokale Server abgefragt und das Ergebnis lokal gespeichert
  rm $PAS_PROMETHEUS_LOCAL_FILE
  curl $PAS_PROMETHEUS_LOCAL_URL > $PAS_PROMETHEUS_LOCAL_FILE
  if [ -f $PAS_PROMETHEUS_LOCAL_FILE ]; then
    # Wir übertragen die Daten aus der Gemstone/DB
    cat $PAS_PROMETHEUS_LOCAL_FILE | curl --data-binary @- $PAS_PROMETHEUS_PUSH_GATEWAY/metrics/job/$PAS_PROMETHEUS_JOB/instance/$PAS_PROMETHEUS_INSTANCE -u "$PAS_PROMETHEUS_LOGIN:$PAS_PROMETHEUS_PASSWORD"
    rm "$PAS_PROMETHEUS_LOCAL_FILE"
    echo "Prometheus-Gemstone-Daten geschickt"
  fi

  if [ -f "$PAS_PROMETHEUS_LOCAL_APPDATA_FILE" ]; then
    cat "$PAS_PROMETHEUS_LOCAL_APPDATA_FILE" | curl --data-binary @- $PAS_PROMETHEUS_PUSH_GATEWAY/metrics/job/$PAS_PROMETHEUS_APP_JOB/instance/$PAS_PROMETHEUS_INSTANCE -u "$PAS_PROMETHEUS_LOGIN:$PAS_PROMETHEUS_PASSWORD"
    rm "$PAS_PROMETHEUS_LOCAL_APPDATA_FILE"
    echo "Prometheus-App-Daten geschickt"
  fi

  if [ "$PAS_PROMETHEUS_USE_NODE_EXPORTER_URL" = "true" ]; then
    curl $PAS_PROMETHEUS_NODE_EXPORTER_URL > $PAS_PROMETHEUS_LOCAL_NODE_EXPORTER_FILE
    if [ -f $PAS_PROMETHEUS_LOCAL_NODE_EXPORTER_FILE ]; then
        cat $PAS_PROMETHEUS_LOCAL_NODE_EXPORTER_FILE | curl --data-binary @- $PAS_PROMETHEUS_PUSH_GATEWAY/metrics/job/$PAS_PROMETHEUS_SYSTEM_JOB/instance/$PAS_PROMETHEUS_INSTANCE -u "$PAS_PROMETHEUS_LOGIN:$PAS_PROMETHEUS_PASSWORD"
        rm "$PAS_PROMETHEUS_LOCAL_NODE_EXPORTER_FILE"
        echo "Prometheus-System-Daten geschickt"
      fi
  fi

#
# Wenn die Datei nicht mehr vorhanden ist -> sofort Abbruch
# ansonsten 60 sekunden warten, damit nicht zu schnell respawned wird
#
if [ ! -f $PAS_STONE_NAME ]; then
   exit 0
else
   sleep 60s
fi
done
