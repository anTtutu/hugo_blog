---
title: "Mac下安装aria2下载工具"
date: 2020-09-20T00:29:47+08:00
tags: [ "mac", "aria2" ]
description: "Mac下安装aria2下载工具"
categories: [ "mac", "aria2" ]
toc: true
---

## 前言

尝试在自己的Mac上源码方式安装aria2，根据教程修改了下限制的线程数，然后总结下经验

## 1、下载aria2源码

下载地址：<https://github.com/aria2/aria2>

```bash
git clone --depth=1 https://github.com/aria2/aria2.git
```

## 2、提前准备Mac的编译环境

因aria2是C++的，需要C++的环境，可以通过brew安装

```bash
xcode-select --install

brew install autoconf automake cppunit libtool libxml2 gettext openssl pkg-config sqlite zlib
```

## 3、参考前人总结的源码修改经验修改aria2的源码

```bash
cd aria2/src
vim OptionHandlerFactory.cc
```

### 3.1 将

```c++
OptionHandler* op(new NumberOptionHandler(PREF_MAX_CONNECTION_PER_SERVER,
                                               TEXT_MAX_CONNECTION_PER_SERVER,
                                               "1", 1, 16, 'x'));
```

修改为

```c++
OptionHandler* op(new NumberOptionHandler(PREF_MAX_CONNECTION_PER_SERVER,
                                               TEXT_MAX_CONNECTION_PER_SERVER,
                                               "128", 1, -1, 'x'));
```

### 3.2 将

```c++
PREF_MIN_SPLIT_SIZE, TEXT_MIN_SPLIT_SIZE, "20M", 1_m, 1_g, 'k'));
```

修改为

```c++
PREF_MIN_SPLIT_SIZE, TEXT_MIN_SPLIT_SIZE, "4K", 1_k, 1_g, 'k'));
```

### 3.3 将

```c++
PREF_CONNECT_TIMEOUT, TEXT_CONNECT_TIMEOUT, "60", 1, 600));
```

修改为

```c++
PREF_CONNECT_TIMEOUT, TEXT_CONNECT_TIMEOUT, "30", 1, 600));
```

### 3.4 将

```c++
PREF_PIECE_LENGTH, TEXT_PIECE_LENGTH, "1M", 1_m, 1_g));
```

修改为

```c++
PREF_PIECE_LENGTH, TEXT_PIECE_LENGTH, "4k", 1_k, 1_g));
```

### 3.5 将

```c++
new NumberOptionHandler(PREF_RETRY_WAIT, TEXT_RETRY_WAIT, "0", 0, 600));
```

修改为

```c++
new NumberOptionHandler(PREF_RETRY_WAIT, TEXT_RETRY_WAIT, "2", 0, 600));
```

### 3.6 将

```c++
new NumberOptionHandler(PREF_SPLIT, TEXT_SPLIT, "5", 1, -1, 's'));
```

修改为

```c++
new NumberOptionHandler(PREF_SPLIT, TEXT_SPLIT, "8", 1, -1, 's'));
```

好的，到这里为止我们全部修改完成，保存退出。  

修改参数解读，实际上就是让aria2更加激进，分包多线程下载

```properties
1. PREF_MAX_CONNECTION_PER_SERVER（-x）
修改内容：默认值从 "1" 改成 "128"，最大值从 16 改成 -1（表示无上限）。

参数含义：--max-connection-per-server，同一台服务器最多允许几个连接。

aria2 把文件分成多块，每块可以从同一个服务器用不同连接并行下载。默认只允许 1 个连接，意味着即使服务器支持多连接，aria2 也不会用。改成 128 后，单服务器可以开最多 128 个连接并行拉取，对支持多连接的高速服务器提速明显。

2. PREF_MIN_SPLIT_SIZE（-k）
修改内容：默认值从 "20M" 改成 "4K"，最小值从 1_m 改成 1_k。

参数含义：--min-split-size，文件分片的最小大小。

aria2 决定“要不要把文件拆成多块并行下载”时，会看文件大小是否超过这个阈值。默认 20M 意味着小于 20M 的文件不拆分，只用一个连接。改成 4K 后，几乎任何文件都会被拆成多块，从而触发多连接并行下载。

3. PREF_CONNECT_TIMEOUT
修改内容：默认值从 "60" 改成 "30"。

参数含义：--connect-timeout，建立连接的超时时间（秒）。

默认 60 秒意味着如果一个服务器 60 秒内没连上，aria2 才会放弃并重试。改成 30 秒后，连接失败能更快被发现，从而更快切换到备用连接或重试，减少等待时间。

4. PREF_PIECE_LENGTH（--piece-length）
修改内容：默认值从 "1M" 改成 "4k"，最小值从 1_m 改成 1_k。

参数含义：--piece-length，分片长度。

这个参数和 BitTorrent 的“piece”概念类似，它决定每个分片有多大。分片越小，理论上并行粒度越细，但元数据开销也越大。改成 4K 是为了让小文件也能被拆得更细，配合前面的 min-split-size，让更多文件走多连接下载。

5. PREF_RETRY_WAIT（--retry-wait）
修改内容：默认值从 "0" 改成 "2"。

参数含义：--retry-wait，重试前的等待秒数。

默认 0 表示失败后立刻重试，容易在服务器短暂抖动时反复撞墙。改成 2 秒后，每次重试前先等 2 秒，给服务器一点恢复时间，降低无效重试。

6. PREF_SPLIT（-s）
修改内容：默认值从 "5" 改成 "8"。

参数含义：--split，单个文件最多分成几块并行下载。

默认 5 表示一个文件最多拆成 5 块同时下。改成 8 后，并行度更高，配合前面的 max-connection-per-server=128，可以同时开更多连接抢带宽。

提醒:
这些改动是把 aria2 的默认行为推向“激进多连接”。对支持多连接的高速服务器效果很好，但如果遇到限速严格或对连接数敏感的服务器，反而可能触发风控、被限流甚至封 IP。建议在 aria2.conf 里按需覆盖
```

## 4、编译

每一步都没ERROR，注意查看控制台信息并排错，如果前面编译环境准备到位，应该不会编译环节报错的

```bash
# 下载github依赖包
autoreconf -i

# mac下可以用macos的TLS
./configure --without-openssl --without-gnutls --with-appletls
或
./configure

# 测试可以忽略，一般会报错，如果报错可以忽略直接make && make install，底下会展示报错样例
make check

# 多线程编译
sudo make -j$(sysctl -n hw.ncpu)

sudo make install
```

make install执行完没有任何报错表示安装成功

make check我个人碰到下面错，可以忽略

```bash
ld: warning: -bind_at_load is deprecated on macOS
/Library/Developer/CommandLineTools/usr/bin/make  check-TESTS
FAIL: aria2c
============================================================================
Testsuite summary for aria2 1.37.0
============================================================================
# TOTAL: 1
# PASS:  0
# SKIP:  0
# XFAIL: 0
# FAIL:  1
# XPASS: 0
# ERROR: 0
============================================================================
See test/test-suite.log for debugging.
Some test(s) failed.  Please report this to https://github.com/aria2/aria2/issues,
together with the test-suite.log file (gzipped) and your system
information.  Thanks.
============================================================================
make[3]: *** [test-suite.log] Error 1
make[2]: *** [check-TESTS] Error 2
make[1]: *** [check-am] Error 2
make: *** [check-recursive] Error 1
```

检测aria2c命令，可以出现参数介绍

```bash
> aria2c -h

> aria2c -h
Usage: aria2c [OPTIONS] [URI | MAGNET | TORRENT_FILE | METALINK_FILE]...
Printing options tagged with '#basic'.
See 'aria2c -h#help' to know all available tags.
Options:
 -v, --version                Print the version number and exit.

                              Tags: #basic

 -h, --help[=TAG|KEYWORD]     Print usage and exit.
                              The help messages are classified with tags. A tag
                              starts with "#". For example, type "--help=#http"
                              to get the usage for the options tagged with
                              "#http". If non-tag word is given, print the usage
                              for the options whose name includes that word.

                              Possible Values: #basic, #advanced, #http, #https, #ftp,#metalink, #bittorrent,
                              #cookie, #hook, #file, #rpc, #checksum, #experimental, #deprecated, #help, #all
                              Default: #basic
                              Tags: #basic, #help

 -l, --log=LOG                The file name of the log file. If '-' is
 ......
```

表示环境变量也准备成功

## 5、设置aria2的配置文件(可选)

aria2配置文件参考如下

```bash
mkdir ~/.aria2

vim ~/.aria2/aria2.conf
```

输入以下参数，供参考：

```properties
## 下载设置 ##

# 断点续传
continue=true
# 最大同时下载任务数, 运行时可修改, 默认:5
max-concurrent-downloads=256
# 单个任务最大线程数, 添加时可指定, 默认:5
split=64
# 最小文件分片大小, 添加时可指定, 取值范围1M -1024M, 默认:20M
# 假定size=10M, 文件为20MiB 则使用两个来源下载; 文件为15MiB 则使用一个来源下载
min-split-size=1M
# 同一服务器连接数, 添加时可指定, 默认:1
max-connection-per-server=64
# 断开速度过慢的连接
lowest-speed-limit=0
# 整体下载速度限制, 运行时可修改, 默认:0
#max-overall-download-limit=0
# 单个任务下载速度限制, 默认:0
#max-download-limit=0
# 整体上传速度限制, 运行时可修改, 默认:0
#max-overall-upload-limit=0
# 单个任务上传速度限制, 默认:0
#max-upload-limit=0
# 禁用IPv6, 默认:false
#disable-ipv6=true
# 当服务器返回503错误时, aria2会尝试重连
# 尝试重连次数, 0代表无限, 默认:5
max-tries=0
# 重连冷却, 默认:0
#retry-wait=0

## 进度保存相关 ##

daemon=true 
# 日志保存路径
log=/Users/name/Downloads/aria2/aria2.log
# 从会话文件中读取下载任务
# 开启该参数后aria2将只接受session中的任务, 这意味着aria2一旦使用conf后将不再接受来自终端的任务, 所以该条只需要在启动rpc时加上就可以了
input-file=/Users/name/Downloads/aria2/aria2.session
# 在Aria2退出时保存`错误/未完成`的下载任务到会话文件
save-session=/User/name/Downloads/aria2/aria2.session
# 定时保存会话, 0为退出时才保存, 需1.16.1以上版本, 默认:0
save-session-interval=30
# 强制保存会话, 即使任务已经完成, 默认:false
# 较新的版本开启后会在任务完成后依然保留.aria2文件
force-save=true

## RPC相关设置 ##

# 启用RPC, 默认:false
enable-rpc=false
# 允许所有来源, 默认:false
rpc-allow-origin-all=true
# 允许非外部访问, 默认:false
rpc-listen-all=true
# 事件轮询方式, 取值:[epoll, kqueue, port, poll, select], 不同系统默认值不同
event-poll=kqueue
# RPC监听端口, 端口被占用时可以修改, 默认:6800
#rpc-listen-port=6800
# 设置的RPC授权令牌, v1.18.4新增功能, 取代 --rpc-user 和 --rpc-passwd 选项
#rpc-secret=<TOKEN>
# 设置的RPC访问用户名, 此选项新版已废弃, 建议改用 --rpc-secret 选项
#rpc-user=<USER>
# 设置的RPC访问密码, 此选项新版已废弃, 建议改用 --rpc-secret 选项
#rpc-passwd=<PASSWD>

## BT/PT下载相关 ##

# 当下载的是一个种子(以.torrent结尾)时, 自动开始BT任务, 默认:true
#follow-torrent=true
# BT监听端口, 当端口被屏蔽时使用, 默认:6881-6999
#listen-port=51413
# 单个种子最大连接数, 默认:55
#bt-max-peers=55
# 打开DHT功能, PT需要禁用, 默认:true
#enable-dht=false
# 打开IPv6 DHT功能, PT需要禁用, 默认:true
#enable-dht6=false
# DHT网络监听端口, 默认:6881-6999
#dht-listen-port=6881-6999
# 本地节点查找, PT需要禁用, 默认:false
bt-enable-lpd=true
# 种子交换, PT需要禁用, 默认:true
#enable-peer-exchange=true
# 每个种子限速, 对少种的PT很有用, 默认:50K
#bt-request-peer-speed-limit=50K
# 客户端伪装, PT需要
#peer-id-prefix=-TR2770-
#user-agent=Transmission/2.77
# 当种子的分享率达到这个数时, 自动停止做种, 0为一直做种, 默认:1.0
#seed-ratio=0
# BT校验相关, 默认:true
#bt-hash-check-seed=true
# 继续之前的BT任务时, 无需再次校验, 默认:false
bt-seed-unverified=true
# 保存磁力链接元数据为种子文件(.torrent文件), 默认:false
bt-save-metadata=true
# 强制加密, 防迅雷必备
#bt-require-crypto=true

## 磁盘相关 ##

#文件保存路径, 默认为当前启动位置
dir=/Users/name/Downloads/aria2
#另一种Linux文件缓存方式, 使用前确保您使用的内核支持此选项, 需要1.15及以上版本(?)
enable-mmap=true
# 文件预分配方式, 能有效降低磁盘碎片, 默认:prealloc
# 预分配所需时间: 快none < trunc < falloc < prealloc慢
# falloc仅仅比trunc慢0.06s
# 磁盘碎片: 无falloc = prealloc < trunc = none有
# 推荐优先级: 高falloc --> prealloc --> trunc -->none低
# EXT4, btrfs, xfs, NTFS等新型文件系统建议使用falloc, falloc(fallocate)在这些文件系统上可以瞬间创建完整的空文件
# trunc(ftruncate) 同样是是瞬间创建文件, 但是与falloc的区别是创建出的空文件不占用实际磁盘空间
# prealloc 传统的创建完整的空文件, aria2会一直等待直到分配结束, 也就是说如果是在HHD上下载10G文件，那么你的aria2将会一直等待你的硬盘持续满载工作直到10G文件创建完成后才会开始下载
# none将不会预分配, 磁盘碎片程度受下面的disk-cache影响, trunc too
# 请勿在传统文件系统如:EXT3, FAT32上使用falloc, 它的实际效果将与prealloc相同
# MacOS建议使用prealloc, 因为它不支持falloc, 也不支持trunc, but可以尝试用brew安装truncate以支持trunc(ftruncate)
# 事实上我有些不能理解trunc在aria2中的角色, 它与none几乎没有区别, 也就是说:太鸡肋了
file-allocation=prealloc
# 启用磁盘缓存, 0为禁用缓存, 需1.16以上版本, 默认:16M
disk-cache=64M
```

如果新增了conf文件后下载报错，也可以去掉conf文件

## 6、测试下载

```bash
aria2c http://mirror.compevo.com/centos/8.1.1911/isos/x86_64/CentOS-8.1.1911-x86_64-dvd1.iso
```

稍等会看到下载目录下有centos的iso镜像

## 7、注意

Mac下开启rpc配置项和ssl证书需要参考官方这里的讨论做下测试  
打开rpc配置：

```properties
## RPC相关设置 ##

# 启用RPC, 默认:false
enable-rpc=true
```

### issue参考

issue参考：<https://github.com/aria2/aria2/issues/1379>
