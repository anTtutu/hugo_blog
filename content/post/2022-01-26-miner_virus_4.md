---
title: "挖矿病毒4-容器挖矿病毒清理"
date: 2022-01-26T00:29:47+08:00
tag : [ "mine", "virus", "linux", "check", "docker" ]
description: "挖矿病毒4-容器挖矿病毒清理"
categories: [ "mine", "virus", "linux", "check", "docker" ]
toc: true
---

## 前言
1月26日，运维同学收到告警邮件，告诉我某台测试服务器中了挖矿病毒，心想怎么最近挖矿这么猖狂...  

## 1、分析准备
仍然下载是busybox
```bash
wget https://busybox.net/downloads/binaries/1.30.0-i686/busybox 
chmod +x busybox
cp busybox /usr/bin 
busybox  top
```

## 2、按步骤排查
剩余步骤跟[挖矿病毒2-分析和排查思路](/post/2021-01-28-miner_virus_2)一样，只是所有的命令前面是 busybox command  
不过这次是容器挖矿，ECS 排查步骤仍然走一遍，但是没啥收货，但是恶意进程还是可以找到的

## 3、找到恶意进程
```bash
[root@harbor ~]# busybox top
top - 14:14:48 up 6 days, 10 min,  1 user,  load average: 2.06, 2.32, 2.30
Tasks: 171 total,   1 running, 169 sleeping,   0 stopped,   1 zombie
%Cpu(s): 50.7 us,  0.7 sy,  0.0 ni, 48.7 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem : 16266252 total, 10225056 free,  5006372 used,  1034824 buff/cache
KiB Swap:        0 total,        0 free,        0 used. 10917736 avail Mem 
  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND                                                                                          
 4116 root      20   0 2439464   3272   2132 S 200.3  0.0 750:29.39 .ddns
```

## 4、找到程序目录
```bash
[root@harbor ~]# cd /proc/4116
[root@harbor 4116]# ls -alrt
total 0
dr-xr-xr-x 182 root root 0 Jan 20 14:04 ..
-r--r--r--   1 root root 0 Jan 26 07:58 status
-r--r--r--   1 root root 0 Jan 26 07:58 stat
lrwxrwxrwx   1 root root 0 Jan 26 07:58 cwd -> /var/tmp/.crypto/...
-r--r--r--   1 root root 0 Jan 26 07:58 cgroup
dr-xr-xr-x   9 root root 0 Jan 26 07:58 .
lrwxrwxrwx   1 root root 0 Jan 26 07:58 exe -> /var/tmp/.crypto/.../.ddns


[root@harbor admin]# cd /proc/4115/
[root@harbor 4115]# ls -alrt
total 0
dr-xr-xr-x 182 root root 0 Jan 20 14:04 ..
lrwxrwxrwx   1 root root 0 Jan 26 07:58 cwd -> /var/tmp/.crypto/...
dr-xr-xr-x   9 root root 0 Jan 26 07:58 .
-r--r--r--   1 root root 0 Jan 26 07:58 status
-r--r--r--   1 root root 0 Jan 26 07:58 stat
lrwxrwxrwx   1 root root 0 Jan 26 07:59 exe -> /var/tmp/.crypto/.../httpd-crypto
```

## 5、查看进程
```bash
[root@harbor ~]# busybox lsof -i | grep ddns
4116    /var/tmp/.crypto/.../.ddns      /var/tmp/.crypto/.../.pid
4116    /var/tmp/.crypto/.../.ddns      anon_inode:[eventpoll]
4116    /var/tmp/.crypto/.../.ddns      pipe:[15165876]
4116    /var/tmp/.crypto/.../.ddns      pipe:[15165876]
4116    /var/tmp/.crypto/.../.ddns      pipe:[15165877]
4116    /var/tmp/.crypto/.../.ddns      pipe:[15165877]
4116    /var/tmp/.crypto/.../.ddns      anon_inode:[eventfd]
4116    /var/tmp/.crypto/.../.ddns      /var/tmp/.crypto/.../.ddns.log
4116    /var/tmp/.crypto/.../.ddns      anon_inode:[eventfd]
4116    /var/tmp/.crypto/.../.ddns      anon_inode:inotify
4116    /var/tmp/.crypto/.../.ddns      anon_inode:[eventfd]
4116    /var/tmp/.crypto/.../.ddns      /dev/null
4116    /var/tmp/.crypto/.../.ddns      socket:[15167677]
```

## 6、查找程序本体
发现并不在 ECS 上，试了下有 docker 命令，就查看下 docker 镜像清单
```bash
[root@harbor ~]# docker ps -a

CONTAINER ID        IMAGE                                                                 COMMAND                  CREATED             STATUS                       PORTS                                         NAMES
fd3a4ea7e1d9        ubuntu                                                                "/bin/bash /var/tmp/./crypto/.../httpd-crypto"   11 hours ago        Exited (1) 11 hours ago                                                    
```

## 7、停容器
```bash
[root@harbor ~]# docker stop fd3a4ea7e1d9
```

## 8、删容器
```bash
[root@harbor ~]# docker rm fd3a4ea7e1d9
c5607dd23d6b
```

## 9、删镜像
```bash
[root@harbor ~]# docker rmi 4e5021d210f6
```

## 10、入侵原因
容器的入侵途径没 ECS 方便定位，等后续学会了再补充。。。  
不过清理容器挖矿比 ECS 还方便，查看了下 ECS 日志，只能看到部分 messages 里面存在日志，其他找不到蛛丝马迹了  
不过可以把测试服务器的开源软件版本搜集下，搜查下 CVE 库看看是否有漏洞，如果有漏洞的话可以升级下安全版本