# PAS (PUM Application Stack)
## Backup der Datenbank
Um die Datenbank zu sichern, verwende ich immmer ein Full-Backup. Datenbanken bis 200GB sind so in 2 Stunden zu sichern (NVMe SSD). 
Eine einfache Sicherung führt man über den folgenden Befehl aus:
```
pas_cron_backup.sh <stone-name> <registry-name> <absolute-path-backup-directory>
```
Das System speichert das Backup dann in dem angegebenen Verzeichnis ab. 

An dem Namen des Backups kann man einiges ablesen:
```
2024_12_12_01_01-logid-733-gc_365-30605.gz
```
Folgende Informationen kann man dann von links nach rechts lesen:
* Das Backup wurde zur folgenden UTC Zeit durchgeführt: 12.12.2024 um 01:01 (Start des Backups)
* Zum Zeitpunkt des Backups wurde die tranlog-Datei mit der Nummer 733 genutzt.
* Der Name des Stone ist "gc_365"
* Und basiert auf der Gemstone/S Version 3.6.5

Das bedeutet, daß man für eine vollständige Wiederherstellung der Datenbank das Vollback benötigt und alle translog-Dateien ab der Nummer 733 (inklusive).

## Restore der Datenbank
### Zuerst die Vollbackup Datei
Wir beginnen die Wiederherstellung der Datenbank mit dem Anlegen einer neuen Datenbank "gc_365_new work":
```
pas_restore_from_fullbackup.sh <stone-name> <registry-name> <absolute-path-backup-file> <gemstone/s-version
```
also als Beispiel:
```
pas_restore_from_fullbackup.sh gc_365_new work /srv/db_backup/2024_12_12_01_01-logid-733-gc_365-30605.gz 3.6.5
```
### Danach die Translog-Dateien
Um auch die Änderungen NACH dem Zeitpunkt des Vollbackups zu erhalten, muß man noch die translog-Dateien einspielen, die nach dem Vollbackup beschrieben 
wurden. Die Nummer findet man im Dateinamen des Backups (s.o). Vor dem Einspielen  sollte man die notwendigen Dateien in das 
"tranlogs"-Verzeichnis der neu erstellten Datenbank kopieren. Danach ruft man den entsprechenden Befehl auf:
```
pas_restore_from_fullbackup.sh <stone-name> <registry-name>
```
also hier:
```
pas_restore_from_fullbackup.sh gc_365_new work
```
### Abschluß des Restore
Danach muß man den Restore-Vorgang beendet:
```
pas_restore_finish.sh <stone-name> <registry-name>
```
also hier:
```
pas_restore_finish.sh gc_365_new work
```
und die Datenbank ggfs. neu starten:
```
startStone.solo gc_365_new --registry=work
```

## Hinweis
Man kann ein Backup in die gleiche Datenbank zurückspielen, dann startet man den Vorgang mit:
```
pas_restore_data_from_fullbackup.sh <stone-name> <registry-name> <absolute-path-backup-file> <gemstone/s-version
```
also als Beispiel:
```
pas_restore_data_from_fullbackup.sh gc_365_new work /srv/db_backup/2024_12_12_01_01-logid-733-gc_365-30605.gz 3.6.5
```
Danach erfolgt das Einspielen der translog-Dateien und der Abschluß. Bei diesem Vorgehen ist es natürlich vorteilhaft,
daß die translog-Dateien bereits am richtigen Ort liegen.