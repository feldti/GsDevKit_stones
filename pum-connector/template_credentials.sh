#!/usr/bin/env bash
#

#
#
#
export PAS_STONE_NAME="stone-name"
export PAS_STONE_REGISTRY="work"

#
# Connection information for the RabbitMQ System
#
export PAS_APP_RMQ_ADR="rmq-adresse"
export PAS_APP_RMQ_PORT=5672
export PAS_APP_RMQ_ACCOUNT="rmq-user"
export PAS_APP_RMQ_PASSWD="rmq-password"
export PAS_APP_RMQ_VHOST="/"

export PUMCONNECTORQUEUE="pum.$PAS_STONE_NAME.source"

