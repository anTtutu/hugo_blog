---
title: "mac配置docker开发工具"
date: 2022-09-06T00:29:47+08:00
tag : [ "docker", "mac" ]
description: "mac配置docker开发工具"
categories: [ "docker", "mac" ]
toc: true
---

## 前言
2020年整了一套android下的termux开发环境，今天继续配置一套docker环境的开发环境。

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
>目前通过 open /Applications/Docker.app 可以启动，通过 launchctl start com.docker.docker.xxx 方式不能启动了。测试环境：mac ：10.15.6，docker：19.03.8 ，测试时间：2021-09-06

## 4、docker的镜像存储位置
```bash
MacOS:
容器和镜像在如下目录下,不同版本或许可能文件版本不一样
/Users/{whoami}/Library/Containers/com.docker.docker/Data
可以到上面的目录中，查看文件大小, du -sh *
本机存放位置如下
/Users/{whoami}/Library/Containers/com.docker.docker/Data/vms/0/data/Docker.raw
```

## 5、查询mysql镜像的所有tags
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

## 6、安装mysql需要的tags
以mysql举例
```bash
docker pull mysql:8.0
```

## 7、启动mysql容器
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
-v /Users/{whoami}/Downloads/Docker/mysql/data:/usr/data \
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
-v /Users/{whoami}/Downloads/Docker/mysql/data:/usr/data|映射data目录
-v /Users/{whoami}/Downloads/Docker/mysql/log:/logs|映射logs目录
-v /Users/{whoami}/Downloads/Docker/mysql/localtime:/etc/localtime|映射时区，解决容器mysql是0时区问题
-e|设置环境变量:<br>MYSQL_USER：添加用户<br>MYSQL_PASSWORD：设置添加用户密码<br>MYSQL_ROOT_PASSWORD：设置root用户密码<br>character-set-server：设置字符集<br>collation-server：设置字符比较规则<br>
mysql:8.0|mysql(repository) : 8.0(tag)

## 8、停止mysql容器
```bash
docker ps
CONTAINER ID   IMAGE                    COMMAND                  CREATED          STATUS          PORTS                               NAMES
b055811ce23c   mysql:8.0                "docker-entrypoint.s…"   25 minutes ago   Up 25 minutes   0.0.0.0:3306->3306/tcp, 33060/tcp   mysql8
d439c916d2e4   docker/getting-started   "/docker-entrypoint.…"   6 hours ago      Up 6 hours      0.0.0.0:80->80/tcp                  crazy_chatterjee

docker stop b055811ce23c
b055811ce23c
```

## 9、启动mysql容器
```bash
docker ps -a
CONTAINER ID   IMAGE                    COMMAND                  CREATED          STATUS                     PORTS                NAMES
b055811ce23c   mysql:8.0                "docker-entrypoint.s…"   29 minutes ago   Exited (0) 3 minutes ago                        mysql8
d439c916d2e4   docker/getting-started   "/docker-entrypoint.…"   6 hours ago      Up 6 hours                 0.0.0.0:80->80/tcp   crazy_chatterjee

docker start b055811ce23c
b055811ce23c
```

## 10、进入mysql容器内部
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

## 11、查询redis镜像的所有tags
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

## 12、安装redis需要的tags
```bash
docker pull redis:7.0
```

## 13、配置redis.conf
```bash
#bind 127.0.0.1             #注释掉这部分,使redis可以外部访问
protected-mode no           #修改为no,去掉保护模式,让外网可以访问
daemonize no                #修改为no,不用守护线程的方式启动
requirepass test123456      #密码
appendonly yes              #redis持久化,默认是no
```

## 14、启动redis容器
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

## 15、起停redis容器
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

## 16、进入redis容器内部
```bash
docker exec -it e7bbf340c66c /bin/bash

root@e7bbf340c66c:/data# redis-cli
127.0.0.1:6379> auth test123456
OK
127.0.0.1:6379> get 123
(nil)
127.0.0.1:6379>
```

## 17、查询mongo镜像的所有tags
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

## 18、安装mongo需要的tags
```bash
docker pull mongo:6.0
```

## 19、配置mongod.conf
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

## 20、启动mongo容器
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

## 21、起停mongo容器
```bash
docker ps -a
CONTAINER ID   IMAGE                    COMMAND                  CREATED         STATUS         PORTS                               NAMES
9d71df7b26d0   mongo:6.0                "docker-entrypoint.s…"   8 seconds ago   Up 7 seconds   0.0.0.0:27017->27017/tcp            mongo6
e7bbf340c66c   redis:7.0                "docker-entrypoint.s…"   4 hours ago     Up 4 hours     0.0.0.0:6379->6379/tcp              redis7
b055811ce23c   mysql:8.0                "docker-entrypoint.s…"   8 hours ago     Up 7 hours     0.0.0.0:3306->3306/tcp, 33060/tcp   mysql8
d439c916d2e4   docker/getting-started   "/docker-entrypoint.…"   13 hours ago    Up 13 hours    0.0.0.0:80->80/tcp                  crazy_chatterjee

docker stop 9d71df7b26d0
9d71df7b26d0

docker start 9d71df7b26d0
9d71df7b26d0
```

## 22、进入mongo容器内部
```bash
docker exec -it 9d71df7b26d0 /bin/bash

root@9d71df7b26d0:/# ./bin/mongosh
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