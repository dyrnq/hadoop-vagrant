#!/usr/bin/env bash
set -eux
docker build --tag base:1 --build-arg CURL_OPTS="" --file Dockerfile .


# ssh-keygen -f "/root/.ssh/known_hosts" -R "[127.0.0.1]:2222"



# docker rm -f hdp || true
# docker run -d -p 2222:22 --name hdp -e TZ=Asia/Shanghai --hostname hadoop base:1 

# sleep 10s;
 
# ssh -i /vagrant/insecure_private_key hduser@127.0.0.1 -p 2222