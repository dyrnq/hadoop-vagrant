#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)

set -o nounset
set -o errexit

DEBUG=${DEBUG:-}

while [ $# -gt 0 ]; do
    case "$1" in
        --verbose|--debug)
            DEBUG=0;
            ;;
        --iface|-i)
            iface="$2"
            shift
            ;;
        --*)
            echo "Illegal option $1"
            ;;
    esac
    shift $(( $# > 0 ? 1 : 0 ))
done

command_exists() {
    command -v "$@" > /dev/null 2>&1
}



is_debug() {
    if [ -z "$DEBUG" ]; then
        return 1
    else
        return 0
    fi
}


if is_debug ; then
    set -x
else
    set +x
fi


docker network create --subnet=172.21.0.0/16 superman 2>/dev/null || true

docker network list

docker compose down --remove-orphans || true


sudo mkdir -p /data/filebeat

sudo rm -rf /data/filebeat/filebeat.csv.to.kafka.yml

sudo bash -c 'cat << EOF > /data/filebeat/filebeat.csv.to.kafka.yml
filebeat.inputs:
- type: log
  enabled: true
  paths:
    - /dev/shm/staging.csv
output.kafka:
  hosts: ["kafka1:9092", "kafka2:9092", "kafka3:9092"]
  topic: test
  #version: 2.0.0
EOF'

sudo chown 0 /data/filebeat/filebeat.csv.to.kafka.yml
sudo chmod go-w /data/filebeat/filebeat.csv.to.kafka.yml

sudo mkdir -p /data/zoo/data1
sudo mkdir -p /data/zoo/data2
sudo mkdir -p /data/zoo/data3
sudo mkdir -p /data/postgres-data
sudo mkdir -p /data/mysql-data
sudo mkdir -p /data/kafka_data/kafka1
sudo mkdir -p /data/kafka_data/kafka2
sudo mkdir -p /data/kafka_data/kafka3
sudo mkdir -p /data/hadoop_data/hadoop1
sudo mkdir -p /data/hadoop_data/hadoop2
sudo mkdir -p /data/hadoop_data/hadoop3
sudo mkdir -p /data/hadoop_data/hadoop4


sudo chown -R 1001:1001 /data/zoo
sudo chown -R 1001:1001 /data/kafka_data
sudo chown -R 1001:1001 /data/kafka_data
sudo chown -R 1000:1000 /data/hadoop_data

sudo chmod -R a+w /data/hadoop_data



sudo chown -R 999:999 /data/postgres-data
sudo chown -R 999:999 /data/mysql-data

docker compose up -d
