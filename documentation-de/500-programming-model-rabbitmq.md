# Programmiermodell RabbitMQ
Das allgmeine Programmiermodell des Systems ist ja ein API getriebenes Modell. Nun könnte man also alle 
Antwort-Prozesse mit einer eigenen Verbindung nach RabbitMQ ausstatten.

Das wird hier aber genau *nicht* getan. Die Antwortpozesse besitzen direkt keine Verbindung mit RabbitMQ,
sondern erzeugen im normalen Transaktionsverlauf, RabbitMQ Strukturen und speichern diese in der eigenen 
Transaktion erst einmal intern in Gemstone/S. Da diese Zwischenstruktur eine RcQueue ist, droht hier kein 
Concurrency Problem.

Ein eigener Prozess vom Gemstone/S verarbeitet diese vorbereiteten Telegramme weiter und sendet diese dann 
an RabbitMQ als topic Message. Das bedeutet, dass amq.topic das primäre Ziel (auf der RMQ Seite) der Telegramme ist.

Dieses Programmiermodell wird erst mit der Runtime v100 unterstützt. Die Runtimes vorher haben langsam zu 
diesem Modell hingeführt.


