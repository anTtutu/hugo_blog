---
title: "我把 VCS 模拟器搬进了浏览器：vcs-simulator-web 开源了"
date: 2026-10-17T20:00:00+08:00
tags: [ "vcs", "ha", "cluster", "开源", "simulator" ]
description: "自研 Web 版 Veritas Cluster Server 模拟器开源：25 个内置 Demo 集群、37 种资源类型、依赖序波浪编排仿真引擎、MonScript 四形态探活、main.cf 往返导入导出、演练剧本与 ha 命令控制台，还能 SSH 接管真实集群。从 2017 年那套官方 Windows 模拟器说起，为什么造轮子、引擎里做了哪些 VCS 语义、十分钟怎么跑起来"
categories: [ "vcs", "开源" ]
toc: true
---

## 前言

2017 年刚从电信行业转出来的时候，我在博客里写过四波 VCS（Veritas Cluster Server）笔记：第一波讲怎么用官方 Windows 模拟器跑 Demo，第二波整理 `ha*` 命令，第三波翻 HAD/LLT/GAB/Fencing 的模块原理，第四波逐行解读 main.cf。那会儿学 VCS 基本只有一条路——下载官方 Simulator，装 JRE，再装个 Java 版 Cluster Manager 控制台，一步一个截图地啃。

快十年过去，VCS 在电信、金融这些行业里还在跑，但学习环境反而更难搞了：官方模拟器是 Java 桌面程序，安装链路长、基本停更，演示全靠手点，想批量构造故障场景、想在自己的教材里复现一版拓扑，都很别扭。带新人的时候尤其明显——口头上讲"资源依赖上线是波浪式的、Critical 资源 failover 会遍历 SystemList"，不如让他自己在浏览器里把一个 Oracle 双机的节点干挂一次。

于是今年我把这个需求做成了一个完整的项目：**vcs-simulator-web**，Web 版 VCS 模拟器，最近以 v0.1.0 开源了：

- 仓库：<https://github.com/anTtutu/vcs-simulator-web>
- License：MIT，技术栈 Vue3 + Vite + Pinia + AntV X6 + Express + better-sqlite3，Node ≥ 20
- 定位：**教学与演示用途**的模拟器，复刻官方 Windows 版 Simulator 的核心能力，并补上现代 Web 交互和一个"真实模式"

这篇跟 2017 年那四波不一样，不重复讲 VCS 概念和命令，主要聊三件事：为什么自己造这个轮子、仿真引擎里认真做了哪些 VCS 语义、以及十分钟怎么在你自己机器上跑起来。

## 1、它长什么样

先上图。集群管理面板，内置 25 个 Demo 集群，从经典 Oracle 双机、NFS、VVR/SRDF 容灾对，到 MySQL/Nginx/Kafka/Redis/ES/MongoDB 副本集、19c 多租户都有：

![集群管理面板](/posts/vcs-simulator/vcs_list.png)

点进单个集群是 AntV X6 画的拓扑视图，立体图标、自由拖拽、依赖连线自动成环检测，Oracle 双机 HA 的服务组/资源依赖一眼看穿：

![拓扑视图（Oracle 双机 HA）](/posts/vcs-simulator/ora_cluster.png)

除了看，还能改：拓扑设计器支持拖拽布局（坐标持久化）、Auto Arrange 分层排版、PNG 导出；建好的配置可以**以 main.cf / types.cf 的格式导入导出，往返无损**——也就是说官方 Simulator 里攒下来的配置文件，可以直接喂进来继续玩，反过来生成的 main.cf 拿去对照真实环境读也没有违和感。

## 2、为什么自己造轮子

官方模拟器不是不好，2017 年那四波笔记就是靠它学的。但这次立项前我列了一下它满足不了的点：

- **环境链路太长**：JRE + Java Console + Simulator 三件套，版本还要对齐；新人第一天半天耗在装环境上
- **不可编程**：探活脚本、故障场景都是死的，想演示"存储先挂、应用级联下线"这种连环剧情只能手动点
- **没有演练叙事**：教学需要的是"基础上线 → 手工 failover → 脑裂 → 站点容灾"这种有字幕、有节奏的剧本流，而不是一堆按钮
- **不进浏览器**：没法直接嵌到内部 wiki/培训页面里，截图都得多一道工序

Web 版把这几点全反过来做了：打开 URL 就是集群面板，故障是**引擎真实编排**出来的（不是放动画），演练内置剧本，探活脚本可编程，还能反向接管真实环境（后面第 5 节讲）。

## 3、仿真引擎里的 VCS 语义

这是整个项目我最花心思的部分。模拟器最怕做成"会闪灯的 PPT"，所以引擎是按真实 VCS 的行为语义来实现的状态机，核心几条：

- **依赖序波浪编排**：上线/下线按资源依赖图分层推进，上层等下层。`Oracle → Mount → Volume → DiskGroup` 这种链路，顺序错了就直接报依赖错误，跟真集群一致
- **Offline Propagation**：父资源下线时优雅传播给后代，配合"持续故障 + 后代连带"的故障注入，可以稳定复现存储级联故障的完整时间线
- **Critical failover**：服务组挂了不是无限重试，而是沿 SystemList 逐节点尝试，全部失败后**冻结等人工介入**——这是 VCS 很有教学价值的一个行为，很多资料只讲切换不讲冻结
- **probe 周期监控 + MonScript 四形态**：探活脚本不是摆设，引擎真实执行，按值前缀自动分流——JS 沙箱表达式（`attrs/state/random`）、`shell:` 本机脚本、`powershell:` Windows 服务探活、`http(s)://` REST 探活，还支持 JSON 多平台块按集群平台自动选脚本。解释器、超时、环境变量全在 `probe.config.json` 里配置，改完免重启
- **脑裂冻结**：心跳断链后按 GAB/AUTODISABLED 语义冻结集群，控制台里 `gabconfig -a` 能看到分区输出，配合演练剧本把"为什么需要 fencing"讲透

领域核心是无 IO 依赖的纯状态机，状态编排/传播/failover 规则全部单测覆盖（全项目 70+ 测试用例），改引擎不怕改崩。

## 4、十分钟跑起来

```bash
pnpm install          # 首次放行 better-sqlite3/esbuild/ssh2 原生构建（pnpm-workspace.yaml 已配 allowBuilds）
pnpm dev:server       # 后端 http://localhost:3100（SQLite 落盘 server/data/）
pnpm dev:web          # 前端 http://localhost:5173（/api 代理 3100）
```

打开 `http://localhost:5173`，路径照着走：

1. 集群面板选中 `SOL_ORACLE`（经典 Oracle 双机）→ **Start Cluster**
2. **Launch Console**（admin / 任意密码即可登录）
3. 进拓扑后先跑一遍**演练剧本**：基础上线 → failover → 存储级联 → 脑裂 → 站点容灾，字幕叙事流带着走，适合新人第一次建立直觉
4. 然后开**命令控制台**：`ha` 系列命令 SSH 式连续输入，带 ↑↓ 历史和 Tab 补全，`hagrp -switch` 切换、`haconf -dump` 落配置都支持——2017 年第二波笔记里整理的命令，在这里可以直接敲着玩
5. 改坏了也不怕：配置快照支持 LCS 行级 diff 对比，一键回滚

三角色权限（Administrator/Operator/Observer）是演示级的，用来演示"Observer 只读、Operator 不能碰关键变更"这类管理语义。

另外面板里有个「🧩 类型管理」，支持自定义资源类型（属性 schema + 四形态探测全链路），内置 37 种类型从经典/新版 Oracle 全家桶到 Kafka/ES/MinIO 都有；弹窗里附了 Agent 二开教程，想给官方没覆盖的组件写 Agent 可以照着做。

## 5、真实模式：SSH 接管真实集群

这是跟官方模拟器思路完全不同的部分：模拟教学之外，它还能**连真实 VCS 节点**。

- 导航进「🛰 真实模式」，填节点 IP/SSH 账号，后端聚合并展示真实集群状态（`hasys`/`hagrp`/`hares`/`gabconfig`/`lltstat`）
- 白名单内可下发操作命令，变更类命令二次确认；凭据仅存内存不落盘

两套模式的关系一句话讲清：**模拟模式练手，真实模式干活**。前者本地 SQLite + 仿真引擎，故障可以反复注入；后者是命令直通真实集群，所以务必只在测试环境用——这个免责声明 README 里也写了：本项目不实现任何真实 VCS 内核行为，不与 Veritas 产品交互，Veritas/VCS 商标归其所有者所有。

## 6、架构一瞥

```
Vue3 + Vite + Pinia + AntV X6  ──REST/SSE──▶  Express
                                                ├─ SimulationEngine（状态机/编排/故障/failover，纯领域核心）
                                                ├─ cf parser/generator（main.cf ⇄ 领域模型）
                                                ├─ ScenarioRunner / CLI(ha*) / MonScript 四形态探活
                                                ├─ Real SSH Pool（真实模式，命令白名单）
                                                └─ better-sqlite3（事务落库）
```

两条设计原则值得一提：

- **引擎是唯一状态权威**：所有变更 = 事务落库 + SSE 事件广播，前端动画按事件序列回放——所以多开几个浏览器窗口看到的状态是一致的
- **领域核心零 IO**：状态机/传播/failover 规则不碰网络不碰库，单测直接跑领域对象，这也是引擎敢单测 100% 覆盖的前提

## 7、小结

把 2017 年靠官方模拟器学的东西，反手做成一个浏览器里开箱即用的开源模拟器，算是给自己当年的学习笔记画了个闭环。项目信息汇总：

- **仓库**：<https://github.com/anTtutu/vcs-simulator-web>（MIT，v0.1.0）
- **上手**：`pnpm install && pnpm dev:server && pnpm dev:web`，README 有截图和逐步说明
- **文档**：`docs/01-需求分析与设计报告.md` 是完整设计文档，`docs/02-Agent二开指南.md` 讲自定义资源类型
- **在规划**：云原生批次（K8s 控制面/Ingress/ArgoCD 等）类型在设计讨论中

VCS 本身是小众技能，但"高可用、依赖编排、故障切换、脑裂"这些概念是通用的——就算你工作里碰不到 Veritas，把它当一套现成的高可用教学沙盘玩也值回票价。觉得有用的话去点个 Star，想看云原生批次或者有类型需求，欢迎提 Issue。
