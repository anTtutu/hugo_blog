---
title: "AI开发入门：Agent与Skill体系详解，附可复制的自定义样例"
date: 2026-03-20T08:00:00+08:00
tags: [ "AI", "agent", "claude", "效率工具" ]
description: "AI 编码 Agent 与 Skill 详解：Agent 的感知-规划-行动循环、Claude Code 的 subagent 与 Skill 机制原理、SKILL.md 结构与触发逻辑，附自定义代码审查 Agent 与 SQL 优化 Skill 完整样例"
categories: [ "AI" ]
toc: true
---

## 前言

用 Claude Code 干活一段时间之后，慢慢摸清了 Agent 和 Skill 这两个概念的门道。Agent 解决「谁来干、怎么干」，Skill 解决「会不会这一行」。这篇整理两者的原理，配上两个我自己在用的自定义样例，可以直接抄走改。

## 1、先分清三个词

| 概念 | 本质 | 打个比方 |
| - | - | - |
| 模型（LLM） | 会推理的「大脑」，只能输入文本输出文本 | 一个聪明但没有手脚的顾问 |
| **Agent** | 模型 + 工具调用 + 自主循环：能读文件、执行命令、改代码、自己验收 | 授权完整的员工：自己查资料、自己动手、自己检查 |
| **Skill** | 预先打包的领域知识和流程，按需加载 | 员工手册里的 SOP：平时不占脑子，干到对应活时翻出来照做 |

Agent 是干活的，Skill 是干活的技能包，就这么简单。

## 2、Agent 是怎么干活的

每次回合都在跑这个循环：

```
目标 → [感知] 读代码/终端输出 → [规划] 决定下一步 → [行动] 调工具执行
         ↑                                              │
         └────────────── 观察结果，修正计划 ←────────────┘
                          直到完成或需要用户输入
```

两个边界要心里有数：工具层决定能力边界（能读、能写、能执行、能搜索哪些），权限系统决定安全边界（哪些操作要人确认）。

**子 Agent（subagent）** 是隔离上下文的执行单元。主 Agent 把独立的子任务（比如全局搜一遍用法、跑测试分析失败原因）派给子 Agent，子 Agent 有自己的上下文窗口，干完只把结论带回来，中间过程不会把主对话撑爆。

## 3、Skill 机制

传统 prompt 库有两个毛病：要么全量塞进上下文浪费 token，要么靠人手动复制粘贴。Skill 把这两个都解决了：

1. **结构**：一个 Skill 就是一个目录，核心是 `SKILL.md`（YAML 头 + 正文指令），可以挂脚本和模板文件
2. **触发**：YAML 头里的 `description` 参与语义匹配，用户请求跟描述相关时，正文才被加载进上下文。平时不占地方
3. **可执行**：正文可以让 Agent 调用目录下的脚本，知识和工具打包在一起

目录结构：

```
.claude/
├── agents/                    # 自定义子 Agent
│   └── code-reviewer.md
└── skills/                    # 自定义 Skill
    └── sql-optimizer/
        ├── SKILL.md           # 核心：元数据+指令
        └── scripts/
            └── explain.sh     # 配套脚本（可选）
```

项目级放 `.claude/`（进 git 随仓库共享），个人全局的放 `~/.claude/`。

## 4、样例一：代码审查 Agent

`.claude/agents/code-reviewer.md`：

```markdown
---
name: code-reviewer
description: 资深代码审查员。对本次改动做安全性/性能/可维护性审查，输出分级问题清单。触发词：审查代码、review、帮我看看这次改动
tools: Read, Grep, Glob, Bash
model: sonnet
---

你是资深 Java/全栈代码审查员，审查标准：

## 审查清单（按优先级）
1. 安全：SQL 注入（拼接 SQL）、反序列化、敏感信息硬编码（密码/密钥/token）
2. 正确性：空指针风险、事务边界（@Transactional 失效场景）、并发安全
3. 性能：N+1 查询、循环内远程调用、大集合全量加载
4. 规范：命名语义、异常处理（禁止吞异常）、日志规范

## 工作流程
1. 用 git diff 或用户指定的文件范围获取改动
2. 逐文件审查，引用具体 file:line
3. 输出格式：
   - 【严重】必须修：问题 + 位置 + 修复建议代码
   - 【建议】应该改：问题 + 理由
   - 【可选】可以更好
4. 不评价与本次改动无关的历史代码

## 输出约束
中文回复；每个问题必须给出可直接采用的修复代码片段。
```

几个设计点：

- `description` 里的触发词决定主 Agent 什么时候把任务派给它
- `tools` 只给了读类工具，不给写权限，审查员就不该改代码
- 正文就是岗位说明书，清单化、规定输出格式，输出质量会稳定很多

对话里说一句「帮我 review 这次改动」，主 Agent 就会派它出场。

## 5、样例二：SQL 优化 Skill

`.claude/skills/sql-optimizer/SKILL.md`：

```markdown
---
name: sql-optimizer
description: MySQL SQL 优化助手。当用户提供慢 SQL 需要分析执行计划、加索引建议或改写优化时使用。触发词：SQL优化、慢SQL、执行计划、加索引
---

# MySQL SQL 优化 SOP

用户给出 SQL 后，严格按以下流程执行：

## 1. 先要上下文
- 表结构：`SHOW CREATE TABLE 表名`（没有索引信息一切白搭）
- 数据量级：`SELECT COUNT(*)` 或业务方提供的量级

## 2. 看执行计划
对 SQL 执行 EXPLAIN（有 PMM/慢日志平台则引用真实执行计划），逐列解读：
- type：至少到 range，出现 ALL 即全表扫描（小表除外）
- key/rows：实际走的索引与预估扫描行数
- Extra：出现 filesort/temporary 必须说明原因

## 3. 输出三件套
1. 诊断：哪一步慢、为什么
2. 索引建议：给出 `ALTER TABLE ... ADD INDEX ...` 完整语句，
   遵循最左前缀；区分「必须/建议」两级
3. 改写建议：如分页深翻页改延迟关联、select * 改覆盖索引

## 4. 约束
- MySQL 8.0 语法；字符集 utf8mb4 排序 utf8mb4_general_ci（用户环境 utf8_bin 时按实际）
- 索引建议必须评估写入放大，单表索引不超过 5 个的提醒
- 禁止凭感觉给结论，一切以 EXPLAIN 输出为准
```

配套脚本 `scripts/explain.sh`（可选，固定动作脚本化更稳）：

```bash
#!/bin/bash
# 用法: ./explain.sh "SELECT ..."  从环境变量读连接信息
mysql -h "${DB_HOST}" -u"${DB_USER}" -p"${DB_PASS}" "${DB_NAME}" \
  -e "EXPLAIN FORMAT=TRADITIONAL $1\G"
```

Skill 真正的价值在把 SOP 固化下来：团队里最会调 SQL 的人把经验写成流程，其他人的 Agent 都按同一套水准执行。「先要上下文再下结论」「一切以 EXPLAIN 为准」这种约束，专治 AI 张口就来。

## 6、Agent、Skill、MCP 什么关系

| 维度 | Skill | MCP（Model Context Protocol） | 子 Agent |
| - | - | - | - |
| 解决什么 | 知识/流程注入 | 标准化的外部工具接入协议 | 上下文隔离的并行执行 |
| 形态 | Markdown + 脚本 | JSON-RPC 服务（数据库/浏览器/Jira…） | Markdown 定义 + 工具白名单 |
| 打个比方 | 员工的 SOP 手册 | USB 接口标准 | 外聘专家 |

串起来用：主 Agent 派出 SQL 优化子 Agent → 子 Agent 按 sql-optimizer 的 SOP 干活 → 通过 MCP 的数据库工具真连库跑 EXPLAIN → 回传诊断报告。

## 7、几点建议

1. 从 Skill 起步，把团队里反复被问的活（发布流程、SQL 规范、日志排查路径）写成 Skill，见效最快
2. 子 Agent 按「最小工具集」给权限，审查类只读、生成类才给写
3. `description` 写清楚「什么时候用我 + 触发词」，匹配不上等于白写
4. SKILL.md 进 git 仓库，跟代码一起评审、一起版本化，这是团队资产，不是个人本地配置
5. 定期用 `/skills`、`/agents` 盘点（命令见 [Claude Code常用命令速查](/post/2026-07-02-claude-code-cli-cheatsheet/)），不用的删掉

## 总结

Agent 把「目标到结果」的执行交给 AI，Skill 把「怎么干才专业」固化下来给它随取随用。从一份 SKILL.md 开始写起，把团队里重复的活慢慢沉淀进去，比一次性搞一套大而全的体系实际得多。

## 相关阅读

- [Claude技能体系实战：claude-skills](/post/2026-04-30-claude-skills/)
- [Claude Code常用命令速查](/post/2026-07-02-claude-code-cli-cheatsheet/)
