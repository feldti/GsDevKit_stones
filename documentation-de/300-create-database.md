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
Zur Zeit gibt es die folgenden Template-Datenbanken für PAS:

```
-rw-rw-r-- 1 mf mf  39450321 Nov 26 11:48 3.6.5-v80-20241126.gz
-rw-rw-r-- 1 mf mf  39408526 Nov 26 11:48 3.6.5-v81-20241126.gz
-rw-rw-r-- 1 mf mf  39341377 Nov 26 11:48 3.6.5-v90-20241126.gz
-rw-rw-r-- 1 mf mf  39304994 Nov 26 11:48 3.6.8-v80-20241126.gz
-rw-rw-r-- 1 mf mf  39373101 Nov 26 11:48 3.6.8-v81-20241126.gz
-rw-rw-r-- 1 mf mf  39373814 Nov 26 11:48 3.6.8-v90-20241126.gz
-rw-rw-r-- 1 mf mf  39826627 Nov 26 11:48 3.7.0-v80-20241126.gz
-rw-rw-r-- 1 mf mf  39712779 Nov 26 11:48 3.7.0-v81-20241126.gz
-rw-rw-r-- 1 mf mf  39711986 Nov 26 11:48 3.7.0-v90-20241126.gz
-rw-rw-r-- 1 mf mf 352633898 Nov 28 08:54 all.zip


```
Die Gemstone-Versionen 3.6.5, 3.6.8 und 3.7.0 werden unterstützt. Bei neuen Projekten würde ich die Versionen mit der v90 empfehlen. Eine Version kann man wie folgt herunterladen:

```
wget https://feldtmann.ddns.net/pas-template-databases/[dateiname]
```