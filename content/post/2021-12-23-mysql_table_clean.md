---
title: "mysql大表的数据清理"
date: 2021-12-23T00:29:47+08:00
tag : [ "mysql", "clean" ]
description: "mysql大表的数据清理"
categories: [ "mysql", "clean" ]
toc: true
---

## 前言
mysql的表日积月累也会出现过千万的大表，有些历史数据可以定期归档清理的，保留最近的数据即可。但是delete table_name where id = '';这种方式只是逻辑上的删除，不会释放表空间和索引的。因此需要在历史数据归档后做表分析才行

## 1、大表归档大量数据
先远程备份，可以开发成shell脚本，设置crontab定期备份
```bash
mysqldump -h 192.168.XX.XX -P 3306 -u${USER} -p${PWD} --database test --tables t_event | gzip > /data/backup/20211223/t_event.sql.gz
```
可以根据自己的业务策略进行历史数据清理
```sql
delete from t_event where id in ('...');
```

## 2、表分析
OPTIMIZE TABLE $(table_name);
```sql
OPTIMIZE TABLE t_event;

Table	        Op	        Msg_type	Msg_text
test.t_event	optimize	note	    Table does not support optimize, doing recreate + analyze instead
test.t_event	optimize	status	    OK
```

发现optimize失效，提示不支持
查了下资料，有说innoDB不支持，用alert替代
```
OPTIMIZE TABLE continues to use ALGORITHM=COPY under the following conditions:
When the old_alter_table system variable is turned ON.
set old_alter_table=on; //alter table 修改表采用 algorithm=copy 方式
When the mysqld --skip-new option is enabled.
```
例如:
```bash
mysqld --datadir=/data --basedir=/usr/local/mysql56 --user=mysql --gdb --skip-new
```

## 3、ALTER表
ALTER TABLE ${tableName} ENGINE=INNODB
```sql
ALTER TABLE t_event ENGINE=INNODB;

OK, Time: 0.014000s
```

## 4、对比前后表数据的条数
重建表后确实生效了数据释放和索引释放，连表空间的占用也少了很多
![](/posts/mysql/before.jpg)
重建表后
![](/posts/mysql/after.jpg)

## 5、另外一种方式
还可以使用pt-online-schema-change脚本在线DDL，属于percona-toolki运维工具系列
```bash
 pt-online-schema-change  
  -h地址
  -P端口号
  -u用户名
  -p密码   
  --database=数据库
  t=表名字
  --charset=utf8 
  --max-lag=300 
  --check-interval=5 
  --alter="ENGINE=InnoDB" 
  --max-load="Threads_running:400" 
  --critical-load="Threads_running:400" 
  --nocheck-replication-filters 
  --alter-foreign-keys-method=auto  
  --execute
```