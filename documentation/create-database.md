# Anlegen einer Datenbank

## Anlegen ohne PAS
Um eine Datenbank normal anzulegen, sollte man das folgend Skript ausführen:

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


