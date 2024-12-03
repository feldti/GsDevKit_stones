# PAS (PUM Application Stack)

PAS-Anwendungen sind API-orientierte Anwendungen, die auf eine bestimmte Umgebung aufbauen:

- Datenbank Gemstone/S auf Basis eines Seaside Image
- Datenbank PostgreSQL
- PDF Bibliothek
- RabbitMQ

PAS-Anwendungen sind KEINE Seaside Anwendungen, sondern gehen von einer externen Javascript-UI aus, 
die über eine RPC-HTTP Schnittstelle mit der Datenbank kommuniziert. 



## PAS Installation

Im "bin" Verzeichnis von GsDevKit_stones findet man ein Skript "pas_install_env.sh" (damit es revisioniert ist). Eine 
aktuelle Version Skript ist auch unter "https://feldtmann.ddns.net/pas-project/pas_install_env.sh" zu finden. Das 
Skript installiert das GsDevKit_stones und baut die notwendige Struktur für PAS Anwendungen auf.

Dieses Skript führt man an der Stelle aus, wo die Installation stattfinden soll.

Es erstellt ein "pas" Verzeichnis und installiert alle notwendigen Softwaresysteme unterhalb dieses Verzeichnisses. 

Mit der Installation werden auch vorerstellte PAS-Datenbanken heruntergeladen - in verschiedenen Gemstone/S Versionen.

Es legt auch ein erstes Registry mit dem Namen "work" an. Man könnte also sofort loslegen und unter dieser Registry Datenbanken anlegen.

Am Ende des Skriptes werden Einträge ausgegeben, die man in seine lokale .bashrc aufnehmen sollte.