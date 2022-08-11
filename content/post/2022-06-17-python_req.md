---
title: "python打包-只依赖自己项目引用的module"
date: 2022-06-17T00:29:47+08:00
tag : [ "python", "package" ]
description: "python打包-只依赖自己项目引用的module"
categories: [ "python", "package" ]
toc: true
---

## 前言
本地开发python后，需要生成requirements.txt，但是不做处理的话，会把你本地安装的所有module都依赖进来，找到一个根据项目生成依赖的工具

## 1、安装
```bash
pip install pipreqs
```

## 2、生成项目依赖
进入项目根目录
```bash
pipreqs . --encoding=utf8 --force
```
说明
参数|说明
-|-
--force|会覆盖前一个requirements.txt
--encoding=utf8|解决编码问题

## 3、参数介绍
```bash
Usage:
    pipreqs [options] <path>

Options:
    --use-local           Use ONLY local package info instead of querying PyPI
    --pypi-server <url>   Use custom PyPi server
    --proxy <url>         Use Proxy, parameter will be passed to requests library. You can also just set the
                          environments parameter in your terminal:
                          $ export HTTP_PROXY="http://10.10.1.10:3128"
                          $ export HTTPS_PROXY="https://10.10.1.10:1080"
    --debug               Print debug information
    --ignore <dirs>...    Ignore extra directories
    --encoding <charset>  Use encoding parameter for file open
    --savepath <file>     Save the list of requirements in the given file
    --print               Output the list of requirements in the standard output
    --force               Overwrite existing requirements.txt
    --diff <file>         Compare modules in requirements.txt to project imports.
    --clean <file>        Clean up requirements.txt by removing modules that are not imported in project.
    --no-pin              Omit version of output packages.
```

## 4、参考
参考文档：<https://pypi.org/project/pipreqs/>
