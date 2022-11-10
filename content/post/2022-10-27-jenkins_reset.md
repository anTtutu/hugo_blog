---
title: "jenkins的admin密码忘记了如何重置"
date: 2022-10-27T00:29:47+08:00
tag : [ "jenkins", " devops" ]
description: "jenkins的admin密码忘记了如何重置"
categories: [ "jenkins", "devops" ]
toc: true
---

## 前言
最近项目比较忙，没时间记录一些日常的心得，慢慢整理一些吧。正好9月份碰到一个交接的项目和服务器，发现服务器占用率很低，找运维重置了密码后登录检查服务，发现部署工具jenkins没人知道admin密码，于是重置了admin密码，记录下步骤

## 1、删除配置项
找到下面的配置项并注释
```xml
<!-->
  <useSecurity>true</useSecurity>
  <authorizationStrategy class="hudson.security.FullControlOnceLoggedInAuthorizationStrategy">
    <denyAnonymousReadAccess>true</denyAnonymousReadAccess>
  </authorizationStrategy>
  <securityRealm class="hudson.security.HudsonPrivateSecurityRealm">
    <disableSignup>true</disableSignup>
    <enableCaptcha>false</enableCaptcha>
  </securityRealm>
<-->
```

## 2、重启Jenkins服务
```bash
ps -ef | grep jekins

kill -9 22092

/usr/java/jdk1.8.0_192/bin/java -Dcom.sun.akuma.Daemon=daemonized -Djava.awt.headless=true -DJENKINS_HOME=/var/lib/jenkins -jar /usr/lib/jenkins/jenkins.war --logfile=/var/log/jenkins/jenkins.log --webroot=/var/cache/jenkins/war --daemon --httpPort=8321 --debug=5 --handlerCountMax=100 --handlerCountMaxIdle=20 &
```

## 3、系统管理
进入首页>“系统管理”>“Configure Global Security”

## 4、启用安全
勾选“启用安全”

## 5、专有用户数据库
点选“Jenkins专有用户数据库”，并点击“保存”

## 6、管理用户
重新点击首页>“系统管理”,发现此时出现“管理用户”

## 7、修改密码
点击右侧进入修改密码页面，修改后即可重新登录

## 8、参考
参考文档：<https://blog.csdn.net/leenhem/article/details/122013630>
