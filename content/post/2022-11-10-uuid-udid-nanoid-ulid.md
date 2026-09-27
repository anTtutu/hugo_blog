---
title: "ID生成方案对比：UUID、UDID、NanoID与ULID"
date: 2022-11-10T08:00:00+08:00
tags: [ "java", "架构" ]
description: "四种 ID 生成方案横向对比：UDID 设备标识、UUID 五个版本的演进、ULID 的字典序可排序特性、NanoID 的更短更快，选型建议"
categories: [ "java" ]
toc: true
---

## 前言

做分布式系统或设计表主键时总要面对「用什么生成唯一 ID」的问题。UUID 不是唯一选项——ULID、NanoID 都在特定场景下更有优势。这篇把四个常见方案放在一起对比。

## 一、UDID：设备的身份证

UDID（Unique Device Identifier，设备唯一标识符）只和设备有关，类似 MAC 地址。iOS 真机调试时需要把 UDID 加进 Provisioning Profile 授权文件来识别设备。UDID 是一个 40 位十六进制序列，可以通过 iTunes 和 Xcode 获取。

> 因为隐私问题，Apple 从 iOS 7 起禁止 APP 直接获取 UDID，后来陆续用 IDFA、IDFV 替代——但「设备唯一标识」这个需求形态就是 UDID 定义的。

## 二、UUID：五个版本的演进

UUID（Universally Unique Identifier，通用唯一标识符）目前有 5 个版本：

| 版本 | 生成方式 | 问题 |
| - | - | - |
| v1 | 时间戳 + MAC 地址 | 需要访问唯一稳定的 MAC 地址，容易被攻击 |
| v2 | 把 v1 的时间戳前四位换成 POSIX UID/GID | 问题同 v1 |
| v3 | MD5 哈希 + 唯一种子 | 随机分布的 ID 导致数据结构碎片化 |
| v4 | 随机数 / 伪随机数 | 除随机性外不含任何信息；仍有（极小的）冲突风险 |
| v5 | SHA-1 哈希 + 唯一种子 | 问题同 v3 |

实际使用最多的是 **UUID v4**。它简单可靠，但有两个天生短板：36 个字符太长，且完全随机——**无法排序**，做数据库主键或聚集索引时写入性能差（页分裂严重）。

## 三、ULID：可排序的 UUID 替代品

ULID（Universally Unique Lexicographically Sortable Identifier，通用唯一字典序可排序标识符）的思路是**时间戳 + 随机数**：时间戳精确到毫秒，毫秒内有 1.21e+24 个随机数，不存在实用意义上的冲突。

特性清单：

- 与 UUID 的 128 位兼容
- 每毫秒 1.21e+24 个唯一 ULID
- **按字典序（字母顺序）排序**——这是和 UUID v4 的本质区别
- 规范编码为 26 个字符（UUID 是 36 个）
- 使用 Crockford's base32，效率和可读性更好（每字符 5 位）
- 不区分大小写
- 没有特殊字符，URL 安全
- 同一毫秒内单调递增（正确处理时钟相同的情况）

按时间有序意味着做主键时新记录总是追加在 B+ 树右侧，写入性能友好，还天然带创建时间信息。

## 四、NanoID：更短更快的现代选择

NanoID 与 UUID v4 相当，随机位数相近（NanoID 126 位 vs UUID 122 位），冲突概率相似——要有十亿分之一的重复机会，得产生 103 万亿个 ID。

和 UUID v4 的主要区别：

| 对比项 | NanoID | UUID v4 |
| - | - | - |
| 长度 | **21 个字符** | 36 个字符 |
| 代码体积 | 130 字节 | 483 字节（uuid/v4 包的 1/4） |
| 生成速度 | 快约 60%（内存分配技巧） | 基准 |
| 随机源 | Node.js crypto / Web Crypto API（硬件级不可预测） | 依赖实现，常见不安全的 Math.random() |
| 分布均匀性 | 自研统一算法，不用 `random % alphabet` | - |
| 语言支持 | 14+ 种语言（Java/Go/Python/Rust/Swift…） | 所有语言内置 |
| 自定义 | 支持自定义字母表和长度 | 不支持 |
| 依赖 | 零第三方依赖 | - |

局限：非人类可读（调试略难，但比 UUID 短）；做表主键且该列是聚集索引时，与 UUID 一样存在随机写入的问题（它无序）。

## 五、怎么选

- **分布式唯一性优先、不关心排序**：UUID v4 或 NanoID（更短更快选 NanoID）
- **要当数据库主键 / 需要按时间排序**：ULID（或雪花算法 Snowflake——趋势递增但依赖时钟回拨处理）
- **标识物理设备**：这是 UDID 的领域，与另外三个不是一类问题

## 总结

四个名字里，UDID 是设备标识、UUID 是通用唯一、ULID 补上了「有序」、NanoID 补上了「更短更快」。没有银弹：随机 ID 别做聚集索引主键，有序需求交给 ULID/Snowflake，前端展示和 URL 场景 NanoID 最舒服。
