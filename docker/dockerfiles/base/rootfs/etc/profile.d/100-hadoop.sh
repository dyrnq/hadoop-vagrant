# PDSH Variables START
export PDSH_RCMD_TYPE=ssh
# PDSH Variables END

# HADOOP Variables START
#export HADOOP_HOME=/usr/local/hadoop
export HADOOP_HOME=/opt/hadoop
export HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export YARN_EXAMPLES=$HADOOP_HOME/share/hadoop/mapreduce
export PATH=$PATH:$HADOOP_HOME/bin:$HADOOP_HOME/sbin
# HADOOP Variables END