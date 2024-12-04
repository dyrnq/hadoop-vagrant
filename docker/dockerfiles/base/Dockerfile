#FROM ubuntu:jammy
FROM ubuntu:focal
#FROM debian:bullseye

ARG user=hduser
ARG group=hadoop
ARG uid=1000
ARG gid=1000
ARG GIT_VERSION
ARG GITLFS_VERSION
ARG GOSU_VERSION
ARG S6_OVERLAY_VERSION
ARG DOCKER_VERSION
ARG PCRE2_VERSION
ARG RG_VERSION
ARG YQ_VERSION
ARG FD_VERSION
ARG CURL_OPTS

ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.utf8 \
    GIT_VERSION=${GIT_VERSION:-2.38.1} \
    GITLFS_VERSION=${GITLFS_VERSION:-3.2.0} \
    GOSU_VERSION=${GOSU_VERSION:-1.16} \
    S6_OVERLAY_VERSION=${S6_OVERLAY_VERSION:-3.1.2.1} \
    DOCKER_VERSION=${DOCKER_VERSION:-20.10.21} \
    PCRE2_VERSION=${PCRE2_VERSION:-10.40} \
    RG_VERSION=${RG_VERSION:-13.0.0} \
    YQ_VERSION=${YQ_VERSION:-v4.25.2} \
    FD_VERSION=${FD_VERSION:-8.4.0} \
    HADOOP_HOME=${HADOOP_HOME:-/opt/hadoop} \
    HIVE_HOME=${HIVE_HOME:-/opt/hive} \
    SPARK_HOME=${SPARK_HOME:-/opt/spark}


RUN set -eux; \
    apt-get clean && \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get install -yq \
    apt-transport-https \
    bash-completion \
    bridge-utils \
    ca-certificates \
    conntrack \
    curl \
    difference \
    fontconfig \
    gettext \
    git \
    git-lfs \
    gnupg2 \
    htop \
    iftop \
    iproute2 \
    ipset \
    iptables \
    ipvsadm \
    iputils-ping \
    jq \
    less \
    less \
    libfreetype6-dev \
    locales \
    lrzsz \
    lsof \
    mtr \
    netcat \
    net-tools \
    nmap \
    nmap-common \
    openssh-client \
    openssh-server \
    procps \
    psmisc \
    rsync \
    socat \
    software-properties-common \
    sudo \
    sysstat \
    tar \
    tcpdump \
    telnet \
    tree \
    unzip \
    vim \
    wget \
    xfsprogs \
    xz-utils \
    && \
    localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
    groupadd -g ${gid} ${group} && useradd -u ${uid} -g ${gid} -m -s /bin/bash ${user} && \
    echo "${user}:${user}" | chpasswd && \
    echo "${user} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${user}





RUN set -eux; \
    ARCH="$(uname -m)"; \
    case "${ARCH}" in \
       aarch64|arm64) \
         dockerArch="aarch64"; \
         s6overlayArch="aarch64"; \
         gosuArch="arm64"; \
         lfsArch="arm64"; \
         ;; \
       armhf|armv7l) \
         dockerArch="armhf"; \
         s6overlayArch="armhf"; \
         gosuArch="armhf"; \
         lfsArch="arm"; \
         c_rehash /etc/ssl/certs; \
         ;; \
       ppc64el|ppc64le) \
         dockerArch="ppc64le"; \
         s6overlayArch="ppc64le"; \
         gosuArch="ppc64el"; \
         lfsArch="ppc64le"; \
         ;; \
       amd64|x86_64) \
         dockerArch="x86_64"; \
         s6overlayArch="x86_64"; \
         gosuArch="amd64"; \
         lfsArch="amd64"; \
         ;; \
       *) \
         echo "Unsupported arch: ${ARCH}"; \
         exit 1; \
         ;; \
    esac; \
    curl ${CURL_OPTS} --retry 3 -fsSL https://github.com/atkrad/wait4x/releases/download/v2.9.1/wait4x-linux-amd64.tar.gz | tar -xvz -C /usr/local/bin wait4x; \
    curl ${CURL_OPTS} --retry 3 -fsSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-${s6overlayArch}.tar.xz | tar -Jxpv -C /; \
    curl ${CURL_OPTS} --retry 3 -fsSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz | tar -Jxpv -C /; \
    curl ${CURL_OPTS} --retry 3 -fsSL https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz | tar -Jxpv -C /; \
    curl ${CURL_OPTS} --retry 3 -fsSL https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$gosuArch -o /usr/local/bin/gosu; \
    curl ${CURL_OPTS} --retry 3 -fsSL https://github.com/BurntSushi/ripgrep/releases/download/${RG_VERSION}/ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl.tar.gz | tar -xzv --strip-components=1 -C /usr/local/bin/ ripgrep-${RG_VERSION}-x86_64-unknown-linux-musl/rg;  \
    curl ${CURL_OPTS} --retry 3 -fsSL https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64.tar.gz | tar -xzv --strip-components=1 -C /usr/local/bin/ --transform "s/yq_linux_amd64/yq/";  \
    curl ${CURL_OPTS} --retry 3 -fsSL https://github.com/sharkdp/fd/releases/download/v${FD_VERSION}/fd-v${FD_VERSION}-x86_64-unknown-linux-gnu.tar.gz | tar -xzv --strip-components=1 -C /usr/local/bin/ fd-v${FD_VERSION}-x86_64-unknown-linux-gnu/fd;  \
    chmod +x /usr/local/bin/yq; \
    chmod +x /usr/local/bin/fd; \
    chmod +x /usr/local/bin/rg; \
    chmod +x /usr/local/bin/gosu; \
    chmod +x /usr/local/bin/wait4x; \
    gosu --version;



RUN cp /etc/ssh/sshd_config /etc/ssh/sshd_config_back && cp /etc/pam.d/sshd /etc/pam.d/sshd_back
RUN \
mkdir /run/sshd && \
sed -i 's|^#PermitRootLogin .*|PermitRootLogin yes|g' /etc/ssh/sshd_config; \
sed -i 's|^#MaxSessions .*|MaxSessions 1000|g' /etc/ssh/sshd_config; \
sed -i 's|^#MaxStartups .*|MaxStartups 1000|g' /etc/ssh/sshd_config; \
sed -ri 's/^#?PubkeyAuthentication\s+.*/PubkeyAuthentication yes/' /etc/ssh/sshd_config; \
sed -i 's|^UsePAM .*|UsePAM no|g' /etc/ssh/sshd_config;


# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile


RUN \
mkdir -p /usr/local/jvm/java-8-openjdk-amd64 && \
mkdir -p /usr/local/jvm/java-11-openjdk-amd64 && \
mkdir -p ${HADOOP_HOME} && \
mkdir -p ${HIVE_HOME} && \
mkdir -p ${SPARK_HOME} && \
curl ${CURL_OPTS} --retry 3 -fSL -# https://github.com/adoptium/temurin11-binaries/releases/download/jdk-11.0.25%2B9/OpenJDK11U-jdk_x64_linux_hotspot_11.0.25_9.tar.gz | tar -xvz --strip-components 1 -C /usr/local/jvm/java-11-openjdk-amd64 && \
curl ${CURL_OPTS} --retry 3 -fSL -# https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u432-b06/OpenJDK8U-jdk_x64_linux_hotspot_8u432b06.tar.gz | tar -xvz --strip-components 1 -C /usr/local/jvm/java-8-openjdk-amd64 && \
curl ${CURL_OPTS} --retry 3 -fSL -# https://archive.apache.org/dist/hadoop/common/hadoop-3.3.0/hadoop-3.3.0.tar.gz | tar -xvz --strip-components 1 -C ${HADOOP_HOME} && \
curl ${CURL_OPTS} --retry 3 -fSL -# https://archive.apache.org/dist/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz | tar -xvz --strip-components 1 -C ${HIVE_HOME} && \
curl ${CURL_OPTS} --retry 3 -fSL -# https://archive.apache.org/dist/spark/spark-3.3.2/spark-3.3.2-bin-hadoop3.tgz | tar -xvz --strip-components 1 -C ${SPARK_HOME} && \
echo ""



COPY rootfs /

RUN mkdir -p /home/${user}/.ssh && mkdir -p /data/hadoop
COPY .ssh /home/${user}/.ssh/

RUN \
chown -R ${user}:${group} /home/${user} && \
chown -R ${user}:${group} ${HADOOP_HOME} && \
chown -R ${user}:${group} ${HIVE_HOME} && \
chown -R ${user}:${group} ${SPARK_HOME} && \
chown -R ${user}:${group} /data/hadoop && \
chmod 600 /home/${user}/.ssh/id_rsa.pub && \
chmod 600 /home/${user}/.ssh/id_rsa && \
chmod 644 /home/${user}/.ssh/authorized_keys && \
chmod 700 /home/${user}/.ssh

EXPOSE 22
VOLUME [ "/data/hadoop" ]


ENTRYPOINT ["/init"]