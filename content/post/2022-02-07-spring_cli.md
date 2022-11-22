---
title: "springboot cli&springcloud cli简单介绍"
date: 2022-02-07T00:29:47+08:00
tag : [ "java", "springboot", "cli" ]
description: "springboot cli&springcloud cli简单介绍"
categories: [ "java", "springboot", "cli" ]
toc: true
---

## 前言
尝试了下springboot cli和spring cloud cli 命令，整理了下参数和创建项目的介绍  

## 1、下载
### 1.1 下载springboot cli安装包
官方介绍：<https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started.html#getting-started.system-requirements>
#### 注意：
需要核对版本支持的jdk、maven、gradle、springboot版本，不能过于追求最新版本，比如springboot3.0.0.M1就只支持jdk17

我们不采用官方介绍的sdkman、homebrew等安装方式，直接手工安装
官方下载链接: <https://repo.spring.io/ui/native/release/org/springframework/boot/spring-boot-cli/2.6.3/>

### 1.2 下载springcloud cli安装包
官方介绍: <https://spring.io/projects/spring-cloud-cli>
#### 注意：
springcloud cli是作为 springboot cli的扩展插件安装的，需要下载源码、编译、打包、执行安装等步骤。  
同时也需要核对版本支持的jdk、maven、gradle、springboot版本，不能过于追求最新版本。

官方下载链接：<https://github.com/spring-cloud/spring-cloud-cli/archive/refs/tags/v2.2.4.RELEASE.tar.gz>

## 2、安装springboot cli
```bash
tar -zvxf spring-boot-cli-2.6.3-bin.tar.gz
cd spring-cli-2.6.3/
pwd
```
提取完整路径

## 3、配置环境变量
```bash
# springboot cli
export SPRING_HOME="/Users/xxxx/spring/tools/spring-cli-2.6.3"
export PATH=${SPRING_HOME}/bin:$PATH
```

## 4、安装springcloud cli
```bash
tar -zvxf spring-cloud-cli-2.2.4.RELEASE.tar.gz
cd spring-cloud-cli-2.2.4.RELEASE
mvn clean install -DskipTests=true
spring install org.springframework.cloud:spring-cloud-cli:2.2.4.RELEASE
```
mvn打包成功后，安装基本上就没问题

## 5、创建springboot web项目
示例
```bash
spring init --build=maven --java-version=1.8 --dependencies=web --packaging=jar --boot-version=1.5.3.RELEASE --groupId=com.dtbuluo --artifactId=javen --version 1.0
```

### 5.1 完整案例
```bash
spring init --build=maven --java-version=1.8 --dependencies=web --packaging=jar --boot-version=2.6.3.RELEASE --groupId=com.anttu --artifactId=demo --version=0.0.1-SNAPSHOT --description="demo springboot" --type=maven-project --name=springboot-demo --packageName=com.anttu.demo --language=java 
```

### 5.2 参数
参数|含义|示例或范围
-|-|-
build|表示项目构建工具maven，也可以选择gradle|maven、gradle
javaVersion或java-version|表示依赖JDK版本|1.8
dependencies=web|表示依赖web插件|web、websocket
packaging|表示打包程序方式|jar、war
bootVersion或boot-version|选择 spring boot的版本|2.6.3
groupId|maven的project groupId|com.example
artifactId|maven的project artifactId|demo
version|maven的project version|0.0.1-SNAPSHOT
description|maven的project描述|demo
type|project type, project 打包类型|maven-project或gradle-project
name|project name, 项目名称|demo
packageName|root package, 包名|com.example.demo
language|语言|java、kotlin


## 6、参数demo
```bash
Parameters
+-------------+------------------------------------------+------------------------------+
| Id          | Description                              | Default value                |
+-------------+------------------------------------------+------------------------------+
| artifactId  | project coordinates (infer archive name) | demo                         |
| bootVersion | spring boot version                      | 2.6.3                        |
| description | project description                      | Demo project for Spring Boot |
| groupId     | project coordinates                      | com.example                  |
| javaVersion | language level                           | 11                           |
| language    | programming language                     | java                         |
| name        | project name (infer application name)    | demo                         |
| packageName | root package                             | com.example.demo             |
| packaging   | project packaging                        | jar                          |
| type        | project type                             | maven-project                |
| version     | project version                          | 0.0.1-SNAPSHOT               |
+-------------+------------------------------------------+------------------------------+
```

## 7、命令
### 7.1 查看清单
```bash
spring init list
```

### 7.2 版本
```bash
spring --version
```

## 8、参考
官方链接：<https://start.spring.io/>