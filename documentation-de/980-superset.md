# PAS (PUM Application Stack) - Apache Superset
Ja, wir sind alle Gemstone/S Programmierer, aber hier noch ein paar Hinweise zur Installation und Handhabung
von Apache Superset

Apache Superset wird genutzt für Visualisierungen von Daten, die in PostgreSQL abgelegt wurden. Um die Sicherheitsbedenken 
zu reduzieren, empfehle ich die Installation von PostgreSQL, .Net Core für paslog und Apache Superset auf einem Rechner.

Apache Superset ist ein Softwaremonster, daß man immer bändigen muß. Native Installation erscheint kaum möglich, daher 
erfolgt die Installation via docker oder kubernetes.

Die in Apache Superset definierten Dashboarde werden in der JS-UI als iframe eingebunden - aber auch das ist nicht immer einfach.

## Apache Superset Installation
Zuerst einmal: Einfach starten. 

### Auschecken aus github
Zuerst einmal eine Kopie lokal anlegen:

    git clone https://github.com/apache/superset

### Bauen immer auf Basis von den lokalen Konfiguratonsdaten
Wir starten das Gesamtsystem auf Basis der lokalen Konfiguration

    docker compose -f docker-compose-non-dev.yml up

### Lokalen Konfiguration abändern
Wir beginnen nun die Konfiguration abzuändern. Dazu verändern wir die Datei unter
    ./superset/docker/pythonpath_dev/superset_config.py
und lassen die globale config.py unverändert. Bei den Änderungen muß man immer darauf achten, daß ein Attribut
auch nur 1x (!) in superset_config.py genutzt wird - sonst verliert man den Überblick oder man wundert sich, daß
keine Änderungen eintreten (alles schon passiert).

### Embedden von Dashboards freischalten
Wenn man die Dashboards aus Superset in einer eigenen Anwendung einbinden möchte, dann muß man das Feature erst 
einmal freischalten. Dazu ver#ndert man den Eintrag "FEATURE_FLAGS" in der Datei "superset_config.py" wie folgt ab:

    FEATURE_FLAGS = {"ALERT_REPORTS": True, "EMBEDDED_SUPERSET": True}

Dadurch wird der Menüeintrag "Enbed Dashboard" beim Dashboard (sichtbar im Nicht-Edit Modus) im Apache Superset freigeschaltet und man kommt an die UUID des Dashboards ran, die
man mit dem SDK benutzen kann.

## Sichern/Export von Dashboard
Man kann Dashboard, Charts und Datasets exportieren (download dann per zip) und in ein neues Superset importieren. Dazu
sollte man auch das Passwort einer eventuellen Datenbankanbindung notieren. Dieses wird beim Import nämlich abgefragt.

## Infrastruktur der Dashboards in der Anwendung
Apache Superset liefert von sich aus alle Voraussetzungen, um den Zugang zu Dashboard zu ermöglichen bzw. zu verhindern. Allerdings möchte 
man diese Funktionalität lieber in seinem Anwendungsprogramm haben.

Eine entsprechende Konfigurationsmöglichkeit sollte auch im Anwendungsprogramm enthalten sein. Dazu müsste von jedem Domainobjekt
eine 1:n Assoziation zu den möglichen/erlaubten Dashboards des Domain-Objektes abgelegt sein (z.B. vom Customer aus oder von einem
Projekt aus).

## Apache Superset Anbindung
Die Nutzbarmachung von Superset erfolgt in mehreren Bereichen
* Ein Hintergrund-Task muß das Benutzer-Token regelmäßig erneuern und auffrischen und dann in der Datenbank speichern (Brute-Force Methode).
* In den Oberflächen muß die UI mittels API-Call vor jeder Nutzung das Token von Gemstone  holen und im IFrame verarbeiten

Damit ist die Basisarbeit bereits getan. Nun kann man noch weitere API-Calls definieren:
* Liste der nutzbaren vorhandenen Dashboard (mit interner UUID), CRUD Call
* Zugriffssteuerung auf die vorherigen Liste

