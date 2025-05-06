# PAS (PUM Application Stack) - .Net Core 8.x mit PASLOG (Logging)
Ja, wir sind alle Gemstone/S Programmierer, aber hier noch ein paar Hinweise zur Installation und Handhabung
von .Net Core.

paslog basiert auf Programmen, die unter .Net Core geschrieben und es kommuniziert via RabbitMQ mit der Gemstone
Anwendung. Daher dieses Kapitel für .Net Core. Diese damit erzeugten Programme laufen unter den von mir genutzten 
Plattformen: Windows, Linux (X64) und Raspberry (aarch64).

## .Net Core

### Installation unter Ubuntu x86_64
Die Installation von .NetCore unter Ubuntu ist problemlos. Ich würde die aktuelle Version 8.x empfehlen.

### Installation unter aarch64 (Raspi 5)
Es gibt anscheinend keine Installationpakete für Raspi (64 Bit), also geht man auf die Seite https://dotnet.microsoft.com/en-us/download/dotnet/scripts 
und lädt das Installationsscript für die Runtime herunter und startet das Script. Es lädt die notwendigen Binaries herunter und
legt eine Verzeichnis ".dotnet" im HOME-Verzeichnis an und fügt das dem PATH an.

## PASLOG
PASLOG ist unter https://feldti-git.ddns.net/mf/pas_logging publiziert. Es benötigt eine relationale Datenbank PostgreSQL 
um zu funktionieren. Eine Visualisierung kann mittels Apache Superset gelingen.

PASLOG besteht aus dem einzigen Tool pas_psql_logger, das gleichzeitig Verwaltung und auch Service-Task ist. Das Tool legt die 
notwendigen Strukturen an, löscht ältere Daten und fügt LOG-Informationen, die über RabbitMQ geschickt werden.

Die notwendigen Konfigurationsdaten holt sich das System von einer lokalen "settings.txt" Datei, die bis zu 14 Einträgen enthalten kann:

    localhost       // RabbitMQ: Rechneradresse des RMQ-Servers
    test            // RabbitMQ: RMQ-Account 
    test            // RabbitMQ: RMQ-Passwort
    paslog          // RabbitMQ: Queue
    amq.topic       // RabbitMQ: Exchange, über den die Telegramme kommen
    paslog          // RabbitMQ: Zu nutzender RoutingKey
    /               // RabbitMQ: Virtual Host in RMQ, der zu benutzen ist
    localhost       // PostgreSQL: Adresse des Datenbank
    paslog          // PostgreSQL: Name der Datenbank
    paslog          // PostgreSQL: PSQL-Account
    paslog          // PostgreSQL: PSQL-Passwort
    5432            // PostgreSQL: PSQL-Port
    100             // PostgreSQL: Transaktionsgröße. Anzahl der in einem Schritt zu bearbeitenden Datensätze (von RMQ)
    40              // PostgreSQL: Min. Message-Level (hier: Error), für Nachrichten, die weitergeleitet werden
    discord         // RabbitMQ: RoutingKey für die weitergeleiteten Telegramme in den oben angegebenen Exchange unter neuen RoutingKey
    false           // Debug (on = true)

## PASLOG - Discord
Es gibt ein zusätzliches Projekt "pas_discord_logger" unter .NetCore C#, das die unter PASLOG weitergeleiteten Nachrichten abfängt und sie für Discord aufbereitet und 
in einen definierten Kanal unter discord postet.

Das Tool wird durch eine lokal vorliegende Datei "settings-discord.txt" konfiguriert:

    localhost       // RabbitMQ:Rechneradresse des RMQ-Servers
    test            // RabbitMQ: RMQ-Account
    test            // RabbitMQ: RMQ-Passwort
    paslog          // RabbitMQ: Queue
    amq.topic       // RabbitMQ: Exchange, über den die Telegramme kommen
    discord         // RabbitMQ: RoutingKey für weitergeleitete Telegramme
    /               // RabbitMQ: Virtual Host in RMQ, der zu benutzen ist
    token           // Discord: Token
    Channel-ID      // Discord: ID des Channels

Wenn man die Quelltexte nutzt, dann können diese Werte von Discord auch in die Quelltexte fest einprogrammiert werden.

### PASLOG - Installation
Sie können das Binary-Package benutzen und die Datei settings.txt entsprechend anpassen.

### PASLOG - PSQL Vorbereitungen
Zuerst müssen Sie zuerst eine Datenbank anlegen (Siehe Dokumentation psql). Benutzer, Datenbanknamen sollten den Einstellungen 
in settings.txt entsprechen.

Danach sollten Sie überprüfen, ob das Tool sich mit der PSQL-Datenbank überhaupt verbinden kann:

    dotnet ./pas_psql_logger.dll dbcheck

Und es geht weiter. Nun sollten Sie probieren, ob Sie auch die Strukturen in der Datenbank anlegen können:

    dotnet ./pas_psql_logger.dll dbcreate

Korrigieren Sie fehlende Berechtigungen bis es funktioniert.

Nun sollten Sie aktuelle Tabellenpartitionen für die Arbeit von paslog anlegen. Damit legen Sie Tabellenpartitionen für 
den aktuellen Monat und die folgenden und den beiden folgenden Monaten (also insgesamt 3 Monate) an.

    dotnet ./pas_psql_logger.dll dbmaint --months 3

Den letzten Befehl sollten Sie in einem CRON-Job eintragen und ihn 1x im Monat ausführen, damit immer genügend und aktuelle
Tabellenpartitionen vorliegen.

Und natürlich sollte man die Datenbank entsprechend auch pflegen und veraltete Partitionen wieder löschen. Also wieder einen
CRON-Job anlegen und ihn 1x im Monat ausführen lassen. Der Parameter "months" ist hier aber als: "älter" als n Monate zu 
interpretieren.

    dotnet ./pas_psql_logger.dll dbgc --months 3

Und nun einige Tests zum Einfüge von LOG-Meldungen direkt in die Datenbanken

    dotnet ./pas_psql_logger.dll dbmsg --msgcnt 100

Ein weiterer Test sendet CATI LOG Meldungen in die Datenbank

    dotnet ./pas_psql_logger.dll dbcatimsg --msgcnt 100

Und so löschen wir die Datenbankstrukturen wieder (bis auf die Datenbank):

    dotnet ./pas_psql_logger.dll dbdrop

### PASLOG - RabbitMQ Vorbereitungen

Nach der Vorbereitung der Datenbank, kommt man zu RabbitMQ. Auch hier sind alle notwendigen Daten in der "settings.txt" 
eingetragen worden. Zuerst müssen alle notwendigen Strukturen angelegt werden. Dies ist gleichzeitig ein
einfacher Kontaktversuch:

    dotnet ./pas_psql_logger.dll mqcreate

Danach werden erst einmal einfache Testnachrichten an RabbitMQ geschickt, diese sollte im UI Managements von RabbitMQ sichtbar sein.

    dotnet ./pas_psql_logger.dll mqmsg --msgcnt 10

Danach werden erst einmal einfache Testnachrichten an RabbitMQ geschickt, diese sollte im UI Managements von RabbitMQ sichtbar sein.

    dotnet ./pas_psql_logger.dll mqmsg --msgcnt 10

### PASLOG - Als Service starten

Und irgendwann sollte man das Tools auch als Service starten, der die Telegramme von RabbitMQ übernimmt und in die Datenbank speichert:

    dotnet ./pas_psql_logger.dll






