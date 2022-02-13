---
title: linux的一些细节点-不定期补充
date: 2019-04-21T21:46:20+08:00
tags: [ "linux" ]
description: "linux的一些细节点-不定期补充"
categories: [ "linux" ]
toc: true
---

## 前言
linux的一些小细节记录

## 1、tmp目录、var目录自动清理
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

## 2、tcp连接数统计
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
-m 是克隆整个网站
-e robots=off 是让wget忽视robots.txt
```

## 5、shell批量注释
```
<<'COMMENT'
...

COMMENT  
```
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
类型|说明
-|-
/dev/pts/x|虚拟终端
/dev/ttySx|串行控制端
/dev/ttyx|控制台
/dev/console|单用户控制台

## 7、ssh登录提示信息
类型|说明
-|-
/etc/motd|用于登陆的提示信息

## 8、使用iptables模拟故障
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

## 9、tty、pts
类型|说明
-|-
tty|本地登陆
pts|远程登录

## 10、base64
### Linux下用base64命令加解密字符串
```bash
编码：
$ echo "Hello World" | base64
SGVsbG8gV29ybGQK
解码：
$ echo "SGVsbG8gV29ybGQK" | base64 -d
Hello World
```
### mac:
```bash
编码： 
echo "abc" | base64
YWJjCg==
解码：     
echo "YWJjCg==" | base64 -D
abc
```
### windows
```bat
编码：
certutil -encode 1.txt 2.txt
//将 1.txt 编码为 2.txt
解码：
certutil -decode 2.txt 3.txt
//将 2.txt 解码为 3.txt
```
#### 注:
windows的base64编码是将1.txt的内容输出到2.txt，2.txt必须不存在由命令自己生成  
base64解码是将刚才生成的2.txt的编码输出到3.txt，3.txt必须不存在由命令自己生成  
windows的base64编码比标准的base64尾部数字有少许字符不同或者缺少

## 11、md5等摘要生成
### linux：
```bash
echo -n "123456" | md5sum
e10adc3949ba59abbe56e057f20f883e
```
### mac:
```bash
$ md5 -s "123456"
MD5 ("123456") = e10adc3949ba59abbe56e057f20f883e
```
其他摘要
```bash
#生成32位散列字符串, 可以不带字符串
md5 -s "111111"
MD5 ("111111") = 96e79218965eb72c92a549dd5a330112

#生成40位SHA1散列字符串
echo -n "111111" | openssl sha1
3d4f2bf07dc1be38b20cd6e46949a1071f9d0e3d

#生成64位SHA256散列字符串
echo -n "111111" | openssl sha256
bcb15f821479b4d5772bd0ca866c00ad5f926e3580720659cc80d39c9d09802a

#生成128位SHA512散列字符串
echo -n "111111" | openssl sha512
b0412597dcea813655574dc54a5b74967cf85317f0332a2591be7953a016f8de56200eb37d5ba593b1e4aa27cea5ca27100f94dccd5b04bae5cadd4454dba67d

#32位HMAC md5字符串
echo -n "111111" | openssl dgst -md5 -hmac "key"
617673cb651cec1b48e88f24d8e4df8d

#40位hmac sha1字符串
echo -n "111111" | openssl sha1 -hmac "key"
1cda07ef7e4d03ec3c1bbddbc6f7f5f6aed7a8ce

#64位hmac sha256字符串
echo -n "111111" | openssl sha256 -hmac "key"
847b111693b519f01f26feee81c4a1b73cf2fe2bd8d5df913c4daa1ef0957809

#128位hmac sha512字符串
echo -n "111111" | openssl sha512 -hmac "key"
14b58f8452542bccc82fcabbd4ac268e9d3ce08dd054f0293097fbedfcc3afefcb6d0f1d3468a3926959d22fd67a595ec1c9b0c4b3f7f15cc34589cfad336273

#计算文件md5
md5 xx.txt

#计算文件sha1
openssl sha1 xx.txt
```
#### windows:
```bat
D:\>certutil -hashfile sensors-analytics-1.7.2676-centos6-standalone.tar MD5
MD5 哈希(文件 sensors-analytics-1.7.2676-centos6-standalone.tar):
f3 32 43 0f c5 97 15 2d 0e e4 51 48 2a c5 7f ab
CertUtil: -hashfile 命令成功完成。
```

#### 注:
linux下的其他摘要跟mac的命令差不多  
windows下没测试出字符串的方式，只能针对文件生成md5摘要

## 12、挖矿病毒二进制命令无法被删除
```bash
[root@kubernetes-master sbin]# lsattr scoutd 
----i--------e-- scoutd
[root@kubernetes-master sbin]# chattr -i scoutd 
[root@kubernetes-master sbin]# lsattr scoutd    
-------------e-- scoutd
[root@kubernetes-master sbin]# rm scoutd 
rm: remove regular file ‘scoutd’? y
[root@kubernetes-master sbin]# lsattr scoutd 
lsattr: No such file or directory while trying to stat scoutd
```
### 12.1 文件属性介绍
属性|说明
-|-
A|即Atime，告诉系统不要修改对这个文件的最后访问时间。
S|即Sync，一旦应用程序对这个文件执行了写操作，使系统立刻把修改的结果写到磁盘。
a|即Append Only，系统只允许在这个文件之后追加数据，不允许任何进程覆盖或截断这个文件。如果目录具有这个属性，系统将只允许在这个目录下建立和修改文件，而不允许删除任何文件。
b|不更新文件或目录的最后存取时间。
c|将文件或目录压缩后存放。
d|当dump程序执行时，该文件或目录不会被dump备份。
D|检查压缩文件中的错误。
i|即Immutable，系统不允许对这个文件进行任何的修改。如果目录具有这个属性，那么任何的进程只能修改目录之下的文件，不允许建立和删除文件。
s|彻底删除文件，不可恢复，因为是从磁盘上删除，然后用0填充文件所在区域。
u|当一个应用程序请求删除这个文件，系统会保留其数据块以便以后能够恢复删除这个文件，用来防止意外删除文件或目录。
t|文件系统支持尾部合并（tail-merging）。
X|可以直接访问压缩文件的内容。

### 12.2 参数介绍
参数|说明
-|-
-R|递归处理，将指定目录下的所有文件及子目录一并处理。
-v<版本编号>|设置文件或目录版本。
-V|显示指令执行过程。
+<属性>|开启文件或目录的该项属性。
-<属性>|关闭文件或目录的该项属性。
=<属性>|指定文件或目录的该项属性。