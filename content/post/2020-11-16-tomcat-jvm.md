---
title: "tomcat环境及线程池、JDK配置详解"
date: 2020-11-16T08:00:00+08:00
tags: [ "tomcat", "jvm", "java" ]
description: "tomcat 生产环境配置详解：三种常见 JVM 内存溢出、catalina.sh 的 JVM 参数全解、server.xml 线程池与 Connector 调优、JNDI 数据源配置与验证"
categories: [ "tomcat", "java" ]
toc: true
---

## 前言

生产环境中 tomcat 的 JVM 和线程池设置不好，很容易出现内存溢出或被流量打垮。这篇整理 tomcat 的三块核心配置：JVM 内存参数（catalina.sh）、线程池（server.xml）、JNDI 数据源（context.xml），以及常见内存溢出的原因和解决方法。

## 一、常见的三种 Java 内存溢出

### 1. JVM Heap（堆）溢出

```txt
java.lang.OutOfMemoryError: Java heap space
```

JVM 启动时会自动设置 Heap 的值：初始空间（`-Xms`）是物理内存的 1/64，最大空间（`-Xmx`）不可超过物理内存。Heap 的大小是 Young Generation 和 Tenured Generation 之和。在 JVM 中如果 98% 的时间用于 GC 且可用的 Heap size 不足 2%，将抛出此异常。

**解决方法**：手动设置 JVM Heap（堆）的大小。

### 2. PermGen space 溢出

```txt
java.lang.OutOfMemoryError: PermGen space
```

PermGen space（Permanent Generation space）是内存的永久保存区域，主要被 JVM 存放 Class 和 Meta 信息。Class 被加载的时候放入 PermGen space，它和存放实例的 Heap 区域不同，GC 不会在主程序运行期对 PermGen space 进行清理，所以应用载入很多 CLASS 的话就很可能出现 PermGen 溢出。

**解决方法**：手动设置 `MaxPermSize` 大小（JDK 8+ 已由 Metaspace 取代，改用 `-XX:MaxMetaspaceSize`）。

### 3. 栈溢出

```txt
java.lang.StackOverflowError
```

JVM 是栈式的虚拟机，函数的调用过程体现在堆栈和退栈上，调用构造函数的"层"数太多以致把栈区撑爆。一般栈区远小于堆区：即便每个函数调用需要 1K 空间，上千层调用也不过是 1MB，通常栈大小是 1~2MB。

**解决方法**：修改程序，避免过深的递归。

## 二、linux 下 tomcat 的 JVM 配置

修改 `TOMCAT_HOME/bin/catalina.sh`，位于 `cygwin=false` 判断之前，加入 `CATALINA_OPTS`：

```bash
export JAVA_HOME="/usr/local/jdk"
export JRE_HOME="/usr/local/jdk/jre"

export CATALINA_OPTS="-server -Xss512k -Xms1024M -Xmx1024M \
-XX:PermSize=128M -XX:MaxPermSize=256M \
-XX:+DisableExplicitGC -XX:+UseConcMarkSweepGC -XX:+UseParNewGC -XX:ParallelGCThreads=8 \
-verbose:gc -Xloggc:$CATALINA_BASE/logs/gc.log \
-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$CATALINA_BASE/ \
-Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=10001 \
-Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
```

### JVM 参数说明

| 参数 | 说明 |
| - | - |
| `-server` | 一定要作为第一个参数。tomcat 默认以 `java -client` 模式运行，server 意味着以真实的 production 模式运行 |
| `-Xms` | java Heap 初始大小。**把 Xms 与 Xmx 设成一样是最优做法** |
| `-Xmx` | java heap 最大值 |
| `-XX:PermSize` | 内存永久保存区初始大小，缺省 64M |
| `-XX:MaxPermSize` | 内存永久保存区最大大小，缺省 64M |
| `-XX:NewSize` | 新生代初始大小，缺省 2M |
| `-XX:MaxNewSize` | 新生代最大大小，缺省 32M |
| `-XX:SurvivorRatio` | 生还者池的比例，默认 2；垃圾回收成为瓶颈时可尝试定制 |
| `-Xmn` | young generation 的 heap 大小，一般设为 Xmx 的 1/3~1/4。堆大小=年轻代+年老代+持久代，增大年轻代会减小年老代，此值对性能影响较大，官方推荐配置为整个堆的 3/8 |
| `-Xss` | 每个线程的 Stack 大小。该值设太大会让每个线程立即消耗大量内存，默认 512k |
| `-verbose:gc` | 显示垃圾收集信息 |
| `-Xloggc:gc.log` | 指定垃圾收集日志文件 |
| `-XX:+UseParNewGC` | 缩短 minor 收集的时间 |
| `-XX:+UseConcMarkSweepGC` | 缩短 major 收集的时间，在 Heap Size 比较大且 Major 收集时间较长的情况下更合适 |
| `-XX:ParallelGCThreads` | 增加并行度【多CPU】 |

> 经验：如果 JVM 的堆大小大于 1GB，应该使用 `-XX:NewSize=640m -XX:MaxNewSize=640m -XX:SurvivorRatio=16`，或者将堆总大小的 50% 到 60% 分配给新生代——调大新对象区，减少 Full GC 次数。

### 新版本 JDK 差异（JDK 8 → 21）

上文参数组合基于 JDK 7/8 时代，其中一批参数已被移除，升级时**带着它们启动会直接失败**：

| 移除项 | 时间线 | 替代 |
| - | - | - |
| `-XX:PermSize` / `-XX:MaxPermSize` | JDK 8 移除永久代 | `-XX:MetaspaceSize` / `-XX:MaxMetaspaceSize` |
| `-XX:+UseConcMarkSweepGC`（CMS） | JDK 9 弃用 → **JDK 14 移除** | G1（默认）或 ZGC |
| `-XX:+UseParNewGC` | 随 CMS 一起退役 | G1 自带年轻代并行回收 |
| `-verbose:gc -Xloggc:` | JDK 9 起统一日志接管 | `-Xlog:gc*`（见下） |

**GC 选型的新逻辑**：当年拼装 ParNew+CMS 是在吞吐与停顿间手工找平衡，现在只需选一个现代收集器——

- **通用服务**：G1（JDK 9+ 默认，什么都不用配），用 `-XX:MaxGCPauseMillis=200` 表达停顿目标，`-Xmn`/`SurvivorRatio` 手工划新生代的时代结束（G1 region 自适应管理）
- **大堆 + 低延迟**：JDK 21 分代 ZGC：`-XX:+UseZGC -XX:+ZGenerational`，亚毫秒级停顿且不随堆变大——正好接棒当年 CMS「缩短 major 收集时间」的诉求
- **纯吞吐批处理**：Parallel GC 依然是吞吐之王，继续用

**GC 日志换统一语法**：

```txt
# JDK 8：-verbose:gc -Xloggc:gc.log
# JDK 9+ 一条等价：
-Xlog:gc*:file=$CATALINA_BASE/logs/gc.log:time,uptime:filecount=5,filesize=50m
```

**配置文件的新姿势**：新版 tomcat（7+）不建议直接改 catalina.sh——升级即被覆盖。在 `bin/` 下新建 `setenv.sh` 写入 `CATALINA_OPTS`，启动脚本自动加载，配置与发行包解耦。

JDK 21 时代等效配置示例（G1 方案）：

```bash
# $CATALINA_HOME/bin/setenv.sh
export CATALINA_OPTS="-server -Xms2g -Xmx2g \
-XX:+UseG1GC -XX:MaxGCPauseMillis=200 \
-XX:MaxMetaspaceSize=256m \
-Xlog:gc*:file:$CATALINA_BASE/logs/gc.log:time:filecount=5,filesize=50m \
-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=$CATALINA_BASE/ \
-Dcom.sun.management.jmxremote.port=10001 \
-Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false"
```

原文其余思路依然成立：Xms=Xmx 避免堆伸缩、堆转储留现场、JMX 远程监控，与 JDK 版本无关。JDK 9+ 已无独立 JRE 目录，`JRE_HOME` 不再需要单独设置。

### JVisualVM 远程监控

在 catalina.sh 中添加 JMX 参数：

```txt
-Dcom.sun.management.jmxremote
-Dcom.sun.management.jmxremote.port=9004        # JMX 代理端口，VisualVM 连接的端口
-Dcom.sun.management.jmxremote.ssl=false        # 是否启用 ssl
-Dcom.sun.management.jmxremote.authenticate=false   # 不需要密码认证
```

## 三、线程池配置（conf/server.xml）

搜索 `<Executor name="tomcatThreadPool"`，开启并调整：

```xml
<Executor name="tomcatThreadPool" namePrefix="catalina-exec-"
    maxThreads="600" minSpareThreads="30" maxIdleTime="60000" />
```

搜索 `port="8080"`，修改 `<Connector ...>` 节点并挂上线程池：

```xml
<Connector executor="tomcatThreadPool"
           port="8001" protocol="HTTP/1.1"
           connectionTimeout="60000"
           redirectPort="443" URIEncoding="UTF-8"
           minSpareThreads="30"
           maxSpareThreads="300"
           enableLookups="false"
           disableUploadTimeout="true"
           compression="on" compressionMinSize="4096"
           noCompressionUserAgents="gozilla, traviata"
           compressableMimeType="text/html,text/xml,text/javascript,text/css,text/plain,application/json,application/x-javascript"
           maxThreads="600" />
```

### 线程池参数说明

- **maxThreads**：Tomcat 可创建的最大线程数，每一个线程处理一个请求，即最大并发数。一般服务器 500~600 足够
- **minSpareThreads**：最小备用线程数，tomcat 启动时初始化的线程数
- **maxSpareThreads**：最大备用线程数。一旦空闲线程数超过这个值，Tomcat 会关闭不再需要的线程，缩减池中线程总数
- **acceptCount**：当所有可用线程都被占用时，可放入处理队列的请求数（被排队的请求数）。队列也满了就直接 refuse connection
- **connectionTimeout**：网络连接超时，单位毫秒。设为 0 表示永不超时，有隐患，通常设 30000
- **enableLookups**：是否允许 DNS 查询，与 Apache 的 HostnameLookups 一样，设为关闭
- **URIEncoding="UTF-8"**：使 tomcat 可以解析含中文名文件的 url
- **compression**：开启 gzip 压缩，配合 compressionMinSize（压缩阈值）与 compressableMimeType（压缩类型）

## 四、JNDI 数据源配置（conf/context.xml）

编辑 conf 下的 context.xml，在 Context 模块插入 Resource 信息（示例含 Oracle 与 MySQL 两种）：

```xml
<Context>

<Resource name="jdbc/cfgDS"
          auth="Container"
          type="javax.sql.DataSource"
          driverClassName="oracle.jdbc.driver.OracleDriver"
          url="jdbc:oracle:thin:@(DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=192.168.1.10)(PORT=1901)))(CONNECT_DATA=(SERVICE_NAME=orcl)))"
          username="your_user"
          password="your_password"
          maxActive="30"
          maxIdle="0"
          maxWait="30000" />

<Resource name="jdbc/BookDB"
          auth="Container"
          driverClassName="com.mysql.jdbc.Driver"
          type="javax.sql.DataSource"
          url="jdbc:mysql://192.168.1.20:3306/your_db?characterEncoding=UTF-8"
          username="your_user"
          password="your_password"
          maxActive="30"
          maxIdle="0"
          maxWait="30000" />

</Context>
```

**验证**：在 WEB-INF 下创建 web.xml 声明资源引用：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE web-app PUBLIC
      '-//Sun Microsystems, Inc.//DTD Web Application 2.3//EN'
      'http://java.sun.com/j2ee/dtds/web-app_2_3.dtd'>
<web-app>
  <resource-ref>
      <description>DB Connection</description>
      <res-ref-name>jdbc/BookDB</res-ref-name>
      <res-type>javax.sql.DataSource</res-type>
      <res-auth>Container</res-auth>
  </resource-ref>
</web-app>
```

创建 index.jsp 测试连通性：

```jsp
<%@ page language="java" import="java.util.*,javax.naming.*,java.sql.*,javax.sql.*" pageEncoding="UTF-8"%>
<%
    Context ctx = new InitialContext();
    String strLookup = "java:comp/env/jdbc/BookDB";
    DataSource ds = (DataSource) ctx.lookup(strLookup);
    Connection con = ds.getConnection();
    if (con != null) {
        out.print("success");
    } else {
        out.print("failure");
    }
%>
```

## 总结

tomcat 调优抓住三点：**Xms=Xmx** 避免堆动态伸缩、线程池 **maxThreads 配合 acceptCount** 匹配业务并发模型、压测时打开 `-verbose:gc` 和 HeapDump 以便事后分析。JDK 8 以后的版本记得把 PermSize 相关参数换成 Metaspace。

---

## 相关阅读

- [JDK 8到21迁移指南](/post/2026-09-27-jdk8-to-21-migration-guide/)
