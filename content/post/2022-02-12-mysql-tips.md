---
title: "mysql实用三则：数据字典SQL、prompt配置与字符集乱码"
date: 2022-02-12T08:00:00+08:00
tags: [ "mysql", "数据库" ]
description: "mysql 实用技巧三则：用 information_schema 一键导出数据字典、mysql client 的 prompt 提示符配置参数详解、库表字符集不一致导致乱码的三种纠正方案"
categories: [ "mysql" ]
toc: true
---

## 前言

三个 mysql 日常高频小技巧：给新库整理数据字典、连接多个实例时防止在错误的库上执行 SQL、以及老库字符集不一致导致查询乱码的处理。

## 一、用 information_schema 生成数据字典

接手一个没有文档的数据库时，用 information_schema 可以一键导出数据字典。

**1. 查询库下所有表**

```sql
SELECT
  t.table_name 表名,
  t.table_comment 表说明
FROM information_schema.TABLES t
WHERE table_schema = 'your_db';
```

**2. 查询字段明细**

```sql
SELECT
  TABLE_Name 表名,
  COLUMN_COMMENT 字段说明,
  COLUMN_NAME 列名,
  COLUMN_TYPE 数据类型,
  DATA_TYPE 字段类型,
  CHARACTER_MAXIMUM_LENGTH 长度,
  IS_NULLABLE 是否为空,
  COLUMN_DEFAULT 默认值
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = 'your_db';
```

**3. 表和字段一起查询**

```sql
SELECT
  c.table_Name 表名,
  b.table_comment 表说明,
  c.COLUMN_COMMENT 字段说明,
  c.COLUMN_NAME 列名,
  c.COLUMN_TYPE 数据类型,
  c.DATA_TYPE 字段类型,
  c.CHARACTER_MAXIMUM_LENGTH 长度,
  c.IS_NULLABLE 是否为空,
  c.COLUMN_DEFAULT 默认值
FROM information_schema.COLUMNS c,
     (SELECT t.table_Name, t.table_comment
      FROM information_schema.TABLES t
      WHERE table_schema = 'your_db') b
WHERE c.table_schema = 'your_db'
  AND c.table_name = b.table_name;
```

**4. 其他常用**

```sql
-- 只列出有记录的表名
SELECT table_name FROM information_schema.COLUMNS
WHERE table_schema = 'your_db' GROUP BY table_name;

-- 不带表说明的简化版（含空表说明列，方便粘到 excel 再补）
SELECT
  c.TABLE_NAME 表名,
  '' 表说明,
  c.COLUMN_COMMENT 字段说明,
  c.COLUMN_NAME 列名,
  c.COLUMN_TYPE 数据类型,
  c.COLUMN_DEFAULT 默认值
FROM information_schema.COLUMNS c
WHERE c.table_schema = 'your_db';
```

## 二、mysql client 的 prompt 配置

用 mysql client 连接多个实例时，想知道当前连的是哪个实例、哪个账号、在哪个 database——prompt 配置可以帮上大忙：

```txt
# /etc/my.cnf
[mysql]
prompt="\\u@\\h [\\d]>"
```

**1. 临时方案**（只对当前连接生效）：

```bash
mysql -S /tmp/mysql3306.sock --prompt="\\u@\\h [\\d]>"
```

**2. 长期方案**（写进配置文件）：

```txt
# /etc/my.cnf
[mysql]
prompt="\\u@\\h [\\d]>"
```

**3. 参数大全**

| 参数 | 含义 |
| - | - |
| \\C | 当前连接的标志符（show processlist 中看到的连接 ID） |
| \\c | 每次新连接执行语句计数器 |
| \\D | 当前完整时间，包括年月日时分秒 |
| \\d | 当前数据库（use 前显示 (none)） |
| \\h | 实例连接地址 |
| \\l | 分号分界符，可用于多个配置之间 |
| \\m | 当前时间分钟 |
| \\n | 换行符 |
| \\O | 三个字母的月份（Jan, Feb, …） |
| \\o | 数字格式的月份 |
| \\P | 上午下午 am/pm |
| \\p | 当前 TCP/IP 端口 |
| \\R | 当前时间小时，24 时制（0-23） |
| \\r | 当前时间小时，12 时制（1-12） |
| \\S | 分号 |
| \\s | 当前时间秒 |
| \\t | 制表符 |
| \\U | 完整账户名称 user_name@host_name |
| \\u | 用户名 user_name |
| \\v | MySQL 服务器版本 |
| \\w | 当前周几（Mon, Tue, …） |
| \\Y | 当前 4 位数字年 |
| \\y | 当前 2 位数字年 |
| \\_ | 空格 |

## 三、字符集不一致导致查询乱码

**场景**：数据库字符集是 latin1，存储时没乱码；但用 UTF-8 的 JDBC 读取时全是乱码。

![latin1 库查询结果乱码](/posts/mysql/mysql_0.png)

![IDE 控制台读取乱码](/posts/mysql/mysql_1.png)

**纠正方案**：

**方案 1**：连接后显式声明会话字符集：

```java
jdbcTemplate.execute("set names latin1");
```

**方案 2**：JDBC URL 上强制指定字符编码：

```txt
spring.datasource.demo.jdbc-url=jdbc:mysql://192.168.1.100:3306/your_db?characterEncoding=utf8&zeroDateTimeBehavior=convertToNull
```

**方案 3**：从 ResultSet 里按字节流读取后手动转码：

```java
byte[] bb = rs.getBytes(i);
String val = new String(bb, "UTF-8");
```

三个方案按侵入性从低到高排列：能改连接参数就优先方案 2；代码已成型不好动配置时用方案 1；历史数据混杂多种编码时只能用方案 3 逐字段兜底。根治的办法还是找停机窗口把库表统一迁移到 utf8mb4。

---

## 相关阅读

- [mysql主从复制：搭建、状态检查与断点恢复](/post/2020-12-26-mysql-master-slave-replication/)
- [mysql锁与死锁排查](/post/2021-12-18-mysql-lock-deadlock-troubleshooting/)
