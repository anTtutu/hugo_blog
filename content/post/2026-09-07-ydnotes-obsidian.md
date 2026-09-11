---
title: "有道云笔记迁移到obsidian"
date: 2026-09-07T00:29:47+08:00
tag : [ "notes", "obsidian", "ydnotes" ]
description: "有道云笔记迁移到obsidian"
categories: [ "notes", "obsidian", "ydnotes" ]
toc: true
---

## 前言

白嫖了差不多有10年出头的有道云笔记，最开始也为同步丢失烦恼过，因没有备份更换电脑丢失了就丢失了，好在有道云笔记后续稳定些了。但是随着AI的加持，有道云这种传统笔记有心无力，虽然有道云也在不停的迭代增加AI，但是没有个人整理的一些skill好用，2025年下半年就想迁移了，但是一直因为量大且没有很好的导出工具搁置，上半年发现github上有大佬开放了有道云笔记导出markdown格式的工具，于是便抱着试一试的心态，结合cc测试修复了一些细节问题，这次总算是完整的把笔记全部导出好了，记录下导出工具的用法

## 1、准备工具

先前找到的工具[youdaonote-pull](https://github.com/DeppWang/youdaonote-pull)，但是一看时间，作者2024年迁移成功后就没有再更新了，再看了下issue，确实有不少用户提了一些细节兼容不足的问题，又找到了另外一个工具[youdaonote-pull](https://github.com/chunxingque/youdaonote-pull), 这个作者2026年初还更新过，也是看了下后者有参考前者并修复了一些兼容性问题，便用后者试一试，如果还有细节不足，可以用cc修复下

```bash
git clone --depth=1 https://github.com/chunxingque/youdaonote-pull
```

## 2、参考说明提取cookie参数

网页端登录有道云笔记web版本，F12进入开发者模式，刷新页面，获取类似这种请求地址的cookie信息即可: https://note.youdao.com/yws/api/personal/user, 提取cookie最后3个参数

```javascript
YNOTE_SESS=v2|_************
YNOTE_LOGIN=3||************
YNOTE_CSTK=************
```

有很明显的格式，比如SESS参数是v2|后面是遗传类似hash的值，LOGIN参数是3||纯数字类似id，CSTK参数是类似一串很短的字符串(类似token经过hash后经过缩短提炼的字符串)，可能推理不准请指正，我只是根据参数含义和值大致推理的

## 3、测试

因为有道云经营了10多年，还在不停迭代，只是迭代速度一般般，所以不能保证刚下的工具就可以使用，发现基本上正常，只有一些比较早起的笔记转换失败，这个时候有2中方法：
>1、升级你的有道云笔记客户端，重新登录下，把测试报错的笔记从html格式转换成最新版本适配的格式。这个办法比较笨，需要记录错误日志的路径并挨个转换，如果多就有点麻烦
>2、打开claude code或者其他coding工具，让cc帮你分析错误信息并修复，我就是走的这条路

```bash
## 安装依赖
uv pip install -r pyproject.toml

## 执行
python pull_notes.py

## macos修复报错，把windows相关的import和下面的进度条windows的都注释
```

## 4、比较

虽然有道云笔记属于传统笔记客户端，但是别说它的markdown渲染还是美观一些，obsidian只是把markdown原生展示出来，并没有做美化，但是也不是不能用，对吧。迁移了就别在乎那点美化效果了

## 4、结果参考

有道云笔记导出的![ydnotes](/posts/obsidian/ydnotes.png)
obsidian复制进去的![obsidian](/posts/obsidian/obsidian.png)