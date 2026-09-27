---
title: "agent-database-cli：让Claude Code安全操作多种数据库的CLI工具"
date: 2026-09-27T09:30:00+08:00
tags: [ "AI", "claude", "数据库", "效率工具" ]
description: "agent-database-cli 实战：npm 安装与 AI 一键安装、一套 config 适配 MySQL/PostgreSQL/Redis 单机与集群/Oracle/MongoDB、SSH 隧道与 sslmode 多种连接方式、install-skill 一键装 skill、passwordRef 密码加密与只读黑名单安全设计"
categories: [ "AI", "数据库" ]
toc: true
---

## 前言

让 AI 直接连数据库干活（查表结构、验证数据、排查问题），最大的顾虑是安全和连接管理：密码放哪、怎么防止 AI 手滑删库、十来个环境怎么统一管理。我为此写了一个本地 CLI 工具 **agent-database-cli**（Rust 实现，npm 发包），把 MySQL、PostgreSQL、Redis（单机/集群）、Oracle、MongoDB 的连接、查询、元信息读取统一封装，配合 Claude Code 的 Skill 机制使用。这篇记录安装、配置和接入 Claude Code 的完整过程。

开源地址：<https://github.com/sleepinginsummer/agent-database-cli>

## 1、它解决什么问题

- **统一入口**：不同数据库的客户端命令五花八门（mysql/psql/redis-cli/mongo/sqlplus），AI 每种都要会拼写参数。统一成 `agent-database-cli exec <连接名> "<命令>"`，AI 只需要知道连接名
- **安全兜底**：每个连接可配只读模式和命令黑名单，黑名单优先级高于只读；密码不落明文（自动加密成 `passwordRef` 引用）
- **连接复用**：本地 daemon 保持连接，普通命令按需自动拉起，单个连接空闲 180 秒释放、daemon 空闲 300 秒退出，避免 AI 每条命令都重新建连
- **Oracle 特殊照顾**：默认走 SQLcl，也可以配 `oracleDriver: "oracledb"` 切原生驱动（需要 Oracle Instant Client）
- **细节靠谱**：Redis 的 keys 元信息用 `SCAN` 分批读，不用会阻塞的 `KEYS`

## 2、安装

### 2.1 手动安装

环境要求 Node.js >= 20、npm >= 10，安装时自动拉取对应平台的 Rust 二进制（macOS x64/arm64、Linux x64/arm64、Windows x64）：

```bash
npm install -g agent-database-cli
agent-database-cli --help
```

npm 受限时用源码方式：

```bash
git clone https://github.com/sleepinginsummer/agent-database-cli.git
cd agent-database-cli
npm install
npm run build
npm link
agent-database-cli --help
```

### 2.2 AI 一键安装（让 Claude Code 自己装）

README 里放了一段「AI 一键安装」提示词，直接丢给 Claude Code：

```text
安装请阅读 https://github.com/sleepinginsummer/agent-database-cli/blob/main/AI_INSTALL.md，按说明安装 CLI 并添加 SKILL.md。
```

AI 会读 AI_INSTALL.md，按里面的步骤自己完成安装和 skill 添加，全程不用动手。这个模式很适合团队推广：新同事把这段话贴给 AI 就完成环境准备。

## 3、配置：一套 config 适配多种数据库

配置文件在 `~/.agent-database-cli/config.json`（可用环境变量 `AGENT_DATABASE_CLI_CONFIG` 改位置），`databases` 下每个 key 就是一个连接名。常用字段：

| 字段 | 说明 |
| --- | --- |
| `type` | `mysql` / `postgres` / `redis` / `oracle` / `mongodb` |
| `url` | 连接 URL；Redis 集群模式下作为入口节点 |
| `passwordRef` | URL 密码的本地密文引用，首次使用明文密码时自动生成 |
| `readonly` | 只读模式，**默认 true**——不显式关闭就拒绝写操作 |
| `blacklist` | 命令黑名单数组，大小写不敏感，**优先级高于只读** |
| `keepAliveSeconds` | 连接空闲释放秒数，默认 180 |
| `oracleDriver` / `sqlclPath` / `javaHome` | Oracle 用：默认 `sqlcl`，可切 `oracledb` |
| `redisCluster.nodes` | Redis 集群节点清单，配置后进入集群模式 |
| `sshTunnel` | SSH 隧道，支持密码/私钥/密码+私钥/带通行短语的私钥四种认证 |

### 3.1 MySQL / PostgreSQL

```json
"test-mysql": {
  "type": "mysql",
  "url": "mysql://app_user@10.0.1.10:3306/app_db",
  "readonly": true,
  "blacklist": ["drop", "truncate", "delete"],
  "keepAliveSeconds": 180,
  "passwordRef": "agentdbcli:test-mysql:url"
}
```

PostgreSQL 的 URL 支持 `sslmode` 参数，云数据库常用：

```json
"test-pg": {
  "type": "postgres",
  "url": "postgresql://app_rw@10.0.1.20:15432/app_db?sslmode=require",
  "readonly": true,
  "blacklist": ["drop", "truncate", "delete"],
  "keepAliveSeconds": 180,
  "passwordRef": "agentdbcli:test-pg:url"
}
```

生产要校验证书就上 `verify-full`。

### 3.2 Redis：单机、集群、SSH 隧道三种姿势

单机（黑名单把清库命令拦掉）：

```json
"test-redis": {
  "type": "redis",
  "url": "redis://10.0.2.50:6379",
  "readonly": true,
  "blacklist": ["flushall", "flushdb"],
  "keepAliveSeconds": 180
}
```

集群模式：`url` 作入口节点 + `redisCluster.nodes` 节点清单，两个都配才生效：

```json
"redis-cluster": {
  "type": "redis",
  "url": "redis://10.0.0.11:7001",
  "redisCluster": {
    "nodes": [
      "redis://10.0.0.11:7001",
      "redis://10.0.0.12:7001",
      "redis://10.0.0.13:7001"
    ]
  },
  "readonly": true,
  "blacklist": ["flushall", "flushdb"],
  "keepAliveSeconds": 180
}
```

### 3.3 SSH 隧道：不暴露公网也能连

数据库只在内网时，配 `sshTunnel` 走跳板机。MySQL 直连内网库：

```json
"remote-mysql": {
  "type": "mysql",
  "url": "mysql://user@db.internal.example.com:3306/app",
  "sshTunnel": {
    "host": "jump.example.com",
    "port": 22,
    "username": "deploy",
    "privateKeyPath": "~/.ssh/id_rsa"
  },
  "readonly": true,
  "keepAliveSeconds": 180
}
```

Redis 集群走 SSH 是最复杂的场景：程序会给**每个集群节点分别建立本地端口转发**，并通过地址映射接管集群的节点跳转（MOVED 重定向也照常工作），`redisCluster.nodes` 要覆盖客户端实际可能访问到的节点地址。SSH 认证支持密码、私钥、密码加私钥、带通行短语的私钥四种。

### 3.4 MongoDB 与 Oracle

```json
"test-mongodb": {
  "type": "mongodb",
  "url": "mongodb://app_user@10.0.1.40:27017/app_db",
  "readonly": true,
  "timeout": 30000,
  "passwordRef": "agentdbcli:test-mongo:url"
},
"test-oracle": {
  "type": "oracle",
  "url": "oracle://app_user@10.0.1.50:1521/ORCL",
  "oracleDriver": "sqlcl",
  "readonly": true
}
```

## 4、密码安全：passwordRef 自动加密

这是我比较得意的设计：**配置里可以先用明文写密码，首次使用时工具自动把明文加密**——密文写进配置目录的 `secrets.json`，本地密钥写 `secret.key`，配置里的明文被清掉、替换成 `passwordRef` 引用，之后运行只通过引用在内存里解密，全程不落明文、不输出明文。改密码时把明文字段填回新值，下次使用自动覆盖旧密文。

所以仓库里的 config 示例可以放心带 `passwordRef` 字段，真实的 secrets.json 和 secret.key 永远只在本机。

## 5、接入 Claude Code：一条命令装 Skill

CLI 本身 AI 就能调用，但配上 Skill 之后 AI 才知道「有哪些连接、怎么安全地用」。一条命令：

```bash
agent-database-cli install-skill --dry-run   # 先看安装计划
agent-database-cli install-skill            # 确认后安装/更新
```

它会把 `SKILL.md` 装到 Claude Code 的 skill 目录，装完 Claude Code 就自动获得了这套数据库操作能力。SKILL.md 里内置了安全约束：

- 执行任何可能写入/删除/改结构的命令前，先确认目标连接的 `readonly` 和 `blacklist`
- 危险命令（DDL、DML 写入、`flushall`、`dropDatabase` 等）必须先说明目标库、命令和影响，等用户明确同意
- **即使用户同意，也不能绕过配置里的黑名单和只读模式**——工具层面的拦截不因为口头同意而失效
- 读取 config.json 前需要用户确认，防止密钥泄露

日常用法就三个命令：

```bash
agent-database-cli list                          # 列出已配置的连接
agent-database-cli test test-mysql               # 测试连通性
agent-database-cli meta test-mysql               # 查表/列/keys 元信息
agent-database-cli exec test-mysql "select 1"    # 执行 SQL/Redis/MongoDB 命令
```

之后在 Claude Code 里直接说「查一下 test-mysql 里 order 表的结构」「看下 redis-cluster 里这个 key 的值」，AI 会自己调 CLI 完成。

## 6、安全设计的取舍

| 层 | 机制 |
| - | - |
| 密码 | 明文即加密（passwordRef），secrets.json + secret.key 本地保管，输出永远脱敏 |
| 权限 | 默认只读；黑名单优先于只读；写操作要显式 `readonly: false` |
| 流程 | 危险命令 AI 必须先请示；配置文件读取也要确认 |
| 能力边界 | 不扫描网络发现数据库，只认配置里的连接 |

推荐姿势：**所有连接默认只读，需要变更时让 AI 先给出 SQL，人确认后再人工执行**（或临时开一个可写连接用完改回）。AI 负责查和推理解释，变更的扳机始终在人手里。

## 总结

agent-database-cli 把「AI 连数据库」的三件事做扎实了：连接统一（五种数据库一套命令）、安全默认（只读 + 黑名单 + 密码加密）、接入简单（npm 装 + install-skill 一条命令）。配合下一篇的 ELK 日志 MCP，就能组成「日志定位问题 → 数据库验证数据」的完整 AI 排查工作流。

## 相关阅读

- [AI开发入门：Agent与Skill体系详解](/post/2026-03-20-ai-agent-and-skill/)
- [Claude Code常用命令速查](/post/2026-07-02-claude-code-cli-cheatsheet/)
