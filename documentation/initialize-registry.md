# Arbeiten nach der Installation

Nach der Installation gibt es die Verzeichnisse "GsDevKit_stones" und "superDoit". 

```
drwxrwxr-x  3 mfeldtmann mfeldtmann 4096 Nov 26 15:39 '~'
drwxrwxr-x 14 mfeldtmann mfeldtmann 4096 Nov 26 15:21  GsDevKit_stones
drwxrwxr-x  2 mfeldtmann mfeldtmann 4096 Nov 26 15:41  stones
drwxrwxr-x  3 mfeldtmann mfeldtmann 4096 Nov 26 15:34  stones_data_home
drwxrwxr-x 15 mfeldtmann mfeldtmann 4096 Nov 26 15:30  superDoit
```

Zusätzlich lege ich noch ein leeres Verzeichnis "stones_data_home" an und lasse STONES_DATA_HOME auf dieses Verzeichnis zeigen. Weiterhin lege ich noch das Verzeichnis "stones" an, in der später die eigentlichen Daten liegen werden.

Um ein wengi Komfort genießen zu können, füge ich die folgenden Zeilen in meine .bashrc ein:

```
export PATH=~/superDoit/bin:~/GsDevKit_stones/bin:$PATH
export STONES_DATA_HOME=~/stones_data_home
```

## Definiton einer Registry

Um überhaupt arbeiten zu können, muß man sich erst einmal eine Umgebung definieren. Diese Umgebung nennt man "Registry". 

In meinem Fall nenne ich die Umgebung "cati". In dieser Umgebung werden ich später Datenbaken angelegen

```
createRegistry.solo cati
```

und man erhält die initiale Umgebung angezeigt:

```
GDKStonesRegistry {
        #name : 'cati',
        #parentRegistryName : 'cati',
        #parentRegistryPath : '$STONES_DATA_HOME/gsdevkit_stones/registry.ston',
        #stones : { },
        #sessions : { },
        #products : { },
        #projectSets : { },
        #templates : {
                'default_seaside' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_seaside.ston',
                'default_rowan3' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_rowan3.ston',
                'minimal_rowan' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_rowan.ston',
                'default_tode' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_tode.ston',
                'minimal_rowan3' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_rowan3.ston',
                'minimal_seaside' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_seaside.ston',
                'minimal' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal.ston',
                'default' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default.ston',
                'default_rowan' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_rowan.ston'
        }
}
```
Diese Information werden abgelegt und durch Tools bearbeitet in dem Verzeichnis: "$STONES_DATA_HOME/gsdevkit_stones/registry".

### Ort der Datenbanken

Erst einmal defineren wir, WO die Datenbanken (stones) überhaupt abgelegt werden:

```
registerStonesDirectory.solo --registry=cati --stonesDirectory=/home/mfeldtmann/stones
```
Das Skript trägt den Wert entsprechend ein und gibt das aktuelle Registry zurück:

```
GDKStonesRegistry {
        #name : 'cati',
        #parentRegistryName : 'cati',
        #parentRegistryPath : '$STONES_DATA_HOME/gsdevkit_stones/registry.ston',
        #stones : { },
        #stonesDirectory : '/home/mfeldtmann/stones',
        #sessions : { },
        #products : { },
        #projectSets : { },
        #templates : {
                'default_seaside' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_seaside.ston',
                'default_rowan3' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_rowan3.ston',
                'minimal_rowan' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_rowan.ston',
                'default_tode' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_tode.ston',
                'minimal_rowan3' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_rowan3.ston',
                'minimal_seaside' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_seaside.ston',
                'minimal' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal.ston',
                'default' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default.ston',
                'default_rowan' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_rowan.ston'
        }
```
### Ort der Datenbank-Produkte (Gemstone/S)

Nun müssen wir noch definieren, wo wir die herunterzuladenen Gemstone/S Produkte abgelegt werden sollen

```
registerProductDirectory.solo --registry=cati --productDirectory=/home/mfeldtmann/stones/gemstone
```

Das Skript trägt den Wert entsprechend ein und gibt das aktuelle Registry zurück:
```
GDKStonesRegistry {
        #name : 'cati',
        #parentRegistryName : 'cati',
        #parentRegistryPath : '$STONES_DATA_HOME/gsdevkit_stones/registry.ston',
        #stones : { },
        #stonesDirectory : '/home/mfeldtmann/stones',
        #sessions : { },
        #productDirectory : '/home/mfeldtmann/stones/gemstone',
        #products : { },
        #projectSets : { },
        #templates : {
                'default_seaside' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_seaside.ston',
                'default_rowan3' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_rowan3.ston',
                'minimal_rowan' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_rowan.ston',
                'default_tode' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_tode.ston',
                'minimal_rowan3' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_rowan3.ston',
                'minimal_seaside' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_seaside.ston',
                'minimal' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal.ston',
                'default' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default.ston',
                'default_rowan' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_rowan.ston'
        }
}
```

Erst mit diesen Informationen kann man eine Datenbank anlegen. Wenn ich also drei Datenbanken anlege:

```
createStone.solo --force --registry=cati --template=minimal cati 3.6.8
createStone.solo --force --registry=cati --template=minimal ctm 3.6.8
createStone.solo --force --registry=cati --template=minimal cis 3.6.8
```

wird die Registry entsprechend aussehen:

```
GDKStonesRegistry {
        #name : 'cati',
        #parentRegistryName : 'cati',
        #parentRegistryPath : '$STONES_DATA_HOME/gsdevkit_stones/registry.ston',
        #stones : {
                'ctm' : '$STONES_DATA_HOME/gsdevkit_stones/stones/cati/ctm.ston',
                'cati' : '$STONES_DATA_HOME/gsdevkit_stones/stones/cati/cati.ston',
                'cis' : '$STONES_DATA_HOME/gsdevkit_stones/stones/cati/cis.ston'
        },
        #stonesDirectory : '/home/mfeldtmann/stones',
        #sessions : { },
        #productDirectory : '/home/mfeldtmann/stones/gemstone',
        #products : {
                '3.6.8' : '/home/mfeldtmann/stones/gemstone/GemStone64Bit3.6.8-x86_64.Linux'
        },
        #projectSets : { },
        #templates : {
                'default_seaside' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_seaside.ston',
                'default_rowan3' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_rowan3.ston',
                'minimal_rowan' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_rowan.ston',
                'default_tode' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_tode.ston',
                'minimal_rowan3' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_rowan3.ston',
                'minimal_seaside' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_seaside.ston',
                'minimal' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal.ston',
                'default' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default.ston',
                'default_rowan' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_rowan.ston'
        }
```
Das sieht ja alles ganz schön kompliziert aus, hat aber gegenüber GsDevKit_home einen großen Vorteil: man kann die gleiche Datenbank-Produktversion in unterschiedlichen Lizenzen laufen lassen.
