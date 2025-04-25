# PAS (PUM Application Stack) - RabbitMQ
Ja, wir sind alle Gemstone/S Programmierer, aber hier noch ein paar Hinweise zur Installation und Handhabung
von RabbitMQ.

Prinzipiell würde ich immer empfehlen, eine aktuelle Version von RabbitMQ zu benutzen und zu installieren. 

Außerdem würde ich empfehlen, erst einmal mit den Standardaccounts (guest/guest) lokal entwickeln. Später kann man https etc. 
hinzufügen. Die notwendigen Eintragungen werden in PAS in der credentials.sh getätigt.

## Installation des Paketes - Client
Wenn wir einen RabbitMQ Server benutzen wollen, der auf einem anderen Rechner liegt, dann benötigen wir lokal 
das Entwicklungspaket für RabbitMQ - darin enthalten ist auch die Shared-Library, die Gemstone/S benutzt.

Die Installation erfolgt mit dem folgenden Befehl:

    sudo apt-get install librabbitmq-dev

Diese Installation legt die notwendige Bibliothek unter '/lib/x86_64-linux-gnu/librabbitmq.so.4' (für die x86_64 Architektur) 
ab. Auf diese Bibliothek greift das Gemstone/RabbitMQ Binding zu. Hierzu braucht man mindestens die Version Gemstone/S 3.6.5.

Man beachte: der so konfigurierte Stone, ist dann nicht so ohne weiteres auf einer aarch64 Architektur zum Laufen zu bekommen. 
Die RabbitMQ Anbindung muß dann neu installiert werden.

## Installation des Paketes - Server
Ich empfehle die Installation via cloudsmith: https://www.rabbitmq.com/docs/install-debian#apt-quick-start-cloudsmith

Die Seite ist so ausführlich, daß man da nicht mehr viel dazu sagen muß.

## Erste Schritte

### Server Installation - Konfiguration
Die Konfigurationsdatei sollte im Verzeichnis /etc/rabbitmq liegen. Nach der Installation ist das Verzeichnis 
aber leer. Um eine Konfigurationsdatei anzuleen, kann man einen einfachen Text-Editor benutzen und eine Datei mit 
dem Namen rabbitmq.conf anlegen. Dort werden die folgenden Konfigurationseinträge reingeschrieben.

### Starting and Stopping des Dienstes
Der Server kann mit dem folgendem Statement gestartet werden:

    sudo service rabbitmq-server start

Der Server kann mit dem folgendem Statement angehalten werden:

    sudo service rabbitmq-server stop

Der RabbitMQ Server wird nicht automatisch gestartet. Dies kann man aber mit dem folgenden Statemwent erreichen:

    sudo systemctl enable rabbitmq-server

### Installation des UI Managements
Nach einer Installation is das UI Management plugin nicht installiert. Daher gibt es dann auch keine UI zur Verwaltung.
Das Plugin muß erst einmal installiert werden.

    sudo rabbitmq-plugins enable rabbitmq_management

#### Neuer Benutzer für die UI
Mit dem Standardbenutzer kann man sich nur über localhost anmelden. Das könnte/wird nicht ausreichen. Daher kann man
einen neuen Benutzer (mit Adminrechten) einrichten:

    sudo rabbitmqctl add_user username password
    sudo rabbitmqctl set_user_tags username administrator
    sudo rabbitmqctl set_permissions -p / username ".*" ".*" ".*"

#### Nutzung der UI
Die Benutzeroberfläche kann bei https und ssl/tls wie folgt aufgerufen werden:

    https://<fullname>:15671

Die Benutzeroberfläche kann lokal mit http aufgerufen werden:

    http:/localhost:15672

#### Sicherung der Konfiguration
Über die Oberfläche kann die Struktur der Exchanges und Queues sichern und wieder einspielen

### Aktivierung - MQTT über WebSockets
Für die Anbindung von WebApplication wird das RabbitMQ Web MQTT Plugin genutzt. Es wird mit RabbitMQ ausgeliefert. Die Anwendungen bauen einen WebSocket auf, abonnieren die gewünschten Kanäle und erhalten dann die Nachrichten. Man beachte, daß man für die MQTT Anbindung einen eigenen Benutzer festlegen sollte. Die Credentials für diesen Benutzer erhält der Client über das Session Objekt. Diese Informationen muß er bei der Anmeldung bei MQTT über WebSockets nutzen.

Man möge beachten, dass man den default_user und default_pass für dieses Plugin auf einen Benutzer setzt, der keine Berechtigungen hat. Da die WebSocket Anbindung durch einen Apache getunnelt wird, erscheinen alle Anmeldungen als "localhost" getrieben - und dadurch hätten automatisch der default_user alle Berechtigungen.

Das Plugin gibt einen WebSocket Endpunkt unter 15675 frei ("ws://127.0.0.1:15675/ws"). 

#### Freigabe des Plugins

    rabbitmq-plugins enable rabbitmq_web_mqtt

#### Konfiguration des Plugin
Hier die Konfigurationseinträge für das Plugin. Der Benutzer "guest" sollte abgeschaltet werden und ein anderer Benutzer genutzt werden.

    web_mqtt.ssl.port       = 15676
    web_mqtt.ssl.backlog    = 1024
    web_mqtt.ssl.cacertfile = /path/to/ca_certificate.pem
    web_mqtt.ssl.certfile   = /path/to/server_certificate.pem
    web_mqtt.ssl.keyfile    = /path/to/server_key.pem
    # needed when private key has a passphrase
    # web_mqtt.ssl.password   = changeme

### SSL/TLS
Rabbitmq is portable - so you have to do all the stuff by yourself. This ist NOT nice, but ok. You have to change the 
configuration file to make all stuff working under SSL. After the installation, RabbitMQ is only accessable via plain 
http. Here an example how to make changes, so that RabbitMQ works under SSL/TLS. You need your certification for your 
domain, a private key file (alles was mit "blubber" s.u. benannt wird) and a cacertfile (a summary of Level 1 
certificates).

    management.path_prefix    = /rabbitmq
    management.ssl.port       = 15671
    management.ssl.cacertfile = /home/1234567/ssl/all_cacerts.pem
    management.ssl.certfile   = /home/1234567/ssl/blubber_ssl_certificate.pem
    management.ssl.keyfile    = /home/1234567/ssl/blubber_private_key.pem

    listeners.ssl.default     = 5671
    ssl_options.cacertfile    = /home/1234567/ssl/all_cacerts.pem
    ssl_options.certfile      = /home/1234567/ssl/blubber_ssl_certificate.pem
    ssl_options.keyfile       = /home/1234567/ssl/blubber_private_key.pem
    ssl_options.verify        = verify_peer
    # ssl_options.fail_if_no_peer_cert = true

The only problem here is to get a cacertfile. You may either create an example from all certification files located under /etc/ssl/certs via

    cat /etc/ssl/certs/* > /home/1234567/ssl/all_cacerts.pem

or via other ways:

•https://curl.se/docs/caextract.html
•http://www.cacert.org/index.php?id=3