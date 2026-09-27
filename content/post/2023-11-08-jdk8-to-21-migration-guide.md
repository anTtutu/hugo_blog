---
title: "JDK 8到21迁移指南：参数变化、GC演进与虚拟线程实战"
date: 2023-11-08T08:00:00+08:00
tags: [ "java", "jvm", "JDK21", "升级迁移" ]
description: "JDK 8 升级 21 完整迁移指南：移除参数清单与启动失败排查、G1/分代 ZGC 选型决策、GC 统一日志、依赖库兼容（ASM/CGLIB/Spring Boot）、虚拟线程改造与 pinning 规避、分阶段迁移路径"
categories: [ "java", "jvm" ]
toc: true
---

## 前言

手上一批老服务还跑在 JDK 8 上，Oracle 的免费更新早就停了，趁着最近有空把几个服务迁到 21 试了试，过程不算复杂，但坑主要在两个地方：老参数会直接启动失败，还有依赖库的字节码兼容。把迁移过程和注意事项记录下，方便后来者。

站内 tomcat-jvm 那篇有 JDK21 的参数对照，oom 那篇有 OOM 新旧形态对照，这篇侧重**怎么迁**。

## 1、先清掉会启动失败的参数

升级前把启动脚本全量搜一遍，下面这些参数在新版是硬错误，带着它们直接起不来：

| 参数 | 状态 | 处理 |
| - | - | - |
| `-XX:PermSize` / `-XX:MaxPermSize` | JDK 8 就移除了，启动报错 | 删掉；要限制元空间改 `-XX:MaxMetaspaceSize=256m` |
| `-XX:+UseConcMarkSweepGC` | JDK 14 移除，启动报错 | 删掉，用默认 G1；或者换 `-XX:+UseZGC` |
| `-XX:+UseParNewGC` | 跟着 CMS 一起退役了 | 删掉 |
| `-XX:+UseBiasedLocking` | JDK 15 弃用 | 删掉，偏向锁已经从 JVM 里移除 |
| `-XX:+UseCompressedOops` 手工声明 | 没意义了 | 删掉 |
| `-verbose:gc -Xloggc:xxx` | JDK 9 起被统一日志接管 | 改 `-Xlog:gc*:file=gc.log:time:filecount=5,filesize=50m` |
| `-XX:+PrintGCDetails` 等 Print 系列 | 并进统一日志了 | `-Xlog:gc*` 的标签和修饰符替代 |

一条命令把生产脚本里的过时参数全搜出来：

```bash
grep -rn "PermSize\|UseConcMarkSweepGC\|UseParNewGC\|UseBiasedLocking\|Xloggc\|PrintGCDetails" \
  /opt/app/*/bin/ /etc/systemd/system/*.service 2>/dev/null
```

## 2、GC 怎么选

JDK 8 时代拼 ParNew + CMS 是在吞吐和停顿之间手工找平衡，现在简单了：

| 你的现状 | 迁移动作 |
| - | - |
| ParNew + CMS 加一堆新生代调参 | 全删，用默认 G1；压测后按 P99 目标加 `-XX:MaxGCPauseMillis=200` |
| 大堆（16G 以上）又对停顿敏感 | 分代 ZGC：`-XX:+UseZGC -XX:+ZGenerational`，停顿亚毫秒级，堆再大也不涨 |
| Parallel GC 跑批 | 保留 `-XX:+UseParallelGC`，论吞吐它还是最强的 |
| 堆大于 1G 手工分一半给新生代的老经验 | 作废，G1/ZGC 自己管，`-Xmn`、`SurvivorRatio` 别再带了 |

我的建议是先什么都不配跑默认 G1 看数据，不够再调。老版本那一套手工调参经验，在新的收集器上基本都是噪音。

## 3、依赖兼容才是真正的坑

JVM 本身向后兼容做得不错，升级翻车基本都翻在依赖上：

1. **ASM/CGLIB 版本**：JDK 21 的类文件版本是 65，老版本 ASM/CGLIB 碰到新字节码直接 `UnsupportedClassVersionError`。Spring Boot 3.2+ 和 Hibernate 6+ 内置的新字节码库没问题；还停在 Spring 5.x + 老 CGLIB 的得先把框架升上去
2. **JDK 内部 API**：`sun.misc.Unsafe`、`sun.misc.BASE64Encoder` 这些内部 API 在 JDK 16+ 强封装了，`--add-opens` 只能救急不是长久之计。用 `jdeps --jdk-internals app.jar` 一次扫出所有引用
3. **移除的模块**：JAXB/JAX-WS/activation（JDK 11 移除）、Nashorn（JDK 15 移除）、SecurityManager（JDK 17 弃用、24 移除）——有引用的补依赖或者换实现

```bash
# 迁移体检三连
jdeps --jdk-internals app.jar                  # 扫内部 API 引用
java -jar app.jar                              # 直接跑，看启动告警
mvn enforcer:enforce -Drules=requireJavaVersion # 核对版本约束
```

## 4、虚拟线程

虚拟线程是 JDK 21 最值得用的东西。

```java
// 旧写法：线程池 + 异步编排，为了省线程代码绕来绕去
ExecutorService pool = Executors.newFixedThreadPool(200);

// 新写法：一个任务一个虚拟线程，阻塞式代码就有异步的吞吐
try (var executor = Executors.newVirtualThreadPerTaskExecutor()) {
    for (var req : requests) {
        executor.submit(() -> handle(req));
    }
}
```

用的时候注意几点：

- **不要池化虚拟线程**，它便宜到用完就扔，池化反而出问题
- **pinning 坑**：synchronized 块里阻塞会把虚拟线程钉在载体线程上卸载不掉（JDK 21 的问题，JDK 24 的 JEP 491 才解除）。IO 阻塞的临界区改用 `ReentrantLock`，或者加 `-Djdk.tracePinnedThreads=full` 排查哪里被钉住了
- **ThreadLocal 慎用**：几十万虚拟线程每个一份副本，内存放大得厉害，跨层传上下文后面走 Scoped Values
- **限流别再用线程池大小**，虚拟线程下改 `Semaphore`

## 5、迁移步骤

我是按这个顺序走的，一次只动一个变量：

1. CI 上先加一条 JDK 21 的构建流水，保证能编译、测试是绿的，先不发布
2. 挑个无状态、依赖简单的服务先切 21，观察 GC 日志和 P99 一到两周
3. 按第 1 节的清单清参数，GC 一律先用默认 G1，老参数别翻译着带过去
4. 没问题再按依赖复杂度从低到高滚动升级，保留快速回退 8 的能力
5. 全量上到 21 之后，再逐个服务试点虚拟线程。先升级、后改造，别一步到位

## 总结

迁移的活儿就集中在两块：清参数（第二节清单，半小时的事）和核对依赖（内部 API 和字节码库，这才是大头）。GC 先用默认 G1 起步，别把 8 时代的调参经验翻译过去；升完之后虚拟线程是最大的红利，记得先把 synchronized 里的阻塞段换成 ReentrantLock。
