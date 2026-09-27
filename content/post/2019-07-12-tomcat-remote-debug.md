---
title: "tomcat开启远程debug"
date: 2019-07-12T08:00:00+08:00
tags: [ "tomcat", "java", "调试" ]
description: "tomcat 开启远程 debug：CATALINA_OPTS 配置 JDWP 参数让 IDEA/Eclipse 远程连调，老写法与现代写法对照（JDK 9+ 的 address=* 前缀），以及开启 debug 后 shutdown.sh 失效的坑"
categories: [ "tomcat", "java" ]
toc: true
---

## 前言

测试环境的问题在本地复现不出来，最直接的办法就是远程 debug：本地 IDEA 打断点，连到测试环境的 tomcat 上单步跟。配置很简单，给 catalina 加一段 JDWP 参数就行，但有个 shutdown.sh 失效的坑要提前知道。

## 1、配置方法

linux 下在 catalina.sh 开头（或者按规范放 bin/setenv.sh）加：

```bash
CATALINA_OPTS="-server -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5888"
```

windows 下修改 catalina.bat：

```bat
SET CATALINA_OPTS=-server -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5888
```

参数含义：

| 参数 | 含义 |
| - | - |
| `-Xrunjdwp:transport=dt_socket` | 用 socket 通信 |
| `server=y` | JVM 作为调试服务端，等 IDE 来连（反过来 client=y 是 JVM 连 IDE，少用） |
| `suspend=n` | 启动时不挂起等调试器，正常启动；调成 y 会卡住等 IDE 连上才继续 |
| `address=5888` | 调试端口，IDE 连这个口 |

重启 tomcat 后，IDEA 里 Remote JVM Debug（老版本叫 Remote）填目标 IP + 5888 端口，和本地代码一致（同版本同分支）就能打断点单步跟了。

## 2、新版本写法

上面那串是 JDK 1.4 时代的老写法，`-Xdebug -Xnoagent -Djava.compiler=NONE` 在现代 JDK 上都是多余的，一行就够：

```bash
# JDK 5-8
CATALINA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5888"

# JDK 9+：address 默认只监听本机 127.0.0.1，远程连要加 *: 前缀（并注意安全）
CATALINA_OPTS="-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:5888"
```

**JDK 9+ 的 `*:` 前缀是个容易懵的点**：不加的话本地 IDEA 连测试环境一直 connection refused，参数明明配了就是连不上。

## 3、坑：shutdown.sh 失效

开了 debug 端口之后，`./shutdown.sh` 有时会关不掉 tomcat（8005 的 shutdown 指令发下去没反应），需要手动 kill 掉进程再启。这是这个模式的已知问题，测试环境这么用没问题，**生产环境千万不要开 debug 端口**：一是性能损耗，二是调试端口暴露在外等于把 JVM 的控制权交出去了（能远程 attach 就能远程执行代码）。

生产要排查问题，用 arthas 这类诊断工具代替远程 debug，安全得多。

## 总结

远程 debug 三步：加 JDWP 参数、重启、IDE 连端口。记住两点：JDK 9+ 的 address 要写 `*:端口`；这东西只属于测试环境，生产用 arthas。

## 相关阅读

- [tomcat环境及线程池、JDK配置详解](/post/2020-11-16-tomcat-jvm/)
