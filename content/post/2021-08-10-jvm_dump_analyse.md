---
title: "jvm的大dump文件分析"
date: 2021-08-10T00:29:47+08:00
tag : [ "dump", "jvm", "java" ]
description: "jvm的大dump文件分析"
categories: [ "dump", "jvm", "java" ]
toc: true
---

## 前言 
参考dump文件的大小，如果超过6G、8G 一般我们本地电脑无法打开，可以找大容量的linux服务器，配置对应启动的jvm 内存后可以参考下面的步骤

## 1、下载linux版本的mat
```bash
wget http://eclipse.stu.edu.tw/mat/1.9.0/rcp/MemoryAnalyzer-1.9.0.20190605-linux.gtk.x86_64.zip
```
## 2、解压zip包
```
unzip MemoryAnalyzer-1.9.0.20190605-linux.gtk.x86_64.zip
```
## 3、修改linux mat的堆内存大小（看自己下载的堆的大小，默认mat的堆支持1g）
```bash
vi MemoryAnalyzer.ini
```
```ini
-startup
plugins/org.eclipse.equinox.launcher_1.5.0.v20180512-1130.jar
--launcher.library
plugins/org.eclipse.equinox.launcher.gtk.linux.x86_64_1.1.700.v20180518-1200
-vmargs
-Xmx10240m
```
## 4、执行分析脚本
```bash
./ParseHeapDump.sh [hprof文件] org.eclipse.mat.api:suspects org.eclipse.mat.api:overview org.eclipse.mat.api:top_components
```
 
### 可能因为 jdk 版本不一致导致启动失败，可以调整 jdk 为1.8.*
```bash
export JAVA_HOME=/opt/soft/jdk/jdk1.8.0_66/
export PATH=$JAVA_HOME/bin:$PATH
"$(dirname -- "$0")"/MemoryAnalyzer -consolelog -application org.eclipse.mat.api.parse "$@"
```
## 5、等待分析结果
![](/posts/dump/analyse_result.png)

## 6、查看分析结果
### 6.1 大对象
![](/posts/dump/problem.png)
### 6.2 大对象分析
![](/posts/dump/big_object.png)
### 6.3 线程堆栈信息
![](/posts/dump/jvm_stack.png)

## 7、上面很明显的线程内存泄露，结合实际场景修复吧