#!/bin/bash

# Debug-Modus aktivieren
DEBUG=1

# Debugging-Funktion
debug() {
    if [[ $DEBUG -eq 1 ]]; then
        echo "[DEBUG] $1"
    fi
}

# Suche nach laufenden Stone-Prozessen
debug "Suche nach laufenden Stone-Prozessen..."
stone_processes=$(ps axf | grep "stoned" | grep -v "grep")

if [[ -z "$stone_processes" ]]; then
    echo "Keine laufenden Stones gefunden."
    exit 0
fi

echo "Gefundene Stone-Prozesse:"
echo "$stone_processes"

# Verarbeite jeden Stone-Prozess
echo "$stone_processes" | while read -r process_line; do
    # Extrahiere den vollständigen Pfad des Prozesses
    process_path=$(echo "$process_line" | awk '{for(i=NF;i>0;i--) if ($i ~ /stoned$/) {print $i; break}}')

    # Extrahiere den Stein-Namen (erstes Argument nach "stoned")
    stone_name=$(echo "$process_line" | awk '{for(i=1;i<=NF;i++) if ($i ~ /stoned$/) {print $(i+1); break}}')

    # Extrahiere den Registry-Namen aus dem Pfad
    registry=$(echo "$process_path" | awk -F/products '{print $1}' | awk -F/ '{print $NF}')

    if [[ -n "$stone_name" && -n "$registry" ]]; then
        debug "Gefundener Stone-Prozess für $stone_name in Registry $registry"
        echo "Beende Stone $stone_name in Registry $registry..."
        stopStone.solo -i "$stone_name" --registry="$registry"
        if [[ $? -eq 0 ]]; then
            echo "Stone $stone_name erfolgreich gestoppt."
        else
            echo "Fehler beim Beenden von Stone $stone_name."
        fi
    else
        debug "Konnte Stein oder Registry aus Prozess nicht extrahieren: $process_line"
    fi
done
