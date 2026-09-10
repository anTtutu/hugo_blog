---
title: "日常研究备用的一些镜像记录"
date: 2026-09-10T00:29:47+08:00
tag : [ "docker", "image", "k8s" ]
description: "日常研究备用的一些镜像记录"
categories: [ "docker", "image", "k8s" ]
toc: true
---

## 前言

日常研究需要用到一些基础镜像，下载了一些轻量或者合集的镜像，方便手头立马使用，记录下这些搜集的镜像

## 一、镜像总览（列表）

| # | 镜像 | 镜像 ID | 磁盘占用 | 唯一占用 | 分类 |
|---|---|---|---|---|---|
| 1 | harbor-test.***.cn/library/golang:1.26-bookworm | 116d58cbd88c | 1.24GB | 10.53MB | WeKnora 项目 |
| 2 | harbor-test.***.cn/library/node:22-bookworm | 8a34c4ab3ea2 | 1.64GB | 16.19MB | WeKnora 项目 |
| 3 | harbor-test.***.cn/library/debian:12.12-slim | d5d3f9c23164 | 116MB | 2.362MB | WeKnora 项目 |
| 4 | harbor-test.***.cn/library/nginx:1.30.3-alpine | 0d3b80406a13 | 93.3MB | 890.3kB | WeKnora 项目 |
| 5 | harbor-test.***.cn/library/ubuntu:24.04 | 224a1869083a | 119MB | 1.941MB | WeKnora 项目 |
| 6 | harbor-test.***.cn/library/weknora-app-builder:latest | f6096ec30238 | 5.53GB | 4.308GB | WeKnora 项目 |
| 7 | harbor-test.***.cn/library/weknora-ui-builder:latest | 62228836b8ec | 2.65GB | 1.025GB | WeKnora 项目 |
| 8 | harbor-test.***.cn/library/weknora-app-runtime-base:latest | 28db2cbf471c | 2.04GB | 8.257kB | WeKnora 项目 |
| 9 | harbor-test.***.cn/library/weknora-ui-runtime-base:latest | 45c33e557ef6 | 92.4MB | 4.338kB | WeKnora 项目 |
| 10 | harbor-test.***.cn/library/weknora-app:v0.7.2-a40b4fb8 | 549319f486b6 | 2.39GB | 357.4MB | WeKnora 项目 |
| 11 | harbor-test.***.cn/library/weknora-ui:v0.7.2-a40b4fb8 | c76acfe248fb | 129MB | 36.41MB | WeKnora 项目 |
| 12 | harbor-test.***.cn/library/kkfileview-base:4.4.0 | 9f395205812d | 1.89GB | 6.515kB | WeKnora 项目 |
| 13 | harbor-test.***.cn/library/kkfileview:4.4.0 | 7abaef3beead | 2.54GB | 654.1MB | WeKnora 项目 |
| 14 | golang:1.26-alpine | 28d89ee9cc0f | 364MB | 351.2MB | 语言与运行时 |
| 15 | sirmark/golang:1.26-alpine-glibc2.44 | e01a877bd319 | 381MB | 300.5MB | 语言与运行时 |
| 16 | node:22-slim | 83f487e0a634 | 329MB | 329.2MB | 语言与运行时 |
| 17 | python:3.13-slim | 7ce4b6dfe35e | 178MB | 60.76MB | 语言与运行时 |
| 18 | eclipse-temurin:21-alpine | 6ea5548706b6 | 553MB | 540.1MB | 语言与运行时 |
| 19 | eclipse-temurin:8-alpine | 971ad985d2d2 | 274MB | 260.8MB | 语言与运行时 |
| 20 | ghcr.io/graalvm/native-image-community:21-muslib | 9c27f6de343c | 1.75GB | 1.75GB | 语言与运行时 |
| 21 | debian:trixie-slim | d7e12182ce18 | 119MB | 1.979MB | 语言与运行时 |
| 22 | kouleen/mysql:8.0.38 | a5afd0f5940f | 784MB | 784.3MB | 数据库 |
| 23 | technoboggle/mysql-alpine:latest | ef31f6d1473b | 396MB | 396.4MB | 数据库 |
| 24 | postgres:17-alpine | 18cfe3ef5e68 | 424MB | 410.9MB | 数据库 |
| 25 | gvenzl/oracle-free:23 | e2763af84ecc | 4.13GB | 4.131GB | 数据库 |
| 26 | mongodb/mongodb-community-server:8.3-ubi8-slim | c7ad6700ee65 | 667MB | 666.5MB | 数据库 |
| 27 | redis:7-alpine | ff02b58f971e | 57.8MB | 57.83MB | 数据库 |
| 28 | neo4j:2026.07.1-trixie | dca31d0d938d | 1.08GB | 1.081GB | 数据库 |
| 29 | clickhouse/clickhouse-server:latest-alpine | 0a45b864c733 | 1.02GB | 1.007GB | 数据库 |
| 30 | influxdb:1.8-alpine | 2601e27d6b7e | 229MB | 228.6MB | 数据库 |
| 31 | rustfs/rustfs:latest | 41fe89380f41 | 314MB | 300.7MB | 数据库 |
| 32 | openeuler/milvus:2.6.0-oe2403sp2 | e761daa832cc | 4.71GB | 4.705GB | 数据库 |
| 33 | apache/kafka-native:4.3.1 | 2885898ba170 | 208MB | 195.2MB | 中间件 |
| 34 | hashicorp/consul:latest | 56a8d0fdbfcb | 312MB | 302.9MB | 中间件 |
| 35 | voxxit/consul:latest | 5c3c4fd69210 | 48.7MB | 48.73MB | 中间件 |
| 36 | alpine/minio:latest-release | cf23643a6cf9 | 233MB | 233.3MB | 中间件 |
| 37 | sourcemation/etcd:latest | 0a8b00f6aab2 | 208MB | 208.4MB | 中间件 |
| 38 | nginx:1.30.3-alpine-slim | d5b51cfc7d55 | 21MB | 514.3kB | Web 服务器 |
| 39 | grafana/grafana-enterprise:12.4.0 | 582fc54fb34a | 1.09GB | 1.09GB | 监控可观测 |
| 40 | prom/prometheus:v3.10.0-distroless | 4d2174874988 | 534MB | 534MB | 监控可观测 |
| 41 | prom/alertmanager:v0.33.0 | af26fbe4dd18 | 121MB | 121.5MB | 监控可观测 |
| 42 | clickhouse/clickstack-all-in-one:latest | 383610987863 | 2.63GB | 2.614GB | 监控可观测 |
| 43 | mdmahtabuddin/aamar-elk-stack:latest | 08c227b76827 | 5.9GB | 5.904GB | 监控可观测 |
| 44 | xuxueli/xxl-job-admin:3.4.2 | fa6ad9343f41 | 513MB | 513.2MB | 调度与工具 |
| 45 | whyour/qinglong:debian | fb2953a71260 | 881MB | 880.7MB | 调度与工具 |
| 46 | 99sono/99sono-public-repo:dev-environment-1.0.0-SNAPSHOT | a7cf7e38f0f3 | 5.64GB | 5.636GB | 调度与工具 |
| 47 | katorlys/workspace-all:latest | 4663edac9aef | 8.72GB | 8.724GB | 其他 |
| 48 | miguerubsk/factorio-headless:2.1.14 | ef508222a0e5 | 987MB | 986.6MB | 其他 |
| 49 | palemoky/chinese-poetry-api:latest | 0de9bf0fde3e | 64.4MB | 51.47MB | 其他 |

---

## 二、分类详细介绍

### 1. WeKnora 项目镜像（公司内部 Harbor，13 个，约 20.47GB）

存放于 `harbor-test.***.cn`（DCE5 测试环境 Harbor 仓库），与当前 `bdc-weknora` 项目（检索增强知识库）的 CI/CD 构建链和运行时直接相关。

> 2026-09-10 里程碑：构建链的全部 5 个上游基础镜像（golang / node / debian / nginx / ubuntu）已同步推送至内部 Harbor，CI 构建自此**不再依赖外网 Docker Hub**；本地 `nginx:1.30.3-alpine` 已 re-tag 为 `library/nginx:1.30.3-alpine`（镜像 ID 不变）。同日四个基础镜像 + kkfileview-base 重建（ID 全部更新），业务镜像更新为 `v0.7.2-a40b4fb8`（commit a40b4fb8）。

#### 构建链上游基础镜像（5 个，2026-09-10 补齐）

| 镜像 | 体积 | 唯一占用 | 说明 |
|---|---|---|---|
| library/golang:1.26-bookworm | 1.24GB | 10.53MB | Docker Hub `golang:1.26-bookworm` 的内部拷贝（Go 1.26.6 + Debian 12），`weknora-app-builder` 的 FROM 源 |
| library/node:22-bookworm | 1.64GB | 16.19MB | Docker Hub `node:22-bookworm` 的内部拷贝（Node 22.23.2 + Yarn 1.22.22 完整版），`weknora-ui-builder` 的 FROM 源，两者共享 1.62GB 层 |
| library/debian:12.12-slim | 116MB | 2.362MB | Docker Hub `debian:bookworm-slim` 的内部拷贝（tag 直接标明 Debian 12.12），`weknora-app-runtime-base` 的 FROM 源 |
| library/nginx:1.30.3-alpine | 93.3MB | 890.3kB | Docker Hub `nginx:1.30.3-alpine`（Alpine 3.23.5）的内部拷贝，`weknora-ui-runtime-base` 的 FROM 源 |
| office/ubuntu:24.04 | 119MB | 1.941MB | Docker Hub `ubuntu:24.04` 的内部拷贝（office 目录，办公组件专用），`kkfileview-base` 的 FROM 源 |

#### 构建镜像（builder，2 个）

| 镜像 | 体积 | 唯一占用 | 说明 |
|---|---|---|---|
| weknora-app-builder:latest | 5.53GB | 4.308GB | 后端构建镜像（2026-09-10 重建，ID f6096ec30238），FROM `bdmp/golang:1.26-bookworm`。含 Go 工具链、golang-migrate、DuckDB 扩展预下载及 third_party 依赖（如 anydoc-go），用于 `go build ./...` 编译后端主程序。唯一占用最大，冷构建耗时最长 |
| weknora-ui-builder:latest | 2.65GB | 1.025GB | 前端构建镜像（2026-09-10 重建，ID 62228836b8ec），FROM `bdmp/node:22-bookworm`，npm registry 指向 npmmirror，WORKDIR `/app/frontend` |

#### 运行时基础镜像（runtime-base，2 个）

| 镜像 | 体积 | 唯一占用 | 说明 |
|---|---|---|---|
| weknora-app-runtime-base:latest | 2.04GB | 8.257kB | 后端运行时基底（原名 weknora-runtime-base，2026-09-02 改名；2026-09-10 重建，ID 28db2cbf471c），FROM `bdmp/debian:12.12-slim`。安装 build-essential、PostgreSQL/MySQL 客户端、python3+pip、nodejs+npm、ffmpeg、uv、gosu，内置 migrate、DuckDB 扩展、jieba 分词词典。层被 `weknora-app` 完整复用，唯一占用趋近于零 |
| weknora-ui-runtime-base:latest | 92.4MB | 4.338kB | 前端运行时基底（2026-09-02 新增；2026-09-10 重建，ID 45c33e557ef6），FROM `bdmp/nginx:1.30.3-alpine`，按 digest 固定的零操作搬运镜像，与上游完全共享层 |

#### 业务镜像（2 个）

| 镜像 | 体积 | 唯一占用 | 说明 |
|---|---|---|---|
| weknora-app:v0.7.2-a40b4fb8 | 2.39GB | 357.4MB | 后端业务镜像：`weknora-app-runtime-base` 之上叠加 WeKnora 二进制与 config/scripts/migrations/skills 等可变资源，由 `deploy/daocloud/Dockerfile` 多阶段构建（增量编译 + 组装，约 3-5 分钟）；tag 格式 `<版本>-<commit短号>`，与 runtime-base 共享 2.04GB 底层，体现分层方案的磁盘收益 |
| weknora-ui:v0.7.2-a40b4fb8 | 129MB | 36.41MB | 前端业务镜像：`weknora-ui-runtime-base`（nginx）之上 COPY `frontend/dist` 静态产物，无编译步骤，秒级组装 |

#### 文档预览组件（2 个）

| 镜像 | 体积 | 唯一占用 | 说明 |
|---|---|---|---|
| office/kkfileview-base:4.4.0 | 1.89GB | 6.515kB | kkFileView 4.4.0 文档在线预览基础镜像（office 目录，属办公通用组件）。基于 LibreOffice 实现 office 文档转 PDF/图片预览，WeKnora 文档预览依赖此能力；2026-09-10 重建（ID 9f395205812d），FROM `office/ubuntu:24.04`。层已被完整版 kkfileview 全部引用，唯一占用趋近于零 |
| office/kkfileview:4.4.0 | 2.54GB | 654.1MB | kkFileView **完整应用镜像**（2026-09-10 新增，ID 7abaef3beead），FROM `kkfileview-base` 分层构建，叠加 kkFileView 应用本体（Java 服务 + 配置）。与 base 共享 1.888GB 层，形成 `ubuntu:24.04 → kkfileview-base → kkfileview` 三层链路，可直接部署运行 |

### 2. 编程语言与运行时（8 个，约 3.95GB）

通用语言基础镜像，多用于本地开发调试、多阶段构建或作为自定义镜像的基底。

| 镜像 | 体积 | 基础系统 | 说明 |
|---|---|---|---|
| golang:1.26-alpine | 364MB | Alpine | Go 官方镜像，适合编译静态二进制 |
| sirmark/golang:1.26-alpine-glibc2.44 | 381MB | Alpine+glibc | 第三方增强版，解决 musl 兼容性问题（DNS/timezone 等），CGO 场景更稳 |
| node:22-slim | 329MB | Debian slim | Node.js 22 LTS，前端构建常用 |
| python:3.13-slim | 178MB | Debian slim | Python 3.13，轻量脚本/服务基底 |
| eclipse-temurin:21-alpine | 553MB | Alpine | Eclipse Temurin JDK 21，公司新项目标准 JDK（含完整 JDK 工具） |
| eclipse-temurin:8-alpine | 274MB | Alpine | JDK 8，维护存量老项目必备 |
| ghcr.io/graalvm/native-image-community:21-muslib | 1.75GB | Alpine musl | GraalVM Native Image 编译器，用于把 Java 应用 AOT 编译成本地可执行文件（大幅降低内存与启动时间） |
| debian:trixie-slim | 119MB | Debian 13 | 通用最小化系统基底，构建自定义镜像的干净起点 |

### 3. 数据库（11 个，约 13.81GB）

本地开发联调用的各类数据存储。

#### 关系型数据库

| 镜像 | 体积 | 说明 |
|---|---|---|
| kouleen/mysql:8.0.38 | 784MB | MySQL 8.0.38 社区版，公司业务主力数据库（注意 utf8/utf8_bin 规范） |
| technoboggle/mysql-alpine:latest | 396MB | MySQL 的 Alpine 精简打包，体积约为官方镜像一半 |
| postgres:17-alpine | 424MB | PostgreSQL 17，功能最强大的开源关系库 |
| gvenzl/oracle-free:23 | 4.13GB | Oracle Database 23ai Free，gvenzl 打包的单容器 Oracle，本地模拟 Oracle 生产环境用（体积大，默认含数据库文件） |

#### NoSQL 数据库

| 镜像 | 体积 | 说明 |
|---|---|---|
| mongodb/mongodb-community-server:8.3-ubi8-slim | 667MB | MongoDB 8.3 官方社区版（UBI8 精简基底），文档型存储 |
| redis:7-alpine | 57.8MB | Redis 7 缓存/分布式锁，极小体积 |
| neo4j:2026.07.1-trixie | 1.08GB | Neo4j 图数据库，运维知识图谱等图遍历场景（公司 ops 知识图谱即用图数据库） |

#### 分析型/时序数据库

| 镜像 | 体积 | 说明 |
|---|---|---|
| clickhouse/clickhouse-server:latest-alpine | 1.02GB | ClickHouse 列式 OLAP 数据库，海量日志/指标聚合分析 |
| influxdb:1.8-alpine | 229MB | InfluxDB 1.8 时序数据库，兼容 SQL 语法（1.x 系列），网络流量历史数据常用 |

#### 对象存储

| 镜像 | 体积 | 说明 |
|---|---|---|
| rustfs/rustfs:latest | 314MB | RustFS，Rust 编写的 S3 兼容分布式对象存储，新兴项目，对标 MinIO |

#### 向量数据库（2026-09-01 新增）

| 镜像 | 体积 | 说明 |
|---|---|---|
| openeuler/milvus:2.6.0-oe2403sp2 | 4.71GB | Milvus 2.6.0 向量数据库（openEuler 24.03 LTS SP2 打包版），用于海量 Embedding 向量的存储与相似度检索。RAG 知识库（如 WeKnora）的核心检索组件；openEuler 基底适配信创环境 |

### 4. 中间件（5 个，约 1.01GB）

| 镜像 | 体积 | 说明 |
|---|---|---|
| apache/kafka-native:4.3.1 | 208MB | Apache Kafka 4.3.1 Native 版，GraalVM AOT 编译，无需 JVM、启动秒级、内存占用极低 |
| hashicorp/consul:latest | 312MB | HashiCorp Consul 官方镜像，服务发现/配置中心/健康检查 |
| voxxit/consul:latest | 48.7MB | 社区轻量 Consul 替代实现，仅实现 DNS/HTTP 接口子集，用于本地模拟 |
| alpine/minio:latest-release | 233MB | MinIO S3 兼容对象存储（Alpine 精简打包），本地文件存储/仿 OSS 环境 |
| sourcemation/etcd:latest | 208MB | etcd 分布式键值存储（2026-09-01 新增），Kubernetes 的底座组件，也可独立用作配置中心/服务发现；Sourcemation 打包，常为 UBI/openEuler 基底 |

### 5. Web 服务器（1 个，约 0.02GB）

| 镜像 | 体积 | 说明 |
|---|---|---|
| nginx:1.30.3-alpine-slim | 21MB | 极致精简版（去除非必要模块），只跑静态页面或简单反代时使用，适合嵌入最终交付镜像 |

> 2026-09-02 引入的 `nginx:1.30.3-alpine`（93.3MB）已于 2026-09-10 re-tag 为 `bdmp/nginx:1.30.3-alpine` 并归入 WeKnora 项目分类（作为 `weknora-ui-runtime-base` 的上游），故本分类现仅剩 slim 版。

### 6. 监控与可观测性（5 个，约 10.27GB）

| 镜像 | 体积 | 说明 |
|---|---|---|
| prom/prometheus:v3.10.0-distroless | 534MB | Prometheus v3.10 指标采集与时序存储，distroless 版无 shell 更安全 |
| grafana/grafana-enterprise:12.4.0 | 1.09GB | Grafana 企业版 12.4，指标可视化大盘，与 Prometheus 经典组合 |
| prom/alertmanager:v0.33.0 | 121MB | Prometheus 告警组件，负责告警分组/去重/路由 |
| clickhouse/clickstack-all-in-one:latest | 2.63GB | ClickStack（原 Uberglobe），ClickHouse 官方推出的一体化可观测平台：OpenTelemetry 采集 + ClickHouse 存储 + UI，涵盖日志/指标/链路追踪 |
| mdmahtabuddin/aamar-elk-stack:latest | 5.9GB | ELK 全家桶（Elasticsearch + Logstash + Kibana + APM）单容器集成包，本地快速搭日志分析环境（体积大，单容器多进程，不建议生产） |

### 7. 任务调度与开发工具（3 个，约 7.03GB）

| 镜像 | 体积 | 说明 |
|---|---|---|
| xuxueli/xxl-job-admin:3.4.2 | 513MB | XXL-JOB 3.4.2 分布式任务调度平台控制台，公司定时任务标准组件（bit-education 等项目均使用） |
| whyour/qinglong:debian | 881MB | 青龙面板，支持 Python/JS/Shell 的定时任务管理平台，带 Web 界面，常用于脚本托管 |
| 99sono/99sono-public-repo:dev-environment-1.0.0-SNAPSHOT | 5.64GB | 第三方集成开发环境镜像，含完整开发工具链，镜像名带 SNAPSHOT 表明为开发迭代版本 |

### 8. 其他（3 个，约 9.77GB）

| 镜像 | 体积 | 说明 |
|---|---|---|
| katorlys/workspace-all:latest | 8.72GB | 本地最大镜像，多语言综合开发工作区（单一镜像集成多种语言/工具），体积巨大 |
| miguerubsk/factorio-headless:2.1.14 | 987MB | 异星工厂（Factorio）无头专用服务器，游戏联机用途，与工作无关 |
| palemoky/chinese-poetry-api:latest | 64.4MB | 中华古诗文 API 服务（chinese-poetry 数据库的 REST 封装），2026-09-08 清单首次收录 |

---

## 三、备注

1. **数据时效**：以上清单采集于 2026-09-10（首次采集 2026-08-31 共 41 个；09-01 新增 2 个；09-02 构建链调整 44 个；09-08 磁盘事故清理+重建 45 个；09-10 上游基础镜像补齐 48 个、同日新增 kkfileview 完整镜像后为 49 个），镜像会随 pull/build 动态变化。
2. **可回收性**：本地当前无任何容器（含已停止的），所有镜像在 Docker 视角下均"未激活"，理论上全部可删；实际删除前请确认 WeKnora 基础镜像是否仍需保留（重新冷构建约 30-40 分钟，harbor 有备份可回拉）。
3. **清理建议命令**（谨慎执行）：
   - `docker image prune` 仅清理悬空镜像（dangling）；
   - `docker system prune -a` 会删除所有未使用镜像（**危险，WeKnora 镜像也会被删**）；
   - `docker builder prune` 单独清理构建缓存（2026-09-10 已清空为 0，下次冷构建基础镜像会显著变慢，约 30-40 分钟）。
4. **2026-09-08 事故记录**：宿主机磁盘写满（仅剩 400MB）导致 Docker Desktop VM 文件系统进入只读保护模式，构建基础镜像时报 `input/output error`。处置：手工清理宿主空间 + 重启 Docker Desktop + `docker builder prune -af` 清空 22.4GB 构建缓存后恢复。教训：宿主磁盘长期 >95% 占用会触发此故障，建议保持 20GB 以上余量。
5. **WeKnora 自建镜像的本质上游对照**（2026-09-02 通过 `docker history` 逐层核实；2026-09-10 起全部上游已同步至内部 Harbor 并存在于本地，通过层共享数据实证）：

   | WeKnora 镜像 | 本质上游官方镜像 | 内部 Harbor 对应镜像 | 关键证据 |
   |---|---|---|---|
   | weknora-app-builder | `golang:1.26-bookworm` | `bdmp/golang:1.26-bookworm` | ENV GOLANG_VERSION=1.26.6；两者共享 1.225GB 层 |
   | weknora-ui-builder | `node:22-bookworm` | `bdmp/node:22-bookworm` | ENV NODE_VERSION=22.23.2、YARN_VERSION=1.22.22；两者共享 1.624GB 层 |
   | weknora-app-runtime-base | `debian:bookworm-slim` | `bdmp/debian:12.12-slim`（tag 直接标明版本） | 底层 rootfs 为 debian.sh/bookworm，/usr/share/man 为空（slim 特征），Debian 12.12 |
   | weknora-ui-runtime-base | `nginx:1.30.3-alpine` | `bdmp/nginx:1.30.3-alpine` | ENV NGINX_VERSION=1.30.3、alpine-minirootfs-3.23.5；两者共享 92.39MB 层（唯一占用仅 4.3kB） |
   | office/kkfileview-base | `ubuntu:24.04` | `office/ubuntu:24.04` | LABEL org.opencontainers.image.version=24.04、/bin/bash；两者共享 117.4MB 层 |
   | office/kkfileview（完整版） | —（FROM `kkfileview-base`） | — | 与 base 共享 1.888GB 层，叠加 654MB 应用本体；三层链路 ubuntu → base → 完整版 |

   > 换算关系：后端构建走 Go（app-builder 基于 golang），前端构建走 Node（ui-builder 基于 node）；后端运行时是 Debian slim 多语言环境（python3/nodejs/ffmpeg 等文档处理依赖），前端运行时是 Alpine + nginx，文档预览走 Ubuntu + LibreOffice。上游镜像收归内部 Harbor 后，整条 CI 构建链已完全脱离外网 Docker Hub。

