---
title: "用pt-query-digest分析mysql binlog"
date: 2020-02-11T08:00:00+08:00
tags: [ "mysql", "binlog", "运维" ]
description: "mysql binlog 分析方法：mysqlbinlog 将事件转为可读 SQL，再用 percona 的 pt-query-digest 按 --type binlog 统计分析，含 pt-query-digest 单独安装步骤与实际命令"
categories: [ "mysql" ]
toc: true
---

## 前言

排查历史数据问题时经常要翻 binlog：某个时间段数据到底被谁改成了什么样。mysqlbinlog 只能把 binlog 转成可读文本，想要按语句聚合统计（哪类语句最多、耗时分布），用 percona toolkit 里的 pt-query-digest 加上 `--type binlog` 就能对转出来的结果做分析。我的环境是 centos，亲测可用。

## 1、单独安装 pt-query-digest

不想装整套 percona toolkit 的话，单独装 pt-query-digest 就够了：

```bash
yum install perl-DBI
yum install perl-DBD-MySQL
yum install perl-Time-HiRes
yum install perl-IO-Socket-SSL
wget https://www.percona.com/get/pt-query-digest
chmod u+x pt-query-digest
```

四个 perl 依赖装齐，脚本直接就能跑。

## 2、两步分析法

### 第一步：mysqlbinlog 把事件转成 SQL 文本

```bash
mysqlbinlog ./mysql-bin.000214 \
  --start-datetime="2017-11-08 15:00:00" \
  --stop-datetime="2017-11-08 15:30:00" \
  --base64-output=decode-rows \
  --result-file=result1109-1.sql
```

参数说明：

- `--start-datetime` / `--stop-datetime`：只取目标时间窗内的事件，别全量转，几 G 的 binlog 转出来没法看
- `--base64-output=decode-rows`：ROW 格式的 binlog 里数据是 base64 编码的，加这个参数解码成可读 SQL
- `--result-file`：结果写到指定文件

### 第二步：pt-query-digest 按 binlog 类型分析

```bash
pt-query-digest --type binlog /opt/result1109-1.sql \
  --since "2017-11-08 15:00:00" \
  --until "2017-11-08 15:30:00" >> /opt/mysql-event-3.log
```

`--type binlog` 告诉它输入是 mysqlbinlog 转出来的事件文件（默认分析的是慢查询日志）。输出结果里能看到时间窗内各类事件的统计：每类语句的执行次数、占比、分布，按量排序，谁在疯狂写库一目了然。

## 3、配合使用的场景

这个组合最常用的三个场景：

1. **数据异常追溯**：某张表的数据被意外改了，按时间窗转出 binlog，统计这个时间段谁在写这张表、写了多少条
2. **主从延迟排查**：从库延迟高的时候看看主库 binlog 里是不是有大批量写入（一次 update 几十万行这种）
3. **审计需求**：某个库在某段时间的全部变更操作留档

## 总结

流程就两步：mysqlbinlog 按时间窗解码成 SQL 文本，pt-query-digest `--type binlog` 聚合统计。注意 `--base64-output=decode-rows` 别漏（否则 ROW 格式全是 base64 乱码），时间窗尽量收窄。站的更远一点，日常 binlog 格式如果是 ROW，配合 `--verbose` 还能带上每行的前后镜像，追溯数据变化更直观。
