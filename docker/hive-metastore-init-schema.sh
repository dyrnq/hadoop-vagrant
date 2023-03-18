#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)

set -o nounset
set -o errexit


docker exec -i postgres bash <<EOF
if [ \$(psql -tA --username "postgres" -c "select count(1) from pg_database where datname='metastore_db'") = "0" ]; then
    psql -v ON_ERROR_STOP=1 --username "postgres" --no-password -c "create database metastore_db with encoding='utf8' TEMPLATE template0;"
else
    echo "metastore_db exists"
fi
EOF

# cd /opt/hive/lib && wget https://maven.aliyun.com/repository/central/org/postgresql/postgresql/42.5.1/postgresql-42.5.1.jar
docker exec -i -u hduser hadoop1 bash <<EOF
cd /opt/hive/bin && ./schematool -initSchema -dbType postgres -verbose
EOF