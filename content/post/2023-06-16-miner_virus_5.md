---
title: "挖矿病毒5-私有云机房挖矿病毒定位"
date: 2023-06-16T00:29:47+08:00
tag : [ "mine", "virus", "linux", "check" ]
description: "挖矿病毒5-私有云机房挖矿病毒定位"
categories: [ "mine", "virus", "linux", "check" ]
toc: true
---

## 前言
6月16日晚，一位朋友咨询說私有云机房服务器有占用cpu比较高的进程无法kill，我通过向日葵远程跳板机分析了下，发现一些不同于以往挖矿病毒有趣的现象，总结下

## 1、初查
初步筛查，发现crontab、top如其他挖矿病毒差不多

### 1.1 进程名称模仿系统进程
![](/posts/virus/top5.png)
初步看进程名kthreaddk，这个挖矿的进程名挺像内核进程kthreadd，但是系统内核进程不太可能cpu占用异常，就继续往下检查
![](/posts/virus/crontab5.png)
查看crontab，发现异常，结果多次执行，发现路径会变。。。，总结下规律，发现一直在/dev/cpu/、/dev/mapper/、/dev/disk/、/dev/一直出现在这几层跳跃

### 1.2 守护进程目录会变
守护进程的目录一直在/dev/cpu/、/dev/mapper/、/dev/disk/、/dev/ 这些目录下反复感染，统计了下，/dev/下目录不少，而且很多是系统设备的数据，因此增加了物理删除的困难性
![](/posts/virus/top5_2.png)

### 1.3 找守护进程的前置脚本
根据定位过程中的信息，想查找前置脚本
![](/posts/virus/wget5.png)
可惜的是前置脚本服务器上的脚本已经被清理
![](/posts/virus/wget5_2.png)

PS:后续提取找本挖矿病毒的前置样本再补充这样的脚本样本... 

### 1.4 提取到守护进程二进制文件
提取到守护进程二进制脚本并上传到病毒库分析
![](/posts/virus/scan5.png)

### 1.5 反编译守护进程
ida打开全部都是会变，仍然是ELF64 linux二进制加壳，换个思路找蛛丝马迹

### 1.6 三板斧：定时任务、隐藏目录、进程和守护机制分析
仍然是三板斧思路，检查和观察定时任务、检查和观察怀疑的目录是否存在隐藏目录、检查和观察进程是否反复拉起

### 1.7 开始清理
清理守护进程、清理隐藏目录、清理定时任务

### 2、后记
这次水了一些，因为挖矿病毒处理起来比较熟练了，基本上仍然是前几篇的思路，寻找守护进程和隐藏目录并清理干净，观察没有反复出现异常进程。

### 3、参考
linux实战清理挖矿病毒kthreaddi: <https://bbs.huaweicloud.com/blogs/363652>  
阿里云【kthreaddk】挖矿病毒清理: <https://www.cnblogs.com/Dev0ps/p/17235809.html>  
典型挖矿家族系列分析三: <https://www.freebuf.com/articles/network/355182.html>
