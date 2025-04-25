# PAS (PUM Application Stack) - Apache2
Ja, wir sind alle Gemstone/S Programmierer, aber hier noch ein paar Hinweise zur Installation und Handhabung
von Apache2.

## Installation des Paketes
Wir schalten Apache2 vor Gemstone/S. Die gesamte HTTP(s) oder WebSocket Kommunikation läuft durch den Apache2.

Die Installation erfolgt mit dem folgenden Befehl:

    sudo apt-get install apache2

## Installation der notwendigen Module
Für die Konfigurationseinträge benötigen wir einige zusätzliche Module für den Apache2, die wir so installieren:

    sudo a2enmod slotmem_shm slotmen_plain rewrite proxy proxy_http proxy_wstunnel proxy_balancer lbmethod_byrequests lbmethod_heartbeat lbmethod_bybusyness heartbeat heartmonitor ssl

## Neustart ds Apache
Hiermit starten wir den Apache2 neu:

    sudo systemctl restart apache2

## Konfigurationseintrag für eine Gemstone/S Anwendung

Unter app-template/app-apache finden wir eine Datei "000-default.conf" mit den notwendigen Einträge für eine Beispielanwendung,
die dann entsprechend angepasst werden müssen.