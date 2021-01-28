---
title: "挖矿病毒2"
date: 2021-01-28T00:29:47+08:00
tags: [ "miner" ]
description: "挖矿病毒2"
categories: [ "miner" ]
toc: true
---

## 1、前言
1月23日晚上22点附近，公司群收到管理员说阿里云报了挖矿病毒的警告，看机器用途像是我负责的服务

## 2、分析

## 3、排查

## 4、思路

top查找异常进程，发生时
/tmp下找异常目录
$HOME下找异常目录

检查日志/var/log/messages
/var/log/cron

定时任务
/etc/crontab
/var/spool/cron/root

检查是否有创建账号
/etc/passwd
/etc/shadow

检查命令 - 有的会更改
wget
curl

检查/$HOME/.bash_profile
.bash_history

端口
netstat -antlp|more

pid找目录
ps -axuf | grep pid
ls /proc/{$pid}/