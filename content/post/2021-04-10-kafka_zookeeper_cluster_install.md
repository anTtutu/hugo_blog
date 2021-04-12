---
title: "kafka集群和zk集群搭建"
date: 2021-04-10T00:29:47+08:00
tags: [ "kafka", "zookeeper", "zk" ]
description: "kafka集群和zk集群搭建"
categories: [ "kafka", "zookeeper", "zk" ]
toc: true
---

## 1、前言
一台应用的第三方服务器的kafka只有3个分区，测试一直存在积压的消息，搭建了一套最简单集群测试下，记录中间的参数。

## 2、准备工作
环境准备
环境|版本|说明
-|-|-
centos|7.0|操作系统服务器，3台
JDK|1.8.261|安装好jdk并设置好环境变量
zookeeper|3.4.9|zk官方安装包
kafka|2.2.0_2.12|kafka官方安装包

服务器
IP|端口|说明
-|-|-
192.168.211.125|zk:2181<br>zk heartbeat:2888、3888<br>kafka:9092|zk默认端口<br>zk心跳默认端口<br>kafka默认监听端口
192.168.211.126|zk:2181<br>zk heartbeat:2888、3888<br>kafka:9092|zk默认端口<br>zk心跳默认端口<br>kafka默认监听端口
192.168.211.127|zk:2181<br>zk heartbeat:2888、3888<br>kafka:9092|zk默认端口<br>zk心跳默认端口<br>kafka默认监听端口

目录规划
中间件|安装目录|数据目录|日志目录|说明
-|-|-|-|-
jdk|/home/jdk_version|-|-|Oracle jdk是直接tgz解压的，只需要安装目录<br>openjdk不需要这个目录规划
zk|/home/zookeeper_version|/opt/data/zookeeper|/opt/data/zookeeper/zkdata<br>/opt/data/zookeeper/zklogs|zkdata是zk的数据目录，zklogs是日志目录
kafka|/home/kafaka_version|/opt/data/kafka|/opt/data/kafka/kafka_logs|kafka_logs是日志目录

## 3、下载zk
官网：https://archive.apache.org/dist/zookeeper/zookeeper-3.4.9/  
下载地址：https://archive.apache.org/dist/zookeeper/zookeeper-3.4.9/zookeeper-3.4.9.tar.gz

## 4、下载kafka
官网：http://kafka.apache.org/  
下载地址：https://archive.apache.org/dist/kafka/2.2.0/kafka_2.12-2.2.0.tgz

## 5、安装jdk
这些作为java开发来说，很简单，只是简单记录下步骤，不做过多解释
### 5.1 安装openjdk
```bash
yum install java-1.8.0-openjdk
```
### 5.2 安装Oracle jdk
```bat
https://www.oracle.com/java/technologies/javase/javase-jdk8-downloads.html
```

### 5.3 配置环境变量
新增JAVA_HOME、JRE_HOME并设置到PATH
```bash
vi ~/.bash_profile
JAVA_HOME=/home/jdk1.8.0_281
PATH=$PATH:$HOME/bin:$JAVA_HOME/bin
```

### 5.4 测试环境变量
```bash
java -version

java version "1.8.0_281"
Java(TM) SE Runtime Environment (build 1.8.0_281-b09)
Java HotSpot(TM) 64-Bit Server VM (build 25.281-b09, mixed mode)
```

## 6、安装zk集群
```bash
tar -zvxf zookeeper-3.4.9.tar.gz
```

### 6.1、配置参数
```bash
cd /home/zookeeper-3.4.9/conf
cp zoo_sample.cfg zoo.cfg

# 新增数据目录、日志目录、集群地址
vim zoo.cfg 

dataDir=/opt/data/zookeeper/zkdata
dataLogDir=/opt/data/zookeeper/zklogs

server.1=192.168.211.125:2888:3888
server.2=192.168.211.126:2888:3888
server.3=192.168.211.127:2888:3888

# 创建好规划的目录
mkdir -p /opt/data/zookeeper/zkdata
mkdir -p /opt/data/zookeeper/zklogs

# 创建集群id文件
touch /opt/data/zookeeper/zkdata/myid

echo 1 > /opt/data/zookeeper/zkdata/myid  #192.168.211.125
echo 2 > /opt/data/zookeeper/zkdata/myid  #192.168.211.126
echo 3 > /opt/data/zookeeper/zkdata/myid  #192.168.211.127
```
注：没单独说明的3台都重复一样的安装步骤，只myid注意id值3台不一样

### 6.2、启动zk集群
```bash
cd /home/zookeeper-3.4.9/bin
./zkServer.sh start
```

### 6.2、测试zk集群状态
```bash
cd /home/zookeeper-3.4.9/bin
./zkServer.sh status

# 192.168.211.125
ZooKeeper JMX enabled by default
Using config: /home/zookeeper-3.4.9/bin/../conf/zoo.cfg
Mode: follower

# 192.168.211.126
ZooKeeper JMX enabled by default
Using config: /home/zookeeper-3.4.9/bin/../conf/zoo.cfg
Mode: follower

# 192.168.211.127
ZooKeeper JMX enabled by default
Using config: /home/zookeeper-3.4.9/bin/../conf/zoo.cfg
Mode: leader
```
注：zk集群可以通过状态判断，必须有一个leader，其他事follewer，如果出现其他状态表示配置有错误需要排查，一般集群没组成是单机模式standalone
mode|说明
-|-
leader|主节点
follower|从节点
standalone|单机

## 7、安装kafka集群
```bash
tar -zvxf kafka_2.12-2.2.0.tgz 
```

### 7.1、配置参数
```bash
cd /home/kafka_2.12-2.2.0/config
vim server.properties

broker.id=0   #192.168.211.125
broker.id=1   #192.168.211.126
broker.id=2   #192.168.211.127

#192.168.211.125
listeners=PLAINTEXT://192.168.211.125:9092
advertised.listeners=PLAINTEXT://192.168.211.125:9092
#192.168.211.126
listeners=PLAINTEXT://192.168.211.126:9092
advertised.listeners=PLAINTEXT://192.168.211.126:9092
#192.168.211.127
listeners=PLAINTEXT://192.168.211.127:9092
advertised.listeners=PLAINTEXT://192.168.211.127:9092

log.dirs=/opt/data/kafka/kafka_logs

num.partitions=9

zookeeper.connect=192.168.211.125:2181,192.168.211.126:2181,192.168.211.127:2181

# 创建好规划的目录
mkdir -p /opt/data/kafka/kafka_logs
```
注：没单独说明的3台都重复一样的安装步骤，只注意broker.id需要不一样、listeners和advertised.listeners本机的监听ip不一样

### 7.2、启动kafka集群
```bash
cd /home/kafka_2.12-2.2.0/bin
nohup ./kafka-server-start.sh /home/kafka_2.12-2.2.0/config/server.properties &
```

## 8、检测kafka工作情况
前面的集群都搭建好了，开始进行kafka的工作校验了
### 8.1、创建topic
```bash
./kafka-topics.sh --zookeeper 192.168.211.125:2181,192.168.211.126:2181,192.168.211.127:2181 --create --replication-factor 1 --partitions 1 --topic test
```

### 8.2、查询创建的topic
```bash
./kafka-topics.sh --zookeeper 192.168.211.125:2181,192.168.211.126:2181,192.168.211.127:2181 --list

__consumer_offsets
test
```

### 8.4、测试生产端
```bash
./kafka-console-producer.sh --broker-list 192.168.211.127:9092 --topic test
```

### 8.5、测试消费端
```bash
./kafka-console-consumer.sh --bootstrap-server 192.168.211.126:9092 --topic test --from-beginning

./kafka-console-consumer.sh --bootstrap-server 192.168.211.125:9092 --topic test --from-beginning
```

### 8.6、发送测试数据
```bash
./kafka-console-producer.sh --broker-list 192.168.211.127:9092 --topic test
>1
>2
>3
>4
>5
>6
>7
>8
>9
>10
```
同步的2个从节点数据会同步接收，参考下图
127-producer：
![](/posts/kafka/producer.png)
125-consumer：
![](/posts/kafka/consumer_125.png)
126-consumer：
![](/posts/kafka/consumer_126.png)

### 8.7、监控topic
```bash
./kafka-topics.sh --zookeeper 192.168.211.125:2181,192.168.211.126:2181,192.168.211.127:2181 --describe --topic test
```

## 9、性能测试结果
性能测试结果等后续整理补充...
