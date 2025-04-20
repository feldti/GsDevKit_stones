# Programmiermodell PostgreSQL
Das allgmeine Programmiermodell des Systems ist ja ein API getriebenes Modell. Nun könnte man also alle
Antwort-Prozesse mit einer eigenen Verbindung nach PostgreSQL ausstatten.

Das kann man machen - vor allem in den Programmen, in denen die API Daten aus der relationalen Datenbank 
liefern muß.

Wenn aber Gemstone/S - außer zum Loggen - die rel. DB nur für einen nachgelagerten Export von Daten auf 
Basis der Gemstone/S-Transaktionen dient, dann sollte man ein entsprechendes Modell nutzen, wie auch bei 
der RabbitMQ Anbindung.

Es gibt nun mehrere Methoden, um einen alternativen Feed der rel. Datenbank zu realisieren:

## SQL-Statements in Transaktionsdaten

Die Gemstone/S Transaktion erzeugt die SQL-Statements während der Beantwortung eines API-Calls und das 
System speichert diese in einer RcQueue ab (keine Concurreny-Probleme). Ein eigenständiger Gemstone/S
Prozess liest diese Queue aus und führt die eigentlichen SQL-Statements aus.

## SQL-Daten als RMQ-Message

Die Gemstone/S Transaktion erzeugt Datenstrukturen während der Beantwortung eines API-Calls und das
System speichert diese als Telegrammstruktur in einer Gemstone/S-RcQueue ab (keine Concurreny-Probleme). 

Dann übernimmt der eigenständige RMQ-Prozess den Versand nach RabbitMQ. Durch entsprechende Konfiguration auf
dem RMQ-Server wartet ein anderer Prozess auf die Daten und fügt diese in die Datenbank ein. Dieser
Prozess kann dann ja in einer anderen Programmiersprache geschrieben werde (und auch so die Last von einer 
Gemstone wegnehmen)

Als Beispiel für dieses Verfahren dient paslog, das Loggen in die relationale Datenbank.

## Warum überhaupt eine rel.DB ?
Ja, die Frage wird immer wieder gestellt. Ist die erste Datenbank nicht ausreichend ? Nein, aber es gibt Gründe, 
warum man eine rel. DB in eine Projektlösung aufnehmen könnte:

### Performance
Viele Strukturen enden oftmals alleinstehend als einfacher Record - also einer Tabellenstruktur. Warum dann nicht 
auch relationale DBs nutzen. Und man muß auch einigermßen ehrlich sein - auf dem Gebiet von Tabellen kann keine alternative Datenbank die Performance von 
rel. DB Systemen erreichen.

### Kundennähe - mit SQL näher am Kunden als mit einer API
OpenAPI sind zwar nett, bringen aber dem Kunden per se keinen Nutzen. Viele Kunden können inzwischen SQL, also
ist es für sie leichter, wenn man ihnen ein Teil der Daten als SQL abrufbar anbietet - damit landen wir dann
in einer Art Data Warehouse.

### Data Warehouse
Viele Strukturen enden oftmals alleinstehend als einfacher Record - also einer Tabellenstruktur. Und man muß auch
einigermßen ehrlich sein - auf dem Gebiet von Tabellen kann keine alternative Datenbank die Performance von
rel. DB Systemen erreichen.

### Third-Party Tools
Wir haben SQL, wir haben eine Art Data Warehouse ... kommen wir zu einem weiteren Teil: die visuellen Aufbereitung 
der Daten in rel. DBs und hier gibt es bereits eine ganze Menge an Tools: z.B. Apache Superset.

### Lizenzrestriktionen
Die Gemstone/S Datenbank ist ein kommerzielles Produkt und kostet Geld und das muß man erst einmal verdienen bzw.
man kann Lizenzen in verschiedenen Formen kaufen, die mal mehr, mal weniger Resourcen zur Verfügung stellen.

Wenn man also die freie Lizenz nutzen will, dann sollte man die Logik in der Gemstone/S halten und auch die
wesentlichen Daten ... aber LOG-Daten z.B: kann man dann besser auslagern und spart viel Platz in der eigentlichen
Datenbank.

Außerdem kann man CPU intensive Anwendungen in dem DataWarehouse laufen lassen mit den entsprechenden Tools.