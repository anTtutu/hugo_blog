---
title: "docker build的一些问题"
date: 2026-01-13T00:29:47+08:00
tag : [ "docker", "images", "build" ]
description: "docker build的一些问题"
categories: [ "docker", "images", "build" ]
toc: true
---

## 前言
2024年国内无法访问docker hub了，且国内的一些公共镜像提供服务组织陆续关停服务。
因23年开始陆续每年有重要项目要上线，很少有时间静下心来写问题东西，这里简短记录下最近编译个开源组件的os镜像的一些问题和解决方案

## 1、docker hub无法访问问题
可以用国内一些云厂商的代理或者加速地址。
[https://github.com/dongyubin/DockerHub]
比如道客就提供了一个，这里不是说只有道客提供，只是正好用道客的加速成功拉取了ubuntu的镜像就以道客举例
[https://github.com/DaoCloud/public-image-mirror]

## 2、Mac端编译其他平台格式
比如要编译centos AMD64
```
docker build --platform linux/amd64 -t iamges_name .
```

## 3、突发奇想试试异星工厂的服务端镜像，竟然还真有网友整理的
官方也有岀，但是没梯子情况下网络是不通的
```
docker pull registry.cn-shanghai.aliyuncs.com/wittchen/factorio:2.0.60
```

## 4、IDC机房编译不行试试本地编译
IDC机场编译OS镜像，ubuntu需要从aliyun下载包含ubuntu的GPG文件，卡壳了半天，在没有梯子情况下，切换到办公电脑编译成功

## 5、因github等需要设置2步验证或者本地不允许账号密码直连
基于macos可以采用"HTTPS + 令牌 + osxkeychain"
```
macOS的 “钥匙串访问”
在弹窗中输入：
账号：你的 GitHub/Gitee 用户名。
密码：粘贴第一步复制的个人访问令牌（不是你的账户登录密码）。
点击 登录 或 允许，并务必勾选“始终允许”。
完成后，凭据将被永久安全地存储在macOS系统钥匙串中，后续所有操作均无需再输入
```