# Anlegen einer Datenbank

## Anlegen ohne PAS
Um eine Datenbank normal anzulegen, sollte man das folgende Skript ausführen:

- createStone.solo --force --registry=[registryname] --template=[template_name] [stoneName] [gemstone-version]

Dabei liegen z.Z. die folgenden Templates vor:

- default_seaside
- default
- minimal_seaside
- minimal

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
Zur Zeit gibt es die folgenden Template-Datenbanken für PAS:

```
-rw-rw-r-- 1 mf mf 39341377 Nov 26 11:47 2024_11_26_09_01-logid-3-template-3.6.5-v90-30605.gz
-rw-rw-r-- 1 mf mf 39373814 Nov 26 11:47 2024_11_26_09_08-logid-3-template-3.6.8-v90-30608.gz
-rw-rw-r-- 1 mf mf 39711986 Nov 26 11:47 2024_11_26_09_50-logid-3-template-3.7.0-v90-30700.gz
-rw-rw-r-- 1 mf mf 39712779 Nov 26 11:47 2024_11_26_09_56-logid-3-template-3.7.0-v81-30700.gz
-rw-rw-r-- 1 mf mf 39373101 Nov 26 11:47 2024_11_26_10_04-logid-3-template-3.6.8-v81-30608.gz
-rw-rw-r-- 1 mf mf 39408526 Nov 26 11:47 2024_11_26_10_11-logid-3-template-3.6.5-v81-30605.gz
-rw-rw-r-- 1 mf mf 39450321 Nov 26 11:47 2024_11_26_10_18-logid-3-template-3.6.5-v80-30605.gz
-rw-rw-r-- 1 mf mf 39304994 Nov 26 11:47 2024_11_26_10_26-logid-3-template-3.6.8-v80-30608.gz
-rw-rw-r-- 1 mf mf 39826627 Nov 26 11:47 2024_11_26_10_31-logid-3-template-3.7.0-v80-30700.gz
```
Die Gemstone-Versionen 3.6.5, 3.6.8 und 3.7.0 werden unterstützt. Bei neuen Projekten würde ich die Versionen mit der v90 empfehlen. Eine Version kann man wie folgt herunterladen:

```
wget https://feldtmann.ddns.net/pas-template-databases/[dateiname]
```