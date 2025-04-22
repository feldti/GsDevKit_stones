# Allgemeines Programmiermodell - API Call Ablauf
Dieses System möchte die Entwicklung von OpenAPI Systemen auf Basis von HTTP-RPC unterstützen. Wir reden dabei 
nicht von REST - sondern wir benutzen HTTP(s) als Transportmittel für RPCs gegenüber der Datenbank.

Praktisch nutzen wir nur die Methode POST von HTTP. Das ist aber nicht zwingend notwendig. PUM erzeugt neben den Domain-Klassen 
auch die notwendigen Klassen für die API-Calls.

## RestCall Klasse
PUM legt eine Unterklasse von MSKRestCallV2 an, in der alle definierten API-Calls auf der Klassenseite aufgeführt sind. 
Die Kategorien der angelegten Methoden sind gleichzusetzen mit den API-Kategorien. 

Die meisten dieser Methoden definieren wie der API Call auszuführen ist. Dazu gehört unter anderem ein Parameter "serviceBlock", 
der einen Block mit zwei Parameter aufruft: der API-Parameter und eine Instanz von MSKRestCallOptions.

Dieser Block wird aufgerufen werden und in dem Block sieht man den Namen der Methode, die auf der Klassenseite der Serviceklasse 
implementiert werden muss.

In diesen zu implementierenden Methoden bewegt man sich die allermeiste Zeit beim Programmieren.

## Aufgaben in jeder einzelnen API-Methode in der Serviceklasse
Wenn die API-Methode durch das System aufgerufen wurde, dann ist zumindestens sichergestellt, dass es eine Benutzersession gibt und 
daß eine Parameterinstanz erstellt wurde.

Nun muß man in der API-Methode in der Regel immer die folgenden Arbeiten ausführen:

- Hat die Benutzersitzung überhaupt die Rechte, diesen Call überhaupt auszuführen
- Sind alle notwendigen Parameterwerte gesetzt worden.
- Verweisen einige der Parameterwerte auf interne Objekte (via gop !) und hat der Benutzer überhaupt Rechte zum entsprechenden Zugriff auf diese Objekte
- Danach erfolgt die eigentliche API-Domain-Logik
- Und es erfolgt die Rückgabe von Ergebniswerten

Wenn man mal eine einfache Methode anschaut:

    apiSessionNoop: undefined  options: aMSKRestCallOptions

        aMSKRestCallOptions session ifNotNil:[ :session | session updateTimeout ].
    
        ^(self restAnswerClass 
                okRequestFor: aMSKRestCallOptions restCallInstance
                result: (ES3APIGeneralResult new initialize setSuccess: true ; yourself)) 
                successWithCommitCall;
                considerWaitingMessages: aMSKRestCallOptions ;
                yourself

dann kann man erkennen, daß hier keine großen Checks notwendig sind. Die Methode hat keine Parameterwerte ("undefined") und 
verändert nur die Sessionaktivität in der eigenen Session-Instanz.

Am Ende erfolgt die Erstellung der Antwort. Ein "okRequestFor:" sagt aus, daß ein 200er HTTP Code zurückgegeben werden soll 
und der Call ist ein Erfolg und sollte mit einem commit abgeschlossen werden ("successWithCommitCall").

Die Instanz des Rückgabewertes ("result:") wird aufbereitet und alle Events und LOG-Meldungen werden zur VWeiterverarbeitung 
übergeben ("considerWaitingMessages:").

Den Rest macht das Framework. Im Fall von Concurrency-Problemen, versucht das System die Aktionen mehrfach durchzuführen - das 
senkt die Anzahl an Fehlermeldung im Client beträchtlich, bedeutet aber mehr Last auf dem Server.

Jetzt gibt es auch Calls, bei denen weiß man bereits, dass ein Retry im Fehlerfalle nicht sinnvoll ist. Dann schliesst man den
Call anders ab ("noRetriesAllowed") und an den Client wird sofort eine Fehlermeldung zurückgegeben.

    apiSessionNoop: undefined  options: aMSKRestCallOptions

        aMSKRestCallOptions session ifNotNil:[ :session | session updateTimeout ].
    
        ^(self restAnswerClass 
                okRequestFor: aMSKRestCallOptions restCallInstance
                result: (ES3APIGeneralResult new initialize setSuccess: true ; yourself)) 
                successWithCommitCall;
                noRetriesAllowed;
                considerWaitingMessages: aMSKRestCallOptions ;
                yourself

Wenn man bei der Abarbeitung auf Probleme stößt, die ein Abbruch der Methode sofort notwendig macht, dann geschieht dies mit 
folgender Sequenz:

		(...) isNil
			ifTrue:[
				ES3EnumErrorCodesLocaleErrorDefinition 
                    errCodeGeneralErrorThrowSignal: aMSKRestCallOptions  
                    with1Args: (Array with: 'apiGraphicsNextGraphicsJob:options: - nicht in der aktuelle Queue') 
			]

Dann wird eine Exception geworfen mit Informationen über den aktuellen Call ("aMSKRestCallOptions") und einem Fehlertext. Die im 
obigen Beispiel genutzte Klasse "ES3EnumErrorCodesLocaleErrorDefinition" lautet in jedem Projekt anders und wird durch 
PUM erzeugt.

Beim Abbruch einer Methode wird ein "badRequestFor:result:" aufgerufen, was zu einem HTTP 400 Code führt.

Außerdem gibt es noch einige weitere Methoden in der obigen Fehlerklasse, um Exceptions in speziellen Fällen zu werfen. Die obige Fehlerklasse ist eine Unterklasse
von MSKRESTLocaleErrorDefinition.





