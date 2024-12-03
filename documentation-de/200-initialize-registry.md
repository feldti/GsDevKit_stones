# Arbeiten nach der Installation

Nach der Installation gibt es 

- die Verzeichnisse "GsDevKit_stones" und "superDoit" unterhalb von git
- in "pas-templates" findet man Full-Backups von nutzbaren Datenbanken.
- das "products" Verzeichnis ist gedacht als Aufnahme für Femstone/S Produkt-Downloads - getrennt nach Registry
- in "stones" findet man letzten Endes die Datenbanken
- in "stones_data_home" findet man Verwaltungsinformationen.
 

```
drwxrwxr-x 4 mf mf 4096 Nov 27 08:16 git
drwxrwxr-x 2 mf mf 4096 Nov 27 08:16 pas-templates
drwxrwxr-x 3 mf mf 4096 Nov 27 08:16 products
drwxrwxr-x 3 mf mf 4096 Nov 27 08:17 stones
drwxrwxr-x 3 mf mf 4096 Nov 27 08:16 stones_data_home
```

Zusätzlich lege ich noch ein leeres Verzeichnis "stones_data_home" an und lasse STONES_DATA_HOME auf dieses Verzeichnis zeigen. Weiterhin lege ich noch das Verzeichnis "stones" an, in der später die eigentlichen Daten liegen werden.

Um ein wengi Komfort genießen zu können, füge ich die folgenden Zeilen in meine .bashrc ein:

```
export PATH=~/superDoit/bin:~/GsDevKit_stones/bin:$PATH
export STONES_DATA_HOME=~/stones_data_home
```

## Definiton einer Registry

Um überhaupt arbeiten zu können, muß man sich erst einmal eine Umgebung definieren. Diese Umgebung nennt man "Registry". 
Eine dieser Registry ist bereits mit der Installation angelegt worden: "work".

In den folgenden Abschnitten wird gezeigt, wie man eine Registry "cati" anlegt.

### Anlage via Skript

Es gibt ein Skript, das alles im Rahmen von PAS machen kann:

```
pas_create_registry.sh cati
```
Das legt die Registry Struktur an und definiert die Orte für die stones und die heruntergeladenen Gemstone/S Produkte.

### Manuelle Schritte 

Man kann das auch manuell machen. Zuerst die Registry:

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

Wo sollen die Datenbankdaten liegen:

```
registerStonesDirectory.solo --registry=cati --stonesDirectory='$PAS_HOME_PATH/cati/stones'
```
Das Skript trägt den Wert entsprechend ein und gibt das aktuelle Registry zurück:

```
GDKStonesRegistry {
        #name : 'cati',
        #parentRegistryName : 'cati',
        #parentRegistryPath : '$STONES_DATA_HOME/gsdevkit_stones/registry.ston',
        #stones : { },
        #stonesDirectory : '/home/mfeldtmann/pas/cati/stones',
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
registerProductDirectory.solo --registry=cati --productDirectory='$PAS_HOME_PATH/cati/products'
```

Das Skript trägt den Wert entsprechend ein und gibt das aktuelle Registry zurück:
```
GDKStonesRegistry {
        #name : 'cati',
        #parentRegistryName : 'cati',
        #parentRegistryPath : '$STONES_DATA_HOME/gsdevkit_stones/registry.ston',
        #stones : { },
        #stonesDirectory : '/home/mfeldtmann/pas/cati/stones',
        #sessions : { },
        #productDirectory : '/home/mfeldtmann/pas/cati/products',
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

### Ort der TodeHome Verzeichnisses-Produkte (Gemstone/S)

Auf dieses Verzeichnis wird bei einigen Templates (z.B. default_seaside) zugegriffen. Daher lieber anlegen. Eigentlich möchte 
ich das nicht machen, aber bei "default*" templates scheint das benötigt zu werden.

```
registerTodeSharedDir.solo --registry=work --todeHome=$PAS_HOME_PATH/cati/tode  --populate
```

Das Skript trägt den Wert entsprechend ein und gibt das aktualisierte Registry zurück:
```
GDKStonesRegistry {
        #name : 'cati',
        #parentRegistryName : 'cati',
        #parentRegistryPath : '$STONES_DATA_HOME/gsdevkit_stones/registry.ston',
        #stones : { },
        #stonesDirectory : '/home/mfeldtmann/pas/cati/stones',
        #sessions : { },
        #productDirectory : '/home/mfeldtmann/pas/cati/products',
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
        #stonesDirectory : '/home/mfeldtmann/pas/cati/stones',
        #sessions : { },
        #productDirectory : '/home/mfeldtmann/pas/cati/products',
        #products : {
                '3.6.8' : '/home/mfeldtmann/pas/cati/products/GemStone64Bit3.6.8-x86_64.Linux'
        },
        #projectSets : { },
        #templates : {
                'default_seaside' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_seaside.ston',
                'default_rowan3' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_rowan3.ston',
                'minimal_rowan' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_rowan.ston',
                'default_tode' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_tode.ston',
                'minimal_rowan3' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_rowan3.ston',
                'minimal_seaside' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal_seaside.ston',
                'pas_seaside' : '$STONES_DATA_HOME/gsdevkit_stones/templates/pas_seaside.ston',
                'minimal' : '$STONES_DATA_HOME/gsdevkit_stones/templates/minimal.ston',
                'default' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default.ston',
                'default_rowan' : '$STONES_DATA_HOME/gsdevkit_stones/templates/default_rowan.ston'
        }
```
Das sieht ja alles ganz schön kompliziert aus, hat aber gegenüber GsDevKit_home einen großen Vorteil: man kann die gleiche Datenbank-Produktversion in unterschiedlichen Lizenzen laufen lassen.
