---
title: linux的一些细节点-不定期补充
date: 2019-04-21T21:46:20+08:00
tags: [ "linux" ]
description: "linux的一些细节点-不定期补充"
categories: [ "linux" ]
toc: true
---

## 前言
linux的 tmp 目录和 var 目录会被系统定期清理

## 1、tmp目录
tmp下的文件或目录长时间没有更新或者改动的话会被系统定期时间，配置参考如下:
```bash
vi /usr/lib/tmpfiles.d/tmp.conf
``` 
```bash
# Clear tmp directories separately, to make them easier to override  
v /tmp 1777 root root 90d  
v /var/tmp 1777 root root 90d  

# Exclude namespace mountpoints created with PrivateTmp=yes  
x /tmp/systemd-private-%b-*  
X /tmp/systemd-private-%b-*/tmp  
x /var/tmp/systemd-private-%b-*  
X /var/tmp/systemd-private-%b-*/tmp
```

## 2、tcp连接数
```bash
netstat -ant|awk '/^tcp/ {++S[$NF]} END {for(a in S) print (a,S[a])}'

TIME_WAIT 1
FIN_WAIT2 1
ESTABLISHED 34
LAST_ACK 1
LISTEN 23
```

## 3、wget下载提示ssl错
```bash
wget --no-check-certificate -O brutexss.zip "http://files.cnblogs.com/files/Pitcoft/Brutexss(%E6%B1%89%E5%8C%96%E6%94%B9%E8%BF%9B).zip"
```

## 4、wget抓取网站
```bash
wget -m -e robots=off https://www.baidu.com
-m是克隆整个网站,-e robots=off是让wget忽视robots.txt
```

## 5、shell批量注释
<<'COMMENT'
...

COMMENT
举例如下：
```bash
#!/bin/bash
echo "Say Something"
<<COMMENT
    your comment 1
    comment 2
    blah
COMMENT
echo "Do something else"
```

## 6、linux的proc
/dev/pts/x       虚拟终端
/dev/ttySx       串行控制端
/dev/ttyx        控制台
/dev/console     单用户控制台

/etc/motd        用于登陆的提示信息

## 7、使用iptables模拟故障
使用 iptables 来模拟网络故障的时候，我们针对 Redis 写入进行处理。
简单来说就是在 Redis Server 端口 OUTPUT 的网络包分别进行 REJECT 和 DROP 操作。
```bash
sudo iptables -D OUTPUT -p tcp --destination-port 22368 -j REJECT
sudo iptables -D OUTPUT -p tcp --destination-port 22368 -j DROP
```
异常信息：
```java
Caused by: java.net.SocketTimeoutException: connect timed out
```

## 8、删除乱码文件
查询文件的inode编号
```bash
ls -li 
```
列出文件的节点ID, 如: 123456789 
单个删除
```bash
find ./ -inum 123456789 -print -exec rm -rf {} \; 
```
批量删除 
```bash
for n in 123456789 987654321; 
do 
   find . -inum $n -exec rm -f {} \;
done 
```
-inum是find命令的参数  
-exec后面是shell命令  
{}代表当前文件（夹），  
\;表示shell命令结束  

## 9、tty、pts
tty本地登陆
pts远程登录

## 10、一些特殊参数
参数|说明
-|-
$#|是传给脚本的参数个数  
$0|是脚本本身的名字
$1|是传递给该shell脚本的第一个参数
$2|是传递给该shell脚本的第二个参数
$@|是传给脚本的所有参数的列表
$*|是以一个单字符串显示所有向脚本传递的参数，与位置变量不同，参数可超过9个
$$|是脚本运行的当前进程ID号
$?|是显示最后命令的退出状态，0表示没有错误，其他表示有错误

## 11、base64
Linux下用base64命令加解密字符串
```bash
加密：
$ echo Hello World | base64
SGVsbG8gV29ybGQK
解密：
$ echo SGVsbG8gV29ybGQK | base64 -d
Hello World
```
mac:
```bash
字符串： 
echo "abc" | base64
解码：     
echo "YWJjCg==" | base64 -D
```