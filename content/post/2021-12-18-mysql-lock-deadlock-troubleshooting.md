---
title: "mysql锁与死锁排查：从锁查询到表空间回收"
date: 2021-12-18T08:00:00+08:00
tags: [ "mysql", "数据库" ]
description: "mysql 锁排查实用合集：锁表/进程/锁事务的查询 SQL、Oracle 锁会话处理附节、DELETE 后表空间不回收的两种回收方式与 Online DDL 的 ALGORITHM/LOCK 选项"
categories: [ "mysql" ]
toc: true
---

## 前言

三个日常高频的数据库锁问题合在一起：mysql 里怎么查「谁锁了谁」、Oracle 的锁会话处理（附节）、以及 DELETE 大量数据后表空间为什么不回收、怎么回收。都是拿来就能用的 SQL。

## 一、mysql 锁排查四连查

**1. 查询是否锁表**

```sql
SHOW OPEN TABLES WHERE In_use > 0;
```

**2. 查询当前进程**（看哪些会话在跑、哪些在等待）

```sql
SHOW PROCESSLIST;
```

**3. 查看正在锁的事务**

```sql
SELECT * FROM information_schema.INNODB_LOCKS;
```

**4. 查看等待锁的事务**（与上一条配合定位「谁阻塞了谁」）

```sql
SELECT * FROM information_schema.INNODB_LOCK_WAITS;
```

排查路径：`PROCESSLIST` 找到卡住的会话 → `INNODB_LOCK_WAITS` 找到它在等哪个锁 → `INNODB_LOCKS` 找到持锁者 → 决定 kill 还是等事务提交。

> 释放锁的时机：读锁在第一个 SQL 语句后释放，写锁在事务完成后释放——没有「手动释放锁」的操作，只能结束持锁的会话或事务。`autocommit=0` 时必须手动 commit 才释放，这也是很多「锁莫名不释放」的原因。

## 二、附：Oracle 锁会话处理

Oracle 里的排查思路类似，但要用 `v$` 视图。以 DBA 角色查当前锁：

```sql
SELECT object_id, session_id, locked_mode FROM v$locked_object;

SELECT t2.username, t2.sid, t2.serial#, t2.logon_time
FROM v$locked_object t1, v$session t2
WHERE t1.session_id = t2.sid
ORDER BY t2.logon_time;
```

长期不释放的锁，在**数据库级别**杀掉会话：

```sql
ALTER SYSTEM KILL SESSION 'sid,serial#';
```

注意不要用 OS 层的 `kill -9` 去杀进程：一个用户进程可能持有多把锁，杀 OS 进程不能彻底清除锁的问题，一定用 `ALTER SYSTEM KILL SESSION`。

## 三、DELETE 后表空间为什么不回收

DELETE 只把数据标识为删除，**并没有整理数据文件**——新插入的数据会复用这些被标记的空间，所以 `ibd` 文件不会变小。要真正回收空间有两种方式：

**方式 1：OPTIMIZE TABLE**

```sql
OPTIMIZE TABLE 表名;
```

回收未使用的空间并整理数据文件碎片，对 MyISAM、BDB 和 InnoDB 表生效。

**方式 2：ALTER TABLE 重建表**

```sql
ALTER TABLE 表名 ENGINE=INNODB;
```

## 四、Online DDL 的 ALGORITHM 与 LOCK 选项

上面两条都支持 Online DDL，但重建表期间的锁行为可以显式控制。在 DDL 语句最后用逗号隔开追加：

```sql
ALTER TABLE tbl_name ADD COLUMN col_name col_type, ALGORITHM=INPLACE, LOCK=NONE;
```

**ALGORITHM 选项**：

| 选项 | 含义 | 说明 |
| - | - | - |
| INPLACE | 替换 | 直接在原表上执行 DDL |
| COPY | 复制 | 克隆临时表执行 DDL 再导数据重命名，需要约一倍额外磁盘空间，期间不允许 DML |
| DEFAULT | 默认 | MySQL 自己选择，优先 INPLACE |

**LOCK 选项**：

| 选项 | 含义 | 说明 |
| - | - | - |
| NONE | 无限制 | 可读可写 |
| SHARED | 共享锁 | 可读不可写 |
| EXCLUSIVE | 排它锁 | 不可读不可写 |
| DEFAULT | 默认 | 交给 MySQL 决定；确定不锁表时可以不指定，否则建议显式指定锁类型 |

不指定 ALGORITHM 时，MySQL 按 **INSTANT → INPLACE → COPY** 的顺序自动选择；显式指定但不支持会直接报错——这反而是好事，提前暴露问题而不是悄悄 COPY 大表。

## 总结

锁排查记住路径：`SHOW PROCESSLIST` → `INNODB_LOCK_WAITS` → `INNODB_LOCKS` → 处理会话；空间回收记住两条：`OPTIMIZE TABLE` 或 `ALTER TABLE ... ENGINE=INNODB`，且都安排在业务低峰执行——Online DDL 再「online」，重建大表也是 IO 大户。

## 参考

- [mysql 死锁查询](https://www.cnblogs.com/caidapeng/p/8177293.html)
- [Online DDL 选项说明](https://www.jb51.net/article/201221.htm)

---

## 相关阅读

- [mysql实用三则：数据字典、prompt与字符集乱码](/post/2022-02-12-mysql-tips/)
- [mysql主从复制：搭建、状态检查与断点恢复](/post/2020-12-26-mysql-master-slave-replication/)
