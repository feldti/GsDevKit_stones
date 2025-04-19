# Anlegen einer Datenbank

## Anlegen ohne PAS
Um eine Datenbank normal anzulegen, sollte man das folgende Skript ausführen:

- createStone.solo --force --registry=[registryname] --template=[template_name] [stoneName] [gemstone-version]

Dabei liegen z.Z. die folgenden Templates vor:

- default_seaside
- default
- minimal_seaside
- minimal

und eben auch:

- pas_seaside

Letztes ist ein minimal_seaside, aber mit der Struktur von default_seaside. Das bedeutet aber auchu, daß es KEINE PAS Datenbank ist.

Es gibt noch weitere Templates auf Rowan basierend

## Anlegen für Nutzung mit PAS
Um eine Datenbank anzulegen, die ein PAS Template benutzt, sollte man erst einmal eine Datenbank ohne PAS anlegen für die gewünschte Gemstone/S Version und bereits mit dem entsprechenden Namen.

- createStone.solo --force --registry=[registryname] --template=[template_name] [stoneName] [gemstone-version]

In einem zweiten Schritt wird dann ein PAS-Template-Backup in die neu erstellte Datenbank eingespielt:

- pas_restore.sh [stoneName] [registryname] [path to backup]
- pas_finish_restore.sh [stoneName] [registryname]
- stopStone.solo --registry=[registryname] [stoneName]
- startStone.solo --registry=[registryname] [stoneName]

### PAS Template Datenbanken
Zur Zeit gibt es noch keine Template-Datenbanken. Wenn man Template-Datenbanken anlegen möchte, dann muss man berücksichtigen, 
daß die Anbindungen an RabbitMQ und PostgreSQL für die jeweilige Architektur angeboten werden müssen, da diese dann
Pfade zu externen Bibliotheken beinhalten ... die je nach Architektur unterschiedlich sind

```



```
Die Gemstone-Versionen 3.6.5, 3.6.8 und 3.7.0 werden unterstützt. Bei neuen Projekten würde ich die Versionen mit der v100 empfehlen. Eine Version kann man wie folgt herunterladen:

```
wget https://feldtmann.ddns.net/pas-template-databases/[dateiname]
```

### PAS Template Datenbanken erzeugen
Um ein eigene Template-Datenbank (auf Basis der Runtime v100 und der Gemstone Version 3.7.2) zu erzeugen, sollte man das folgende Skript starten:
```
pas_create_pas_stone.sh <stoneName> <registryName> 3.7.2 v100
```
Dann erhält man eine Datenbank, die als Template dienen kann. Diese kann man dann sichern und das Backup als Template zur Verfügung stellen.

### PAS Template Datenbanken - Grober Überblick über den Inhalt einer Template Datenbank

< to be written >