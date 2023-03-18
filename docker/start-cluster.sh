#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd -P)

set -o nounset
set -o errexit


docker exec -it -u hduser hadoop1 bash -c "/opt/hadoop/sbin/start-dfs.sh"


docker exec -it -u hduser hadoop1 bash -c "nohup /opt/hadoop/sbin/start-yarn.sh"


docker exec -i -u hduser hadoop1 bash <<'EOF'
# source /etc/profile by manual
source /etc/profile
# 启动metastore
mkdir -p /opt/hadoop/logs
hive --service metastore --hiveconf hive.root.logger=INFO,console > /opt/hadoop/logs/metastore.log 2>&1 &


# 启动hiveserver2
mkdir -p /opt/hadoop/logs
hive --service hiveserver2 --hiveconf hive.root.logger=INFO,console > /opt/hadoop/logs/hiveserver2.log 2>&1 &
EOF


sleep 5s

docker exec -i -u hduser hadoop1 bash<<EOF
source /etc/profile
ss -tunlp
jps -mlvV
EOF