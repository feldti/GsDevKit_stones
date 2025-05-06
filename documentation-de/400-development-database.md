# Entwicklungszyklus in einer Entwicklungsdatenbank
Mit PUM definiert man das Modell und die API. Irgendwann ist man dann soweit und möchte den Quelltexte in 
eine Entwicklungsdatenbank laden.

PUM erzeugt immer topaz-Code, der ausgeführt werden muß. Das Skript legt dann alle notwendigen Klassen, 
Methoden und Monticello-Packages in der Datenbank an. Dieses Skript kann durchauch mehrere Megabyte an 
Größe annehmen.

Das Topaz-Skript legt immer zwei Monticello-Packages in der Datenbank an:

- Das Package "SurveyManager" (Name des PUM-Projektes: "SurveyManager") mit den Klassen und den API 
Strukturen aus PUM
- Das Package "SurveyManagerExtension", in dem der Programmierer seinen Anwendungscode ablegt. Dieses package ist anfänglich leer

Das Programmiermodell sieht also so aus, daß der Entwickler in 99.9% im Package "SurveyManager" arbeitet 
und dort immer nur Methoden anlegt/löscht/bearbeitet, die in Extensions ("*SurveyManagerExtension") definirt 
sind und in "SurveyManagerExtension" gespeichert werden.

Danach speichert man diese Packages regelmäßig ab ... wie man es gewohnt ist.

Mit jeder neuen Modellversion wird das dann neu erstellt Topaz-Skript neu erzeugt und neu ausgeführt.  
Die Änderungen betreffen bei einer erneuten Anwendung immer nur das Package "SurveyManager". Die 
"Extension" wird dann nicht mehr angefasst durch das Skript.

