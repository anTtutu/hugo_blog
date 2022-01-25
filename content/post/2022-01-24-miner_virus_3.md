---
title: "挖矿病毒3-分析和清理过程"
date: 2022-01-24T00:29:47+08:00
tag : [ "mine", "virus", "linux", "check" ]
description: "挖矿病毒3-分析和清理过程"
categories: [ "mine", "virus", "linux", "check" ]
toc: true
---

## 前言
1月23日，公司邮箱收到说阿里云报了挖矿病毒的警告  

## 1、分析
这次思路改进了些，起初有个只是定时任务没被清理，阿里云通过定时任务关键字"pool.minexmr.com:4444"报了蠕虫病毒，但是根据关键字查看，这像挖矿  
然后 top 了半天没看到结果，怀疑是top被篡改了？？？然后进了/usr/bin/核对下 top 的时间，发现没差异呀，但是本着稳妥期间，还是下载 busybox
```bash
wget https://busybox.net/downloads/binaries/1.30.0-i686/busybox 
chmod +x busybox
cp busybox /usr/bin 
busybox  top
```

## 2、按步骤排查
剩余步骤跟[挖矿病毒2-分析和排查思路](/post/2021-01-28-miner_virus_2)一样，只是所有的命令前面是 busybox command

## 3、整理下一些共性问题
### 3.1 crontab -l失效
crontab -l查不到但是查看/var/log/cron还是会有挖矿的定时任务  
挖矿病毒的定时任务喜欢藏在/var/spool/cron/这里

### 3.2 喜欢隐藏在/tmp或/var这些临时目录
不光喜欢临时目录，而且都是隐藏格式的文件夹，ls 不带-a 的话可能就没法发现  
守护进程和病毒本体放在不同隐藏目录，狡兔三窟
```bash
/dev/shm/.x/secure
/var/tmp/.xri/monitor
/home/oracle/.dhpcd
```

### 3.3 清理系统日志
日志和痕迹基本上都被清理干净，很难找到一些蛛丝马迹
```
其他日志记录：
echo 0>/var/spool/mail/root
last日志
echo 0>/var/log/wtmp
echo 0>/var/log/secure
echo 0>/var/log/cron
history日志 echo > /root/.bash_history

history -c

查看机器创建以来登陆过的用户
/var/log/wtmp

查看机器当前登录的全部用户
/var/run/utmp

登录信息
/var/log/secure
```

### 3.4 前置脚本布置环境
有部分病毒前置脚本加工成二进制，有部分直接 curl 从远程获取并无痕执行  
很难提取到前置脚本

### 3.5 挖矿本体程序都是二进制或加壳
通过 top 、 ps -axuf 或 lsof -i 找到异常进程并跟踪到挖矿本体目录后，发现这些挖矿程序本体都是 ELF 的二进制，有的甚至加壳  
ELF用ida pro 分析下，汇编晦涩难懂，只能提取是否还有价值的信息  
加壳更加不擅长砸壳，只能点到位置，把病毒本体和守护进程、定时任务这些清理干净还原

### 3.6 部份挖矿病毒还会感染
部分挖矿病毒还会通过 .ssh/know_hosts 文件进行感染，需要注意排查

### 3.7 部分挖矿病毒会伪装成系统进程
部分挖矿病毒还会伪装成系统进程，比如kerberdos，直接安装到/user/sbin 目录下

### 3.9 部分挖矿病毒会篡改top grep等系统命令
部分挖矿病毒还会篡改top、grep等系统基础命令，达到过滤病毒本体的目录，这点通过 busybox 即可解决

### 3.10 部分挖矿病毒感染途径是开源软件的漏洞
比如jekins、redis、apache、文件上传漏洞

### 3.11 部分挖矿病毒比较克制，不占满cpu
部分病毒为了达到细水长流的目的，不会跑满所有cpu核心，会伪装成系统进程并只占用一些程序常规的占用率，达到细水长流的目的

### 3.12 部分挖矿病毒是针对容器化的
比如针对docker，不过目前为止，发现的几期都是针对ECS的

## 4、防护建议
### 4.1 注意账号密码保管
不要设置过于简单的密码

### 4.2 使用堡垒机
目前有一例怀疑是外包开发坚守自盗，自己安装了开源挖矿程序，并且本地编译然后启动的

### 4.3 控制端口
按白名单规则开放，只开放需要的端口，其他端口禁止

### 4.4 云服务器的云盾产品尽量安装
云盾产品能够多方位检测入侵和病毒，比如通过病毒本体的 hash 值、异常进程、异常cpu 占用率等因素提醒你服务器异常并排查

### 4.5 不要图方便直接开公网地址和端口
尽量通过堡垒机跳转或者 VPN 跳转，一般应用都是通过 nginx 或者 slb 提供80 443访问的，不会直连服务器，自己方便了，没加固做好防护就是给这些病毒可乘之机

## 5、挖矿病毒的参考
挖矿进程——pool.minexmr.com的解决办法1: https://blog.csdn.net/dot_life/article/details/105480202  
挖矿进程——pool.minexmr.com的解决办法2: https://blog.csdn.net/qq_16845639/article/details/77650271  
kerberods挖矿病毒查杀及分析: https://blog.csdn.net/u010457406/article/details/89328869