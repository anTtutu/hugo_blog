---
title: "Win10安装kenlm语言模型模块"
date: 2020-11-15T00:29:47+08:00
tags: [ "Win10", "python", "kenlm" ]
description: "Win10安装kenlm语言模型模块"
categories: [ "Win10", "python", "kenlm" ]
toc: true
---

## 1、前言
最近找到一个汉字点选验证的识别程序，安装了试下效果，成功率很高，93%以上的成功率，还是很不错的，但是安装其中kenlm语言模型模块时走了不少弯路，记录下

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

## 2、第一次安装
直接安装
```bat
pip3 install kenlm

出现：error: Microsoft Visual C++ 14.0 is required. Get it with “Microsoft Visual C++ Build Tools

这时，安装Microsoft Visual C++ 14.0
```

## 3、安装VC++编译工具类库
(https://devblogs.microsoft.com/python/unable-to-find-vcvarsall-bat/)
![/post/python/vc++.jpg]

或者(http://go.microsoft.com/fwlink/?LinkId=691126)

注意：千万别安装成了Visual Studio，2015版的起码有7、8G，光下载都要很费力费时，完整的build Tools只有3~4M
![/post/python/vc++_install.jpg]

## 4、安装gitbash
这里直接从官方下载合适版本安装就行(https://gitforwindows.org/)
如果在cmd窗口执行，会碰到如下错误：
![/post/python/kenlm_error.jpg]

## 5、在Git Bash执行安装命令
在Git Bash里面输入下面一整行命令
```bash
pip install -e git+https://github.com/kpu/kenlm.git#egg=kenlm
```
![/post/python/kenlm_install_success.jpg]
