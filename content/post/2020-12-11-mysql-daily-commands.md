---
title: "mysql日常检查命令与优化散记"
date: 2020-12-11T08:00:00+08:00
tags: [ "mysql", "数据库", "优化" ]
description: "mysql 日常巡检命令合集：show warnings/连接数/线程缓存/表锁等状态检查与经验阈值，加建表与索引层面的优化散记（NOT NULL、哈希索引、前缀索引、反序存储等）"
categories: [ "mysql" ]
toc: true
---

## 前言

攒的一些 mysql 日常巡检命令和优化散记，合在一起记录。巡检部分用 show status/variables 就能完成，优化部分是建表和索引设计层面的经验，标注了适用版本。

## 1、日常巡检命令

### 1.1 最后一条语句的报错信息

```sql
-- 显示最后一个执行语句产生的错误、警告和通知
show warnings;

-- 只显示错误
show errors;
```

调试 SQL 时比看客户端提示更全，写存储过程排查尤其有用。

### 1.2 慢查询相关变量

```sql
show variables like '%slow%';
```

看慢查询日志开关和文件位置有没有配上。

### 1.3 连接数

```sql
show variables like 'max_connections';
show global status like 'max_used_connections';
```

经验公式：`max_used_connections / max_connections * 100%`，理想值约 85%。到 99.6% 说明连接数马上要打满，该查漏连接（代码里没释放的）或者调 max_connections 了。

### 1.4 线程缓存

```sql
show global status like 'Thread%';
show variables like 'thread_cache_size';
```

配了 `thread_cache_size` 之后，客户端断开时线程会缓存下来响应下一个连接（缓存数未达上限时）。如果 `Threads_created` 持续增长过大，说明一直在新建线程，适当调大 `thread_cache_size`。

### 1.5 表锁情况

```sql
show global status like 'table_locks%';
```

`Table_locks_immediate` 是立即获得表锁的次数，`Table_locks_waited` 是需要等待表锁的次数。如果 `Table_locks_immediate / Table_locks_waited < 5000`（等待占比过高），说明表锁成了瓶颈——MyISAM 是表锁，高并发写入场景建议换 InnoDB（行锁）。

### 1.6 show 命令常用集

```sql
show tables;                          -- 当前库所有表（或 show tables from db_name）
show databases;                       -- 所有数据库
show columns from table_name;         -- 表的列信息
show grants for user_name;            -- 用户权限
show index from table_name;           -- 表的索引
show status;                          -- 系统资源状态（运行线程数等）
show variables;                       -- 系统变量
show processlist;                     -- 当前正在执行的查询
```

`show processlist` 有 process 权限才能看到所有人的连接。

## 2、建表与索引优化散记

> 说明：以下经验基于 MySQL 5.1-5.6，新版本大部分仍适用但以实际测试为准；是否有效果应以基于业务数据的验证为准。

**1、列优先 NOT NULL**：允许 NULL 的列更占空间，还会影响优化器。业务允许就 NOT NULL 加默认值（空串、-1 之类）。

**2、整型代替浮点**：DECIMAL 精度高但效率和空间都差。精确到小数点后 7 位的数据，可以乘以 1000000 存整型，显示时应用层转换。

**3、索引优先唯一**：确定不重复且有查询需求的列建唯一索引——除了防脏数据，还明确告诉优化器「找到一条就可以结束扫描」。

**4、长字符串精确查找用哈希索引**：URL 这类长列上直接建索引又大又慢：

```sql
-- 原查询
select url from myurls where url='http://blog.example.com/article/51660864';
-- 加一列 hashurl 存哈希值并建索引，插入时应用层算好
select url from myurls where hashurl=3346369 and url='http://blog.example.com/article/51660864';
```

hashurl 索引先过滤掉绝大多数行，等值匹配解决哈希冲突。

**5、前缀索引**：同一个问题的另一个解法，只对开头几个字符建索引：

```sql
alter table myurls add key(url(10));
```

注意前缀的区分度——网址都以 http 开头，前 10 个字符就没什么过滤作用。《高性能MySQL》里的定长方法：先对完整列 group by 看值分布，再逐步增加前缀长度 group by，直到分布数字和完整列接近。

**6、反序存储绕过前置通配符**：`like '%qq.com'` 这类查询索引不生效，把字符串反序存储解决：

```sql
-- 123@qq.com 存成 moc.qq@321
select * from emails where email like 'moc.qq@%';
```

**7、能用 ENUM 就别 VARCHAR**：取值固定的列（状态、类型）用 ENUM，存储和比较都是整数，比字符串列高效。

## 总结

巡检记住四个数：连接数比例（≈85%）、Threads_created 增长、表锁等待比（<5000 换 InnoDB）、慢查询开关。优化的共同思路是**给优化器喂确定性**：NOT NULL、唯一索引、哈希列、前缀长度，都是在帮它少扫描。

## 相关阅读

- [mysql主从复制：搭建、状态检查与断点恢复](/post/2020-12-26-mysql-master-slave-replication/)
- [mysql锁与死锁排查：从锁查询到表空间回收](/post/2021-12-18-mysql-lock-deadlock-troubleshooting/)
- [mysql实用三则：数据字典、prompt与字符集乱码](/post/2022-02-12-mysql-tips/)
