# PASLOG - Loggen in eine relationale Datenbank
PASLOG ist ein Framework zum Loggen von Informationen aus den Gemstone/S-Anwendungen heraus.

PASLOG benutzt RabbitMQ zum Versenden von LOG-Meldungen und nutzt Programme in .Net-Core (C#), um diese Inormationen 
in eine relationale Datenbank PostgreSQL zu schreiben.

Die C# Programme sind gleichzeitig Managementprogramm, wie auch LOG-Client und arbeiten unabhängig von der 
Gemstone/S Anwendung. Man kann mehrere Gemstone/S Anwendungen in die gleiche Tabelle und in die gleiche Datenbank
schreiben lassen.

Für die Visualisierung kann man Apache-Superset benutzen, oder man schreibt ein eigenes Visualisierungsprogramm.

## Strukturiert Loggen !

Bevor man überhaupt anfängt zu loggen: Nachdenken. Man beachte die folgenden Ideen beim Loggen:

- Kann man aus den Log-Daten einen kompletten API Call nachvollziehen ? (Wer hat den API Call gemacht, von wo kam der Call)
- Kann man aus den LOG-Daten alle Calls einer speziellen Benutzersitzung herausfinden ?
- Kann man aus den LOG-Daten alle Calls eines Kunden herausfinden ? (Multi-Tennant Anwendungen)
- Kann man aus den LOG-Daten alle speziellen Calls herausfinden ? (z.B. alle Login-Calls, alle Logout-Calls)
- Kann man alle Calls oder Sessions herausfinden, wo es Zugriffsberechtigungsprobleme gab ?
- Kann man aus den LOG-Daten Concurrency-Probleme erkennen ? 

## Log-Daten Visualisieren
Bei der Visualisierung der LOG-Daten hat sich Apache-Superset sehr gut bewährt. Das Problem ist nur, daß dieses ein 
sehr mächtiges Tool ist und viele Resourcen in Anspruch nimmt. Es ist also wünschenswert, daß man mit einer Instanz
von Apache Superset auch andere Visualisierungen machen kann.

Das bewegt sich natürlich schon sehr in Richtung Data-Warehouse.

## Log-Strukturen
Einen LOG-Eintrag zu schreiben, bedeutet eine Topic-Nachricht (z.B. amq.topic) für RMQ zu erstellen, in der die eigentliche LOG-Nachricht
gekapselt ist. Die dafür notwendigen Methoden findet man in der Serviceklasse der Anwendung.

Eine derartige gekapselte LOG-Meldung kann direkt in der RMQ-Topic-Ausgangsqueue der Projektklasseninstanz abgelegt werden. Die LOG-Meldung
würde dann als normaler Event verschickt werden. Das macht natürlich nur Sinn, wenn RMQ-Support überhaupt vorhanden ist.

Das zu entscheiden ist Aufgabe der Serviceklasse. Dort ("putLogMessageIntoSendQueue: rmqTopicMessage") wird fest kodiert, ob eine LOG
Meldung in den RMQ-Versand gelangen soll oder in eine gesonderte Ausgabequeue in der Projektklasseninstanz.

Bei der Erstellung eines LOG-Eintrag muß man sich entscheiden, ob der LOG-Eintrag im Erfolgsfall, im Fehlerfall oder immer 
erzeugt werden soll.

## Loggen aus der Anwendung heraus (ServiceClass REST Call API)
Wenn man in der ServiceClass die API-Routinen ausprogrammiert, dann hat man ja bereits die direkte Referenz zu den 
Hilfsmethoden. Jeder API-Call bekommt eine Instanz der Klasse MSKRestCallOptions, die Daten während eines API-Calls
sammelt, die am Ende abgearbeitet werden müssen.

Wenn man einen LOG-Eintrag für den Fehlerfall schreiben möchte, dann kann man das in der Serviceklasse so schreiben:

    aMSKRestCallOptions addLogOnFailure: (self 
                                            paserror: logText
                                            topic: topicString 
                                            subTopic: subTopicString 
                                            session: aMSKRestCallOptions session)

Entsprechendes gilt für den Erfolgsfall:

    aMSKRestCallOptions addLogOnSuccess: (self 
                                            paslog: logText
                                            topic: topicString 
                                            subTopic: subTopicString 
                                            session: aMSKRestCallOptions session)

oder halt immer:

    aMSKRestCallOptions addLogOnAll: (self 
                                            paslog: logText
                                            topic: topicString 
                                            subTopic: subTopicString 
                                            session: aMSKRestCallOptions session)

Wenn man nicht direkt in einem API Call ist, dann kann man versuchen, die aktuelle Instanz von MSKRestCallOptions zu bekommen, in 
dem man den folgenden Statement aufruft:

    MSKRestCallOptions currentInProcess

Dann kann man mit der Instanz arbeiten, aber: sie könnte auch nicht definiert sein. Wenn die Instanz nicht definiert ist, dann
muss man die meiste Arbeit manuell machen und die ServiceClass (des Projektes aus PUM - e.g. "MyServiceClass") selber aufrufen:

        MyServiceClass
            putLogMessageIntoSendQueue: 
                (MyServiceClass
                    paserror: logText
                    topic: topicString 
                    subTopic: subTopicString 
                    session: nil).
        System commitTransaction.

Dann (NACH dem commit) sollte die LOG-Meldung asynchron (in einem anderen Thread) verarbeitet werden.