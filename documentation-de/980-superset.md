# PAS (PUM Application Stack) - Apache Superset
Ja, wir sind alle Gemstone/S Programmierer, aber hier noch ein paar Hinweise zur Installation und Handhabung
von Apache Superset

Apache Superset wird genutzt für Visualisierungen von Daten, die in PostgreSQL abgelegt wurden. Um die Sicherheitsbedenken 
zu reduzieren, empfehle ich die Installation von PostgreSQL, .Net Core für paslog und Apache Superset auf einem Rechner.

Apache Superset ist ein Softwaremonster, daß man immer bändigen muß. Native Installation erscheint kaum möglich, daher 
erfolgt die Installation via docker.

Die in Apache Superset definierten Dashboarde werden in der JS-UI eingebunden.
