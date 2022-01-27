---
title: java小日常记录-不定期更新
date: 2017-08-27T21:46:20+08:00
tags: [ "java" ] 
description: "java小日常记录"
categories: [ "java" ]
toc: true
---

## 前言
记录工作中碰到的一些 java 小日常积累
## 1、远程debug调测
web项目远程调测 - 仅用于测试环境或者上线前的调测

### 注意：
仅限测试环境或者上线前的调测，如果用于生产环境，你的开发工具再debug模式起着的话，会拦截所有的请求。
```bash
# linux增加以下这段就可以远程连接服务器的5888端口了
CATALINA_OPTS="-server -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5888"
```
### 1.1 关闭的问题
添加了debug端口以后好像会出现./shutdown.sh 无法关闭tomcat，需要手动kill

```bat
# Windows下面修改catalina.bat，增加：  
SET CATALINA_OPTS=-server -Xdebug -Xnoagent -Djava.compiler=NONE -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5888
```
### 1.2 eclipse
然后配置你的eclispe启动remote：新建remote java Application
![](/posts/debug/add-remote.jpg)
配置host和port：
![](/posts/debug/config.jpg)
然后就可以调测定位问题。

## 2、bug重现
生产环境的数据问题如何在本地开发环境重现？

这个问题碰不到还好，碰到就头疼了，我个人是把依赖的几个工程转成osgi的模式，然后测试代码，替换到spring的服务，抓到生产的入参，然后在测试代码中跟踪逻辑走向。

这种是单项目可以，微服务就不行了。详细步骤后续待补充。

## 3、base64奇葩问题
周五（2017年6月10日晚）碰到个诡异问题：  
用maven引入commons-codec-1.10的包，使用base64加密，结果怎么都不对，一直提示方法找不到，如下面的报错
```java
Java.lang.NoSuchMethodError: org.apache.commons.codec.binary.Base64.decodeBase64
```
后来找了下，发现QQ的第三方登录SDK包重写了apache的base64，而且包名都一样，导致找不到对应的方法，  
经打开两个包查看，验证确实如此，给自己做个记录，以免再入坑：

### 3.1 QQ的Sdk4j
![](/posts/debug/tx.jpg)
### 3.2 Apache的commons-codec:
![](/posts/debug/apache.jpg)
### 解决方案
只能继承 apache 的 base64了，成为自己的工具类，再用自己的工具类的 base64方法