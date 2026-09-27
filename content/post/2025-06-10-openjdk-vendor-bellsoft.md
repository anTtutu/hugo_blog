---
title: "OpenJDK厂商选型：从Oracle JDK到BellSoft Liberica，那些容易被忽略的差异点"
date: 2025-06-10T08:00:00+08:00
tags: [ "java", "jvm", "openjdk" ]
description: "OpenJDK 发行版选型指南：Oracle JDK 授权变化回顾、主流厂商（Temurin/Corretto/Zulu/Liberica/Dragonwell）对比、加解密长度 JCE 策略差异、字体渲染与容器适配等细节坑，附 AES-256 验证代码"
categories: [ "java", "jvm" ]
toc: true
---

## 前言

JDK 8 时代「装个 JDK」没得选，Oracle JDK 一把梭。2019 年 Oracle 改了授权之后，生产环境陆续迁到 OpenJDK 系的发行版上。但「都是 OpenJDK」不等于完全一样，加密策略、字体这些细节差异，我是迁完之后在生产上才碰到的，记录下。

## 1、Oracle JDK 和 OpenJDK 什么关系

- 2006 到 2019：Sun/Oracle 开源了 OpenJDK，但 Oracle JDK（商业授权）和它并存，细节上有一些差距
- 2019 年 1 月：Oracle 宣布 JDK 8u211 之后以及 JDK 11 起商用要收费，这是大家迁 OpenJDK 的分水岭
- 现在：Oracle JDK 17+ 又恢复免费（NFTC 协议），但条款写明下个 LTS 发布后旧 LTS 可能转回收费，企业不太敢把命脉押在这种条款上

代码层面 Oracle JDK 和 OpenJDK 已经高度同源，差异不到 1%。选型的差异主要在：**谁构建、谁维护、免费支持多久**。

## 2、主流发行版对比

| 发行版 | 维护方 | 免费更新期 | 特点 |
| - | - | - | - |
| **Eclipse Temurin**（原 AdoptOpenJDK） | Eclipse Adoptium | 每个 LTS 4 年+ | 社区中立，装机量最大，CI 默认选择 |
| **Amazon Corretto** | AWS | 免费、长期 | AWS 环境优化，EC2 上零成本换用 |
| **Azul Zulu** | Azul | 免费 + 付费支持 | 平台覆盖最广（含老旧系统） |
| **BellSoft Liberica** | BellSoft | 免费、长期 | **Spring 官方 buildpacks 默认 JRE**；全平台含 musl/ARM；自带字体 |
| **Alibaba Dragonwell** | 阿里 | 免费 | 淘宝双 11 同款，带诊断增强 |
| **华为毕昇 BiSheng** | 华为 | 免费 | 鲲鹏 ARM 优化 |
| **Red Hat Build of OpenJDK** | Red Hat | 随 RHEL 订阅 | RHEL 系统级集成 |
| Oracle JDK | Oracle | 新 LTS 出来后旧版转收费 | 条款摆动风险 |

我的选法：在哪个云上就用哪家自己的（Corretto/Dragonwell/毕昇），优化有针对性、支持链也短；通用环境用 **Temurin** 或者 **Liberica**。Spring Boot 官方 buildpacks（paketo-buildpacks）里内置的就是 Liberica JRE，容器化的 Spring 应用其实已经选了它。需要 alpine、ARM、Windows 32 位这种冷门平台覆盖的，看 Liberica 和 Zulu。

## 3、容易被忽略的差异点

### 3.1 加解密长度：AES-256 的 128 位限制

JDK 8u161 之前，Oracle JDK 和部分 OpenJDK 构建默认装的是「有限强度」JCE 策略，AES 超过 128 位直接抛异常：

```java
// JDK 8u151 及更早 + 没装无限强度策略时
KeyGenerator kg = KeyGenerator.getInstance("AES");
kg.init(256);                       // 抛 InvalidKeyException:
SecretKey key = kg.generateKey();   // Illegal key size or default parameters
```

这就是「同一份加解密代码，A 机器正常 B 机器抛异常」的经典来源：

| 构建版本 | AES-256 默认可用？ |
| - | - |
| Oracle JDK 8（≤8u151） | 不行，要手动下载 **JCE Unlimited Strength** 两个策略文件，覆盖到 `jre/lib/security/` |
| Oracle/OpenJDK 8u161+ | 可以（8u161 起 `crypto.policy=unlimited` 默认生效） |
| JDK 9+ 所有构建 | 可以，默认 unlimited |

排查方法：

```java
int maxLen = Cipher.getMaxAllowedKeyLength("AES");
System.out.println(maxLen);   // 128 = 有限策略；2147483647 = unlimited
```

注意一点：策略只影响「能不能用」，**已经用 128 位密钥加密的存量数据不受影响**，密钥长度和策略是两回事。

### 3.2 字体：容器里验证码变方块

Oracle JDK 和一些精简的 OpenJDK 构建不带字体库。容器化之后用 `java.awt` 画验证码、水印、导出 Excel 图表时：

```txt
java.lang.NullPointerException at sun.awt.FontConfiguration.getVersion
```

- **Liberica 完整版内置字体**，拿来就能画
- Temurin/Zulu 要自己在镜像里补：`apt-get install -y fontconfig fonts-dejavu-core`（中文再加 `fonts-wqy-zenhei`）

我就是换了个 JDK 发行版之后验证码挂了，查了半天才发现是字体的事。

### 3.3 容器内存感知

JDK 8u191+ / JDK 10+ 才有 `UseContainerSupport`（默认开启），容器里 `Runtime.availableProcessors()` 和堆大小才按 cgroup 算。主流发行版的现代构建都带了，从老 JDK 8 升上来就不用再手工 `-Xmx` 配到精确值，以前「容器被 OOMKilled 但 jvm 看不到」的问题在 21 上没有了。

### 3.4 免费更新期

Oracle 对非订阅用户只给**下一个 LTS 发布后 6 个月**的免费更新；Temurin/Liberica 对每个 LTS 提供 4 年以上。跑 17 的话要规划好吃到 2027 年往后的补丁，这是选发行版时最实际的一笔账。

### 3.5 TCK 认证

「Java 兼容」靠 TCK 认证背书。Temurin、Corretto、Zulu、Liberica 都过了认证，个别小众构建没有，生产选型认准 TCK。

## 4、Liberica 上手

**sdkman 安装切换：**

```bash
sdk list java | grep liberica     # 看可用版本
sdk install java 21.0.5-librca    # 装 Liberica 21
sdk use java 21.0.5-librca        # 当前 shell 生效
java -version
# openjdk version "21.0.5" 2024-10-15 LTS
# OpenJDK Runtime Environment (build 21.0.5+11-LTS) (BellSoft...)
```

**容器镜像（带字体的运行时）：**

```dockerfile
# 完整 JRE（含字体，画验证码/导出图表稳）
FROM bellsoft/liberica-openjre-debian:21
COPY app.jar /app/app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

# 极简容器（不含字体，纯接口服务更小）
# FROM bellsoft/liberica-openjre-cds-musl:21   # musl 版适配 alpine
```

**AES-256 自检代码（迁完跑一遍放心）：**

```java
import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;

/**
 * JDK 加密策略自检：验证 AES-256 与 HmacSHA512 是否可用
 */
public class CryptoCheck {
    public static void main(String[] args) throws Exception {
        System.out.println("AES max key length: "
                + Cipher.getMaxAllowedKeyLength("AES"));   // 期望 2147483647

        KeyGenerator kg = KeyGenerator.getInstance("AES");
        kg.init(256);                                      // JDK8 老环境会在这里抛异常
        System.out.println("AES-256 generate ok");

        KeyGenerator kg2 = KeyGenerator.getInstance("HmacSHA512");
        kg2.init(512);
        System.out.println("HmacSHA512-512 ok");
    }
}
```

## 5、选型建议

| 场景 | 推荐 |
| - | - |
| Spring Boot 容器化（buildpacks） | 默认就是 Liberica，不用动 |
| AWS 云 | Corretto |
| 阿里云/国内信创 | Dragonwell / 毕昇 / Liberica（看信创目录） |
| 通用 CI/CD 和开发机 | Temurin 或 Liberica（sdkman 一行切换） |
| 需要 alpine/musl 或全平台 | Liberica / Zulu |
| 法律合规敏感 | 避开 Oracle JDK 的条款摆动，统一 OpenJDK 发行版 |

## 总结

从 Oracle JDK 迁到 OpenJDK 发行版，代码层面基本零改动，要盯的是三个细节：老 JDK 8 的 JCE 加密策略（AES-256 限制）、字体缺失导致 AWT 崩、免费更新期的长短。容器化 Spring 用 Liberica，通用场景用 Temurin，云上用云厂商自己的。迁完跑一遍第 4 节的 CryptoCheck，这事就算闭环了。

## 相关阅读

- [JDK 8到21迁移指南](/post/2026-09-27-jdk8-to-21-migration-guide/)
- [GraalVM与Native Image详解](/post/2025-09-18-graalvm-native-image/)
- [docker镜像清单与梳理](/post/2026-09-10-docker_images/)（bellsoft/graalvm 镜像）
