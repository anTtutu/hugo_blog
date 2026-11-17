---
title: "CC Switch 对比 Magpie：两家供应商管家的优缺点掰开看，以及我为什么重心挪到了后者"
date: 2026-11-17T11:30:00+08:00
tags: [ "AI", "Claude Code", "效率工具" ]
description: "CC Switch 和 Magpie 都是管理 Claude Code / Codex 等工具供应商配置的开源工具，但思路完全不同：一个是替你改配置文件的桌面配置中心，一个是所有 Agent 共用的本地网关。这篇用我机器上的真实配置，逐项对比两者的用法、优势和不足，以及我为什么从用 CC Switch 更多变成了现在更常用 Magpie"
categories: [ "AI" ]
toc: true
---

## 前言

用 Claude Code 这两年，供应商和中转换了一拨又一拨。最早手搓 `~/.claude/settings.json` 和 `~/.codex/config.toml`，改坏了翻备份，后来嫌烦装了 **CC Switch**（今年 6 月它就把我的 Codex 配置迁过一遍，`~/.cc-switch` 里还留着当时的迁移记录），这一用就是大半年，供应商、MCP、Skills、会话、用量全交给它。

前阵子看到 yetone（macOS 翻译工具 Bob 的作者）发了 **Magpie**，口号是「Every agent's model. One place.」，10 月 13 日顺手装上，配了几家中转断断续续用到现在。

结果是：**以前 CC Switch 用得多，现在 Magpie 更适合我。** 这篇不劝谁照搬，就是把两家掰开揉碎对比一遍——用法、优势、不足，最后说说我的情况和理由。口径先讲清：CC Switch 那半边来自半年日常，Magpie 那半边来自文档加实际使用（用量页截图为证）；版本号和 star 数是写稿当天（2026-11-17）的快照，功能以各家官方文档为准。

## 1、先看我机器上两家的真实状态

先说个容易误判的细节：**写稿这天，CC Switch 的进程在跑，Magpie 的网关没在跑**。`ps` 里 cc-switch 活着、监听 `127.0.0.1:15721`；`127.0.0.1:3425` 无人接听。但这不是「Magpie 被淘汰了」的证据——Magpie 的 TUI/CLI 形态关掉之后网关本身就停，它是按需起服务的。所以下面只拿这些当背景，不当裁判依据。

### 1.1 CC Switch：4.0.4，从 6 月用到现在

`~/.cc-switch/live-state.json` 记着运行时状态，摘关键字段：

```json
"apps": {
  "claude":    { "mode": "proxy", "attached": true, "proxy_route": "020f…" },
  "codex":     { "mode": "direct" },
  "gemini":    { "mode": "direct" },
  "grokbuild": { "mode": "direct" }
}
```

翻译成人话：Claude Code 挂在它的**本地路由**上，其余三家**直连**。整个 `~/.cc-switch` 目录 43MB（含备份），光数据库就 4.7MB——会话和用量的家底都在里面。

### 1.2 Magpie：0.1.1220，配了 4 家中转

`~/.config/magpie/providers.json` 里是我自己加的 4 家中转网关（agnes-text-free、oneapi-bl、llm-gateway、agentrouter 这类自定义供应商），模型列表是从供应商那儿实时拉的，不内置写死。配置最后一次动是 10 月 23 日，之后停了一阵子，最近才重新捡起来。

## 2、用法对比：配置中心 vs 本地网关

两家的根本分歧在这，后面所有优缺点都从这来。

### 2.1 CC Switch：替你改配置文件的桌面应用

管 12 个工具（Claude Code、Claude Desktop、Codex、Gemini CLI、Grok Build、OpenCode、OpenClaw、Hermes、Pi、MiniMax Code、Kimi Code、Oh My Pi），90+ 供应商预设，macOS 推荐 `brew install --cask cc-switch`。三种工作模式：

- **直连**：选一个供应商，把地址、Key、模型名写进工具自己的配置，工具直连供应商
- **路由**：CC Switch 在本机当转发层，做协议转换（Anthropic / OpenAI Chat / OpenAI Responses / Gemini 四种格式互转，让 Claude Code 用 GPT、Codex 用 Claude 成为可能），带故障转移队列、熔断器和健康监控
- **聚合**：把多家供应商的模型塞进 Claude Code / Codex 的同一个模型列表，`/model` 选哪个，请求就发去哪一家

切换生效范围要记牢：**Claude Code 热切换不用重启；Codex、Gemini CLI、Grok Build 要重启终端；Claude Desktop 要重开 App**。

主界面，Claude Code 页签的「路由」模式：顶部写着「路由生效中 → OpenRouter」，下面是故障转移队列，Key 一律打码显示：

![CC Switch 主界面：Claude Code 的路由模式与供应商队列](/posts/ccswitch-magpie/ccswitch_1.png)

托盘子菜单更方便：每个工具一行，点进去直接切供应商，灰色那行是官方订阅（不走路由），打勾的是当前生效的：

![CC Switch 托盘子菜单：Claude Code 的路由队列逐一切换](/posts/ccswitch-magpie/ccswitch_2.png)

### 2.2 Magpie：一个本地网关伺候所有 Agent

思路完全不同：`127.0.0.1:3425` 起一个网关，同时说 OpenAI Chat、OpenAI Responses、Anthropic Messages 和 Gemini 四种协议并互相转换，**所有 Agent 都指向这一个端点**，模型从一份统一目录里挑。菜单栏 App、窗口版、`magpie tui`、`magpie web`、CLI 五种形态都有，Mac 上一个二进制才 15 MB 左右。菜单栏面板长这样，Agent / 用量 / 路由三个页签：

![magpie 菜单栏面板：Agent / 用量 / 路由三个页签](/posts/ccswitch-magpie/magpie_2.png)

```sh
magpie provider add deepseek sk-…            # 加供应商，预设只要一个 Key
magpie claude deepseek/deepseek-v4-pro       # 给 Claude Code 指定模型
magpie plugin add opencode-gemini-auth       # 装插件
magpie quota                                 # 看各账号配额
```

窗口版的 Agent 页：左边是使用 / 模型 / 供应商 / 路由 / 网关 / 用量，每个 Agent 一行，模型下拉 + 右侧接入开关。坦白说拍这张时我还没接入任何 Agent（开关全关，都写着「用 xx 自己的设置」）——接入是逐 Agent 决定的，不是一把梭：

![magpie 窗口版 Agent 页：逐 Agent 选模型、逐 Agent 接入](/posts/ccswitch-magpie/magpie_1.png)

它强在三块：

- **订阅共享**：登录过的 Claude、ChatGPT、Copilot、Gemini Code Assist 等订阅会当成供应商，其他 Agent 直接共用，多账号自动故障转移，还有「每日热身」帮你卡 5 小时窗口
- **路由组**：`smart`（用快续期的订阅）、`order`（前一个答不上来才换下一个）、`rotate`（每轮换）、`usage`（最少用的先用）、`pace`（按周剩余额度匀着用）；会话粘在答过它的账号上以保住提示词缓存，组还能嵌套
- **隐私脱敏**：默认关，打开后密钥、邮箱、证件号在请求离开本机前被替换成 `{{API_KEY_k3v9x2mq}}` 这样的占位符，回复里再还原；规则找不准的还能选本地小模型兜底

设置 › 隐私页，脱敏的粒度都在这：密钥、个人信息（邮箱 / 手机号 / 身份证号 / 银行卡号）、账号打码，外加脱敏词和自定义规则（前缀或正则）。注意看开关——拍这张时「脱敏密钥」还是关的，默认关这点不是吹的，得自己手动开；底下「计入用户数」就是每天回传一次匿名统计的那条，不想发就关：

![magpie 设置 › 隐私页：脱敏粒度与统计开关](/posts/ccswitch-magpie/magpie_6.png)

路由页是实时播放的：哪个 Agent 的请求经网关走了哪条组、为什么排它、各自回应如何，都在这页看。没请求时给你三个模板起步——难题给强模型、便宜优先、永不卡住：

![magpie 路由页：实时路由决策与三个开箱模板](/posts/ccswitch-magpie/magpie_3.png)

安装是 `curl -fsSL https://usemagpie.ai/install.sh | sh`，或 `go install`，或 Docker；卸载脚本会把 Agent 配置还原回去。而且**它能从 CC Switch、Claude Code、Codex 直接导入供应商**——两家不冲突，迁移不疼。

### 2.3 配置落盘对比

两家都承诺「只改关键字段，不动我的东西」，CC Switch 这条我验过，`~/.claude/settings.json` 现在长这样（敏感值打码）：

```jsonc
"env": {
  "ANTHROPIC_BASE_URL": "http://127.0.0.1:15721",  // cc-switch 的本地路由
  "ANTHROPIC_AUTH_TOKEN": "PROXY_MANAGED",         // 由路由代管，不再是明文 Key
  "ANTHROPIC_DEFAULT_OPUS_MODEL": "claude-opus-5",
  // ……我自己加的 JAVIS_* 等环境变量，原样不动
},
"permissions": { /* 我自己的权限清单，原样 */ },
"hooks": { /* 我自己写的 PreToolUse 等钩子，原样 */ }
```

Codex 那边也一样，`~/.codex/config.toml` 里它只动 `model_provider` / `model` / `base_url` 三个连接字段，我自己的 MCP 和项目信任列表原样保留：

```toml
model_provider = "custom"
model = "gpt-5.3-codex"
model_reasoning_effort = "high"

[model_providers.custom]
name = "custom"
wire_api = "responses"
requires_openai_auth = true
base_url = "https://<中转域名>/v1"   # 内部地址打了码，不放出来

[mcp_servers.codegraph]               // 我自己的 MCP，原样保留
type = "stdio"
command = "codegraph"
args = ["serve", "--mcp"]
```

Magpie 也是同一套路（文档原话是「原子写入，注释、顺序、缩排都不动」）。**单看落盘方式，两家打平；差别全在落盘之后谁替你干活。**

## 3、优缺点对比

先一张表总览，后面展开：

| 维度 | CC Switch | Magpie |
| :-- | :-- | :-- |
| 形态 | Tauri 桌面 App（Win/Mac/Linux） | 菜单栏 App + 窗口 + TUI + Web + CLI + Docker，一个 Go 二进制 |
| 核心思路 | 配置中心：替你改各家配置文件 | 本地网关：所有 Agent 指向它，协议转换 + 调度 |
| 工作模式 | 直连 / 路由（协议转换+故障转移）/ 聚合 | 网关常驻，路由组五种调度模式 |
| 多账号配额 | 故障转移队列 + 熔断 + 健康监控，托盘显示额度 | 路由组（smart/order/rotate/usage/pace）+ 订阅共享 + 每日热身 |
| 覆盖面 | 12 个工具，还管 MCP / Skills / 提示词 / 会话 / 项目 | Agents 表列了 80 来个客户端（含 VS Code / JetBrains / Zed / Cursor 等编辑器） |
| 隐私脱敏 | 无 | 有，默认关，本机替换占位符 |
| 文档与生态 | 中文界面，star 约 15.5 万，文档全 | 英文文档，star 约 3.8 万，仓库不收 PR |
| 数据同步 | WebDAV / S3 | WebDAV / S3 / 加密 GitHub 备份 |

### 3.1 CC Switch 的优势

- **上手零门槛**：中文界面、托盘一键切供应商，供应商卡片直接显示「5 小时剩余 94%」这种额度信息，对我这种同时挂着几个 Coding Plan 的人很实用
- **覆盖面全**：供应商、MCP、Skills、提示词（CLAUDE.md / AGENTS.md / GEMINI.md）、项目、会话阅读页、用量热力图一整套，等于供应商管理 + 轻量 Agent 管家
- **可逆性好**：首次改写配置前自动备份到 `~/.cc-switch/backups/live-first-write/`，还有 Deep Link 一键导入

### 3.2 CC Switch 的不足

- 路由模式要**常驻进程**（退出时会写回直连配置，下次启动再接上）；官方供应商不能走本地路由
- 聚合模式限制明确：不支持 Claude 官方订阅、不提供故障转移；Codex 进出聚合要重启它的守护进程，会中断在跑的任务
- 功能越堆越重，README 打开先是一屏赞助商；「授权中心」用订阅当供应商，文档自己提示可能违反厂商 ToS

### 3.3 Magpie 的优势

- **调度是另一个量级**：配额用完自动接下一个、会话粘账号保缓存、订阅当供应商共享给所有 Agent——这是 CC Switch 给不了的
- **脱敏独一份**：密钥不出本机，Mask / Warn / Block 三档可调，规则 + 可选本地模型双保险
- **形态全且轻**：15 MB 单二进制，TUI/CLI 对终端重度用户友好；编辑器覆盖面比 CC Switch 广
- **观测细**：用量页按今天 / 7 天 / 30 天 / 90 天拉 Token、请求、费用、缓存命中、活跃时长、项目、模型分布，菜单栏面板看个大概，窗口版看细节：

![magpie 用量：菜单栏面板看今日](/posts/ccswitch-magpie/magpie_4.png)

![magpie 窗口版用量页：90 天的会话、Token、缓存命中和按时段热力图](/posts/ccswitch-magpie/magpie_5.png)

### 3.4 Magpie 的不足

- **生态年轻**：版本号还在 0.1.x，文档全英文；仓库明确写着「不收 PR，有事去 Discord 提」——对开源用户来说这条挺要命
- 概念多（供应商 / 订阅 / 路由组 / 插件 / 脱敏 / 配置档），学习曲线比 CC Switch 陡；插件跑在 Bun 上，首次使用要下载
- 网关挂了 Agent 就失联（TUI 形态关掉网关也停）；脱敏开了以后「问密钥本身」这类任务会被误伤，得手动加白名单

## 4、踩坑记录

1. **新旧包共存**：`/Applications` 里留着 3.16.2，实际从 DMG 起的是 4.0.4，托盘图标看着像没升级。判断看 `ps` 里的进程路径，不在 App 目录里就是 DMG 直跑的
2. **路由模式下换模型仍要重启**：Claude Code 热切换，但 Codex / Gemini CLI / Grok Build 换模型后还是得重启终端，别指望全自动
3. **两个工具别同时接管同一份配置**：两家都会写 `~/.claude/settings.json` 里的 `ANTHROPIC_BASE_URL`（一个指 15721，一个指 3425），后写的覆盖先写的。我的规矩是同一时间只让一个接管，另一个想玩就先停掉前者
4. **Magpie 的网关不是常驻的**：TUI/CLI 形态一关网关就停，连着它的 Agent 立刻失联。想让它一直在线，用桌面 App 或 `magpie serve` / Docker，别用 TUI 当主力——我拍 Magpie 截图那会儿窗口版开着，左下角「网关 127.0.0.1:3425」绿灯亮着；等我关窗口去查端口，就没人听了

## 5、我的情况（不是推荐）

以前 CC Switch 用得多，因为它把「换供应商」这件事的摩擦降到了零；现在重心挪到 Magpie，就三个原因：**一个网关统一伺候所有 Agent**（不用再逐个工具点切换）、**路由组真的在替我省配额**（多账号自动接力，会话不丢缓存）、**脱敏和 TUI 贴合我的终端工作流**。但 Magpie 文档全英文、版本还年轻，这是我接受了的代价——你要是不在意调度和脱敏，CC Switch 依然是更省心的那个。

## 总结

**CC Switch 是「配置中心」，解决别手改文件；Magpie 是「调度网关」，解决别浪费配额。**

两家落盘方式打平，差别在落盘之后谁替你干活：前者强在一站式和中文上手，后者强在调度、订阅共享和脱敏。我以前用 CC Switch 更多，现在更常用 Magpie——但这个结论长在我的用法上，你的场景照表 3 对一遍就有答案。

最后一句实话：路由、聚合、订阅共享这类用法，本质上都是绕开官方客户端，**可能违反厂商服务条款**，两家的文档都各自提示过，值不值自己掂量。

## 相关阅读

- [Claude Code 常用命令速查](/post/2026-07-02-claude-code-cli-cheatsheet/)
- [Claude Skills 实践笔记](/post/2026-04-30-claude-skills/)
