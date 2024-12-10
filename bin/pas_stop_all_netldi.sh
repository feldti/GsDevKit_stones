#!/bin/bash

# Debug-Modus aktivieren
DEBUG=1

# Debugging-Funktion
debug() {
    if [[ $DEBUG -eq 1 ]]; then
        echo "[DEBUG] $1"
    fi
}

# Suche nach laufenden NetLDI-Prozessen
debug "Suche nach laufenden NetLDI-Prozessen..."
netldi_processes=$(ps axf | grep "netldid" | grep -v "grep")

if [[ -z "$netldi_processes" ]]; then
    echo "Keine laufenden NetLDI-Prozesse gefunden."
    exit 0
fi

echo "Gefundene NetLDI-Prozesse:"
echo "$netldi_processes"

# Verarbeite jeden NetLDI-Prozess
echo "$netldi_processes" | while read -r process_line; do
    # Extrahiere den vollständigen Pfad des Prozesses
    process_path=$(echo "$process_line" | awk '{for(i=NF;i>0;i--) if ($i ~ /netldid/) {print $i; break}}')

    # Extrahiere den Namen der Registry aus dem Pfad
    registry=$(echo "$process_path" | awk -F/products '{print $1}' | awk -F/ '{print $NF}')

    # Extrahiere den Stein-Namen aus der Prozesszeile
    stone_name=$(echo "$process_line" | awk '{for(i=NF;i>0;i--) if ($i ~ /_ldi$/) {print $i; break}}' | sed 's/_ldi$//')

    if [[ -n "$stone_name" && -n "$registry" ]]; then
        debug "Gefundener NetLDI-Prozess für Stein $stone_name in Registry $registry"
        echo "Beende NetLDI für Stein $stone_name in Registry $registry..."
        stopNetldi.solo "$stone_name" --registry="$registry"
        if [[ $? -eq 0 ]]; then
            echo "NetLDI für $stone_name erfolgreich gestoppt."
        else
            echo "Fehler beim Beenden von NetLDI für $stone_name."
        fi
    else
        debug "Konnte Stein oder Registry aus Prozess nicht extrahieren: $process_line"
    fi
done
