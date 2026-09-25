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
| 20 | debian:trixie-slim | d7e12182ce18 | 119MB | 1.979MB | 语言与运行时 |
| 21 | ghcr.io/graalvm/native-image-community:21 | faed0fd6809b | 1.41GB | 1.243GB | 语言与运行时 |
| 22 | ghcr.io/graalvm/graalvm-community:21 | 6e46c711c90b | 1.57GB | 1.4GB | 语言与运行时 |
| 23 | bellsoft/liberica-native-image-kit-container:jdk-21-nik-23-glibc | 4decf5167a21 | 1.13GB | 1.095GB | 语言与运行时 |
| 24 | bellsoft/liberica-runtime-container:jdk-21-glibc | 25a30e03fcc5 | 216MB | 183.8MB | 语言与运行时 |
| 25 | bellsoft/liberica-runtime-container:jdk-8-glibc | 79e03737491d | 239MB | 206.4MB | 语言与运行时 |
| 26 | rockylinux/rockylinux:9-minimal | e1d0a9f5ed99 | 235MB | 234.9MB | 语言与运行时 |
| 27 | centos:7 | be65f488b776 | 301MB | 301.3MB | 语言与运行时 |
| 28 | kouleen/mysql:8.0.38 | a5afd0f5940f | 784MB | 784.3MB | 数据库 |
| 29 | technoboggle/mysql-alpine:latest | ef31f6d1473b | 396MB | 396.4MB | 数据库 |
| 30 | postgres:17-alpine | 18cfe3ef5e68 | 424MB | 410.9MB | 数据库 |
| 31 | gvenzl/oracle-free:23 | e2763af84ecc | 4.13GB | 4.131GB | 数据库 |
| 32 | mongodb/mongodb-community-server:8.3-ubi8-slim | c7ad6700ee65 | 667MB | 666.5MB | 数据库 |
| 33 | redis:7-alpine | ff02b58f971e | 57.8MB | 57.83MB | 数据库 |
| 34 | neo4j:2026.07.1-trixie | dca31d0d938d | 1.08GB | 1.081GB | 数据库 |
| 35 | clickhouse/clickhouse-server:latest-alpine | 0a45b864c733 | 1.02GB | 1.007GB | 数据库 |
| 36 | influxdb:1.8-alpine | 2601e27d6b7e | 229MB | 228.6MB | 数据库 |
| 37 | rustfs/rustfs:latest | 41fe89380f41 | 314MB | 300.7MB | 数据库 |
| 38 | openeuler/milvus:2.6.0-oe2403sp2 | e761daa832cc | 4.71GB | 4.705GB | 数据库 |
| 39 | apache/kafka-native:4.3.1 | 2885898ba170 | 208MB | 195.2MB | 中间件 |
| 40 | hashicorp/consul:latest | 56a8d0fdbfcb | 312MB | 302.9MB | 中间件 |
| 41 | voxxit/consul:latest | 5c3c4fd69210 | 48.7MB | 48.73MB | 中间件 |
| 42 | alpine/minio:latest-release | cf23643a6cf9 | 233MB | 233.3MB | 中间件 |
| 43 | sourcemation/etcd:latest | 0a8b00f6aab2 | 208MB | 208.4MB | 中间件 |
| 44 | nginx:1.30.3-alpine-slim | d5b51cfc7d55 | 21MB | 514.3kB | Web 服务器 |
| 45 | grafana/grafana-enterprise:12.4.0 | 582fc54fb34a | 1.09GB | 1.09GB | 监控可观测 |
| 46 | prom/prometheus:v3.10.0-distroless | 4d2174874988 | 534MB | 534MB | 监控可观测 |
| 47 | prom/alertmanager:v0.33.0 | af26fbe4dd18 | 121MB | 121.5MB | 监控可观测 |
| 48 | clickhouse/clickstack-all-in-one:latest | 383610987863 | 2.63GB | 2.614GB | 监控可观测 |
| 49 | mdmahtabuddin/aamar-elk-stack:latest | 08c227b76827 | 5.9GB | 5.904GB | 监控可观测 |
| 50 | xuxueli/xxl-job-admin:3.4.2 | fa6ad9343f41 | 513MB | 513.2MB | 调度与工具 |
| 51 | whyour/qinglong:debian | fb2953a71260 | 881MB | 880.7MB | 调度与工具 |
| 52 | 99sono/99sono-public-repo:dev-environment-1.0.0-SNAPSHOT | a7cf7e38f0f3 | 5.64GB | 5.636GB | 调度与工具 |
| 53 | katorlys/workspace-all:latest | 4663edac9aef | 8.72GB | 8.724GB | 其他 |
| 54 | miguerubsk/factorio-headless:2.1.14 | ef508222a0e5 | 987MB | 986.6MB | 其他 |
| 55 | palemoky/chinese-poetry-api:latest | 0de9bf0fde3e | 64.4MB | 51.47MB | 其他 |

---

## 二、分类详细介绍

### 1. WeKnora 项目镜像（公司内部 Harbor，13 个，约 20.47GB）

存放于 `harbor-test.***.cn`（DCE5 测试环境 Harbor 仓库），与当前 `kbs-weknora` 项目（检索增强知识库）的 CI/CD 构建链和运行时直接相关。

> 2026-09-10 里程碑：构建链的全部 5 个上游基础镜像（golang / node / debian / nginx / ubuntu）已同步推送至内部 Harbor，CI 构建自此**不再依赖外网 Docker Hub**；本地 `nginx:1.30.3-alpine` 已 re-tag 为 `library/nginx:1.30.3-alpine`（镜像 ID 不变）。同日四个基础镜像 + kkfileview-base 重建（ID 全部更新），业务镜像更新为 `v0.7.2-a40b4fb8`（commit a40b4fb8）。

#### 构建链上游基础镜像（5 个，2026-09-10 补齐）

| 镜像 | 体积 | 唯一占用 | 说明 |
|---|---|---|---|
| library/golang:1.26-bookworm | 1.24GB | 10.53MB | Docker Hub `golang:1.26-bookworm` 的内部拷贝（Go 1.26.6 + Debian 12），`weknora-app-builder` 的 FROM 源 |
| library/node:22-bookworm | 1.64GB | 16.19MB | Docker Hub `node:22-bookworm` 的内部拷贝（Node 22.23.2 + Yarn 1.22.22 完整版），`weknora-ui-builder` 的 FROM 源，两者共享 1.62GB 层 |
| library/debian:12.12-slim | 116MB | 2.362MB | Docker Hub `debian:bookworm-slim` 的内部拷贝（tag 直接标明 Debian 12.12），`weknora-app-runtime-base` 的 FROM 源 |
| library/nginx:1.30.3-alpine | 93.3MB | 890.3kB | Docker Hub `nginx:1.30.3-alpine`（Alpine 3.23.5）的内部拷贝，`weknora-ui-runtime-base` 的 FROM 源 |
| library/ubuntu:24.04 | 119MB | 1.941MB | Docker Hub `ubuntu:24.04` 的内部拷贝，`kkfileview-base` 的 FROM 源 |

#### 构建镜像（builder，2 个）

| 镜像 | 体积 | 唯一占用 | 说明 |
|---|---|---|---|
| weknora-app-builder:latest | 5.53GB | 4.308GB | 后端构建镜像（2026-09-10 重建，ID f6096ec30238），FROM `library/golang:1.26-bookworm`。含 Go 工具链、golang-migrate、DuckDB 扩展预下载及 third_party 依赖（如 anydoc-go），用于 `go build ./...` 编译后端主程序。唯一占用最大，冷构建耗时最长 |
| weknora-ui-builder:latest | 2.65GB | 1.025GB | 前端构建镜像（2026-09-10 重建，ID 62228836b8ec），FROM `library/node:22-bookworm`，npm registry 指向 npmmirror，WORKDIR `/app/frontend` |

#### 运行时基础镜像（runtime-base，2 个）

| 镜像 | 体积 | 唯一占用 | 说明 |
|---|---|---|---|
| weknora-app-runtime-base:latest | 2.04GB | 8.257kB | 后端运行时基底（原名 weknora-runtime-base，2026-09-02 改名；2026-09-10 重建，ID 28db2cbf471c），FROM `library/debian:12.12-slim`。安装 build-essential、PostgreSQL/MySQL 客户端、python3+pip、nodejs+npm、ffmpeg、uv、gosu，内置 migrate、DuckDB 扩展、jieba 分词词典。层被 `weknora-app` 完整复用，唯一占用趋近于零 |
| weknora-ui-runtime-base:latest | 92.4MB | 4.338kB | 前端运行时基底（2026-09-02 新增；2026-09-10 重建，ID 45c33e557ef6），FROM `library/nginx:1.30.3-alpine`，按 digest 固定的零操作搬运镜像，与上游完全共享层 |

#### 业务镜像（2 个）

| 镜像 | 体积 | 唯一占用 | 说明 |
|---|---|---|---|
| weknora-app:v0.7.2-a40b4fb8 | 2.39GB | 357.4MB | 后端业务镜像：`weknora-app-runtime-base` 之上叠加 WeKnora 二进制与 config/scripts/migrations/skills 等可变资源，由 `deploy/daocloud/Dockerfile` 多阶段构建（增量编译 + 组装，约 3-5 分钟）；tag 格式 `<版本>-<commit短号>`，与 runtime-base 共享 2.04GB 底层，体现分层方案的磁盘收益 |
| weknora-ui:v0.7.2-a40b4fb8 | 129MB | 36.41MB | 前端业务镜像：`weknora-ui-runtime-base`（nginx）之上 COPY `frontend/dist` 静态产物，无编译步骤，秒级组装 |

#### 文档预览组件（2 个）

| 镜像 | 体积 | 唯一占用 | 说明 |
|---|---|---|---|
| library/kkfileview-base:4.4.0 | 1.89GB | 6.515kB | kkFileView 4.4.0 文档在线预览基础镜像。基于 LibreOffice 实现 office 文档转 PDF/图片预览，WeKnora 文档预览依赖此能力；2026-09-10 重建（ID 9f395205812d），FROM `library/ubuntu:24.04`。层已被完整版 kkfileview 全部引用，唯一占用趋近于零 |
| library/kkfileview:4.4.0 | 2.54GB | 654.1MB | kkFileView **完整应用镜像**（2026-09-10 新增，ID 7abaef3beead），FROM `kkfileview-base` 分层构建，叠加 kkFileView 应用本体（Java 服务 + 配置）。与 base 共享 1.888GB 层，形成 `ubuntu:24.04 → kkfileview-base → kkfileview` 三层链路，可直接部署运行 |

### 2. 编程语言与运行时（14 个，约 7.40GB）

通用语言基础镜像与最小化系统基底，多用于本地开发调试、多阶段构建或作为自定义镜像的基底。

> 2026-09-25 变化：Java 工具链大幅扩充 —— 移除单一 musl 版 GraalVM，新增 GraalVM Community 双镜像（native-image 编译器 + 完整 JDK）与 Bellsoft Liberica 三件套（NIK 23 编译器 + JDK 21/JDK 8 运行时，glibc 基底）；系统基底新增 Rocky Linux 9 minimal 与 CentOS 7。三件 Liberica 镜像共享 32.66MB 层，两个 GraalVM Community 镜像共享 166.3MB 层。

| 镜像 | 体积 | 基础系统 | 说明 |
|---|---|---|---|
| golang:1.26-alpine | 364MB | Alpine | Go 官方镜像，适合编译静态二进制 |
| sirmark/golang:1.26-alpine-glibc2.44 | 381MB | Alpine+glibc | 第三方增强版，解决 musl 兼容性问题（DNS/timezone 等），CGO 场景更稳 |
| node:22-slim | 329MB | Debian slim | Node.js 22 LTS，前端构建常用 |
| python:3.13-slim | 178MB | Debian slim | Python 3.13，轻量脚本/服务基底 |
| eclipse-temurin:21-alpine | 553MB | Alpine | Eclipse Temurin JDK 21，公司新项目标准 JDK（含完整 JDK 工具） |
| eclipse-temurin:8-alpine | 274MB | Alpine | JDK 8，维护存量老项目必备 |
| ghcr.io/graalvm/native-image-community:21 | 1.41GB | Oracle Linux | GraalVM Native Image 编译器（2026-09-25 收录，替代已删除的 21-muslib 版），用于把 Java 应用 AOT 编译成本地可执行文件（大幅降低内存与启动时间） |
| ghcr.io/graalvm/graalvm-community:21 | 1.57GB | Oracle Linux | GraalVM Community 完整 JDK 21 发行版，含 native-image 工具链，与上者共享 166.3MB 层 |
| bellsoft/liberica-native-image-kit-container:jdk-21-nik-23-glibc | 1.13GB | glibc | Bellsoft Liberica Native Image Kit（NIK 23 + JDK 21，2026-09-25 收录），Spring 官方推荐的 AOT 编译方案之一，Spring Boot Native 构建常用 |
| bellsoft/liberica-runtime-container:jdk-21-glibc | 216MB | glibc | Liberica JDK 21 运行时容器（仅 JRE 级精简，2026-09-25 收录），Spring Boot 官方推荐发行版，跑编译产物的轻量基底 |
| bellsoft/liberica-runtime-container:jdk-8-glibc | 239MB | glibc | Liberica JDK 8 运行时容器（2026-09-25 收录），存量 Java 8 应用容器化的轻量运行时 |
| debian:trixie-slim | 119MB | Debian 13 | 通用最小化系统基底，构建自定义镜像的干净起点 |
| rockylinux/rockylinux:9-minimal | 235MB | Rocky Linux 9 | RHEL 9 兼容的最小化基底（2026-09-25 收录），适配企业级/信创场景自定义镜像 |
| centos:7 | 301MB | CentOS 7 | 存量 CentOS 7 基底（2026-09-25 收录），已 EOL（2024-06），仅用于复现/维护遗留构建环境 |
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

> 2026-09-02 引入的 `nginx:1.30.3-alpine`（93.3MB）已于 2026-09-10 re-tag 为 `library/nginx:1.30.3-alpine` 并归入 WeKnora 项目分类（作为 `weknora-ui-runtime-base` 的上游），故本分类现仅剩 slim 版。

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