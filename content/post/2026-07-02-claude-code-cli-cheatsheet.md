---
title: "Claude Code常用命令速查"
date: 2026-07-02T08:00:00+08:00
tags: [ "AI", "claude", "效率工具" ]
description: "Claude Code 命令行速查：查看已安装的 skill/agent/plugin/mcp 四类资源的会话命令与 CLI 子命令、免确认模式的适用场景与风险提示"
categories: [ "AI" ]
toc: true
---

## 前言

用 Claude Code 做日常开发，四类可扩展资源（skill、agent、plugin、mcp）装多了之后经常要盘点「我到底装了什么」。这篇汇总最常用的查看命令和一个高频启动参数。

## 一、查看四类已安装资源

**1. 查看已安装的 skill**

```bash
/skills              # 会话内命令
claude skills list   # 终端命令
```

**2. 查看已安装的 agent**

```bash
/agents
claude agents list
```

**3. 查看已安装的 plugin**

```bash
/plugin
claude plugin list
```

**4. 查看已安装的 mcp**

```bash
/mcp
claude mcp list
```

## 二、免确认模式

```bash
claude --dangerously-skip-permissions
```

跳过所有工具调用的确认弹窗，跑批处理任务（比如全量重构、批量测试执行）时效率翻倍。但顾名思义——**dangerous**：任何写文件、执行命令、网络请求都不再询问。建议只在两类场景使用：隔离环境（容器/沙箱/一次性 worktree），或你已完整 review 过即将执行的操作序列。

## 三、使用习惯

- 会话内斜杠命令（`/skills` 等）适合开发中随手盘点；`claude xxx list` 适合写脚本做环境审计
- 排查「某个工具为什么没生效」时，先确认它挂在哪一层（skill 还是 plugin 里带的），再查对应列表
- 免确认模式配合 git worktree 用最稳：出问题直接丢弃整个 worktree

## 总结

记住四组 list（skills/agents/plugin/mcp）加一个 skip-permissions，日常盘点和自动化场景基本够用；免确认模式的原则是「先隔离、再放飞」。

---

## 相关阅读

- [AI开发入门：Agent与Skill体系详解](/post/2026-03-20-ai-agent-and-skill/)
- [Claude技能体系实战：claude-skills](/post/2026-04-30-claude-skills/)
