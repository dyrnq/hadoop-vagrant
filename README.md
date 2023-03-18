# hadoop-vagrant

## tks

- [安瑞哥是码农之大数据项目之用户上网行为分析](https://github.com/Anryg/internet_behavior_project)
- [duartegithub`s vagrant-hadoop-cluster](https://github.com/duartegithub/vagrant-hadoop-cluster)

## introduce

This is a project that attempts to create a working virtual Hadoop cluster with Hadoop + Hive + Spark , using Vagrant and docker.

Streaming ETL (Extract, Transform, Load) is the processing and movement of real-time data from one place to another.

Extract, Load, Transform (ELT) is a data integration process for transferring raw data from a source server to a data system (such as a data warehouse or data lake) on a target server and then preparing the information for downstream uses.

<!--ts-->
- [hadoop-vagrant](#hadoop-vagrant)
  - [tks](#tks)
  - [introduce](#introduce)
  - [requirements](#requirements)
  - [architecture](#architecture)
  - [hadoop](#hadoop)
    - [docker build](#docker-build)
    - [startup containers](#startup-containers)
    - [hdfs cluster](#hdfs-cluster)
    - [yarn cluster](#yarn-cluster)
    - [hive](#hive)
      - [create metastore\_db on postgres](#create-metastore_db-on-postgres)
      - [start metastore and hiveserver2](#start-metastore-and-hiveserver2)
    - [spark](#spark)
    - [jps](#jps)
    - [jdk](#jdk)
    - [vagrant insecure\_private\_key](#vagrant-insecure_private_key)
    - [columes of data](#columes-of-data)
  - [ref](#ref)
<!--te-->

## requirements

- VirtualBox
- Vagrant
- Docker

## architecture

| container     | role                      | ip          | xxx_home           | image                         |
|---------------|---------------------------|-------------|--------------------|-------------------------------|
| zoo1          | zookeeper cluster         | 172.21.0.3  | /bitnami/zookeeper | bitnami/zookeeper:3.8.0       |
| zoo2          | zookeeper cluster         | 172.21.0.4  | /bitnami/zookeeper | bitnami/zookeeper:3.8.0       |
| zoo3          | zookeeper cluster         | 172.21.0.5  | /bitnami/zookeeper | bitnami/zookeeper:3.8.0       |
| zoonavigator  | zoonavigator              | 172.21.0.6  |                    | elkozmon/zoonavigator:latest  |
| gendata       | gendata                   | 172.21.0.7  |                    | golang:1.19.4-bullseye        |
| filebeat      | filebeat                  | 172.21.0.8  |                    | elastic/filebeat:8.5.3        |
| kafka-ui      | kafka-ui                  | 172.21.0.9  |                    | provectuslabs/kafka-ui:latest |
| adminer       | adminer                   | 172.21.0.10 |                    | adminer:4.8.1                 |
| mysql         | mysql(standalone)         | 172.21.0.11 |                    | debezium/example-mysql:1.1    |
| postgres      | postgres(standalone)      | 172.21.0.12 |                    | debezium/example-postgres:1.1 |
| elasticsearch | elasticsearch(standalone) | 172.21.0.13 |                    | elastic/elasticsearch:7.6.0   |
| kibana        | kibana                    | 172.21.0.14 |                    | elastic/kibana:7.6.0          |
| redis         | redis(standalone)         | 172.21.0.15 |                    | redis:6.2.6                   |
| hadoop1       | hdfs: NameNode, yarn: RM  | 172.21.0.21 | /opt/hadoop        |                               |
| hadoop2       | hdfs: DataNode, yarn: NM  | 172.21.0.22 | /opt/hadoop        |                               |
| hadoop3       | hdfs: DataNode, yarn: NM  | 172.21.0.23 | /opt/hadoop        |                               |
| hadoop4       | hdfs: DataNode, yarn: NM  | 172.21.0.24 | /opt/hadoop        |                               |
| kafka1        | kafka cluster             | 172.21.0.31 | /bitnami/kafka     | bitnami/kafka:3.3             |
| kafka2        | kafka cluster             | 172.21.0.32 | /bitnami/kafka     | bitnami/kafka:3.3             |
| kafka3        | kafka cluster             | 172.21.0.33 | /bitnami/kafka     | bitnami/kafka:3.3             |

## hadoop

### docker build

```bash
export VAGRANT_EXPERIMENTAL="disks"
vagrant up
vagrant ssh
cd /vagrant/docker/dockerfiles/base
build.sh
```

### startup containers

```bash
cd /vagrant/docker
./run.sh
```

### hdfs cluster

```bash
docker exec -it -u hduser hadoop1 bash -c "/opt/hadoop/sbin/start-dfs.sh"
```

### yarn cluster

```bash
docker exec -it -u hduser hadoop1 bash -c "nohup /opt/hadoop/sbin/start-yarn.sh"
```

### hive

#### create metastore_db on postgres

```bash

docker exec -it postgres bash

if [ $(psql -tA --username "postgres" -c "select count(1) from pg_database where datname='metastore_db'") = "0" ]; then
    psql -v ON_ERROR_STOP=1 --username "postgres" --no-password -c "create database metastore_db with encoding='utf8' TEMPLATE template0;"
else
    echo "metastore_db exists"
fi


docker exec -it -u hduser hadoop1 bash
# cd /opt/hive/lib && wget https://maven.aliyun.com/repository/central/org/postgresql/postgresql/42.5.1/postgresql-42.5.1.jar

cd /opt/hive/bin && ./schematool -initSchema -dbType postgres -verbose
```

#### start metastore and hiveserver2

```bash
docker exec -it -u hduser hadoop1 bash

# source /etc/profile by manual
. /etc/profile

# 启动metastore
mkdir -p /opt/hadoop/logs
hive --service metastore --hiveconf hive.root.logger=INFO,console > /opt/hadoop/logs/metastore.log 2>&1 &


# 启动hiveserver2
mkdir -p /opt/hadoop/logs
hive --service hiveserver2 --hiveconf hive.root.logger=INFO,console > /opt/hadoop/logs/hiveserver2.log 2>&1 &
```

```bash
# 启动 hive cli
hive --service cli
```

### spark

```bash
hdfs dfs -mkdir /spark-logs
YARN_CONF_DIR=/opt/hadoop/etc/hadoop SPARK_HOME=/opt/spark $SPARK_HOME/bin/spark-submit --class org.apache.spark.examples.SparkPi --master yarn --deploy-mode client $SPARK_HOME/examples/jars/spark-examples*.jar 10
```

### jps

```bash
vagrant@hadoop:/vagrant/docker$ docker exec -it -user hduser hadoop1 bash -c "/usr/local/jvm/java-8-openjdk-amd64/bin/jps"
385 SecondaryNameNode
950 Jps
233 NameNode
606 ResourceManager
vagrant@hadoop:/vagrant/docker$ docker exec -it -user hduser hadoop2 bash -c "/usr/local/jvm/java-8-openjdk-amd64/bin/jps"
113 DataNode
211 NodeManager
313 Jps
vagrant@hadoop:/vagrant/docker$ docker exec -it -user hduser hadoop3 bash -c "/usr/local/jvm/java-8-openjdk-amd64/bin/jps"
113 DataNode
211 NodeManager
312 Jps
vagrant@hadoop:/vagrant/docker$ docker exec -it -user hduser hadoop4 bash -c "/usr/local/jvm/java-8-openjdk-amd64/bin/jps"
113 DataNode
211 NodeManager
313 Jps
```

### jdk

- <https://www.azul.com/downloads/>
- <https://github.com/corretto/corretto-11>
- <https://github.com/corretto/corretto-8>
- <https://github.com/adoptium/temurin11-binaries>
- <https://github.com/adoptium/temurin8-binaries/>

### vagrant insecure_private_key

The vms and containers use the same insecure_private_key and insecure_public_key from hashicorp vagrant.

[https://github.com/hashicorp/vagrant/tree/main/keys](https://github.com/hashicorp/vagrant/tree/main/keys)

### columes of data

| 列               | 说明                                                                                                                                        |
|------------------|--------------------------------------------------------------------------------------------------------------------------------------------|
| client_ip        | 指上网用户的ip地址，你可以根据这个ip知道这个用户大概的位置信息，这个有专门的api可以查询                                                                 |
| domain           | 指上网人要上的网站地址，你可以根据该网站的性质来判断这个人的上网行为                                                                                  |
| time             | 上网人的上网时间                                                                                                                             |
| target_ip        | 上网人要上的网站的目标ip地址                                                                                                                   |
| rcode            | 网站返回状态码，0为正常响应，2为不正常                                                                                                           |
| query_type       | 查询类型，几乎都是1，即正常上网行为                                                                                                              |
| authority_recode | 网站服务器真正返回的域名，可能跟domain不一样，如果不一样的话，可能说明是个钓鱼网站之类的，你可以去分析分析                                                  |
| add_msg          | 附加信息，几乎都为空，你可以看看如果有内容的话，到底是什么玩意                                                                                        |
| dns_ip           | 当前要上的这个网站由哪个DNS服务器给提供的解析，一般一个DNS服务器会服务一个区域，如果由同一个DNS服务器进行解析的，说明他们在同一片大的区域                        |

## ref

- [Deprecated Properties](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-common/DeprecatedProperties.html)
- [HDFS High Availability Using the Quorum Journal Manager](https://hadoop.apache.org/docs/stable/hadoop-project-dist/hadoop-hdfs/HDFSHighAvailabilityWithQJM.html)
- [ResourceManager High Availability](https://hadoop.apache.org/docs/stable/hadoop-yarn/hadoop-yarn-site/ResourceManagerHA.html)
- [How to define multiple disks inside Vagrant using VirtualBox provider](https://sleeplessbeastie.eu/2021/05/10/how-to-define-multiple-disks-inside-vagrant-using-virtualbox-provider/)
