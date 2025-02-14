---
title: "postgresql数据库常用记录"
date: 2024-04-15T00:29:47+08:00
tag : [ "pg", "postgresql", "db" ]
description: "postgresql数据库常用记录"
categories: [ "pg", "postgresql", "db" ]
toc: true
---

## 前言
因项目需要，整理下mysql迁移postgresql的常用工具搜集

## 1、迁移工具
开发的pgloader是一个mysql迁移到pg的工具，性能和表现都良好，开发和测试环境迁移已经验正，github地址: <https://github.com/dimitri/pgloader>
```bash
LOAD DATABASE
 FROM mysql://admin1:***@10.10.214.205:3306/t230530_B
 INTO pgsql://admin:***@10.10.216.108:5432/B


WITH
     include drop, create tables, no truncate, create indexes, reset sequences, foreign keys
 CAST type datetime to timestamp
     drop default drop not null using zero-dates-to-null,
     type date drop not null drop default using zero-dates-to-null

 ALTER SCHEMA 't230530_B' RENAME TO 'public'

SET PostgreSQL PARAMETERS
    maintenance_work_mem to '1GB',
    work_mem to '1GB'

SET MySQL PARAMETERS
    net_read_timeout  = '600',
    net_write_timeout = '600'
```

执行迁移，观察日志没有报错正常结束即可
```bash
./pgloader -L /tmp/database_name_test.log database_name_test.ini
```
注意：  
1、pg的账号的库需要提前创建好，并且数据库的owner跟该账号建议一致  
2、注意pg的时间是默认带时区的，需要CAST里面的时间处理才会跟mysql保持一致

## 2、mysql备份和恢复
```bash
# 备份
mysqldump -P 3306 -uadmin -p*** -h 127.0.0.1 --all-databases > project_dev_mysql_20240430.sql

# 还原
myloader \
-u admin  \
-p *** \
-h 127.0.0.1 \
-P 3306  \
--directory /data/project_dev_mysql_backup20240430  \
--overwrite-tables  \
--enable-binlog  \
--threads 6  \
--verbose 3
```

## 3、pg的一些常见操作
### 3.1 创建超级账号
```bash
1. 创建账号
# admin
CREATE USER admin WITH SUPERUSER PASSWORD 'xxx';

2. 添加白名单
vim /data/postgresql/pg_data/pg_hba.conf 
...
host    all             admin      10.0.0.0/8    md5

3. 重新加载conf配置
select pg_reload_conf();
```

### 3.2 备份和恢复
```bash
# 方案1 - 单个库备份
pg_dump -U admin -h localhost -p 5432 -F c -b -v -f /tmp/project_backup.dump database_bane

# 创建库
createdb -U admin -h localhost -p 5432 database_name

# 恢复
pg_restore -U admin -h localhost -p 5432 -d database_name -v /home/postgres/project_backup.dump

# 方案2 - 全部库备份
pg_dumpall -U username -h hostname -f backup_file.sql

# 恢复
psql -U username -h hostname -f backup_file.sql
```

### pg_dump
#### 优点
- 可以选择性地备份和恢复特定的数据库、表或模式。
- 支持多种输出格式（纯文本、自定义、tar、目录）。
- 可以并行导出和导入数据，提高备份和恢复速度。

#### 缺点
- 只能备份单个数据库，无法备份整个数据库集群。
- 对于大型数据库，备份和恢复可能会比较慢。

### pg_dumpall
#### 优点
- 可以备份整个数据库集群，包括所有数据库和全局对象（如角色和表空间）。
- 生成的备份文件包含所有数据库的创建和数据插入语句。

#### 缺点
- 只能生成纯文本格式的备份文件，不支持自定义格式、tar 格式或目录格式。
- 备份和恢复速度较慢，尤其是对于大型数据库集群。
- 不支持并行导出和导入数据。

### 对比
|工具|主要功能|优点|缺点|
|-|-|-|-|
|`pg_dump`|备份单个数据库|支持多种输出格式；可以选择性备份和恢复特定表或模式；支持并行|只能备份单个数据库；大型数据库备份和恢复速度较慢|
|`pg_dumpall`|备份整个数据库集群，包括所有数据库和全局对象|可以备份整个数据库集群，包括所有数据库和全局对象|只能生成纯文本格式备份文件；备份和恢复速度较慢；不支持并行|


### 3.3 命令行下查看建表语句
```bash
pg_dump -U db_user -h localhost -p 5432 -d database_name -t table_name -s
```

### 3.4 杀进程
```sql
-- pg查询链接
SELECT pid, usename, application_name, client_addr, query FROM pg_stat_activity;


-- kill链接
SELECT pg_terminate_backend(19737);
```

### 3.5 命令行指令
```sql
\h 帮助
\l 查看所有schema
\c 切换schema
\d 查看表结构
```

### 4、后记
常见的操作跟oracle概念很像，因此有oracle经验操作pg会相对顺手一些，暂且记录这些，后续有一些值得记录的再补充