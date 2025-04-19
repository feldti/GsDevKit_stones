# Programmiermodell PostgreSQL
Das allgmeine Programmiermodell des Systems ist ja ein API getriebenes Modell. Nun könnte man also alle
Antwort-Prozesse mit einer eigenen Verbindung nach PostgreSQL ausstatten.

Das kann man machen - vor allem in den Programmen, in denen die API Daten aus der relationalen Datenbank 
liefern muß.

Wenn aber Gemstone/S - außer zum Loggen - die rel. DB nur für einen nachgelagerten Export von Daten auf 
Basis der Gemstone/S-Transaktionen dient, dann sollte man ein entsprchendes Modell nutzen, wie auch bei 
der RabbitMQ Anbindung.

Es gibt nun mehrere Methoden, um einen alternativen Feed der rel. Datenbank zu realisieren:

## SQL-Statements in Transaktionsdaten

Die Gemstone/S Transaktion erzeugt die SQL-Statements während der Beantwortung eines API-Calls und das 
System speichert diese in einer RcQueue ab (keine Concurreny-Probleme). Ein eigenständiger Gemstone/S
Prozess liest diese Queue aus und führt die eigentlichen SQL-Statements aus.

## SQL-Daten als RMQ-Message

Die Gemstone/S Transaktion erzeugt Datenstrukturen während der Beantwortung eines API-Calls und das
System speichert diese als Telegrammstruktur in einer RabbitMQ-RcQueue ab (keine Concurreny-Probleme). 

Dann übernimmt der eigenständige RMQ-Prozess den Versand nach RabbitMQ. Durch entsprechende Konfiguration auf
dem RMQ-Server wartet ein anderer Prozess auf die Daten und fügt diese in die Datenbank ein. Dieser
Prozess kann dann ja in einer anderen Programmiersprache geschrieben werde.

Als Beispiel für dieses Verfahren dient paslog, das Loggen in die relationale Datenbank.