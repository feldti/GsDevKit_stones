#!/bin/bash

# Debug-Modus aktivieren
DEBUG=0

# Debugging-Funktion
debug() {
    if [[ $DEBUG -eq 1 ]]; then
        echo "[DEBUG] $1"
    fi
}

# Umgebungsvariable prüfen
if [[ -z "$STONES_DATA_HOME" ]]; then
    echo "Error: STONES_DATA_HOME ist nicht definiert."
    exit 1
fi
debug "STONES_DATA_HOME ist definiert: $STONES_DATA_HOME"

# Verzeichnis der Registries
registry_dir="$STONES_DATA_HOME/gsdevkit_stones/registry"
stones_dir="$STONES_DATA_HOME/gsdevkit_stones/stones"
debug "Registry-Verzeichnis: $registry_dir"
debug "Stones-Verzeichnis: $stones_dir"

# Header für die Ausgabe
printf "%-20s %-15s %-10s %-15s %-25s\n" "Database Name" "Running" "NetLDI Port" "Version" "Registry"
printf "%-20s %-15s %-10s %-15s %-25s\n" "--------------------" "---------------" "----------" "---------------" "-------------------------"

# Alle Registry-Dateien durchlaufen
for registry_file in "$registry_dir"/*.ston; do
    if [[ ! -f "$registry_file" ]]; then
        debug "Keine Registry-Dateien gefunden."
        continue
    fi

    # Registry-Name aus Dateinamen extrahieren
    registry_name=$(basename "$registry_file" .ston)
    debug "Verarbeite Registry: $registry_name (Datei: $registry_file)"

    # Variablen für die Verarbeitung
    in_stones_block=0
    stones_list=()

    # Datei Zeile für Zeile lesen
    while IFS= read -r line; do
        # Starte die Verarbeitung ab #stones
        if [[ "$line" =~ "#stones" ]]; then
            in_stones_block=1
            debug "Start des #stones-Blocks gefunden."
            continue
        fi

        # Beende die Verarbeitung bei }
        if [[ "$line" =~ "}" ]] && [[ $in_stones_block -eq 1 ]]; then
            in_stones_block=0
            debug "Ende des #stones-Blocks gefunden."
            break
        fi

        # Verarbeite Zeilen im #stones-Block
        if [[ $in_stones_block -eq 1 ]]; then
            if [[ "$line" =~ \'([^\']+)\' ]]; then
                stone="${BASH_REMATCH[1]}"
                stones_list+=("$stone")
                debug "Gefundener Stein: $stone"
            fi
        fi
    done < "$registry_file"

    # Prüfen, ob Steine gefunden wurden
    if [[ ${#stones_list[@]} -eq 0 ]]; then
        debug "Keine Steine in Registry $registry_name gefunden. Überspringe."
        continue
    fi

    # Ausgabe der Steine
    for stone in "${stones_list[@]}"; do
        # Prüfen, ob der Stein läuft
        stone_process=$(ps axf | grep -w "stoned $stone" | grep -v "grep")
        if [[ -n "$stone_process" ]]; then
            running="Yes"
        else
            running="No"
        fi

        # Prüfen, ob ein NetLDI-Prozess läuft, der zu diesem Stein gehört
        netldi_process=$(ps axf | awk -v stone="${stone}_ldi" '$0 ~ "netldid" && $0 ~ stone {print}')
        if [[ -n "$netldi_process" ]]; then
            netldi_port=$(echo "$netldi_process" | grep -oP "(?<=-P)\\d+")
        else
            netldi_port="N/A"
        fi

        # Version aus der Stein-Datei extrahieren
        stone_file="$stones_dir/$registry_name/$stone.ston"
        if [[ -f "$stone_file" ]]; then
            gemstone_version=$(grep -oP "(?<=#gemstoneVersionString : ')[^']+" "$stone_file")
            if [[ -n "$gemstone_version" ]]; then
                debug "Version für $stone aus Datei $stone_file: $gemstone_version"
            else
                gemstone_version="N/A"
                debug "Keine Version gefunden in $stone_file"
            fi
        else
            gemstone_version="N/A"
            debug "Stein-Datei fehlt: $stone_file"
        fi

        # Ausgabe der Informationen
        printf "%-20s %-15s %-10s %-15s %-25s\n" \
            "$stone" "$running" "$netldi_port" "$gemstone_version" "$registry_name"
    done
done
