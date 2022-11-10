---
title: "几种id浅谈"
date: 2022-07-11T00:29:47+08:00
tag : [ "id" ]
description: "几种id浅谈"
categories: [ "id" ]
toc: true
---

## 前言
几种 ID 浅谈，UDID、UUID、ULID、NanoID

## 1、UDID
Unique Device Identifier（设备唯一标识符）  
从名称上也可以看出，UDID这个东西是和设备有关的，而且是只和设备有关的，有点类似于MAC地址。真机调试，然后需要把UDID这个东西添加到Provisoning Profile授权文件中，也就是把设备唯一标识符添加进去，以此来识别某一台设备。 UDID是一个40位十六进制序列，我们可以使用iTunes和Xcode来获取这个值。

## 2、UUID
Universally Unique Identifier（通用唯一标识符）  
UUID 目前有 5 个版本：  
* 版本1：在许多环境中是不切实际的，因为它需要访问唯一的，稳定的MAC地址，容易被攻击；
* 版本2：将版本 1 的时间戳前四位换为 POSIX 的 UID 或 GID，问题同上；
* 版本3：基于 MD5 哈希算法生成，生成随机分布的ID需要唯一的种子，这可能导致许多数据结构碎片化；
* 版本4：基于随机数或伪随机数生成，除了随机性外没有提供其他信息；
* 版本5：通过 SHA-1 哈希算法生成，生成随机分布的ID需要唯一的种子，这可能导致许多数据结构碎片化；

这里面常用的就是 UUID4 了，但是，即使是随机的，但是也是存在冲突的风险。
和 UUID 要么基于随机数，要么基于时间戳不同，ULID 是既基于时间戳又基于随机数，时间戳精确到毫秒，毫秒内有1.21e + 24个随机数，不存在冲突的风险，而且转换成字符串比 UUID 更加友好。

## 3、ULID
Universally Unique Lexicographically Sortable Identifier（通用唯一词典分类标识符）  

特性：
* 与UUID的128位兼容性
* 每毫秒1.21e + 24个唯一ULID
* 按字典顺序(也就是字母顺序)排序！
* 规范地编码为26个字符串，而不是UUID的36个字符
* 使用Crockford的base32获得更好的效率和可读性（每个字符5位）
* 不区分大小写
* 没有特殊字符（URL安全）
* 单调排序顺序（正确检测并处理相同的毫秒）

## 4、NanoID
Nano ID 与 UUID v4 (基于随机) 相当。它们在 ID 中有相似数量的随机位 (Nano ID 为126，UUID 为122),因此它们的冲突概率相似,要想有十亿分之一的重复机会, 必须产生103万亿个版本4的ID.

### 4.1 Nano ID 和 UUID v4之间有下面几点主要区别
* Nano ID 使用更大的字母表，所以类似数量的随机位 被包装在21个符号中，而不是36个。
* Nano ID 代码比uuid/v4包少4倍: 130字节而不是483字节.
* 由于内存分配的技巧，Nano ID 比 UUID 快 60%。
* 不可预测性,不使用不安全的 Math.random(), Nano ID 使用 Node.js 的 crypto 模块和浏览器的 Web Crypto API。这些模块使用不可预测的硬件随机生成器。
* 统一性,NanoID 在 ID 生成器的实现过程中使用了自己的称为统一算法的算法，而不是使用random % alphabet
* 兼容性好,NanoID 支持 14 种不同的编程语言,分别是C#, C++, Clojure and ClojureScript, Crystal, Dart & Flutter, Deno, Go, Elixir, Haskell, Janet, Java, Nim, Perl, PHP, Python with dictionaries, Ruby , Rust, Swift
* NanoID的另一个现有特点是它允许开发者使用自定义字母。你可以改变字面意思或ID的大小
* 无第三方依赖,由于NanoID不依赖于任何第三方的依赖，随着时间的推移，它变得更加稳定的自我管理。从长远来看，这有利于优化包的大小，并使其不容易出现依赖性带来的问题

### 4.2 NanoID局限性
* 根据 StackOverflow 中的许多专家意见，使用 NanoID 没有明显的缺点或限制。
* 非人类可读是许多开发人员在 NanoID 中看到的主要缺点，因为它使调试变得更加困难。但是，与 UUID 相比，NanoID 更短且可读。
* 另外，如果使用 NanoID 作为表的主键，如果使用同一列作为聚集索引，也会出现问题。这是因为 NanoID 不是连续的

## 5、代码示例
github: <https://github.com/anTtutu/anttu.code.github.io.git>