# Session Activity Management
Um eine Benutzersitzun zu erkennen, bei der keine Aktivität mehr besteht, sollte man in regelmäßigen Zuständen 
eine Aktivität durchführen - die nichts macht, aber immerhin einen Kontakt mit dem Server aufbaut.

Dafür gibt es zwei Methoden innerhalb von pas:

## NOOP-API Call definieren
In der API der Anwendung wird ein Noop-Call definiert, der nichts anderes macht, als die Activity in der Session 
aufzufrischen und damit das Timeout zu verschieben. Hier eine Beispielimplementierung.

    apiSessionNoop: undefined  options: aMSKRestCallOptions

	    aMSKRestCallOptions session notNil ifTrue:[ aMSKRestCallOptions session updateTimeout ].

        ^(self restAnswerClass 
                okRequestFor: aMSKRestCallOptions restCallInstance
                result: (ES3APIGeneralResult new initialize setSuccess: true ; yourself)) 
                successWithCommitCall;
                yourself

Man sieht, daß die Methode nicht viel macht. Im Javascript-Client wird dann einfach ein Hintergrund-Task programmiert, 
der z.B. alle 5 Minuten diesen Call abfährt.  Einen Concurrency.Konflikt kann es hier nicht geben.

Das ist sicherlich die einfachste Lösung, aber man darf nicht vergessen, daß diese Lösung halt auch eine Transaktion
jeweils ist.

## SessionActivity via RMQ
Eine alternative Lösung ist es, Telegramme zu bauen in der normalen Transaktion und diese dann nach RMQ zu senden und
es gibt einen empfangenden Gemstone/S Task, der sich nur um diese SessionActivity Telegramme kümmern.  Das führt dazu, dass mehrere
Aktivitäten (100 ?) in einer einzigen Transaktion durchgeführt werden.

Das sieht auf den ersten Blick sehr teuer aus, aber man darf nicht vergessen, daß das asynchrone Versenden von Topic-Nachrichten
eventuell eh aktiviert und implementiert ist.

Dieser Task könnte auch dazu benutzt werden, um abgelaufende Sessions abzuarbeiten. Ansonsten müsste man dazu wieder eine
eigene Überwachung programmieren.

Außerdem sollte dieser Task nach einer gewissen Inaktivität (z.B. 5 Minuten) sich beenden und erneut gestartet werden.

Das Kommunikationsprinzip über RMQ sieht so aus, daß die Telegramme an einen topic-exchange (default: "amq.topic") geschickt werden mit dem routingKey 
"sessionactivity" und dem Eventname "evsessionactivity" (dieser wird nicht benötigt, da der routingkey bereits i.d.R. die Filterung übernimmt)

In der Oberklasse der konkreten Serviceklasse einer Anwendung gibt es eine Beispielimplementation 

    PUMGeneralServiceClass class>>taskStartSessionActivityMaintainance: aMSKRabbitMQConnector fromExchangeNamed: exchgName

Diese IMplementation kann man entsprechend nehmen oder überschreiben.

