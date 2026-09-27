---
title: "GraalVM与Native Image详解：原理、Spring Boot样例与编译/运行镜像选型"
date: 2025-09-18T08:00:00+08:00
tags: [ "java", "graalvm", "native image", "容器" ]
description: "GraalVM 与 Native Image 详解：JIT vs AOT 原理、封闭世界假设与反射配置、Spring Boot 3 原生编译完整样例、Docker 编译镜像与运行镜像的选型对比（glibc/musl、distroless、镜像体积实测）"
categories: [ "java", "jvm", "容器" ]
toc: true
---

## 前言

Java 应用启动慢、吃内存、还要预热，放在 Serverless 和弹性伸缩的场景里很难受。GraalVM 的 Native Image 用 AOT 编译解决了这个问题：毫秒启动、内存省一半、连 JVM 都不要了。代价是反射要登记、构建要等几分钟、生态要适配。这篇把原理讲清、把 Spring Boot 3 的样例跑通，重点记录一下我在容器化时踩坑最多的部分：编译镜像和运行镜像怎么选。

## 1、GraalVM 是什么

GraalVM 是 Oracle 开源的高性能 JDK 发行版，两块东西：

1. **Graal JIT 编译器**：用 Java 写的 JIT，普通 JVM 模式下就能用，零改造白拿性能提升
2. **Native Image**：把 Java 应用 AOT（提前）编译成本地可执行文件，这篇的主角

| 维度 | JVM 模式（JIT） | Native Image（AOT） |
| - | - | - |
| 启动 | 秒级（类加载+JIT 预热） | 毫秒级（没有 JVM、没有类加载） |
| 内存 | 高（元空间+JIT 代码缓存） | 省一半以上 |
| 峰值性能 | 高（JIT 激进优化） | 接近，历史版本略低（PGO 能补） |
| 构建时间 | 秒级 | 分钟级（要做全程序分析） |
| 反射/动态代理 | 随便用 | 要登记元数据 |

## 2、原理：封闭世界假设

AOT 编译的时候没有运行时信息，GraalVM 从 main 入口做静态可达性分析，分析到的代码才编译进二进制，这就是封闭世界假设（Closed World）。带来的限制和对策：

| 动态特性 | 问题 | 对策 |
| - | - | - |
| 反射 `Class.forName("X")` | 分析器不知道 X 被用到 | 登记 reachability metadata：`reflect-config.json` |
| 动态代理 / CGLIB | 运行时生成字节码 | `proxy-config.json` 声明接口列表 |
| JNI / 资源文件 | 同理不可见 | `jni-config.json` / `resource-config.json` |

好消息是主流框架（Spring Boot 3、Quarkus、Micronaut、Hibernate 6）都做了 AOT 适配，构建期自动生成这些元数据，业务代码基本不用手动写 json。

## 3、样例一：纯 Java CLI

```java
public class HelloNative {
    public static void main(String[] args) {
        System.out.println("Hello from native! args=" + String.join(",", args));
    }
}
```

```bash
javac HelloNative.java
native-image -Ob HelloNative hello      # -Ob 快速构建（开发期）
./hello                                 # 没有 JVM，直接跑
file hello                              # ELF 64-bit LSB executable
```

有反射的时候登记元数据：

```bash
native-image -H:ReflectionConfigurationFiles=reflect-config.json HelloNative hello
```

```json
[
  { "name": "com.example.Bean", "allDeclaredConstructors": true,
    "allPublicMethods": true }
]
```

## 4、样例二：Spring Boot 3 原生编译

Spring Boot 3 起官方支持 AOT，框架在构建期自动生成反射配置和代码，业务代码不用动：

```bash
# 前置：本机要 GraalVM JDK 21 + C 编译链（gcc/xcode）
sdk install java 21.0.5-graalce      # GraalVM Community

mvn -Pnative native:compile          # Maven（Gradle 是 gradle nativeCompile）
# 构建要 2~5 分钟，第一次更久，产出 target/demo-web
./target/demo-web                    # 启动 0.1~0.3 秒，内存 80MB 左右
```

pom 里加插件：

```xml
<plugin>
    <groupId>org.graalvm.buildtools</groupId>
    <artifactId>native-maven-plugin</artifactId>
</plugin>
```

同一个简单 Web 服务我实测的对比：jar 模式启动 2.1s、内存 380MB；native 启动 0.2s、内存 85MB。弹性伸缩和 Serverless 场景下这个差距就是钱。

## 5、编译镜像和运行镜像的选型

容器里做 native 编译有个矛盾：构建环境要 GraalVM 加 C 工具链（2~4GB），运行却只要一个几 MB 的可执行文件。所以必然是多阶段构建，两段分开选。

### 5.1 编译镜像（builder）怎么选

| 镜像 | 大小 | 适用 | 说明 |
| - | - | - | - |
| `ghcr.io/graalvm/native-image-community:21` | 2.5GB 左右 | 首选通用 | GraalVM 官方社区版，自带 native-image 和 gcc |
| `bellsoft/liberica-openjdk-debian` + 手装 native-image | 2GB 左右 | Liberica 全家桶 | 和运行时同厂商，版本一致性好 |
| `paketobuildpacks/builder-jammy-buildpacks` | 3GB 左右 | Spring Boot 官方路线 | `pack build` 一条命令出镜像，不用写 Dockerfile |
| 自建（JDK + gcc + zlib） | 自定 | 内网/离线 | 把 sdkman 装 graalvm 的流程固化下来 |

两点提醒：新版 GraalVM 的 native-image 已经默认内置（老版本要 `gu install native-image`）；编译很吃内存，CI 的 build 容器给到 6~8G，不然 OOMKilled。

### 5.2 运行镜像怎么选：glibc 和 musl 是分水岭

native 二进制不是扔哪个 Linux 都能跑：**glibc 环境编译的放 alpine（musl）必挂**。两条路线：

| 路线 | 编译镜像 | 运行镜像 | 产物大小 | 适用 |
| - | - | - | - | - |
| glibc 路线（主流） | `native-image-community:21`（debian 系） | **`gcr.io/distroless/base`** 或 `debian:bookworm-slim` | 80~120MB | 默认选这条；distroless 没有 shell，更安全 |
| musl 静态路线 | alpine 变体 + musl 工具链（`-static` 全静态） | `alpine:3.20` 甚至 `scratch` | 10~30MB | 追求极致体积；要 `-static` 加 musl 工具链，DNS 解析这类库有兼容坑 |

### 5.3 完整 Dockerfile（glibc 路线，可直接用）

```dockerfile
# ---------- 编译阶段 ----------
FROM ghcr.io/graalvm/native-image-community:21 AS builder
WORKDIR /build
COPY .mvn/ mvnw pom.xml ./
RUN ./mvnw dependency:go-offline          # 先拉依赖，吃层缓存
COPY src ./src
RUN ./mvnw -Pnative native:compile \
    -DskipTests && \
    mv target/demo-web /build/app

# ---------- 运行阶段 ----------
FROM gcr.io/distroless/base-debian12
COPY --from=builder /build/app /app
EXPOSE 8080
ENTRYPOINT ["/app"]
```

同一个 Spring Boot Web 应用的体积实测：

| 方案 | 镜像体积 | 启动 |
| - | - | - |
| 传统：eclipse-temurin:21-jre + jar | 310MB 左右 | 2.1s |
| glibc 路线（上面 distroless 那个） | 95MB 左右 | 0.2s |
| musl 全静态 + scratch | 25MB 左右 | 0.2s |

### 5.4 我的建议

- 默认走 glibc + distroless，兼容性最好，Spring Boot 零额外配置
- 追极致体积或者边缘部署再上 musl 静态，留出调试兼容性的时间
- 编译层把「依赖下载」和「源码编译」拆成两层 COPY+RUN，CI 缓存能省很多时间
- 不想写 Dockerfile 的 Spring 团队直接 `pack build app --builder paketobuildpacks/builder-jammy-buildpacks`

## 6、什么场景该用

| 适合 | 不适合 |
| - | - |
| Serverless/按需伸缩（冷启动敏感） | 长驻、靠 JIT 预热堆性能的大吞吐服务 |
| 命令行工具、FaaS 函数 | 重度反射/动态代理的老系统（先评估改造量） |
| 高密度部署（一台机器塞几百个实例） | 构建时间敏感、迭代很快的开发态 |
| 安全敏感（没有 JVM 攻击面，可以静态扫描） | 依赖没做 AOT 适配的老框架（Spring 5 及以前） |

折中方案还有 **CRaC**：JVM 模式下做快照恢复，也能秒启、保留 JIT 的峰值性能，适合不想做 AOT 改造的长驻服务。两条路线可以并存，按服务挑。

## 总结

Native Image 用「封闭世界」换来毫秒启动和一半内存，Spring Boot 3 之后业务代码基本零改造，要花心思的是镜像：编译用 `graalvm/native-image-community`（或者 buildpacks），运行默认 glibc + distroless，追体积再上 musl 静态。冷启动敏感就 AOT，峰值性能敏感就留在 JVM 上配 CRaC，按服务来定。

## 相关阅读

- [OpenJDK厂商选型](/post/2025-06-10-openjdk-vendor-bellsoft/)（Liberica 发行版）
- [JDK 8到21迁移指南](/post/2026-09-27-jdk8-to-21-migration-guide/)
- [Kubernetes学习路径与实用工具箱](/post/2025-12-15-k8s-learning-and-tools/)（容器运行环境）
- [docker镜像清单与梳理](/post/2026-09-10-docker_images/)（graalvm 镜像）
