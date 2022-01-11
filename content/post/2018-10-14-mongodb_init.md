---
title: mongodb安装后的初始化操作
date: 2018-10-14T21:46:20+08:00
tags: [ "mongodb" ] 
description: "mongodb安装后的初始化操作"
categories: [ "mongodb" ]
toc: true
---

## 前言
mongodb安装成功后的初始化操作，安装步骤比较简单略过不讲

## 1、启动
```bash
./mongobd -f /etc/mongodb.conf
```

## 2、进入命令行
```bash
./mongo 
``` 

## 3、创建超级管理账号
```bash
use admin

db.createUser({user:"adminuser",pwd:"12345678",roles:["userAdminAnyDatabase"]})

## 4、用超级管理账号创建业务账号
db.auth('adminuser', '12345678')

use testdb

db.createUser({user:"testuser",pwd:"12345678",roles: [{role:"readWrite", db:"testdb"}]})
```

## 5、conf文件demo，yaml格式，注意空格
```yml
systemLog:
    destination: file
    logAppend: true
    path: /usr/local/mongodb/logs/mongodb.log

storage:
    dbPath: /usr/local/mongodb/data/db
    journal:
        enabled: true

processManagement:
    fork:        
    pidFilePath: /var/run/mongodb/mongod.pid
    timeZoneInfo: /usr/share/zoneinfo

net:
    port: 27017
    bindIp: 0.0.0.0

security:
    authorization: enabled
```

## 6、参数解读：
```yml
systemLog:
  destination: file//指定是一个文件
  path: /data/logs/mongod.log//日志存放位置
  logAppend: true//产生日志内容追加到文件
#  quiet: true//在quite模式下会限制输出信息
#  timeStampFormat: iso8601-utc //默认是iso8601-local，日志信息中还有其他时间戳格式：ctime,iso8601-utc,iso8601-local

processManagement:
  fork: true//以守护进程的方式运行MongoDB，创建服务器进程
  pidFilePath: "/data/mongo-data/mongod.pid"//pid文件路径
net:
# bindIp: 192.168.33.131//绑定ip地址访问mongodb，多个ip逗号分隔
  port: 27017//端口
  maxIncomingConnections：10000//默认65535，mongodb实例接受的最多连接数，如果高于操作系统接受的最大线程数，设置无效。
#  http:
#    enabled: true//http端口最好关闭
#RESTInterfaceEnabled: false//即使http接口选项关闭，如果这个选项打开后会有更多的不安全因素

storage:
  dbPath: "/data/mongo-data"//数据文件存放路径
  engine: wiredTiger//数据引擎
  wiredTiger:
    engineConfig://wt引擎配置
      cacheSizeGB: 1//看服务器情况来进行设置
      directoryForIndexes: true//索引是否按数据库名进行单独存储
    collectionConfig:
      blockCompressor: zlib//压缩配置
    indexConfig:
      prefixCompression: true//索引配置
  journal:
    enabled: true//记录操作日志，防止数据丢失。
  directoryPerDB: true//指定存储每个数据库文件到单独的数据目录。如果在一个已存在的系统使用该选项，需要事先把存在的数据文件移动到目录。
operationProfiling:
  slowOpThresholdMs: 100 //指定慢查询时间，单位毫秒，如果打开功能，则向system.profile集合写入数据
  mode: "slowOp"//off、slowOp、all，分别对应关闭，仅打开慢查询，记录所有操作。
security:
  keyFile: "/data/mongodb-keyfile"//指定分片集或副本集成员之间身份验证的key文件存储位置
  clusterAuthMode: "keyFile"//集群认证模式，默认是keyFile
  authorization: "disabled"//访问数据库和进行操作的用户角色认证
```

## 7、常见操作
命令|含义
-|-
show dbs|显示数据库列表
show collections|显示当前数据库中的集合（类似关系数据库中的表）
show users|显示用户
use dbname|切换当前数据库，这和MS-SQL里面的意思一样
db.help()|显示数据库操作命令，里面有很多的命令

## 8、聚集集合操作
### 8.1、查询所有记录
```bash
db.userInfo.find();
相当于：select* from userInfo;
```

### 8.2、查询去掉后的当前聚集集合中的某列的重复数据
```bash
db.userInfo.distinct("name");
会过滤掉name中的相同数据
相当于：select distinct name from userInfo;
```

### 8.3、查询age = 22的记录
```bash
db.userInfo.find({"age": 22});
相当于： select * from userInfo where age = 22;
```

### 8.4、查询age > 22的记录
```bash
db.userInfo.find({age: {$gt: 22}});
相当于：select * from userInfo where age >22;
```

### 8.5、查询age < 22的记录
```bash
db.userInfo.find({age: {$lt: 22}});
相当于：select * from userInfo where age <22;
```

### 8.6、查询age >= 25的记录
```bash
db.userInfo.find({age: {$gte: 25}});
相当于：select * from userInfo where age >= 25;
```

### 8.7、查询age <= 25的记录
```bash
db.userInfo.find({age: {$lte: 25}});
```

### 8.8、查询age >= 23 并且 age <= 26
```bash
db.userInfo.find({age: {$gte: 23, $lte: 26}});
```

### 8.9、查询name中包含 mongo的数据
```bash
db.userInfo.find({name: /mongo/});
//相当于%%
select * from userInfo where name like ‘%mongo%';
```

### 8.10、查询name中以mongo开头的
```bash
db.userInfo.find({name: /^mongo/});
select * from userInfo where name like ‘mongo%';
```

### 8.11、查询指定列name、age数据
```bash
db.userInfo.find({}, {name: 1, age: 1});
相当于：select name, age from userInfo;
```
当然name也可以用true或false,当用true的情况下河name:1效果一样，如果用false就是排除name，显示name以外的列信息。

### 8.12、查询指定列name、age数据, age > 25
```bash
db.userInfo.find({age: {$gt: 25}}, {name: 1, age: 1});
相当于：select name, age from userInfo where age >25;
```

### 8.13、按照年龄排序
```bash
升序：db.userInfo.find().sort({age: 1});
降序：db.userInfo.find().sort({age: -1});
```

### 8.14、查询name = zhangsan, age = 22的数据
```bash
db.userInfo.find({name: 'zhangsan', age: 22});
相当于：select * from userInfo where name = ‘zhangsan' and age = ‘22';
```

### 8.15、查询前5条数据
```bash
db.userInfo.find().limit(5);
相当于：select top 5 * from userInfo;
```

### 8.16、查询10条以后的数据
```bash
db.userInfo.find().skip(10);
相当于：select * from userInfo where id not in (
select top 10 * from userInfo
);
```

### 8.17、查询在5-10之间的数据
```bash
db.userInfo.find().limit(10).skip(5);
```
可用于分页，limit是pageSize，skip是第几页*pageSize

### 8.18、or与 查询
```bash
db.userInfo.find({$or: [{age: 22}, {age: 25}]});
相当于：select * from userInfo where age = 22 or age = 25;
```

### 8.19、查询第一条数据
```bash
db.userInfo.findOne();
相当于：select top 1 * from userInfo;
db.userInfo.find().limit(1);
```

### 8.20、查询某个结果集的记录条数
```bash
db.userInfo.find({age: {$gte: 25}}).count();
相当于：select count(*) from userInfo where age >= 20;
```

### 8.21、按照某列进行排序
```bash
db.userInfo.find({sex: {$exists: true}}).count();
相当于：select count(sex) from userInfo;
```

## 9、索引
### 9.1、创建索引
```bash
db.userInfo.ensureIndex({name: 1});
db.userInfo.ensureIndex({name: 1, ts: -1});
```

### 9.2、查询当前聚集集合所有索引
```bash
db.userInfo.getIndexes();
```

### 9.3、查看总索引记录大小
```bash
db.userInfo.totalIndexSize();
```

### 9.4、读取当前集合的所有index信息
```bash
db.users.reIndex();
```

### 9.5、删除指定索引
```bash
db.users.dropIndex("name_1");
```

### 9.6、删除所有索引索引
```bash
db.users.dropIndexes();
```

## 10、CRUD
### 10.1、添加
```bash
db.users.save({name: ‘zhangsan', age: 25, sex: true});
```
添加的数据的数据列，没有固定，根据添加的数据为准

### 10.2、修改
```bash
db.users.update({age: 25}, {$set: {name: 'changeName'}}, false, true);
相当于：update users set name = ‘changeName' where age = 25;
db.users.update({name: 'Lisi'}, {$inc: {age: 50}}, false, true);
相当于：update users set age = age + 50 where name = ‘Lisi';
db.users.update({name: 'Lisi'}, {$inc: {age: 50}, $set: {name: 'hoho'}}, false, true);
相当于：update users set age = age + 50, name = ‘hoho' where name = ‘Lisi';
```

### 10.3、删除
```bash
db.users.remove({age: 132});
```

### 10.4、查询修改删除
```bash
db.users.findAndModify({
    query: {age: {$gte: 25}},
    sort: {age: -1},
    update: {$set: {name: 'a2'}, $inc: {age: 2}},
    remove: true
});
db.runCommand({ findandmodify : "users",
    query: {age: {$gte: 25}},
    sort: {age: -1},
    update: {$set: {name: 'a2'}, $inc: {age: 2}},
    remove: true
});
```