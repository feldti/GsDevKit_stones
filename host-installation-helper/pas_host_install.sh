#! /usr/bin/env bash

sudo apt-get update
sudo apt-get upgrade
sudo apt-get install apache
sudo a2enmod slotmem_shm slotmen_plain rewrite proxy proxy_http proxy_wstunnel proxy_balancer lbmethod_byrequests lbmethod_heartbeat lbmethod_bybusyness heartbeat heartmonitor ssl
sudo systemctl restart apache2
sudo apt install certbot python3-certbot-apache
sudo apt-get install curl gnupg apt-transport-https -y

## Team RabbitMQ's signing key
curl -1sLf "https://keys.openpgp.org/vks/v1/by-fingerprint/0A9AF2115F4687BD29803A206B73A36E6026DFCA" | sudo gpg --dearmor | sudo tee /usr/share/keyrings/com.rabbitmq.team.gpg > /dev/null

. /etc/os-release
case "${ID}" in
  debian)
    case "${VERSION_ID}" in
      13)
        sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Latest RabbitMQ releases
##
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-server/debian/trixie trixie main
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-server/debian/trixie trixie main
EOF
       ;;
      *)
       echo "Nichtunterstützte Ubuntu/Tuxedo Version ${VERSION_ID}"
       exit 1
       ;;
    esac
      ;;
  ubuntu|tuxedo)
    case "${VERSION_ID}" in
      24.04)
        sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Modern Erlang/OTP releases
##    
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-erlang/ubuntu/noble noble main
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-erlang/ubuntu/noble noble main

## Latest RabbitMQ releases
##    
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-server/ubuntu/noble noble main
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-server/ubuntu/noble noble main
EOF
        ;;
      22.04)
        sudo tee /etc/apt/sources.list.d/rabbitmq.list <<EOF
## Modern Erlang/OTP releases
##
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-erlang/ubuntu/jammy jammy main
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-erlang/ubuntu/jammy jammy main

## Latest RabbitMQ releases
##
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb1.rabbitmq.com/rabbitmq-server/ubuntu/jammy jammy main
deb [arch=amd64 signed-by=/usr/share/keyrings/com.rabbitmq.team.gpg] https://deb2.rabbitmq.com/rabbitmq-server/ubuntu/jammy jammy main
EOF
        ;;
      *)
       echo "Nichtunterstützte Ubuntu/Tuxedo Version ${VERSION_ID}"
       exit 1
       ;;
    esac
    ;;
  *)
    echo "Unbekannte Distribution: ${ID}"
    exit 1
    ;;
esac

## Update package indices
sudo apt-get update -y

## Install Erlang packages
sudo apt-get install -y erlang-base \
                        erlang-asn1 erlang-crypto erlang-eldap erlang-ftp erlang-inets \
                        erlang-mnesia erlang-os-mon erlang-parsetools erlang-public-key \
                        erlang-runtime-tools erlang-snmp erlang-ssl \
                        erlang-syntax-tools erlang-tftp erlang-tools erlang-xmerl

## Install rabbitmq-server and its dependencies
sudo apt-get install rabbitmq-server librabbitmq-dev -y --fix-missing

## Installation PostgreSQL
. /etc/os-release
case "${ID}" in
      debian|ubuntu|tuxedo)
        apt-get install -y postgresql postgresql-client libpq-dev
        ;;
      *)
        echo "Unbekannte Distribution: ${ID}"
        exit 1
        ;;
esac
sudo systemctl enable --now postgresql
