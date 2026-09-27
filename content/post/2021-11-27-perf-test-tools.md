---
title: "性能测试入门：从PV/QPS/TPS概念到四款压测工具横评"
date: 2021-11-27T08:00:00+08:00
tags: [ "性能测试", "压测" ]
description: "性能测试入门：PV/QPS/TPS 概念辨析，wrk、ab、locust、jmeter 四款压测工具的用法与单机压测横评（含 top 资源监控参数解读）"
categories: [ "性能测试" ]
toc: true
---

## 前言

项目需要对一批接口压测，要求 QPS 达到 6 万以上。一直用的 jmeter 单台电脑打不到这个量级，于是对几款主流压测工具做了一次横评。压测机为 Linux 4核8G，为避免干扰，测试时服务器只运行压测工具，且非本机压本机。

先从概念说起，再对比工具。

## 一、先分清 PV / QPS / TPS

- **PV（Page View）**：页面访问量，每次用户访问或者刷新页面都会被计算在内。
- **QPS（Query Per Second）**：每秒查询数，每秒系统能够处理的查询请求次数。比如执行了 select 操作，相应的 qps 会增加。
- **TPS（Transactions Per Second）**：每秒事务数，每秒系统能够处理的事务次数。比如执行了 dml 操作，那么相应的 tps 会增加。

**不同的应用系统 tps/qps 是没有可对比性的**。例如：

- 应用 A，每个 select 查询需要 1ms，一个 connection 不停执行，1S 内可执行 1000 次，即 1000 qps
- 应用 B，每个 select 查询需要 100ms，一个 connection 不停执行，1S 内可执行 10 次，即 10 qps

这两个 qps 无法对比，不能说哪个好哪个坏——**满足业务要求才是王道**。

## 二、四款压测工具横评

### 1. Wrk

现代化的 HTTP 性能测试工具，即使运行在单核 CPU 上也能产生显著的压力。最大优点是**支持多线程**，更容易发挥多核 CPU 的能力，容易测出系统极限。

安装：

```bash
git clone https://github.com/wg/wrk.git
cd wrk && make
./wrk -v
```

![wrk 版本验证](/posts/perf/perf_0.png)

参数说明：

- `-c`：总的连接数（每个线程处理的连接数 = 总连接数/线程数）
- `-d`：测试持续时间（2s / 2m / 2h，默认 s）
- `-t`：线程总数，默认 2，一般核数的 2~4 倍足够，过多反而因线程切换降低效率
- `-s`：执行 Lua 脚本
- `-H`：添加的头信息，如 `-H "token: abcdef"`
- `--timeout`：超时时间
- `--latency`：显示延迟统计信息

结果名词：Latency 响应时间；Req/Sec 每线程每秒执行的连接数；Avg 平均 / Max 最大 / Stdev 标准差；`+/- Stdev` 正负一个标准差占比；Requests/sec 每秒请求数（QPS）= 总请求数/测试总耗时。

运行：

```bash
./wrk -t 5 -c 300 -d 60 --latency https://api.example.com/logstash/userbehavior/create
# 300 个连接数跑 60 秒：Requests/sec = 3322.48

./wrk -t 5 -c 500 -d 60 --latency https://api.example.com/logstash/userbehavior/create
# 500 个连接数跑 60 秒：Requests/sec = 3321.67
```

![wrk 300 连接压测结果](/posts/perf/perf_1.png)

![wrk 500 连接压测结果](/posts/perf/perf_2.png)

连接数从 300 加到 500，QPS 没有明显变化，就没有再往上加的必要了——再加也只会花更多时间在线程切换上，QPS 不一定上升（300 连接时 CPU 已经跑满）。

post 请求 body 不为空时指定 lua 脚本：

```bash
./wrk -t 5 -c 300 -d 60 --script=post.lua --latency https://api.example.com/xxx
```

post.lua：

```lua
wrk.method = "POST"
wrk.body = ""
wrk.headers["Content-Type"] = "application/x-www-form-urlencoded"
```

### 2. Apache Benchmark（ab）

apache 自带的压力测试工具。

```bash
sudo yum install httpd-tools
ab -V
```

![ab 版本验证](/posts/perf/perf_3.png)

参数说明：`-n` 请求总数（与 -t 二选一）；`-c` 并发数；`-t` 请求时间；`-p` 模拟 post 请求的数据文件（格式 `gid=2&status=1`，配合 -T）；`-T` post 数据的 Content-Type。

结果逐行解读：

```txt
Server Software:        nginx/1.13.6            # 测试服务器的名字
Server Hostname:        api.example.com         # 请求的URL主机名
Server Port:            443
Document Path:          /logstash/userbehavior/create
Document Length:        0 bytes                 # HTTP响应数据的正文长度
Concurrency Level:      300                     # 并发用户数
Time taken for tests:   22.895 seconds          # 所有请求处理完成的总时间
Complete requests:      50000                   # 总请求数
Failed requests:        99                      # 连接服务器、发送数据等环节异常及超时无响应的数量
Total transferred:      96200 bytes             # 所有请求的响应数据长度总和（含头信息）
HTML transferred:       79900 bytes             # 响应正文数据总和
Requests per second:    2183.91 [#/sec] (mean)  # 吞吐率 = 总请求数/总耗时
Time per request:       137.368 [ms] (mean)     # 用户平均请求等待时间 = 总耗时/(总请求数/并发数)
Time per request:       0.458 [ms] (mean, across all concurrent requests)
                                                 # 服务器平均请求等待时间，吞吐率的倒数
Transfer rate:          652.50 [Kbytes/sec] received
                                                 # 单位时间从服务器获取的数据长度，反映处理极限时出口带宽需求
```

运行：

```bash
ab -c 300 -t 60 https://api.example.com/logstash/userbehavior/create
# 300 线程跑 60 秒：Requests per second = 2301.68

ab -c 500 -t 60 https://api.example.com/logstash/userbehavior/create
# 500 线程跑 60 秒：Requests per second = 2279.27
```

![ab 300 并发压测结果](/posts/perf/perf_4.png)

![ab 500 并发压测结果](/posts/perf/perf_5.png)

线程数加到 500 反而不如 300——**线程数不是越高越好**，要根据服务器 CPU、IO、带宽等配置设置合理的值。

> 细节：设置了 `-t 60` 但实际只跑了 20 多秒，因为 ab 跑满 50000 个 request 就自己停了，想跑够 60s 用 `-n` 参数。

post 请求：

```bash
ab -n 100 -c 10 -p 'post.txt' -T 'application/x-www-form-urlencoded' 'http://test.example.com/ttk/auth/info/'
# post.txt 内容：devices=4&status=1
```

### 3. Locust

Python 编写的分布式性能测试工具。

> 注：本文实测于 2018 年，使用 locust 0.9 时代的 API（`pip install locustio`、`HttpLocust`、`task_set`）。locustio 包 2020 年后已废弃，新版安装用 `pip install locust`，且 `HttpLocust` 改名 `HttpUser`、`task_set` 改为 `tasks` 列表、`min_wait/max_wait` 移入 `wait_time` 策略，对照阅读即可。

```bash
sudo yum -y install python-pip
pip install locustio
locust --version
```

![locust 版本验证](/posts/perf/perf_6.png)

参数说明：`--host` 指定被测主机（如 http://192.168.21.25）；`-f` 指定测试文件（默认 locustfile.py）；`--no-web` 无界面模式运行（需配合 `-c` 并发用户数、`-r` 每秒启动用户数、`-t` 运行时间）。

结果名词：reqs 请求数量；fails 失败数量；Avg/Min/Max 平均、最小、最大响应时间（毫秒）；Median 中间值；req/s 每秒请求个数。

locust_demo.py：

```python
# coding=utf-8
from locust import HttpLocust, TaskSet, task

class UserBehavior(TaskSet):
    @task(1)
    def profile(self):
        self.client.post("/logstash/userbehavior/report", {})

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 0
    max_wait = 0
```

```bash
locust -f locust_demo.py --host=https://api.example.com --no-web -c 300 -t 60s
# 300 线程跑 60 秒：Req/s = 730.10
locust -f locust_demo.py --host=https://api.example.com --no-web -c 500 -t 60s
# 500 线程跑 60 秒：Req/s = 741.50
```

![locust 300 并发运行结束日志](/posts/perf/perf_7.png)

![locust 500 并发运行结束日志](/posts/perf/perf_8.png)

### 4. JMeter

Apache 组织开发的基于 Java 的压力测试工具。

> 注：文中所装为 jmeter 3.2（2017 年版本），该大版本早已 EOL，现役为 5.6.x 系列，命令行模式与 jtl 报告用法一致，直接换新包即可。jmeter 需要运行在 Java 8+（新版要求 Java 11+）。

```bash
yum install -y java-1.8.0-openjdk-devel.x86_64
tar zxvf apache-jmeter-3.2.tgz
```

![jmeter 前置 java 版本](/posts/perf/perf_9.png)

参数说明：`-n` 非 GUI 模式；`-t` 测试文件（jmx）位置；`-r` 远程启动所有 agent（分布式场景）；`-l` 结果保存文件（jtl）；`-e` 测试结束后生成报告；`-o` 报告存放位置。

结果名词：Avg/Min/Max 响应时间；Err 错误个数与百分率；Active 激活线程数（Active=0 说明压测结束）；Started/Finished 启动与完成的线程数。

```bash
./jmeter.sh -n -t ./jmx/userbehavior_report.jmx
```

![jmeter 命令行压测运行](/posts/perf/perf_10.png)

300 线程的输出：

```txt
Summary + 398526 in 00:00:18 = 21959.8/s
Summary = 1018846 in 00:01:04 = 15904.6/s
```

`Summary =` 表示总共运行 1 分 04 秒，请求了 1018846 个接口，期间 QPS=15904.6/s；`Summary +` 表示统计最近 18 秒（00:00:46 到 00:01:04）请求了 398526 个接口，QPS=21959.8/s。

### 5. 横评结论

300 线程跑 60 秒，各工具 QPS 对比：

| 工具 | QPS |
| - | - |
| JMeter | 21959.8/s |
| Wrk | 3322.48/s |
| Ab | 2301.68/s |
| Locust | 730.10/s |

我曾以为的压测结果是 wrk > ab > locust > jmeter，实际结果是 **jmeter > wrk > ab > locust**（该 jmeter 用例为批量预生成请求的场景，结果与用例形态有关，仅供参考）。

## 三、压测时怎么看资源消耗：top 参数解读

**cpu 状态**：

- `us`：用户空间占用CPU的百分比
- `sy`：内核空间占用CPU的百分比
- `ni`：改变过优先级的进程占用CPU的百分比
- `id`：空闲CPU百分比
- `wa`：IO等待占用CPU的百分比
- `hi`：硬中断（Hardware IRQ）占用CPU的百分比
- `si`：软中断（Software Interrupts）占用CPU的百分比

**内存状态**：

- `total`：物理内存总量
- `used`：使用中的内存总量
- `free`：空闲内存总量
- `buffers`：缓存的内存量

**进程（任务）状态监控**：

- `PID`：进程id
- `USER`：进程所有者
- `PR`：进程优先级
- `NI`：nice值，负值表示高优先级，正值表示低优先级
- `VIRT`：进程使用的虚拟内存总量，单位kb，VIRT=SWAP+RES
- `RES`：进程使用的、未被换出的物理内存大小，单位kb，RES=CODE+DATA
- `SHR`：共享内存大小，单位kb
- `S`：进程状态。D=不可中断的睡眠状态、R=运行、S=睡眠、T=跟踪/停止、Z=僵尸进程

## 总结

压测三要点：先算清业务要求的 QPS 再选工具；并发数不是越大越好，CPU 跑满后加线程只会增加切换开销；压测同时盯住压测机自身的资源（top 的 us/wa 是关键），别让压测机先成为瓶颈。
