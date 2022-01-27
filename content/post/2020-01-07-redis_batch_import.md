---
title: "30W数据批量导入redis集群"
date: 2020-01-07T00:29:47+08:00
tags: [ "redis" ]
description: "30W数据批量导入redis集群"
categories: [ "redis" ]
toc: true
---

## 前言
碰到工作中有数据要一次性快速刷入redis的场景  
查了下资料，找到了快速高效的写入方法了

## 1、先想法子把数据组装程redis底层的命令格式
比如：
```bash
hset key filed value
set key value
```

## 2、大量的基础数据生成redis命令
之前我是采用golang读取数据源并转化程redis命令

## 3、用redis批量导入方式写入redis
```bash
cat d1.txt | redis-cli -a runoob
```

如果不想看到执行过程，可以用如下
```bash
cat d1.txt | redis-cli -a runoob --pipe
```

如果是远程执行，也可以
```bash
cat d1.txt | redis-cli -a runoob -p 6380 -h 192.168.1.100 --pipe
```

## 4、为什么不用程序去做呢
经过对比测试，程序写入redis还赶不上上面的批量导入命令  
难点是d1.txt文件的生成，需要把数据组装成如下的redis命令  
举例d1.txt样例
```bash
set mykey1 value1
zadd sortedsort 0 a 1 b 3 c
sadd sort mongodb mysql oracle
set mykey2 value2
...
```
不过如果还有其他性能更佳的方式也是可以替代的，目前个人觉得这种批量导入方式性能是最好的
![](/posts/redis/redis.jpg)