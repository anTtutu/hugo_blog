---
title: "linux小技巧：文件句柄排查与乱码文件名删除"
date: 2019-02-18T08:00:00+08:00
tags: [ "linux", "运维" ]
description: "linux 运维小技巧合集：lsof 统计进程文件句柄数与 ulimit 上限调整、TIME_WAIT 过多的内核参数调优、ls -i 配合 find -inum 删除/重命名乱码文件名"
categories: [ "linux" ]
toc: true
---

## 前言

攒了几个 linux 小技巧，单独发太碎，合在一起记录：文件句柄占用排查（句柄打满的锅十有八九是它）、TIME_WAIT 过多的内核参数、还有删除乱码文件名文件。

## 1、文件句柄排查

服务报 `Too many open files` 的时候，先找到是谁把句柄吃光的：

```bash
# 按进程统计打开的文件句柄数量，倒序
lsof -n | awk '{print $2}' | sort | uniq -c | sort -nr | more

# 拿到进程号后再确认是什么进程
ps -aef | grep 进程号
```

调大句柄上限，root 登录：

```bash
vi /etc/security/limits.conf
# 添加（硬/软限制一次配齐的写法）
* - nofile 65535

# 再让登录 shell 生效
vi ~/.profile        # 添加 ulimit -n 65535
. ~/.profile

# 验证
ulimit -n
```

## 2、TIME_WAIT 过多的内核调优

句柄之外的另一类资源耗尽是 TCP 的 TIME_WAIT 堆积。先看状态分布：

```bash
# 各 TCP 状态数量统计
netstat -n | awk '/^tcp/ {++S[$NF]} END {for(a in S) print a, S[a]}'

# 系统级 socket 统计
cat /proc/net/sockstat
```

TIME_WAIT 状态的 socket 要等 2MSL 时间才回收，高并发短连接下会堆到几万个。在 `/etc/sysctl.conf` 里加参数：

```txt
# 改系统默认的 TIMEOUT 时间
net.ipv4.tcp_fin_timeout = 2

# 开启重用，允许将 TIME-WAIT sockets 重新用于新的 TCP 连接（默认 0 关闭）
net.ipv4.tcp_tw_reuse = 1

# 开启 TIME-WAIT sockets 的快速回收（默认 0 关闭）
net.ipv4.tcp_tw_recycle = 1
```

生效：

```bash
sysctl -p
```

> 提醒：`tcp_tw_recycle` 在 NAT 环境下会造成丢包，linux 4.12 起这个参数已被移除；新内核环境配 `tcp_tw_reuse` 加长连接化才是正路。老环境（centos 6/7）按上面配没问题。

## 3、删除/重命名乱码文件名文件

有些文件解压或转移后文件名变成乱码，终端里敲不出名字，rm 都删不掉。用 inode 编号操作：

```bash
# 1. ls -i 列出文件的 inode 编号
ls -i
# 123456789  ????.txt

# 2. 按 inode 删除
find ./ -inum 123456789 -print -exec rm -rf {} \;

# 重命名（比删除更常用：把乱码名改成正常名）
find ./ -inum 123456789 -exec mv {} newname \;

# 3. 批量删除多个
for n in 123456789 987654321; do find . -inum $n -exec rm -f {} \;; done
```

**批量把乱码文件改成编号文件名**（awk 生成命令管道给 sh 执行）：

```bash
ls -i | awk '{printf("find . -inum %s -exec mv {} %03d.txt \\;\\n", $1, ++i)}' | sh
```

原理说明：`-inum` 是 find 按 inode 查找的参数；`-exec` 后面跟 shell 命令，`{}` 代表 find 找到的当前文件，`\;` 表示命令结束。awk 里 `$1` 是 ls -i 输出的第一列（inode），`++i` 从 1 开始自增当文件序号。

## 总结

三个技巧的共同点：都是绕开「名字」直接操作底层资源——句柄看进程、TIME_WAIT 看内核参数、乱码文件看 inode。遇到名字层面解决不了的问题，换个层面下手往往就通了。
