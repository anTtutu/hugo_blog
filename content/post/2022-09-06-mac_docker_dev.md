---
title: "Mac配置docker开发工具"
date: 2022-09-06T00:29:47+08:00
tag : [ "docker", "mac" ]
description: "Mac配置docker开发工具"
categories: [ "docker", "mac" ]
toc: true
---

## 前言
2020年整了一套android下的termux开发环境，今天继续配置一套docker下的开发环境。[termux搭建参考](/post/2020-09-28-android_termux)

开发电脑环境准备如下：
系统|版本
-|-
MacOS|10.14.6
docker|20.10.12

待安装的开发工具环境如下：
镜像|版本
-|-
mongo|6.0
redis|7.0
mysql|8.0
nginx|1.22.0
minio|latest
etcd|latest

## 1、查询docker进程
```bash
launchctl list | grep docker
-	0	com.docker.helper
14047	0	com.docker.docker.47840
```

## 2、停止、启动docker进程
```bash
launchctl stop com.docker.docker.47840 && launchctl start com.docker.docker.47840
```

## 3、启动docker
```bash
open /Applications/Docker.app
```

#### PS:
>目前通过 open /Applications/Docker.app 可以启动，通过 launchctl start com.docker.docker.xxx 方式不能启动了。
>
>测试环境信息如下:
>
>系统|版本
>-|-
>MacOS|10.14.6
>docker|20.10.12
>
>测试时间: 2022-09-06

## 4、docker的镜像存储位置
```bash
Windows:
打开docker desktop界面设置，
Settings -> Resources -> Advanced -> Disk image location

Linux:
cd /var/lib/docker - 容器与镜像存放在此目录下
镜像位置: /var/lib/docker/image
容器位置: /var/lib/docker/containers

MacOS:
容器和镜像在如下目录下,不同版本或许可能文件版本不一样
/Users/{whoami}/Library/Containers/com.docker.docker/Data
可以到上面的目录中，查看文件大小, du -sh *
本机存放位置如下
/Users/{whoami}/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw
```

## 5、准备环境
```bash
# docker script
mkdir -p /Users/{whoami}/Downloads/Docker/shell
# mysql
mkdir -p /Users/{whoami}/Downloads/Docker/mysql
mkdir -p /Users/{whoami}/Downloads/Docker/mysql/config
mkdir -p /Users/{whoami}/Downloads/Docker/mysql/data
mkdir -p /Users/{whoami}/Downloads/Docker/mysql/log
# redis
mkdir -p /Users/{whoami}/Downloads/Docker/redis
mkdir -p /Users/{whoami}/Downloads/Docker/redis/config
mkdir -p /Users/{whoami}/Downloads/Docker/redis/data
mkdir -p /Users/{whoami}/Downloads/Docker/redis/log
# mongo
mkdir -p /Users/{whoami}/Downloads/Docker/mongo
mkdir -p /Users/{whoami}/Downloads/Docker/mongo/config
mkdir -p /Users/{whoami}/Downloads/Docker/mongo/data
mkdir -p /Users/{whoami}/Downloads/Docker/mongo/log
# nginx
mkdir -p /Users/{whoami}/Downloads/Docker/nginx
mkdir -p /Users/{whoami}/Downloads/Docker/nginx/conf
mkdir -p /Users/{whoami}/Downloads/Docker/nginx/conf.d
mkdir -p /Users/{whoami}/Downloads/Docker/mongo/log
mkdir -p /Users/{whoami}/Downloads/Docker/mongo/html
mkdir -p /Users/{whoami}/Downloads/Docker/mongo/cert
# minio
mkdir -p /Users/{whoami}/Downloads/Docker/minio
mkdir -p /Users/{whoami}/Downloads/Docker/minio/config
mkdir -p /Users/{whoami}/Downloads/Docker/minio/data
# etcd
mkdir -p /Users/{whoami}/Downloads/Docker/etcd
mkdir -p /Users/{whoami}/Downloads/Docker/etcd/conf
mkdir -p /Users/{whoami}/Downloads/Docker/etcd/data

# 复制时区文件，解决mysql镜像容器运行时区是0问题
cp /etc/localtime /Users/{whoami}/Downloads/Docker/mysql/
```

## 6、准备配置文件
1、my.cnf直接参考步骤9创建并写入关键参数配置  
[步骤10](#jump10)  
2、下载redis.7版本包，提取redis.conf，然后参考步骤16修改配置  
[步骤17](#jump17)  
3、mongod.conf直接参考步骤22创建并写入关键参数配置  
[步骤23](#jump23)  
4、nginx.conf直接参考步骤29创建并写入关键参数配置  
[步骤29](#jump29)

## 7、准备脚本
docker-show-repo-tag.sh
```bash
# 用镜像v2接口进行解析，需要安装bash的json库
# 安装支持bash的json库-jq
brew install jq

# 脚本内容如下：
repo_url=https://registry.hub.docker.com/v2/repositories/library
image_name=$1

curl -L -s ${repo_url}/${image_name}/tags?page_size=1024 | jq '.results[]["name"]' | sed 's/\"//g' | sort -u

# 下面步骤中提到的脚本也可以搜集整理在这里，其他脚本
ls -lar
total 120
-rwx------@  1 test  staff  314  9  6 16:27 docker-show-repo-tag.sh
-rwx------@  1 test  staff  406  9  6 20:35 docker-redis-7.0-run.sh
-rwx------@  1 test  staff  469  9  7 00:58 docker-mongo-6.0-run.sh
-rwx------@  1 test  staff  357  9  7 11:39 docker-start-container.sh
-rwx------   1 test  staff  149  9  8 18:02 docker-python-demo-v1.0-run.sh
-rwx------   1 test  staff  147  9  8 18:04 docker-nodejs-demo-v1.0-run.sh
-rwx------   1 test  staff  145  9  8 18:08 docker-java-demo-v1.0-run.sh
-rwx------   1 test  staff  146  9  9 14:29 docker-go-demo-v1.0-run.sh
-rwx------   1 test  staff  180  9 20 14:55 docker-getting-started-laster-run.sh
-rwx------   1 test  staff  557  9 27 21:48 demo.sh
-rwx------   1 test  staff  548  9 28 11:29 docker-nginx-1.22.0-run.sh
-rwx------@  1 test  staff  590  9 29 19:26 docker-mysql-8.0-run.sh
-rwx------@  1 test  staff  356  9 30 17:02 docker-stop-container.sh
-rwx------   1 test  staff  347 10  2 18:02 docker-minio-latest-run.sh
-rwx------@  1 test  staff  550 10  2 19:09 docker-etcd-latest-run.sh
drwxr-xr-x  10 test  staff  320 10  2 16:20 ..
drwxr-xr-x  17 test  staff  544 10  2 19:12 .

# 给700权限
chmod 700 *.sh
```

## 8、mysql
### 8.1 查询mysql镜像的所有tags
```bash
cd /Users/{whoami}/Downloads/Docker/shell
./docker-show-repo-tag.sh mysql
5
5-debian
5-oracle
5.5
5.5.55
5.5.56
5.5.57
5.5.58
5.5.59
5.5.60
5.5.61
5.5.62
5.6
5.6.36
5.6.37
5.6.38
5.6.39
5.6.40
5.6.41
5.6.42
5.6.43
5.6.44
5.6.45
5.6.46
5.6.47
5.6.48
5.6.49
5.6.50
5.6.51
5.7
5.7-debian
5.7-oracle
5.7.18
5.7.19
5.7.20
5.7.21
5.7.22
5.7.23
5.7.24
5.7.25
5.7.26
5.7.27
5.7.28
5.7.29
5.7.30
5.7.31
5.7.32
5.7.33
5.7.34
5.7.35
5.7.36
5.7.37
5.7.37-debian
5.7.37-oracle
5.7.38
5.7.38-debian
5.7.38-oracle
5.7.39
5.7.39-debian
5.7.39-oracle
8
8-debian
8-oracle
8.0
8.0-debian
8.0-oracle
8.0.1
8.0.11
8.0.12
8.0.13
8.0.14
8.0.15
8.0.16
8.0.17
8.0.18
8.0.19
8.0.2
8.0.20
8.0.21
8.0.22
8.0.23
8.0.24
8.0.25
8.0.26
8.0.27
8.0.28
8.0.28-debian
8.0.28-oracle
8.0.29
8.0.29-debian
8.0.29-oracle
8.0.3
8.0.30
8.0.30-debian
8.0.30-oracle
8.0.4
8.0.4-rc
debian
latest
oracle
```

### 8.2 安装mysql需要的tags
以mysql 8.0举例
```bash
docker pull mysql:8.0
```

### 8.3 配置my.cnf
<span id="jump10">my.cnf</span>
```bash
[client]
default-character-set=utf8mb4
[mysqld]
user=mysql
character-set-server=utf8mb4
default_authentication_plugin=mysql_native_password
```

### 8.4 启动mysql容器
提前准备一些参数
```bash
docker run \
-d \
-p 3306:3306 \
--name mysql8 \
--network bridge \
--restart always \
--privileged=true \
-v /Users/{whoami}/Downloads/Docker/mysql/config/my.cnf:/etc/mysql/my.cnf \
-v /Users/{whoami}/Downloads/Docker/mysql/data:/var/lib/mysql \
-v /Users/{whoami}/Downloads/Docker/mysql/log:/logs \
-v /Users/{whoami}/Downloads/Docker/mysql/localtime:/etc/localtime \
-e MYSQL_ROOT_PASSWORD="root123456" \
-e MYSQL_USER="mysql" \
-e MYSQL_PASSWORD="test123456" \
-e character-set-server=utf8 \
-e collation-server=utf8_general_ci \
mysql:8.0
```
参数说明：

参数|说明
-|-
-d|后台运行容器
-p|将容器的3306端口映射到主机的3306端口
--name|MySQL容器名称
--network|网络
–-restart always|开机启动
–-privileged=true|提升容器内权限（false可能会因权限导致无法启动）
-v /Users/{whoami}/Downloads/Docker/mysql/config/my.cnf:/etc/mysql/my.cnf|映射my.cnf
-v /Users/{whoami}/Downloads/Docker/mysql/data:/var/lib/mysql|映射data目录
-v /Users/{whoami}/Downloads/Docker/mysql/log:/logs|映射logs目录
-v /Users/{whoami}/Downloads/Docker/mysql/localtime:/etc/localtime|映射时区，解决容器mysql是0时区问题
-e|设置环境变量:<br>MYSQL_USER：添加用户<br>MYSQL_PASSWORD：设置添加用户密码<br>MYSQL_ROOT_PASSWORD：设置root用户密码<br>character-set-server：设置字符集<br>collation-server：设置字符比较规则<br>
mysql:8.0|mysql(repository) : 8.0(tag)

### 8.5 停止mysql容器
```bash
docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED          STATUS          PORTS                               NAMES
b055811ce23c   mysql:8.0                "docker-entrypoint.s…"   25 minutes ago   Up 25 minutes   0.0.0.0:3306->3306/tcp, 33060/tcp   mysql8
d439c916d2e4   docker/getting-started   "/docker-entrypoint.…"   6 hours ago      Up 6 hours      0.0.0.0:80->80/tcp                  crazy_chatterjee

docker stop b055811ce23c
b055811ce23c
```

### 8.6 启动mysql容器
```bash
docker ps -a
CONTAINER ID   IMAGE                    COMMAND                  CREATED          STATUS                     PORTS                NAMES
b055811ce23c   mysql:8.0                "docker-entrypoint.s…"   29 minutes ago   Exited (0) 3 minutes ago                        mysql8
d439c916d2e4   docker/getting-started   "/docker-entrypoint.…"   6 hours ago      Up 6 hours                 0.0.0.0:80->80/tcp   crazy_chatterjee

docker start b055811ce23c
b055811ce23c
```

### 8.7 进入mysql容器内部
```bash
docker ps -a
CONTAINER ID   IMAGE                    COMMAND                  CREATED          STATUS          PORTS                               NAMES
b055811ce23c   mysql:8.0                "docker-entrypoint.s…"   41 minutes ago   Up 10 minutes   0.0.0.0:3306->3306/tcp, 33060/tcp   mysql8
d439c916d2e4   docker/getting-started   "/docker-entrypoint.…"   6 hours ago      Up 6 hours      0.0.0.0:80->80/tcp                  crazy_chatterjee

docker exec -it b055811ce23c /bin/bash

bash-4.4# echo $PATH
/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
bash-4.4# mysql -uroot -proot123456
mysql: [Warning] Using a password on the command line interface can be insecure.
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 9
Server version: 8.0.30 MySQL Community Server - GPL

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| sys                |
+--------------------+
4 rows in set (0.01 sec)

mysql>
```

## 9、redis
### 9.1 查询redis镜像的所有tags
```bash
cd /Users/{whoami}/Downloads/Docker/shell
./docker-show-repo-tag.sh redis
5
5-32bit
5-32bit-bullseye
5-alpine
5-alpine3.15
5-alpine3.16
5-bullseye
5.0
5.0-32bit
5.0-32bit-bullseye
5.0-alpine
5.0-alpine3.15
5.0-alpine3.16
5.0-bullseye
5.0.14
5.0.14-32bit
5.0.14-32bit-bullseye
5.0.14-alpine
5.0.14-alpine3.15
5.0.14-alpine3.16
5.0.14-bullseye
6
6-alpine
6-alpine3.15
6-alpine3.16
6-bullseye
6.0
6.0-alpine
6.0-alpine3.15
6.0-alpine3.16
6.0-bullseye
6.0.16
6.0.16-alpine
6.0.16-alpine3.15
6.0.16-alpine3.16
6.0.16-bullseye
6.2
6.2-alpine
6.2-alpine3.15
6.2-alpine3.16
6.2-bullseye
6.2.6
6.2.6-alpine
6.2.6-alpine3.15
6.2.6-bullseye
6.2.7
6.2.7-alpine
6.2.7-alpine3.15
6.2.7-alpine3.16
6.2.7-bullseye
7
7-alpine
7-alpine3.15
7-alpine3.16
7-bullseye
7.0
7.0-alpine
7.0-alpine3.15
7.0-alpine3.16
7.0-bullseye
7.0-rc
7.0-rc-alpine
7.0-rc-alpine3.15
7.0-rc-bullseye
7.0-rc1
7.0-rc1-bullseye
7.0-rc2
7.0-rc2-alpine
7.0-rc2-alpine3.15
7.0-rc2-bullseye
7.0-rc3
7.0-rc3-alpine
7.0-rc3-alpine3.15
7.0-rc3-bullseye
7.0.0
7.0.0-alpine
7.0.0-alpine3.15
7.0.0-alpine3.16
7.0.0-bullseye
7.0.1
7.0.1-alpine
7.0.1-alpine3.16
7.0.1-bullseye
7.0.2
7.0.2-alpine
7.0.2-alpine3.16
7.0.2-bullseye
7.0.3
7.0.3-alpine
7.0.3-alpine3.16
7.0.3-bullseye
7.0.4
7.0.4-alpine
7.0.4-alpine3.16
7.0.4-bullseye
alpine
alpine3.15
alpine3.16
bullseye
latest
```

### 9.2 安装redis需要的tags
```bash
docker pull redis:7.0
```

### 9.3 配置redis.conf
<span id="jump17">redis.conf</span>
```bash
#bind 127.0.0.1             #注释掉这部分,使redis可以外部访问
protected-mode no           #修改为no,去掉保护模式,让外网可以访问
daemonize no                #修改为no,不用守护线程的方式启动
requirepass test123456      #密码
appendonly yes              #redis持久化,默认是no
```

### 9.4 启动redis容器
```bash
docker run \
-d \
-p 6379:6379 \
--name redis7 \
--network bridge \
--restart=always \
--privileged=true \
--log-opt max-size=100m \
--log-opt max-file=2 \
-v /Users/{whoami}/Downloads/Docker/redis/config/redis.conf:/etc/redis/redis.conf \
-v /Users/{whoami}/Downloads/Docker/redis/data:/data \
redis:7.0 \
redis-server /etc/redis/redis.conf \
--appendonly yes \
--requirepass test123456
```
参数说明：

参数|说明
-|-
-d|后台运行容器
-p 6379:6379| 把容器内的6379端口映射到宿主机6379端口
--name|redis容器名称
--network|网络
–-restart always|开机启动
–-privileged=true|提升容器内权限（false可能会因权限导致无法启动）
-v /Users/{whoami}/Downloads/Docker/redis/config/redis.conf:/etc/redis/redis.conf| 将到宿主机的文件/Users/{whoami}/Downloads/Docker/redis/config/redis.conf 作为redis容器的配置文件/etc/redis/redis.conf
-v /Users/{whoami}/Downloads/Docker/redis/data:/data|把redis持久化的数据放在宿主机目录/mydata/redis/data中，做数据备份
redis-server /etc/redis/redis.conf|这个是关键配置，让redis不是无配置启动，而是按照这个redis.conf的配置启动
–-appendonly yes|redis启动后数据持久化
--requirepass test123456|redis的密码
redis:7.0|redis(repository) : 7.0(tag)

#### PS:
>经测试，redis:7.0不能放在结尾，需要在 redis-server 命令之前，否着启动会报错
```bash
Unable to find image 'redis-server:latest' locally
docker: Error response from daemon: pull access denied for redis-server, repository does not exist or may require 'docker login': denied: requested access to the resource is denied.
See 'docker run --help'.
```

### 9.5 起停redis容器
```bash
docker ps -a
CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS         PORTS                               NAMES
e7bbf340c66c   redis:7.0                "docker-entrypoint.s…"   8 minutes ago   Up 7 minutes   0.0.0.0:6379->6379/tcp              redis7
b055811ce23c   mysql:8.0                "docker-entrypoint.s…"   4 hours ago     Up 3 hours     0.0.0.0:3306->3306/tcp, 33060/tcp   mysql8
d439c916d2e4   docker/getting-started   "/docker-entrypoint.…"   9 hours ago     Up 9 hours     0.0.0.0:80->80/tcp                  crazy_chatterjee

docker stop e7bbf340c66c
e7bbf340c66c

docker start e7bbf340c66c
e7bbf340c66c
```

### 9.6 进入redis容器内部
```bash
docker exec -it e7bbf340c66c /bin/bash

root@e7bbf340c66c:/data# redis-cli
127.0.0.1:6379> auth test123456
OK
127.0.0.1:6379> get 123
(nil)
127.0.0.1:6379>
```

## 10、mongo 
### 10.1 查询mongo镜像的所有tags
```bash
./docker-show-repo-tag.sh mongo
4
4-focal
4.0
4.0-xenial
4.0.28
4.0.28-xenial
4.2
4.2-bionic
4.2-rc
4.2-rc-bionic
4.2-rc-nanoserver
4.2-rc-nanoserver-1809
4.2-rc-nanoserver-ltsc2022
4.2-rc-windowsservercore
4.2-rc-windowsservercore-1809
4.2-rc-windowsservercore-ltsc2022
4.2.22
4.2.22-bionic
4.2.22-windowsservercore-ltsc2022
4.2.23-rc0
4.2.23-rc0-bionic
4.2.23-rc0-nanoserver
4.2.23-rc0-nanoserver-1809
4.2.23-rc0-nanoserver-ltsc2022
4.2.23-rc0-windowsservercore
4.2.23-rc0-windowsservercore-1809
4.2.23-rc0-windowsservercore-ltsc2022
4.4
4.4-focal
4.4-rc
4.4-rc-focal
4.4-rc-nanoserver
4.4-rc-nanoserver-1809
4.4-rc-nanoserver-ltsc2022
4.4-rc-windowsservercore
4.4-rc-windowsservercore-1809
4.4-rc-windowsservercore-ltsc2022
4.4-windowsservercore
4.4-windowsservercore-1809
4.4-windowsservercore-ltsc2022
4.4.16
4.4.16-focal
4.4.16-windowsservercore
4.4.16-windowsservercore-1809
4.4.16-windowsservercore-ltsc2022
4.4.17-rc0
4.4.17-rc0-focal
4.4.17-rc0-nanoserver
4.4.17-rc0-nanoserver-1809
4.4.17-rc0-nanoserver-ltsc2022
4.4.17-rc0-windowsservercore
4.4.17-rc0-windowsservercore-1809
4.4.17-rc0-windowsservercore-ltsc2022
5
5-focal
5-windowsservercore
5-windowsservercore-1809
5-windowsservercore-ltsc2022
5.0
5.0-focal
5.0-windowsservercore
5.0-windowsservercore-1809
5.0-windowsservercore-ltsc2022
5.0.11
5.0.11-focal
5.0.11-windowsservercore
5.0.11-windowsservercore-1809
5.0.11-windowsservercore-ltsc2022
6
6-focal
6-nanoserver
6-nanoserver-1809
6-nanoserver-ltsc2022
6-windowsservercore
6-windowsservercore-1809
6-windowsservercore-ltsc2022
6.0
6.0-focal
6.0-nanoserver
6.0-nanoserver-1809
6.0-nanoserver-ltsc2022
6.0-windowsservercore
6.0-windowsservercore-1809
6.0-windowsservercore-ltsc2022
6.0.1
6.0.1-focal
6.0.1-nanoserver
6.0.1-nanoserver-1809
6.0.1-nanoserver-ltsc2022
6.0.1-windowsservercore
6.0.1-windowsservercore-1809
6.0.1-windowsservercore-ltsc2022
focal
latest
nanoserver
nanoserver-1809
nanoserver-ltsc2022
windowsservercore
windowsservercore-1809
windowsservercore-ltsc2022
```

### 10.2 安装mongo需要的tags
```bash
docker pull mongo:6.0
```

### 10.3 配置mongod.conf
<span id="jump23">mongod.conf</span>
```yaml
systemLog:
    destination: file
    logAppend: true
    path: /data/logs/mongodb.log

storage:
    dbPath: /data/db
    journal:
        enabled: true

processManagement:
    fork: false
    timeZoneInfo: /usr/share/zoneinfo

net:
    port: 27017
    bindIp: 0.0.0.0

security:
    authorization: enabled
```

### 10.4 启动mongo容器
```bash
docker run \
-d \
-p 27017:27017 \
--name mongo6 \
--network bridge \
--restart=always \
--privileged=true \
-e MONGO_INITDB_ROOT_USERNAME=admin \
-e MONGO_INITDB_ROOT_PASSWORD=admin123456 \
-e TZ=Asia/Shanghai \
-v /Users/{whoami}/Downloads/Docker/mongodb/data:/data/db \
-v /Users/{whoami}/Downloads/Docker/mongodb/config:/data/mongo/conf \
-v /Users/{whoami}/Downloads/Docker/mongodb/log:/data/logs \
mongo:6.0 \
-f /data/mongo/conf/mongod.conf
```
参数说明：

参数|说明
-|-
-d|后台运行容器
-p 27017:27017| 把容器内的27017端口映射到宿主机27017端口
--name|mongodb容器名称
--network|网络
–-restart always|开机启动
–-privileged=true|提升容器内权限（false可能会因权限导致无法启动）
-e MONGO_INITDB_ROOT_USERNAME|root账号
-e MONGO_INITDB_ROOT_PASSWORD|root密码
-e TZ=Asia/Shanghai|时区指定shanghai(上海)
-v /Users/{whoami}/Downloads/Docker/mongodb/data:/data/db|映射/data/db
-v /Users/{whoami}/Downloads/Docker/mongodb/config:/data/mongo/conf|映射/data/mongo/conf
-v /Users/{whoami}/Downloads/Docker/mongodb/log:/data/log|映射/data/log
-f /data/mongo/conf/mongod.conf|启动mongo并加载指定配置文件
mongo:6.0|mongo(repository) : 6.0(tag)

### 10.5 起停mongo容器
```bash
docker ps -a
CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS         PORTS                               NAMES
5d3e522b6295   mongo:6.0                "docker-entrypoint.s…"   8 seconds ago   Up 7 seconds   0.0.0.0:27017->27017/tcp            mongo6
e7bbf340c66c   redis:7.0                "docker-entrypoint.s…"   4 hours ago     Up 4 hours     0.0.0.0:6379->6379/tcp              redis7
b055811ce23c   mysql:8.0                "docker-entrypoint.s…"   8 hours ago     Up 7 hours     0.0.0.0:3306->3306/tcp, 33060/tcp   mysql8
d439c916d2e4   docker/getting-started   "/docker-entrypoint.…"   13 hours ago    Up 13 hours    0.0.0.0:80->80/tcp                  crazy_chatterjee

docker stop 5d3e522b6295
5d3e522b6295

docker start 5d3e522b6295
5d3e522b6295
```

### 10.6 进入mongo容器内部
```bash
docker exec -it 5d3e522b6295 /bin/bash

root@5d3e522b6295:/# ./bin/mongosh
Current Mongosh Log ID:	63177d5eaf46621a26b4d4a0
Connecting to:		mongodb://127.0.0.1:27017/?directConnection=true&serverSelectionTimeoutMS=2000&appName=mongosh+1.5.4
Using MongoDB:		6.0.1
Using Mongosh:		1.5.4

For mongosh info see: https://docs.mongodb.com/mongodb-shell/


To help improve our products, anonymous usage data is collected and sent to MongoDB periodically (https://www.mongodb.com/legal/privacy-policy).
You can opt-out by running the disableTelemetry() command.

test> use admin
switched to db admin
admin> db.auth('admin', 'admin123456')
{ ok: 1 }
admin> show users
[
  {
    _id: 'admin.admin',
    userId: UUID("e0536aa2-8b49-4050-acea-0f86413f9711"),
    user: 'admin',
    db: 'admin',
    roles: [ { role: 'root', db: 'admin' } ],
    mechanisms: [ 'SCRAM-SHA-1', 'SCRAM-SHA-256' ]
  }
]
admin> show dbs
admin   100.00 KiB
config   12.00 KiB
local    72.00 KiB
admin>
```

## 11、nginx
### 11.1 查询nginx镜像的所有tags
```bash
./docker-show-repo-tag.sh nginx
1
1-alpine
1-alpine-perl
1-perl
1.18
1.18-alpine
1.18-alpine-perl
1.18-perl
1.18.0
1.18.0-alpine
1.18.0-alpine-perl
1.18.0-perl
1.19
1.19-alpine
1.19-alpine-perl
1.19-perl
1.19.10
1.19.10-alpine
1.19.10-alpine-perl
1.19.10-perl
1.19.9
1.19.9-alpine
1.19.9-alpine-perl
1.19.9-perl
1.20
1.20-alpine
1.20-alpine-perl
1.20-perl
1.20.0
1.20.0-alpine
1.20.0-alpine-perl
1.20.0-perl
1.20.1
1.20.1-alpine
1.20.1-alpine-perl
1.20.1-perl
1.20.2
1.20.2-alpine
1.20.2-alpine-perl
1.20.2-perl
1.21
1.21-alpine
1.21-alpine-perl
1.21-perl
1.21.0
1.21.0-alpine
1.21.0-alpine-perl
1.21.0-perl
1.21.1
1.21.1-alpine
1.21.1-alpine-perl
1.21.1-perl
1.21.3
1.21.3-alpine
1.21.3-alpine-perl
1.21.3-perl
1.21.4
1.21.4-alpine
1.21.4-alpine-perl
1.21.4-perl
1.21.5
1.21.5-alpine
1.21.5-alpine-perl
1.21.5-perl
1.21.6
1.21.6-alpine
1.21.6-alpine-perl
1.21.6-perl
1.22
1.22-alpine
1.22-alpine-perl
1.22-perl
1.22.0
1.22.0-alpine
1.22.0-alpine-perl
1.22.0-perl
1.23
1.23-alpine
1.23-alpine-perl
1.23-perl
1.23.0
1.23.0-alpine
1.23.0-alpine-perl
1.23.0-perl
1.23.1
1.23.1-alpine
1.23.1-alpine-perl
1.23.1-perl
alpine
alpine-perl
latest
mainline
mainline-alpine
mainline-alpine-perl
mainline-perl
perl
stable
stable-alpine
stable-alpine-perl
stable-perl
```

### 11.2 安装nginx需要的tags
```bash
docker pull nginx:1.22.0
```

### 11.3 配置conf
<span id="jump29">nginx.conf</span>
```bash
#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;

        charset utf-8;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        error_page  404              /404.html;
        error_page  500              /500.html;
        error_page  502 503 504      /error.html;
        # redirect server error pages to the static page /50x.html
        #
        #error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

    include conf.d/*.conf;
}
```

### 11.4 启动nginx容器
```bash
docker run \
-d \
-p 80:80 \
-p 443:443 \
--name nginx1.22.0 \
--network bridge \
--restart=always \
--privileged=true \
-v /Users/${whoami}/Downloads/Docker/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
-v /Users/${whoami}/Downloads/Docker/nginx/conf.d:/etc/nginx/conf.d \
-v /Users/${whoami}/Downloads/Docker/nginx/cert:/etc/nginx/certs \
-v /Users/${whoami}/Downloads/Docker/nginx/html:/etc/nginx/html \
-v /Users/${whoami}/Downloads/Docker/nginx/log:/var/log/nginx \
-e LANG=C.UTF-8 \
-e LC_ALL=C.UTF-8 \
nginx:1.22.0
```
参数说明：

参数|说明
-|-
-d|后台运行容器
-p 80:80<br>-p 443:443| 把容器内的80端口、443端口分别映射到宿主机80端口、443端口
--name|nginx容器名称
--network|网络
–-restart always|开机启动
–-privileged=true|提升容器内权限（false可能会因权限导致无法启动）
-v /Users/${whoami}/Downloads/Docker/nginx/conf/nginx.conf:/etc/nginx/nginx.conf|nginx的主配置文件
-v /Users/${whoami}/Downloads/Docker/nginx/conf.d:/etc/nginx/conf.d| nginx的自定义配置文件目录，该目录下所有的*.conf会生效
-v /Users/${whoami}/Downloads/Docker/nginx/cert:/etc/nginx/certs|nginx的ssl证书
-v /Users/${whoami}/Downloads/Docker/nginx/html:/etc/nginx/html|nginx的静态文件
-v /Users/${whoami}/Downloads/Docker/nginx/log:/var/log/nginx|nginx的日志目录
-e LANG=C.UTF-8|解决nginx中文乱码
-e LC_ALL=C.UTF-8|解决nginx中文乱码
nginx:1.22.0|nginx(repository) : 1.22.0(tag)

### 11.5 起停nginx容器
```bash
docker ps -a
CONTAINER ID   IMAGE                    COMMAND                  CREATED       STATUS                     PORTS                                      NAMES
46b779b40bb5   nginx:1.22.0             "/docker-entrypoint.…"   3 days ago    Up 19 seconds              0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   nginx1.22.0
83c107ac3c1b   docker-gs-ping:v1.0      "/docker-gs-ping"        8 days ago    Up 19 seconds              0.0.0.0:8081->8081/tcp                     go-docker-v1
170ce646f5cd   java-docker:v1.0         "./mvnw spring-boot:…"   9 days ago    Up 19 seconds              0.0.0.0:8080->8080/tcp                     java-docker-v1
439741b1c983   node-docker:v1.0         "docker-entrypoint.s…"   9 days ago    Up 18 seconds              0.0.0.0:8000->8000/tcp                     nodejs-docker-v1
77c73cd73550   python-docker:v1.0       "python3 -m flask ru…"   9 days ago    Up 19 seconds              0.0.0.0:5000->5000/tcp                     python-docker-v1
5d3e522b6295   mongo:6.0                "docker-entrypoint.s…"   10 days ago   Up 18 seconds              0.0.0.0:27017->27017/tcp                   mongo6
e7bbf340c66c   redis:7.0                "docker-entrypoint.s…"   10 days ago   Up 19 seconds              0.0.0.0:6379->6379/tcp                     redis7
b055811ce23c   mysql:8.0                "docker-entrypoint.s…"   11 days ago   Up 18 seconds              0.0.0.0:3306->3306/tcp, 33060/tcp          mysql8
d439c916d2e4   docker/getting-started   "/docker-entrypoint.…"   11 days ago   Exited (255) 10 days ago   0.0.0.0:80->80/tcp                         crazy_chatterjee

docker stop 46b779b40bb5
46b779b40bb5

docker start s46b779b40bb5
46b779b40bb5
```

### 11.6 进入nginx容器内部
```bash
docker exec -it 46b779b40bb5 /bin/bash

root@46b779b40bb5:/# ls /etc/nginx/nginx.conf
/etc/nginx/nginx.conf
root@46b779b40bb5:/# cat /etc/nginx/nginx.conf

#user  nobody;
worker_processes  1;

#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    server {
        listen       80;
        server_name  localhost;

        charset utf-8;

        #access_log  logs/host.access.log  main;

        location / {
            root   html;
            index  index.html index.htm;
        }

        error_page  404              /404.html;
        error_page  500              /500.html;
        error_page  502 503 504      /error.html;
        # redirect server error pages to the static page /50x.html
        #
        #error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }

        # proxy the PHP scripts to Apache listening on 127.0.0.1:80
        #
        #location ~ \.php$ {
        #    proxy_pass   http://127.0.0.1;
        #}

        # pass the PHP scripts to FastCGI server listening on 127.0.0.1:9000
        #
        #location ~ \.php$ {
        #    root           html;
        #    fastcgi_pass   127.0.0.1:9000;
        #    fastcgi_index  index.php;
        #    fastcgi_param  SCRIPT_FILENAME  /scripts$fastcgi_script_name;
        #    include        fastcgi_params;
        #}

        # deny access to .htaccess files, if Apache's document root
        # concurs with nginx's one
        #
        #location ~ /\.ht {
        #    deny  all;
        #}
    }


    # another virtual host using mix of IP-, name-, and port-based configuration
    #
    #server {
    #    listen       8000;
    #    listen       somename:8080;
    #    server_name  somename  alias  another.alias;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}


    # HTTPS server
    #
    #server {
    #    listen       443 ssl;
    #    server_name  localhost;

    #    ssl_certificate      cert.pem;
    #    ssl_certificate_key  cert.key;

    #    ssl_session_cache    shared:SSL:1m;
    #    ssl_session_timeout  5m;

    #    ssl_ciphers  HIGH:!aNULL:!MD5;
    #    ssl_prefer_server_ciphers  on;

    #    location / {
    #        root   html;
    #        index  index.html index.htm;
    #    }
    #}

    include conf.d/*.conf;
}
root@46b779b40bb5:/#
```

## 12、minio
### 12.1 安装minio需要的tags
直接安装最新版本
```bash
docker pull quay.io/minio/minio:latest
```

### 12.2 启动minio容器
```bash
docker run \
-d \
--network bridge \
--restart=always \
--privileged=true \
-p 9000:9000 \
-p 9090:9090 \
--user $(id -u):$(id -g) \
--name minio1 \
-e "MINIO_ROOT_USER=admin" \
-e "MINIO_ROOT_PASSWORD=admin123456" \
-v /Users/${whoami}/Downloads/Docker/minio/data:/data \
quay.io/minio/minio server /data --console-address ":9090"
```
参数说明：

参数|说明
-|-
-d|后台运行容器
-p 9000:9000<br>-p 9090:9090| 把容器内的9000端口、9090端口分别映射到宿主机9000端口、9090端口
--name|minio容器名称
--network|网络
–-restart always|开机启动
–-privileged=true|提升容器内权限（false可能会因权限导致无法启动）
--user|设置属组权限
-e "MINIO_ROOT_USER=admin"|设置 root 账号
-e "MINIO_ROOT_PASSWORD=admin123456"|设置 root 密码
-v /Users/${whoami}/Downloads/Docker/minio/data:/data|绑定minio 的数据目录
--console-address ":9090"|启动参数，控制台端口9090

### 12.3 启停minio容器
```bash
docker ps -a
CONTAINER ID   IMAGE                           COMMAND                  CREATED          STATUS          PORTS                                            NAMES
aa0b29848539   quay.io/coreos/etcd:latest      "/usr/local/bin/etcd…"   49 minutes ago   Up 49 minutes   0.0.0.0:2379-2380->2379-2380/tcp                 etcd
8cc751e02862   quay.io/minio/minio             "/usr/bin/docker-ent…"   2 hours ago      Up 2 hours      0.0.0.0:9000->9000/tcp, 0.0.0.0:9090->9090/tcp   minio1
1ee4158a624a   docker/getting-started:latest   "/docker-entrypoint.…"   12 days ago      Up 34 minutes   0.0.0.0:3000->3000/tcp, 0.0.0.0:8001->80/tcp     getting-started-latest
46b779b40bb5   nginx:1.22.0                    "/docker-entrypoint.…"   2 weeks ago      Up 35 minutes   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp         nginx1.22.0
83c107ac3c1b   docker-gs-ping:v1.0             "/docker-gs-ping"        3 weeks ago      Up 34 minutes   0.0.0.0:8081->8081/tcp                           go-docker-v1
170ce646f5cd   java-docker:v1.0                "./mvnw spring-boot:…"   3 weeks ago      Up 34 minutes   0.0.0.0:8080->8080/tcp                           java-docker-v1
439741b1c983   node-docker:v1.0                "docker-entrypoint.s…"   3 weeks ago      Up 34 minutes   0.0.0.0:8000->8000/tcp                           nodejs-docker-v1
77c73cd73550   python-docker:v1.0              "python3 -m flask ru…"   3 weeks ago      Up 34 minutes   0.0.0.0:5000->5000/tcp                           python-docker-v1
5d3e522b6295   mongo:6.0                       "docker-entrypoint.s…"   3 weeks ago      Up 35 minutes   0.0.0.0:27017->27017/tcp                         mongo6
e7bbf340c66c   redis:7.0                       "docker-entrypoint.s…"   3 weeks ago      Up 35 minutes   0.0.0.0:6379->6379/tcp                           redis7
b055811ce23c   mysql:8.0                       "docker-entrypoint.s…"   3 weeks ago      Up 35 minutes   0.0.0.0:3306->3306/tcp, 33060/tcp                mysql8

docker stop 8cc751e02862
8cc751e02862

docker start 8cc751e02862
8cc751e02862 
```

### 12.4 进入minio控制台
浏览器访问http://127.0.0.1:9090
![](/posts/docker/minio_console.png)

## 13、etcd
### 13.1 安装etcd需要的tags
直接安装最新版本
```bash
docker pull quay.io/coreos/etcd:latest
```

### 13.2 启动etcd容器
```bash
NODE1=0.0.0.0

REGISTRY=quay.io/coreos/etcd

docker run \
-d \
-p 2379:2379 \
-p 2380:2380 \
--name etcd \
--network bridge \
--restart=always \
--privileged=true \
--volume=/Users/${whoami}/Downloads/Docker/etcd/data:/etcd/data \
${REGISTRY}:latest \
/usr/local/bin/etcd \
--data-dir=/etcd/data --name node1 \
--initial-advertise-peer-urls http://${NODE1}:2380 --listen-peer-urls http://0.0.0.0:2380 \
--advertise-client-urls http://${NODE1}:2379 --listen-client-urls http://0.0.0.0:2379 \
```
参数说明：

参数|说明
-|-
-d|后台运行容器
-p 2379:2379<br>-p 2380:2380| 把容器内的2379端口、2380端口分别映射到宿主机2379端口、2380端口
--name|etcd容器名称
--network|网络
–-restart always|开机启动
–-privileged=true|提升容器内权限（false可能会因权限导致无法启动）
--volume=/Users/${whoami}/Downloads/Docker/etcd/data:/etcd/data|绑定数据目录
${REGISTRY}:latest|etcd(repository) : latest(tag)
--data-dir|etcd 数据目录
--name|etcd 名称 node1
--initial-advertise-peer-urls http://${NODE1}:2380|该节点同伴监听地址，这个值会告诉集群中其他节点。
--listen-peer-urls http://0.0.0.0:2380|和同伴通信的地址，比如http://ip:2380，如果有多个，使用逗号分隔。需要所有节点都能够访问，所以不要使用 localhost！
--advertise-client-urls http://${NODE1}:2379|对外公告的该节点客户端监听地址，这个值会告诉集群中其他节点。
--listen-client-urls http://0.0.0.0:2379|对外提供服务的地址：比如http://ip:2379,http://127.0.0.1:2379，客户端会连接到这里和 etcd 交互。

### 13.3 启停etcd容器
```bash
docker ps -a
CONTAINER ID   IMAGE                           COMMAND                  CREATED          STATUS          PORTS                                            NAMES
aa0b29848539   quay.io/coreos/etcd:latest      "/usr/local/bin/etcd…"   49 minutes ago   Up 49 minutes   0.0.0.0:2379-2380->2379-2380/tcp                 etcd
8cc751e02862   quay.io/minio/minio             "/usr/bin/docker-ent…"   2 hours ago      Up 2 hours      0.0.0.0:9000->9000/tcp, 0.0.0.0:9090->9090/tcp   minio1
1ee4158a624a   docker/getting-started:latest   "/docker-entrypoint.…"   12 days ago      Up 34 minutes   0.0.0.0:3000->3000/tcp, 0.0.0.0:8001->80/tcp     getting-started-latest
46b779b40bb5   nginx:1.22.0                    "/docker-entrypoint.…"   2 weeks ago      Up 35 minutes   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp         nginx1.22.0
83c107ac3c1b   docker-gs-ping:v1.0             "/docker-gs-ping"        3 weeks ago      Up 34 minutes   0.0.0.0:8081->8081/tcp                           go-docker-v1
170ce646f5cd   java-docker:v1.0                "./mvnw spring-boot:…"   3 weeks ago      Up 34 minutes   0.0.0.0:8080->8080/tcp                           java-docker-v1
439741b1c983   node-docker:v1.0                "docker-entrypoint.s…"   3 weeks ago      Up 34 minutes   0.0.0.0:8000->8000/tcp                           nodejs-docker-v1
77c73cd73550   python-docker:v1.0              "python3 -m flask ru…"   3 weeks ago      Up 34 minutes   0.0.0.0:5000->5000/tcp                           python-docker-v1
5d3e522b6295   mongo:6.0                       "docker-entrypoint.s…"   3 weeks ago      Up 35 minutes   0.0.0.0:27017->27017/tcp                         mongo6
e7bbf340c66c   redis:7.0                       "docker-entrypoint.s…"   3 weeks ago      Up 35 minutes   0.0.0.0:6379->6379/tcp                           redis7
b055811ce23c   mysql:8.0                       "docker-entrypoint.s…"   3 weeks ago      Up 35 minutes   0.0.0.0:3306->3306/tcp, 33060/tcp                mysql8

docker stop aa0b29848539
aa0b29848539

docker start aa0b29848539
aa0b29848539 
```

### 13.4 进入etcd容器内部
```bash
docker exec -it etcd bin/sh
/ # etcdctl member list
1c70f9bbb41018f: name=node1 peerURLs=http://0.0.0.0:2380 clientURLs=http://0.0.0.0:2379 isLeader=true
/ # etcdctl list
No help topic for 'list'
/ # etcdctl ls
/ #
```

## 14、结语
### 14.1 最后环境准备好了，运行信息如下
```bash
# 容器信息如下：
docker ps -a
CONTAINER ID   IMAGE                           COMMAND                  CREATED          STATUS          PORTS                                            NAMES
aa0b29848539   quay.io/coreos/etcd:latest      "/usr/local/bin/etcd…"   49 minutes ago   Up 49 minutes   0.0.0.0:2379-2380->2379-2380/tcp                 etcd
8cc751e02862   quay.io/minio/minio             "/usr/bin/docker-ent…"   2 hours ago      Up 2 hours      0.0.0.0:9000->9000/tcp, 0.0.0.0:9090->9090/tcp   minio1
1ee4158a624a   docker/getting-started:latest   "/docker-entrypoint.…"   12 days ago      Up 34 minutes   0.0.0.0:3000->3000/tcp, 0.0.0.0:8001->80/tcp     getting-started-latest
46b779b40bb5   nginx:1.22.0                    "/docker-entrypoint.…"   2 weeks ago      Up 35 minutes   0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp         nginx1.22.0
83c107ac3c1b   docker-gs-ping:v1.0             "/docker-gs-ping"        3 weeks ago      Up 34 minutes   0.0.0.0:8081->8081/tcp                           go-docker-v1
170ce646f5cd   java-docker:v1.0                "./mvnw spring-boot:…"   3 weeks ago      Up 34 minutes   0.0.0.0:8080->8080/tcp                           java-docker-v1
439741b1c983   node-docker:v1.0                "docker-entrypoint.s…"   3 weeks ago      Up 34 minutes   0.0.0.0:8000->8000/tcp                           nodejs-docker-v1
77c73cd73550   python-docker:v1.0              "python3 -m flask ru…"   3 weeks ago      Up 34 minutes   0.0.0.0:5000->5000/tcp                           python-docker-v1
5d3e522b6295   mongo:6.0                       "docker-entrypoint.s…"   3 weeks ago      Up 35 minutes   0.0.0.0:27017->27017/tcp                         mongo6
e7bbf340c66c   redis:7.0                       "docker-entrypoint.s…"   3 weeks ago      Up 35 minutes   0.0.0.0:6379->6379/tcp                           redis7
b055811ce23c   mysql:8.0                       "docker-entrypoint.s…"   3 weeks ago      Up 35 minutes   0.0.0.0:3306->3306/tcp, 33060/tcp                mysql8

# 镜像信息如下：
docker images
REPOSITORY               TAG       IMAGE ID       CREATED        SIZE
quay.io/minio/minio      latest    7857bafef273   6 days ago     228MB
nginx                    1.22.0    2467b41f2ddd   2 weeks ago    142MB
docker-gs-ping           v1.0      3b7b51a5f6d6   3 weeks ago    541MB
node-docker              v1.0      2378b1604401   3 weeks ago    944MB
java-docker              v1.0      04764e57adf2   3 weeks ago    559MB
python-docker            v1.0      cbc159df0b06   3 weeks ago    129MB
mongo                    6.0       d34d21a9eb5b   4 weeks ago    693MB
mysql                    8.0       ff3b5098b416   4 weeks ago    447MB
redis                    7.0       dc7b40a0b05d   5 weeks ago    117MB
docker/getting-started   latest    cb90f98fd791   5 months ago   28.8MB
quay.io/coreos/etcd      latest    61ad63875109   4 years ago    39.5MB
```

### 14.2 停止容器  
停止脚本如下：
```bash
function stop()
{
    container_name=$1

    if [ "${container_name}" == "all" ]; then
        # 获取所有状态为 running 的容器 ID
        container_ids=$(docker ps -aqf "status=running")

        # 如果没有容器处于运行状态，则输出提示信息并退出脚本
        if [ -z "${container_ids}" ]; then
            echo "No running containers. Done."
            exit 0
        fi

        # 循环停止所有处于运行状态的容器
        for container in ${container_ids}; do
            docker stop ${container}
        done
    else
        container_id=$(docker ps -a | grep "${container_name}" | grep "Up" | awk -F"${container_name}" {'print $1'})

        if [ ! -z ${container_id} ]; then
            docker stop ${container_id}
            echo "stop successful, container name[${container_name}]"
        else
            echo "container name[${container_name}] is not exist or stopped."    
        fi
    fi
}


function main()
{
    if [ $# -eq 1 ]; then
        if [ "$1" == "all" ]; then
            stop "all"
        else
            stop "$1"    
        fi
    else
        echo "Error Parameter, egg: ./docker-stop-container mysql or ./docker-stop-container all "
        exit 1
    fi
}

main $1
```
不需要环境了，可以执行停止脚本暂时停止容器，如下：
```bash
./docker-stop.sh mysql
b055811ce23c
stop successful, container name[mysql]

./docker-stop.sh redis
e7bbf340c66c
stop successful, container name[redis]

./docker-stop.sh mongo
5d3e522b6295
stop successful, container name[mongo]

./docker-stop.sh docker/getting-started
d439c916d2e4
stop successful, container name[docker/getting-started]

docker ps -a
CONTAINER ID   IMAGE                    COMMAND                  CREATED        STATUS                      PORTS     NAMES
46b779b40bb5   nginx:1.22.0             "/docker-entrypoint.…"   3 days ago    Exited (0) 20 seconds ago              0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   nginx1.22.0
5d3e522b6295   mongo:6.0                "docker-entrypoint.s…"   10 hours ago   Exited (0) 22 seconds ago             mongo6
e7bbf340c66c   redis:7.0                "docker-entrypoint.s…"   15 hours ago   Exited (0) 32 seconds ago             redis7
b055811ce23c   mysql:8.0                "docker-entrypoint.s…"   18 hours ago   Exited (0) 39 seconds ago             mysql8
d439c916d2e4   docker/getting-started   "/docker-entrypoint.…"   24 hours ago   Exited (0) 5 seconds ago              crazy_chatterjee
```

### 14.3 启动脚本如下
```bash
function start()
{
    container_name=$1

    if [ "${container_name}" == "all" ]; then
        # 获取所有状态为 exited 的容器 ID
        container_ids=$(docker ps -aqf "status=exited")

        # 如果没有容器处于停止状态，则输出提示信息并退出脚本
        if [ -z "${container_ids}" ]; then
            echo "No exited containers. Done."
            exit 0
        fi

        # 循环启动所有处于停止状态的容器
        for container in ${container_ids}; do
            docker start ${container}
        done
    else
        container_id=$(docker ps -a | grep ${container_name} | grep "Exited" | awk -F"${container_name}" {'print $1'})

        if [ ! -z ${container_id} ]; then
            docker start ${container_id}

            echo "start successful, container name[${container_name}]"
        else
            echo "container name[${container_name}] is not exist or started."    
        fi
    fi

} 

function main()
{
    if [ $# -eq 1 ]; then
        if [ "$1" == "all" ]; then
            start "all"
        else
            start "$1"    
        fi
    else
        echo "Error Parameter, egg: ./docker-start-container mysql or ./docker-start-container all "
        exit 1
    fi
}

main $1
```
需要环境了，可以执行启动脚本再次启动容器，如下：
```bash
./docker-start-container.sh mongo
5d3e522b6295
start successful, container name[mongo]

./docker-start-container.sh redis
e7bbf340c66c
start successful, container name[redis]

./docker-start-container.sh mysql
b055811ce23c
start successful, container name[mysql]

docker ps -a
CONTAINER ID   IMAGE                    COMMAND                  CREATED        STATUS                         PORTS                               NAMES
46b779b40bb5   nginx:1.22.0             "/docker-entrypoint.…"   3 days ago    Up 48 minutes              0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   nginx1.22.0
5d3e522b6295   mongo:6.0                "docker-entrypoint.s…"   11 hours ago   Up 8 seconds                   0.0.0.0:27017->27017/tcp            mongo6
e7bbf340c66c   redis:7.0                "docker-entrypoint.s…"   15 hours ago   Up 6 seconds                   0.0.0.0:6379->6379/tcp              redis7
b055811ce23c   mysql:8.0                "docker-entrypoint.s…"   19 hours ago   Up 2 seconds                   0.0.0.0:3306->3306/tcp, 33060/tcp   mysql8
d439c916d2e4   docker/getting-started   "/docker-entrypoint.…"   24 hours ago   Up 5 minutes                   0.0.0.0:80->80/tcp                  crazy_chatterjee
```


后续有其他工具补充再继续完善。。。