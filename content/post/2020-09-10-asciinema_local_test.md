---
title: "linux下录屏工具本地化测试"
date: 2020-09-10T00:29:47+08:00
tags: [ "linux", "rec" ]
description: "linux下录屏工具本地化测试"
categories: [ "linux", "rec" ]
toc: true
---

## 1、一次看别人的blog发现一个linux的录屏工具asciinema
官网:(https://asciinema.org/)  
github:(https://github.com/asciinema)

## 2、在linux下安装工具
```bash
pip install:
pip3 install asciinema

yum install:
yum install asciinema

homebrew install:
brew install asciinema
```

## 3、常规用途介绍
```bash
开始录屏
asciinema rec

停止录屏
Ctrl+D 或 exit 然后Ctrl+C

本地播放
asciinema play filename

URL播放
asciinema play http(s)://asciinema.org/a/22124.cast

上传到asciinema服务器
asciinema upload filename
```

## 4、转本地化blog播放
1、github下载asciinema-player项目的js和css文件  
下载地址：(https://github.com/asciinema/asciinema-player)

2、添加到hugo的自定义js和css中，config.yml配置
```yml
customCSS = ['asciinema-player.css']
customJS = ['asciinema-player.js']
```

3、开启hugo的自定义html标签，config.yml增加配置
```yml
[markup.goldmark.renderer]
  unsafe = true
```

4、blog中增加播放标签和本地的录制文件，比如下面demo
```html
<asciinema-player src="/posts/rec/335029.cast"></asciinema-player>
```
效果如下：
<asciinema-player src="/posts/rec/14.cast"></asciinema-player>

## 5、更多参数可以参考asciinema --help或官方Doc
官方Doc：(https://asciinema.org/docs/)