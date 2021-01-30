---
title: "redisson不全手册"
date: 2021-01-30T00:29:47+08:00
tags: [ "java", "redis", "redisson" ]
description: "redisson不全手册"
categories: [ "mine", "redis", "redisson" ]
toc: true
---

## 1、前言
在新项目用了半年的redisson，个人总结下使用经验，同时对比下jedis的不同

jedis接近redis底层命令
redisson封装得比较厉害，已经看不出底层命令的痕迹了，但是lock方面好用到哭