# GsDevKit_stones

In addition to the original project I will also add several shell script doing useful work during development or during runtime. All of these shell file from me are starting with "pas_ ....". 
Diese Skripte benutzen eine Methode, um alte sh-Skripte auf der GsDevKit_home Umgebung ablaufen lassen zu können.

| Scriptname              | Kurzbeschreibung                                                                                                                    |
|-------------------------|-------------------------------------------------------------------------------------------------------------------------------------|
| pas_backup_registry.sh  | Sichert das registry-Verzeichnis (§STONES__DATA_HOME) in eine tgz Datei, mit Zeitstempel im Name, in das Verzeichnis $PAS_HOME_PATH |
| pas_create_pas_stone.sh |                                                                                                                                     |
| pas_create_registry.sh  |                                                                                                                                     |
| pas_create_stone.sh     |                                                                                                                                     |
| pas_cron_backup.sh      |                                                                                                                                     |
| pas_cron_fastmark.sh    |                                                                                                                                     |
| pas_cron_gc.sh          |                                                                                                                                     |
| pas_cron_reclaimall.sh  |                                                                                                                                     |
| pas_datadir.sh          |                                                                                                                                     |
| pas_install_env.sh      |                                                                                                                                     |
| pas_load_base_postgresql.sh | Hilfsscript, um das PostgreSQLConnect Package zu laden                                                                              |
| pas_load_base_rabbitmq.sh |                                                                                                                                     |
| pas_load_pas_runtime.sh |                                                                                                                                     |
| pas_load_report4pdf.sh |                                                                                                                                     |
| pas_migrate.sh |                                                                                                                                     |
| pas_migrate_clearhistory.sh |                                                                                                                                     |
| pas_migrate_collect.sh |                                                                                                                                     |
| pas_migrate_pageorder.sh |                                                                                                                                     |
| pas_netldi_list.sh |                                                                                                                                     |
| pas_os_timezone.sh |                                                                                                                                     |
| pas_pageaudit.sh |                                                                                                                                     |
| pas_prepare_seaside_stone.sh |                                                                                                                                     |
| pas_publish_openapi.sh |                                                                                                                                     |
| pas_restore_from_fullbackup.sh |                                                                                                                                     |
| pas_snapshot.sh |                                                                                                                                     |
| pas_stones_list.sh |                                                                                                                                     |
| pas_stop_all_netldi.sh |                                                                                                                                     |
| pas_stop_all_stones.sh |                                                                                                                                     |
| pas_topaz_list.sh |                                                                                                                                     |
| pas_update_gemstone.sh |                                                                                                                                     |
| startStone.solo |                                                                                                                                     |
| stopStone.solo |                                                                                                                                     |
| startNetldi.solo |                                                                                                                                     |
| stopNetldi.solo |                                                                                                                                     |
| gslist.solo |                                                                                                                                     |


### pas_cron_backup.sh

Dieses Skript führt ein Backup einer eventuell laufenden Gemstone/S-Datenbank durch. 
Der Aufruf kann mit einem absoluten Pfad erfolgen und es sollte alle notwendigen Parameter so setzen, daß es aus einer CRON Umgebung aufgerufen werden kann.

Der Aufruf erfolgt auf der CommandLine so:

pas_cron_backup.sh [stoneName] [registryName] [backup-directory] [stonesDataHome]

mit

- stoneName = Name der Datenbank
- registryName = Name der Registry, in der der Stone definiert wurde
- backup-directory = Verzeichnis, in dem das Backup abgelegt werden sollte
- stonesDataHome = Verzeichnis, das als $STONES_DATA_HOME gilt

```
# Edit this file to introduce tasks to be run by cron.
#
# Each task to run has to be defined through a single line
# indicating with different fields when the task will be run
# and what command to run for the task
#
# To define the time you can provide concrete values for
# minute (m), hour (h), day of month (dom), month (mon),
# and day of week (dow) or use '*' in these fields (for 'any').#
# Notice that tasks will be started based on the cron's system
# daemon's notion of time and timezones.
#
# Output of the crontab jobs (including errors) is sent through
# email to the user the crontab file belongs to (unless redirected).
#
# For example, you can run a backup of all your user accounts
# at 5 a.m every week with:
# 0 5 * * 1 tar -zcf /var/backups/home.tgz /home/
#
# For more information see the manual pages of crontab(5) and cron(8)
#
# m h  dom mon dow   command
00 02 * * * /home/GsDevKit_stones/bin/pas_cron_backup.sh gs_366 test /home/mf/backup-dbs /home/mf/stones_data_home
```
Der Dateiname des Backup wird so erzeugt:

2024_11_25_15_33-logid-3-gs_368-30608.gz

und beinhaltet:

- Uhrzeit des Backup (Start)
- Die ID der letzten zu berücksichtigenden translog-Datei
- Der Name des Stones
- Die Versionsnummer der benutzten Gemstome/S Version
## pas_cron_mark.sh

Dieses Skript führt ein markForCollection durch. Das Skript kann in einer CRON-Umgebung ablaufen.

Der Aufruf erfolgt auf der CommandLine so:

pas_cron_mark.sh [stoneName] [registryName] [stonesDataHome]

mit

- stoneName = Name der Datenbank
- registryName = Name der Registry, in der der Stone definiert wurde
- stonesDataHome = Verzeichnis, das als $STONES_DATA_HOME gilt


## pas_cron_reclaimall.sh

Dieses Skript führt ein reclaimAll durch. Das Skript kann in einer CRON-Umgebung ablaufen.

Der Aufruf erfolgt auf der CommandLine so:

pas_cron_reclaimall.sh [stoneName] [registryName] [stonesDataHome]

mit

- stoneName = Name der Datenbank
- registryName = Name der Registry, in der der Stone definiert wurde
- stonesDataHome = Verzeichnis, das als $STONES_DATA_HOME gilt

### pas_cron_backup.sh

Dieses Skript verhält sich wie pas_cron_backup.sh, jedoch wird vorher noch ein MarkCollection, dann ein ReclaimAll und danach erst das backup durchgeführt.

### pas_topaz_list.sh

Dieses Skript listet alle topaz-Prozesse auf, die in einer spezifischen Datenbank arbeiten. 

Der Aufruf erfolgt auf der CommandLine so:

pas_topaz_list.sh [stoneName]

mit

- stoneName = Name der Datenbank

Ausgabe könnte so aussehen:
````
Topaz PID       Stone Name      Topaz Name                              Max Memory (MB)
2938892         ctm             pas_normal.0_20000                      100000
2938894         ctm             pas_normal.1_20010                      100000
2938939         ctm             pas_normal.2_20020                      100000
2938902         ctm             pas_normal.3_20030                      100000
2938966         ctm             pas_normal.4_20040                      100000
2938965         ctm             pas_extdb.0_20400                       50000
2938920         ctm             pas_extdb.1_20410                       50000
2938970         ctm             pas_extdb.2_20420                       50000
2938992         ctm             pas_extdb.3_20430                       50000
2938930         ctm             pas_extdb.4_20440                       50000
2938999         ctm             ctmSserverEventBusMaintainer                    50000
2938927         ctm             ctmSessionActivity                      50000
2568784         ctm             cis_superset_token                      50000
````
Ausgegeben werden also:

- Prozess-ID des topaz Prozessen
- Name der Datenbank, auf der der Prozess arbeitet
- Der Prozessname, um zu verstehen, was der Prozess macht
- Der max. vorgegebene Speicherbedarf des Prozesses

### pas_stones_list.sh
Dieses Skript gibt alle laufenden Datenbank-Daemon Prozessen aus (alle) und ob ein dazu passender NetLDI Prozess besteht und wenn ja: auf welchem Port dieser Prozess lauscht.

Der Aufruf erfolgt auf der CommandLine so:

pas_stones_list.sh


Ausgabe könnte so aussehen:
````
Stone Name      NetLDI Running  NetLDI Port
gs_366          Yes             43241
gs_368          Yes             42731
````

### pas_netldi_list.sh
Dieses Skript gibt Informationen über alle laufenden NetLDI Prozess aus.
Der Aufruf erfolgt auf der CommandLine so:

pas_netldi_list.sh


Ausgabe könnte so aussehen:
````
Version Port    NetLDI                  Owner                   Database Running
3.6.6   43241   gs_366_ldi              mf                      Yes
3.6.8   42731   gs_368_ldi              mf                      Yes
3.7.1   39861   gs_371_ldi              mf                      No
3.7.0   36265   gs_370_ldi              mf                      No

````

### pas_restore.sh
Mit diesem Skript kann man ein Datenbank-Voll-Backup einspielen (d.h. ohne die Transaktions-Logs). Es ist auch der Weg, um eine PAS-Template-Datenbank einzuspielen.
Der Aufruf erfolgt auf der CommandLine so:

pas_restore.sh [stoneName] [registry] [path to backup]

Nachdem dieses Skript durchgelaufen ist, muß man noch mit pas_finish_restore.sh das Einspielen beenden.

### pas_finish_restore.sh
Mit diesem Skript beendet man das Einspielen des Backups
Der Aufruf erfolgt auf der CommandLine so:

pas_finish_restore.sh [stoneName] [registry]

Danach sollte man zur Sicherheit die Datenbank anhalten (stopStone.solo) und erneut starten (startStone.solo)


## pas_datadir.sh

Hilfsscript zur Ermittlung, wo die Datenbank überhaupt ihre Daten ablegt. 
