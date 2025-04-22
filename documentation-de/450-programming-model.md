# Allgemeines Programmiermodell 
Die OODBMS Gemstone/S ist ein objektorientiertes Datenbanksystem. Die interne Prgrammiersprache ist Smalltalk, mit 
einer der mächtigsten Programmiersprachen, die man nutzen kann.

Die Logik der Anwendung wird also in Smalltalk geschrieben. Das Klassenmodell wird mittels PUM erstellt und gepflegt.

## API Programmierung
Dieses System möchte die Entwicklung von OpenAPI Systemen auf Basis von HTTP-RPC unterstützen. Wir reden dabei 
nicht von REST - sondern wir benutzen HTTP(s) als Transportmittel für RPCs gegenüber der Datenbank.

Praktisch nutzen wir nur die Methode POST von HTTP. Das ist aber nicht zwingend notwendig.

## Unabhängigkeit von Programmiersprachen
Die Konzentration auf APIs ermöglicht die Programmierung des Systems von außen in unterschiedlichen 
Programmiersprachen. Das ist zwar nicht die Sache von vielen Programmierern, aber ich denke, daß das
langfristig entscheidend ist.

## Kein serverseitiges Rendering
Die Konzentration auf APIs ermöglicht die Programmierung des Systems von außen in unterschiedlichen Sprachen. Hier
wird erwartet, daß man eine SinglePageApp (oder ein Fat-Client) schreibt (in Javascript). 

## Server Plattformen
Die Basis Plattform ist x64, aber inzwischen kann man das System auch unter aarch64 (einen Raspberry PI4/5) zum 
Laufen bringen.