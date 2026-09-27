---
title: "shell小技巧：URL转码表与set -euo pipefail"
date: 2020-12-05T08:00:00+08:00
tags: [ "shell", "linux" ]
description: "shell 日常小技巧两则：常用符号的 URL 编码对照表，以及 set -e / -u / -o pipefail 在脚本健壮性上的作用与坑"
categories: [ "shell", "linux" ]
toc: true
---

## 前言

日常写 shell 脚本时积攒的小技巧，单拎出来都不长，合在一起记录。这篇是第一批：URL 转码表和 set 选项，后续有新的继续补充。

## 一、常用符号的 URL 转码表

写爬虫或拼 URL 时经常碰到符号需要转码，对照表如下：

| 符号 | url 转码 |
| - | - |
| + | %2B |
| space（空格） | %20 |
| / | %2F |
| ? | %3F |
| % | %25 |
| # | %23 |
| & | %26 |
| = | %3D |

命令行里快速转码/解码：

```bash
# 转码
echo -n "a=b&c=1" | xxd -plain | tr -d '\n' | sed 's/\(..\)/%\1/g'
# a%3db%26c%3d1

# 解码
printf '%b' '${a%3db%26c%3d1//%/\\x}'
```

## 二、set -e、set -u 与 pipefail

写脚本时经常看到开头一句 `set -eu` 或 `set -euo pipefail`，各自的作用：

- **`set -e`**：脚本中任意一个命令返回了非 0 就立即退出。避免错误被吞掉后继续往下跑，把小问题滚成大事故。
- **`set -u`**：引用未赋值的变量视为错误，并向 stderr 输出错误信息。避免变量名打错后以空字符串静默传播。
- **`set -o pipefail`**：管道的返回值取最后一个失败命令的返回码（默认只取最后一个命令的）。配合 `-e` 才能捕获 `xxx | grep yyy` 这类管道中间的失败。

组合使用：

```bash
#!/bin/bash
set -euo pipefail
```

**注意的坑**：

1. `set -e` 对 `if`、`while`、`||`、`&&` 中的命令不生效，需要自己判断的场景别指望它兜底
2. 有意容忍失败的命令用 `cmd || true` 显式声明
3. 需要「定义可能不存在的变量」时用 `${var:-default}` 给默认值

```bash
# 示例：环境变量缺省时的安全写法
DEPLOY_DIR="${DEPLOY_DIR:-/opt/app}"
```

## 总结

转码表贴在手边省得现查；`set -euo pipefail` 应该成为 bash 脚本的默认开场白——成本一行，换来的是失败尽早暴露。
