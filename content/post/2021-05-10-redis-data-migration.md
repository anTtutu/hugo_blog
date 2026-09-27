---
title: "redis数据迁移：跨机房同步的python脚本"
date: 2021-05-10T08:00:00+08:00
tags: [ "redis", "python", "迁移" ]
description: "redis 跨机房数据迁移实战：不支持 slaveof 的云实例如何同步，pipeline 批量 restore 保 TTL、key 冲突阈值处理、iptables 端口转发打通跨机房网络，附完整脚本与实测数据"
categories: [ "redis", "python" ]
toc: true
---

## 前言

那阵子好几个项目要从老机房迁到阿里云，redis 直接用了阿里云带密码认证的实例。开发不想丢数据，又不愿意自己导，最后落到运维头上。麻烦在于：**阿里云的 redis 实例只给访问地址、端口、密码，不支持 slaveof**，主从同步这条路走不通，只能自己写个 python 脚本把源 redis 的数据取出来再写进去。

脚本基于开源工具（作者 JaesonCheng，见文末参考）整理改造，实测 7.7 万个 key 同步只用了 6 秒。

## 1、环境与造数

三个测试实例：

- redis1：localhost:4500（不带认证）
- redis2：localhost:4600（不带认证）
- redis3：localhost:4700（带认证，密码 redistest）

先往 redis1 写 10 万个 key 当测试数据：

```bash
/usr/bin/redis-benchmark -h localhost -p 4500 -t set -r 100000 -n 1000000
```

## 2、脚本设计思路

migrate_redis.py 的几个关键设计：

- **pipeline 批量同步**，不走 for 循环一条条 get/set，速度差几个量级
- 处理 **key 过期、value 为空、多源合并时的 key 冲突**，各自计数
- **冲突阈值策略**：目标里已存在的冲突 key 少于 50 个就直接跳过这些继续同步；超过 50 个直接退出不同步——冲突太多说明目标不是空的，大概率是跑错了环境，宁可停
- 开始前打印源 key 数量、内存占用，结束后打印总耗时和三类异常计数

核心同步逻辑用的是 `DUMP` + `RESTORE` 而不是 GET/SET：

```python
def pipe_restore(self, keys):
    src_len = 0
    keylist = []
    for key in keys:
        keylist.append(key)
        self.src_pipe.dump(key)      # 序列化整个 value（保留类型和编码）
        self.src_pipe.ttl(key)       # 顺带取 TTL
        if src_len < self.pipesize:
            src_len += 1
        else:
            keyttlList = self.src_pipe.execute()
            for (k, t, v) in zip(keylist, keyttlList[1::2], keyttlList[0::2]):
                if t == None or t == -1:          # 永不过期
                    if v != None:
                        self.dst_pipe.restore(k, 0, v)
                    else:
                        self.addvaluenil()        # value 为空计数
                elif t == -2:                     # 已过期
                    self.addkeyoverdue()
                else:                             # 有 TTL，原样保留过期时间
                    if v != None:
                        self.dst_pipe.restore(k, t, v)
                    else:
                        self.addvaluenil()
            self.dst_pipe.execute()
            src_len = 0
            keylist = []
```

用 DUMP/RESTORE 的好处：**序列化格式原样搬，数据类型（hash/list/zset）、编码、TTL 全都保真**，GET/SET 只能搬 string 类型。

pipesize 定 1000，注释里写清楚了原因：源是线上 redis 时 pipeline 太大会产生阻断，影响正常请求。

冲突检查也是 pipeline 批量 exists：

```python
def checkeyexist(self):
    exkeyList = []
    i = -1
    srckeys = self.src_redis.keys()
    for key in srckeys:
        self.dst_pipe.exists(key)
    for st in self.dst_pipe.execute():
        i = i + 1
        if st:
            self.addkeyexist()
            exkeyList.append(srckeys[i])
    return exkeyList
```

## 3、使用方法

参数格式 `ip:port[:db][:passwd]`，冒号分隔：

```bash
$ python migrate_redis.py
  Usage:
      python migrate_redis.py SRC DEST      同步源 Redis 所有 key 到目标 Redis

  example:
      1. python migrate_redis.py 192.168.1.1:4500 192.168.1.5:4500
      2. python migrate_redis.py 192.168.1.1:4500:0 192.168.1.5:4500:1
      3. python migrate_redis.py 192.168.1.1:4500 192.168.1.5:4500::passwd
      4. python migrate_redis.py 192.168.1.1:4501:0:passwd 192.168.1.5:4500:1:passwd
```

同步实测：

```bash
$ python migrate_redis.py 127.0.0.1:4500 127.0.0.1:4600
************************************************************
redis src total keys: 77161  used memory: 7 Mb
redis dst total keys: 77161

value is nil: 0
key overdue : 0
key is exist: 0

Start at 2017-05-16 17:17:05 , End at 2017-05-16 17:17:12 , Usetime: 6.000 s
************************************************************
```

77161 个 key，6 秒同步完。

## 4、跨机房同步：iptables 端口转发

真实环境的问题：业务从一个机房迁另一个机房，redis 默认都只监听内网，跨机房网络不通。

解决办法：在源机器上做端口转发，把外网端口伪装成内网地址。环境模拟：

- 旧业务 redis-4500，外网 eth0：198.51.100.10，内网 eth1：192.168.5.10
- 新业务阿里云 redis-6379，内网：10.0.0.5，密码 redis123

在旧业务 redis 机器上加三条防火墙规则：

```bash
# 允许新业务机器访问本机 4500-4530 端口
iptables -A INPUT -s 203.0.113.10/32 -p tcp -m tcp --dport 4500:4530 -j ACCEPT
# 目标地址转换：外网 IP 的 4500-4530 包转给内网 redis
iptables -t nat -A PREROUTING -d 198.51.100.10/32 -p tcp -m tcp --dport 4500:4530 -j DNAT --to-destination 192.168.5.10
# 内网卡上做源伪装
iptables -t nat -A POSTROUTING -d 192.168.5.10/32 -p tcp -m tcp --dport 4500:4530 -o eth1 -j MASQUERADE
```

先 telnet 验证连通：

```bash
$ telnet 198.51.100.10 4500
Trying 198.51.100.10...
Connected to 198.51.100.10.
Escape character is '^]'.
```

通了之后就可以跨机房同步了：

```bash
python migrate_redis.py 198.51.100.10:4500 10.0.0.5:6379:0:redis123
```

## 总结

这个方案适合「目标 redis 不支持 slaveof、量又不至于上 rump 之类工具」的场景。要点三个：DUMP/RESTORE 保真搬数据、pipeline 控制批量大小（线上源别超 1000）、冲突阈值兜底防跑错环境。跨机房打不通网络就用 iptables DNAT + MASQUERADE 伪装内网。如果目标也是自建 redis 且网络可达，直接 slaveof 同步完 slaveof no one 更省事。

## 参考

- 脚本原作者：JaesonCheng（migrate_redis.py v0.3）
