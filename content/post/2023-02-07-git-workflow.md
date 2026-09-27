---
title: "git工程化实践：commit规范、emoji、多账号与分支规范"
date: 2023-02-07T08:00:00+08:00
tags: [ "git", "工程化" ]
description: "git 日常工程化实践：commit message 五段式规范与 type 说明、常用 emoji 对照表、同机多平台多账号 SSH 配置、团队分支规范定义"
categories: [ "git" ]
toc: true
---

## 前言

单人项目里 git 怎么提交都行，团队协作时就需要约定：commit 怎么写、分支怎么建、一台机器上公司账号和个人账号怎么共存。这篇把这几件事一次说清。

## 一、commit message 规范

commit 一共由五部分组成：

**（1）type：提交类型**

- `feat`: 新功能
- `fix`: 修复问题
- `docs`: 修改文档
- `style`: 修改代码格式，不影响代码逻辑
- `refactor`: 重构代码，理论上不影响现有功能
- `perf`: 提升性能
- `test`: 增加修改测试用例
- `chore`: 修改工具相关（包括但不限于文档、代码生成等）
- `deps`: 升级依赖

**（2）scope**：修改文件的范围（包括但不限于 doc、middleware、core、config、plugin）。

**（3）subject**：用一句话清楚的描述这次提交做了什么。

**（4）body**：补充 subject，适当增加原因、目的等相关因素，也可不写。

**（5）footer**：

- 当有非兼容修改（Breaking Change）时必须在这里描述清楚
- 关联相关 issue，如 `Closes #1, Closes #2, #3`
- 如果功能点有新增或修改的，还需要关联文档 doc

## 二、emoji 规范

以下 emoji 在 git 提交时已经完全支持，直接在 commit message 里使用即可：

| emoji | emoji代码 | commit说明 |
| - | - | - |
| 🎨 (调色板) | `:art:` | 改进代码结构/代码格式 |
| ⚡️ (闪电) | `:zap:` | 提升性能 |
| 🐎 (赛马) | `:racehorse:` | 提升性能 |
| 🔥 (火焰) | `:fire:` | 移除代码或文件 |
| 🐛 (bug) | `:bug:` | 修复 bug |
| 🚑 (急救车) | `:ambulance:` | 重要补丁 |
| ✨ (火花) | `:sparkles:` | 引入新功能 |
| 📝 (铅笔) | `:pencil:` | 撰写文档 |
| 🚀 (火箭) | `:rocket:` | 部署功能 |
| 💄 (口红) | `:lipstick:` | 更新 UI 和样式文件 |
| 🎉 (庆祝) | `:tada:` | 初次提交 |
| ✅ (白色复选框) | `:white_check_mark:` | 增加测试 |
| 🔒 (锁) | `:lock:` | 修复安全问题 |
| 🍎 (苹果) | `:apple:` | 修复 macOS 下的问题 |
| 🐧 (企鹅) | `:penguin:` | 修复 Linux 下的问题 |
| 🏁 (旗帜) | `:checked_flag:` | 修复 Windows 下的问题 |
| 🔖 (书签) | `:bookmark:` | 发行/版本标签 |
| 🚨 (警车灯) | `:rotating_light:` | 移除 linter 警告 |
| 🚧 (施工) | `:construction:` | 工作进行中 |
| 💚 (绿心) | `:green_heart:` | 修复 CI 构建问题 |
| ⬇️ (下降箭头) | `:arrow_down:` | 降级依赖 |
| ⬆️ (上升箭头) | `:arrow_up:` | 升级依赖 |
| 👷 (工人) | `:construction_worker:` | 添加 CI 构建系统 |
| 📈 (上升趋势图) | `:chart_with_upwards_trend:` | 添加分析或跟踪代码 |
| 🔨 (锤子) | `:hammer:` | 重大重构 |
| ➖ (减号) | `:heavy_minus_sign:` | 减少一个依赖 |
| ➕ (加号) | `:heavy_plus_sign:` | 增加一个依赖 |
| 🐳 (鲸鱼) | `:whale:` | Docker 相关工作 |
| 🔧 (扳手) | `:wrench:` | 修改配置文件 |
| 🌐 (地球) | `:globe_with_meridians:` | 国际化与本地化 |
| ✏️ (铅笔) | `:pencil2:` | 修复 typo |

组合示例：

```bash
git commit -m ":sparkles: (order) 新增订单导出功能"
git commit -m ":bug: (pay) 修复支付回调重复入账问题 Closes #1024"
```

## 三、同机多账号管理

工作和个人项目共存一台机器时，为每个平台生成独立的 ssh key：

### 1. 生成 ssh key

```bash
# 通用格式
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/<平台名称>_id_rsa

# 示例：GitHub 一把、GitCode 一把
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/github_id_rsa
ssh-keygen -t rsa -b 4096 -C "your_email@example.com" -f ~/.ssh/gitcode_id_rsa
```

`~/.ssh/` 目录可以看到生成的密钥文件：私钥 `xxx_id_rsa`（不公开）、公钥 `xxx_id_rsa.pub`（添加到对应平台）。

### 2. 配置 ~/.ssh/config

```
# ------------------------ GitHub 配置 ------------------------
Host github.com
  HostName github.com          # 实际主机名（不变）
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/github_id_rsa  # 指向GitHub私钥

# ------------------------ GitCode 配置 ------------------------
Host gitcode.com
  HostName gitcode.com
  PreferredAuthentications publickey
  IdentityFile ~/.ssh/gitcode_id_rsa  # 指向GitCode私钥
```

再配合每个仓库单独设置提交身份，即可完全隔离：

```bash
git config user.name "work-name"
git config user.email "work@example.com"
```

## 四、分支规范

| 分支名 | 说明 | 备注 |
| - | - | - |
| master | 主库 | 生产环境 |
| develop / dev | 开发 | 开发、测试环境 |

在此基础上可以按团队需要扩展：功能分支 `feature/xxx`、修复分支 `hotfix/xxx`、发布分支 `release/x.y`，命名保持 `类型/简述` 的统一风格即可。

## 总结

规范的价值在于可追溯：type + emoji 让 `git log` 一眼可读，scope 让改动范围可定位，分支规范让环境对应关系清晰。工具层面可以再配合 commitlint + husky 做强制校验，把约定变成流程。
