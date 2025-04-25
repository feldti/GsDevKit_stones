# PAS (PUM Application Stack) - PostgreSQL
Ja, wir sind alle Gemstone/S Programmierer, aber hier noch ein paar Hinweise zur Installation und Handhabung
von PostgreSQL.

Prinzipiell würde ich immer empfehlen, eine aktuelle Version von RabbitMQ zu benutzen und zu installieren. 

Außerdem würde ich empfehlen, erst einmal mit den Standardaccounts (guest/guest) lokal entwickeln. Später kann man https etc. 
hinzufügen. Die notwendigen Eintragungen werden in PAS in der credentials.sh getätigt.

## Installation des Paketes - Client
Wenn wir einen PostgreSQL Server benutzen wollen, der auf einem anderen Rechner liegt, dann benötigen wir lokal 
das Entwicklungspaket für PostgreSQL - darin enthalten ist auch die Shared-Library, die Gemstone/S benutzt.

Die Installation erfolgt mit dem folgenden Befehl (bei PostgreSQL-17):

    sudo apt-get install postgresql-client-17

Es gelten entsprechende Hinweise bei anderen Architekturen. Die so konfigurierten Stones halten einen PFad auf eine 
SharedLibrary, unter der der Stone angelegt wurde.

## Installation des Paketes - Server
Ich empfehle die Installation via postgresql: https://www.postgresql.org/download/linux/ubuntu/

Die Seite ist so ausführlich, daß man da nicht mehr viel dazu sagen muß.

## PostgreSQL - Neuer Benutzer hinzufügen
If you know, that you need a new user, then now its time to create them. We want to create a superuser and a normal user:

    sudo -u postgres psql
    CREATE ROLE [superusername] WITH LOGIN SUPERUSER CREATEDB CREATEROLE PASSWORD '[password]';
    create database [dbname];
    create user [normalusername] with encrypted password '[password2]';
    grant all privileges on database  [dbname] to [normalusername];

## PostgreSQL - Erste Hilfen
Hier eine Sammlung mit ersten Tipps.

### psql - starten
    sudo -u postgres psql

### psql - Mit einer bestimmten Datenbank verbinden
Within psql you may execute "\c <dbname>" to aswitch to the specific database

### psql - Tabellenstruktur einer bestimmten tabelle in einer Datenbank anzeigen
Within psql you may execute "\dn <tablename>" to show the structure of a specific table

### psql - Alle vorhandenen Tabellen in einer Datenbank anzeigen
Within psql you may execute "\d " to show all available tables

### psql - Anzeige der Größe einer Datenbank
Within psql you may execute "select pg_size_pretty( pg_database_size(<dbname>));"

### psql - Anzeige der Größe einer Tabelle
Within psql you may execute "SELECT pg_size_pretty( pg_total_relation_size(<tablename>) );

### psql - Ändern eines Kennwortes eines PSQL-Benutzers
Within psql you may execute "ALTER USER postgres PASSWORD '<new-password>';"

### postgresql - Test, ob Zugriff auf externe DB möglich ist
    psql -U postgres -p 5432 -h hostname

### postgrewsql - Öffnung
Ja, das ist ein kritisches Thema - eine offene PostgreSQL Datenbank ist ein Sicherheitsrisiko. Also Vorsicht.