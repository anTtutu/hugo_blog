---
title: springboot的devTools热部署
date: 2019-06-08T21:46:20+08:00
tags: [ "springboot" ]
description: "springboot的devTools热部署"
categories: [ "springboot" ]
toc: true
---

## 前言
springboot利用devtools实现热部署

## 1、application.yml
```yaml
spring:
    devtools:
        restart:
            #热部署生效
          enabled: true
            #设置重启的目录
            #additional-paths: src/main/java
            #classpath目录下的WEB-INF文件夹内容修改不重启
          exclude: WEB-INF/**
```
设置WEB-INF下的jsp修改不需要重启。

## 2、pom.xml
```xml
<!--devtools热部署-->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-devtools</artifactId>
    <optional>true</optional>
    <!-- optional=true,依赖不会传递，该项目依赖devtools；之后依赖该项目的项目如果想要使用devtools，需要重新引入 -->
    <scope>true</scope>
</dependency>
```
```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
      <fork>true</fork>
    </configuration>
    <dependencies>
      <!-- spring热部署-->
      <!-- https://mvnrepository.com/artifact/org.springframework/springloaded -->
      <dependency>
        <groupId>org.springframework</groupId>
        <artifactId>springloaded</artifactId>
        <version>1.2.6.RELEASE</version>
      </dependency>
    </dependencies>
</plugin>

```

## 3、idea设置
1、File-Settings-Compiler-Build Project automatically  
2、ctrl + shift + alt + /,选择Registry,勾上 Compiler autoMake allow when app running