---
title: "Win10安装kenlm语言模型模块"
date: 2020-11-15T00:29:47+08:00
tags: [ "win10", "python", "kenlm" ]
description: "Win10安装kenlm语言模型模块"
categories: [ "win10", "python", "kenlm" ]
toc: true
---

## 1、前言
最近看到一篇关于汉字点选登录校验的学习模型，觉得比较有趣，可以搜集，成功率很高，93%以上的成功率，还是很不错的，于是下载并搭建环境，但是安装其中kenlm语言模型模块时走了不少弯路，记录下  
## 2、依赖
该工程需要依赖如下module，除了最后一个不好安装外，其他都比较容易，tensor修改下源或者网络好下载也快

module|安装命令
-|-
numpy==1.18.5|pip3 install numpy
torch==1.5.1|pip3 install torch
torchvision==0.6.1|pip3 install torchvision
tensorboard==1.14.0|pip3 install tensorboard
matplotlib==3.3.0|pip3 install matplotlib
pillow==7.2.0|pip3 install pillow
selenium==3.141.0|pip3 install selenium
requests==2.24.0|pip3 install requests
kenlm|linux/mac: pip3 install kenlm或pip3 install pypi-kenlm<br>win10: 没法直接安装，会报缺少C++编译库，好不容易安装了C++编译库，发展缺少zlib.h, 新增了该文件发现缺少dll...

## 3、第一次报错
直接安装
```bat
pip3 install kenlm

出现：error: Microsoft Visual C++ 14.0 is required. Get it with “Microsoft Visual C++ Build Tools
...
```
这时，需要安装Microsoft Visual C++ 14.0

## 4、安装VC++编译工具类库
(https://devblogs.microsoft.com/python/unable-to-find-vcvarsall-bat/)
![](/posts/python/vc++.jpg)

或者(http://go.microsoft.com/fwlink/?LinkId=691126)

注意：千万别安装成了Visual Studio，2015版的起码有7、8G，光下载都要很费力费时，完整的build Tools只有3~4M
![](/posts/python/vc++_install.jpg)

## 6、第二次报错
在cmd窗口执行，会碰到如下错误：
![](/posts/python/kenlm_error.jpg)
尝试过直接安装pip3 install kenlm，pypip的方式安装pip3 install pypi-kenlm，github下载源码python3 setup.py install都会出现上图的错误

## 7、安装GitBash
这里直接从官方下载合适版本安装就行(https://gitforwindows.org/)

## 8、在GitBash窗口执行安装命令
在GitBash里面输入下面一整行命令
```bash
pip install -e git+https://github.com/kpu/kenlm.git#egg=kenlm
```
![](/posts/python/kenlm_install_success.jpg)
