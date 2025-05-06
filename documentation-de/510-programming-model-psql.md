# Programmiermodell PostgreSQL
Das allgemeine Programmiermodell des PAS-Systems ist ja ein API getriebenes Modell. 

Nun könnte also jeder API-Antwortprozeß  seine eigene Verbindung aufbauen und während der Beantwortung eines Calls 
auch die entsprechenden Aufrufe von PostgreSQL durchführen.

Immerhin gibt es dafür eine gute Voraussetzung:
* Es gibt eine native Anbindung von Gemstone/S an PostgreSQL

Das hat einige Vorteile:
* einfaches Programmiermodell
* vermutlich bessere Performance

... aber auch Nachteile
* pro API-Antwortprozeß ist eine eigene Verbindung notwendig. Das bedeutet eine erhöhte Ausfallmöglickeit
* zwei Transaktionsmodelle arbeiten gegeneinander - eigentlich kommt man dann in ein 2-Phase-Commit Verfahren - was ich aber unbeding vermeiden möchte
* die Länge der API-Calls erhöht sich durch einen zusätzlichen eventuell Netzwerkzugriff

Natürlich ist das Modell bei bestimmtn Anwendungen notwendig - z.B. dann, wenn man im Client auf die Daten der PostgreSQL zugreifen muß - also die
Daten in der PostgreSQL notwendig sind zur Erfüllung der Programmaufgabem.

Damit nun nicht alle API-Prozesse eine Verbindung aufbauen müssen, kann man die entsprechenden API-Calls (mit Datenbankzugriff) auf eine
eigene URL binden und nur diese beim Start mit einer DB-Verbindung ausstatten.

Wenn man aber die PostgreSQL als Data-Warehouse ansieht - also die Gemstone/S schreibt nur in die PostgreSQL - dann kann man auch asynchrone Verfahren
anwenden, die nun im folgenden beschrieben werden.

## SQL-Statements in Transaktionsdaten
Im ersten Verfahren legt der API-Prozeß Daten in Strukturen ab (Instanzen von xxExtDBCommandStructure) , die für das Rausschreiben in die PostgreSQL benötigt werden. Die Daten werden im 
API-Prozeß überprüft und dann in einer Arbeitsqueue für einen anderen Prozeß abgelegt. Diese Arbeitsqueue wird als 1:n Assoziation (Implementiert durch
eine RcQueue) von z.B. der Instanz des Customers oder der Instanz des Softwareprojektes (Root der Persistenz) abgelegt.

Dieser "andere" Prozeß erzeugt asynchron die SQL Statements und schreibt diese in die Datenbank.

Das ist der direkte und einfachste Weg, eine PostgreSQL Datenbank von Gemstone aus zu füllen. Dieser Export exportiert Strukturdaten als Einträge in
Tabellen - nichts Tabellenübergreifendes oder Assoziationen zwischen Tabellen werden angelegt.

Dieses Verfahren ist natürlich nur anwendbar, wenn die Datenbank direkt erreichbar ist. Wenn das nicht vohanden ist (Sicherheitsaspekte), dann 
kann man eine direkte Verbindung mittels Tunnel herstellen. Ist auch das nicht möglich, dann muß man das andere Verfahren nutzen, wa weiter unten 
beschrieben wird. 

### Anlegen der Tabellendaten in PUM
Für jede benötigte Zieltabelle wird eine Unterklasse von xxExtDBGeneralTable angelegt (Domain-Hierarchie). Instanzen dieser Klasse 
dienen dazu, die Daten für die spätere Speicherung aufzunehmen. In der Regel ist für jede Spalte ein Attribut definiert, aber eben 
nicht immer.

Ausgehend von dieser Klasse wird dann eine entsprechende Klasse in der API-Hierarchie angelegt und in dieser Klasse werden alle 
Datenbankattribute definiert: Name der Tabelle, welche Spalten (Spaltennamen und Index). Wichtig ist dabei eine PrimaryKey Spalte - die ja 
z.B: aus zusammengesetzten Attributwerten berechnet wird. Jeder Eintrag sollte sich auch selber löschen können - über den PrimaryKey.

Alle Statements dieser Instanz von xxExtDBCommandStructure werden später in einer Transaktion in der PostgreSQL durchgeführt.

In der Instanz von xxExtDBCommandStructure werden auch Statements aufgebaut, die die notwendigen Tabellen bzw. Indices bei Bedarf anlegen - 
das erleichtert die Arbeit erheblich (Beispielcode):

    ...
    aXXExtDBCommandStructure := xxExtDBCommandStructure newInitialized.

    stream := WriteStream on: String new.
	GsPostgresConnection 
		pasBuildCreateTableStatementFor: xxAPIExtDBTableBookslot on: stream ;
		pasBuildCreateIndexStatementFor: xxAPIExtDBTableBookslot on: stream.
    stream
        nextPutAll: 'DELETE ......;'.
    aXXExtDBCommandStructure setSqlStatement: stream contents.

    "Einzeldatensätze hinzufügen ... für jeden Tabellentyp eigene Sammlung anlegen"
    xxExtDBDataStructure := XXExtDBDataStructure newInitialized.
    xxExtDBDataStructure addTableEntries: anXXExtDBTableBookslot ; addTableEntries: anXXExtDBTableBookslot ....

    aXXExtDBCommandStructure
        addDataStructures: xxExtDBDataStructure.

    projectInstace addDBCommandStructure: aXXExtDBCommandStructure
    ...

Diesem Stream kann man noch weitere Statements hinzufügen. So könnte man allgemeine DELETE-Befehle anfügen, wenn man weiß, daß alle
folgenden Datenzeilen diesen Key besitzen - so kann man doppelte inserts vermeidet.

Eine Besonderheit ist der JSONB-Datentyp und der serial-Datentyp. Diese Spalte muß entsprechend gekennzeichnet werden im PUM-Modeller 
und die Daten bei jsonb müssen als String angeliefert werden und zwar unbedingt im Unicode-Encoding.

### Der "Hintergrundprozeß"
Wie oben bereits geschildert gibt es einen Hintergrundprozeß, der die aufbereiteten Daten in die Datenbank schreibt. In dem app-python 
Template gibt es das Skript "pas_task_start_extdb.sh", das diesen Hintergrundprozeß startet. In der Oberklasse der Serviceklasse des
Projektes gibt es eine Beispielimplementation des Tasks.

## SQL-Daten als RMQ-Message
Es kann Umstände geben, wo ein direkter Export der Daten in eine PostgreSQL nicht möglich ist. Dann kann man das Verfahren über RabbitMQ 
nutzen. 

Die Gemstone/S Transaktion erzeugt Datenstrukturen während der Beantwortung eines API-Calls und das
System speichert diese als Telegrammstruktur in der vorhanden (z.B. durch Nutzung von PASLOG) RMQ-Prozessstruktur (keine Concurreny-Probleme). 

Dann übernimmt der eigenständige RMQ-Prozess den Versand nach RabbitMQ. 

Durch entsprechende Konfiguration auf
dem RMQ-Server wartet ein anderer Prozess auf die Daten und fügt diese in die Datenbank ein. Dieser
Prozess kann dann ja in einer anderen Programmiersprache geschrieben werde (und auch so die Last von einer 
Gemstone wegnehmen). Dieses zu screibende Tool kann noch zusätzliche Arbeiten übernehmen - Anlegen der Tabllenstruktur,
Partitionierung der Tabellenstruktur, Löschen von Altdaten etc ....

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