#!/usr/bin/env bash
#
# Diese Datei setzt Umgebungsvariablen, die von anderen Skripten abgefragt werden können
#

#
# Name der Datenbank
#
export PAS_STONE_NAME="gc_365"
export PAS_STONE_REGISTRY="work"
#
# Informationen, wie man sich als Benutzer in der API anmeldet. I.d.R. sind das Accounts, die
# ein wenig mehr Rechte haben
#
export PAS_APP_API_USERNAME="mf"
export PAS_APP_API_PASSWORD="mf"

#
# Ggfs. braucht man auch einen Customer Namen
#
export PAS_APP_API_CUSTOMERNAME=""

#
#  Einstellungen für ZMQ
#
export STARTLOGEVENT="false"
export PULLEVENTPORT=23000
export PUBEVENTPORT=23010
export ZMQPULLEVENTPORTADDR="tcp://localhost:${PULLEVENTPORT}"
export ZMQPULLEVENTPORTBINDADDR="tcp://*:${PULLEVENTPORT}"
export ZMQPUBEVENTPORTADDR="tcp://localhost:${PUBEVENTPORT}"
export ZMQPUBEVENTPORTBINDADDR="tcp://*:${PUBEVENTPORT}"

#
# Intervall in Sekunden für den Statistik-Monitor von Gemstone und ob dieser überhaupt gestartet werden sollte
#
export STARTSTATMONITOR="false"
export ITVSTATMON=30

#
# Informationen für das Logging-System
#
export LOGGERPULLPORT=23020
export ZMQPULLLOGGERPORTADDR="tcp://localhost:${LOGGERPULLPORT}"
export ZMQPULLLOGGERPORTBINDADDR="tcp://*:${LOGGERPULLPORT}"
export LOGGERPUBPORT=23030
export LOGGERPUBPORTADDR="tcp://localhost:${LOGGERPUBPORT}"
export LOGGERPUBPORTBINDADDR="tcp://*:${LOGGERPUBPORT}"

#
# Kommunikation-HTTP
#
export PAS_APP_ENABLE_NORMAL_PORT="true"
export PAS_APP_NORMAL_PORT=27000
export PAS_APP_ENABLE_LONG_PORT="true"
export PAS_APP_LONG_PORT=27100
export PAS_APP_ENABLE_MEMORY_PORT="true"
export PAS_APP_MEMORY_PORT=27200
export PAS_APP_ENABLE_LIMITED_PORT="false"
export PAS_APP_LIMITED_PORT=27300
export PAS_APP_ENABLE_EXTDB_PORT="false"
export PAS_APP_EXTDB_PORT=27400

export PAS_APP_NORMAL_MEMORY=100000
export PAS_APP_LONG_MEMORY=2000000
export PAS_APP_MEMORY_MEMORY=4000000
export PAS_APP_LIMITED_MEMORY=200000
export PAS_APP_EXTDB_MEMORY=50000

#
# Auf den Entwicklungsrechnern kann man gleich den support netldi starten
#
export STARTNETLDI="false"

#
# Wenn man eine URL auf die API benötigt
#
export PAS_API_ADDRESS="http://localhost"


#
# Application Specific stuff
#
export PAS_APP_MODEL_TOPAZ_FILE='cis'
export PAS_APP_SERVICE_CLASS='CISServiceClass'
export PAS_APP_PROJECT_CLASS='CISProject'
export PAS_APP_TOPAPI_CLASS='CISAPIGeneralObject'
export PAS_APP_TOPDOMAIN_CLASS='CISGeneralDomain'
# e.g. TSTEnumErrorDefinition (from PUM) + LocaleErrorDefinition
export PAS_APP_ERROR_CLASS='CISEnumErrorDefinitionLocaleErrorDefinition'
export PAS_APP_RESTCALL_CLASS='CISRestClass'
export PAS_APP_DATA_CLASS='CATIInterviewerSchedulingData'
export PAS_APP_PACKAGES="http://dev.gessgroup.de/extfiles/gess/cis/v77/develop/sources/"
export PAS_APP_MDL_PACKAGE="cis"
export PAS_APP_EXT_PACKAGE="cisExtension"
export PAS_APP_SERVERTYPE="test-srvapp"

#
# Points to a directory, where ALL the Monticello packages for the runtime can be found
#
export PAS_RUNTIME_PACKAGES="http://dev.gessgroup.de/extfiles/gess/pas_runtime/v90/sources"

#
# migration file for the migration task
#
export PAS_STONE_MIGRATION_INSTANCES_FILE="$HOME/__temp_migration_classes.bm"

#
# directory path for the certification of OpenSSL. GsSecureSocket within Gemstone needs this informaation
#
export PAS_APP_SSL_CERT_PATH="/etc/ssl/certs"

#
# Connection information for the RabbitMQ System
#
export PAS_APP_RMQ_ADR="rechnername"
export PAS_APP_RMQ_PORT=5672
export PAS_APP_RMQ_ACCOUNT="rmq user"
export PAS_APP_RMQ_PASSWD="rmq password"
export PAS_APP_RMQ_VHOST="/"
export PAS_APP_RMQ_MQTT_ACCOUNT="rmq mqtt benutzer"
export PAS_APP_RMQ_MQTT_PASSWD="rmq mqtt passwort"
export PAS_APP_TLS="false"
export PAS_APP_RMQ_PRVKEY="/home/user/ssl/privkey.pem"
export PAS_APP_RMQ_CERT_PATH="/home/user/ssl/fullchain.pem"
export PAS_APP_RMQ_CACERT_PATH="/home/user/ssl/all_cacerts.pem"

#
# Bei projektübergreifenden Queues, sollte man immer das allgemeine prefix voranstellen
#
export PAS_APP_RMQ_PREFIXNME="pas."

#
# Wenn man eine Verbindung zu einer Datenbank braucht
#
export PAS_APP_PSQL_ADR="psql rechnername"
export PAS_APP_PSQL_PORT=5432
export PAS_APP_PSQL_ACCOUNT="psql account name"
export PAS_APP_PSQL_PASSWD="psql account password"
export PAS_APP_PSQL_DBNAME="psql datenbank name"

#
# Handler starten für den ServerEvent Bus
#
export PAS_APP_RMQ_SERVER_EVENT_BUS_EXCHG="pas.serverEventBus"
export PAS_START_EVENT_SERVERBUS_HANDLER="false"

#
# Handler starten für Session Activity Task
#
export PAS_APP_RMQ_SESSACTQUEUE="cis.sessionActivity"
export PAS_START_SESSION_ACTIVITY_HANDLER="true"

#
# Superset-Token Handler
#
export PAS_START_SUPERSET_TOKEN_HANDLER="false"
export PAS_SUPERSET_LOGIN="admin"
export PAS_SUPERSET_PASSWORD="admin"

#
# Prometheus
#
export PAS_START_PROMETHEUS_COLLECTOR="false"
export PAS_START_PROMETHEUS_APP_COLLECTOR="false"
export PAS_START_PROMETHEUS_APP_DELAY=60
export PAS_START_PROMETHEUS_APP_COLLECT_SYSTEM_DATA=false
export PAS_PROMETHEUS_PASSWORD="2UnsrRmJX5Es9g2iJitpXWCAS7cXkpyq8hEXETd3sZbqJXosg"
export PAS_PROMETHEUS_JOB="cis_db"
export PAS_PROMETHEUS_APP_JOB="cis_app"
export PAS_PROMETHEUS_INSTANCE="dev_local"
export PAS_PROMETHEUS_LOCAL_URL="http://localhost:9986/metrics"
export PAS_PROMETHEUS_LOCAL_FILE="prometheus_cis_data.txt"
export PAS_PROMETHEUS_LOCAL_APPDATA_FILE=prometheus_cis_app_data.txt
export PAS_PROMETHEUS_LOCAL_CONFIG_FILE="prometheus_cis_cfg.json"
export PAS_PROMETHEUS_PUSH_GATEWAY="https://pushgateway.gessgroup.io"

export PAS_PROMETHEUS_USE_NODE_EXPORTER_URL="false"
export PAS_PROMETHEUS_NODE_EXPORTER_URL="http://localhost:9100/metrics"
export PAS_PROMETHEUS_LOCAL_NODE_EXPORTER_FILE=prometheus_node_exp_data.txt
export PAS_PROMETHEUS_SYSTEM_JOB="cis_system"

