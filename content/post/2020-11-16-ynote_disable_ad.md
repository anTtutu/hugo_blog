---
title: "Win10有道云笔记去掉左下角广告"
date: 2020-11-16T00:29:47+08:00
tags: [ "win10", "ynote" ]
description: "Win10有道云笔记去掉左下角广告"
categories: [ "win10", "ynote" ]
toc: true
---

## 前言
有道云笔记，免费的，虽然不那么完美，但是毕竟免费，记录下笔记还是不错的选择，支持markdown、富文本等丰富的类型，但是win10下面左下角有个很烦人的广告，一直想去掉。

结果无意间发现安装目录下有个theme目录，目录下有个build.xml，搜索发现有左下角广告注释，然后看客户端排版是靠这个xml布局的，于是尝试调整。。。
## 1、搜索ad或广告
搜索ad关键字，定位左下角广告xml代码
![](/posts/ynote/ynote_ad.jpg)
## 2、简单修改测试
直接把布局展示的坐标全部修改成"0,0,0,0"这样的布局，没想到重启真的不展示了，但是这里留下空白的区域，不是很完美
![](/posts/ynote/ynote_success.jpg)
## 3、注释修改的地方
修改示例：  
![](/posts/ynote/ynote_disable.jpg)
完美修改示例：
![](/posts/ynote/ynote_disable_perfect.jpg)
## 4、成功展示
只修改布局效果：
![](/posts/ynote/ynote_success.jpg)
完全注释的完美效果：
![](/posts/ynote/ynote_perfect.jpg)