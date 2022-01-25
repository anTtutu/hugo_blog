---
title: "Mac下远程运行Linux的GUI程序"
date: 2020-09-17T00:29:47+08:00
tags: [ "mac", "linux" ]
description: "Mac下远程运行Linux的GUI程序"
categories: [ "mac", "linux" ]
toc: true
---

## 1、前言
2019年嫌公司发的E480定制16G太卡更换自己的MacBookPro2015后，一直也没碰到linux下的GUI程序，前阵子有程序jvm内存泄露，生成的dump文件有5G，用自己的mbp解析内存不足，就想到以前整理的IBM的dump分析工具jca458，然后盲目的试了试，修改了DISPLAY的ip，然后启动报错...  

看来windows下的X11脚本连接Xmanager行不通了，得另外想法子

```java
[root@javaMemoryDumpAnalyzer]# ./memory.sh  
No protocol specified
No protocol specified
Exception occurred in main() of IBM Thread and Monitor Dump Analyzer
java.awt.AWTError: Can't connect to X11 window server using '*.*.*.*:0.0' as the value of the DISPLAY variable.
        at sun.awt.X11GraphicsEnvironment.initDisplay(Native Method)
        at sun.awt.X11GraphicsEnvironment.access$200(X11GraphicsEnvironment.java:65)
        at sun.awt.X11GraphicsEnvironment$1.run(X11GraphicsEnvironment.java:115)
        at java.security.AccessController.doPrivileged(Native Method)
        at sun.awt.X11GraphicsEnvironment.<clinit>(X11GraphicsEnvironment.java:74)
        at java.lang.Class.forName0(Native Method)
        at java.lang.Class.forName(Class.java:264)
        at java.awt.GraphicsEnvironment.createGE(GraphicsEnvironment.java:103)
        at java.awt.GraphicsEnvironment.getLocalGraphicsEnvironment(GraphicsEnvironment.java:82)
        at java.awt.Window.initGC(Window.java:475)
        at java.awt.Window.init(Window.java:495)
        at java.awt.Window.<init>(Window.java:537)
        at java.awt.Frame.<init>(Frame.java:420)
        at java.awt.Frame.<init>(Frame.java:385)
        at javax.swing.JFrame.<init>(JFrame.java:189)
        at com.ibm.jinwoo.thread.Analyzer.<init>(Analyzer.java:489)
        at com.ibm.jinwoo.thread.Analyzer.main(Analyzer.java:7029)
```

## 2、查询了下报错信息
MacOS从v10.5附带了X11的升级版本XQuartz，但是从10.7后又不附带了，需要自己额外安装  
苹果官网介绍X11：(https://support.apple.com/zh-cn/HT201341)  
XQuartz下载地址：(www.xquartz.org)

## 3、Xwindows介绍
XWindow系统最初是由MIT在1984年开发的，目的是为了给Unix以及类Unix操作系统一个通用性强且硬件无关的GUI接口。

目前常见的XWindow系统都是基于11版本进行改良的，所以统称为X11。

目前像KDE、GNOME这些所谓的linux GUI其实就是Xwindows的一种。

## 4、在Mac安装XQuartz
下载步骤2中的XQuartz,然后按照提示一路安装完成
![](/posts/x11/xquartz.jpg)

## 5、可能服务器上需要安装xauth(可选，参考验证后再决策)
```bash
[root@javaMemoryDumpAnalyzer]# yum search xauth
Loaded plugins: fastestmirror, refresh-packagekit, security
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.ustc.edu.cn
 * updates: mirrors.ustc.edu.cn
========================================================================= N/S Matched: xauth =========================================================================
xorg-x11-xauth.x86_64 : X.Org X11 X authority utilities

  Name and summary matches only, use "search all" for everything.
```

如果没安装会提示
```bash
[root@javaMemoryDumpAnalyzer]# yum search xauth
Loaded plugins: fastestmirror, refresh-packagekit, security
Loading mirror speeds from cached hostfile
 * base: mirrors.163.com
 * extras: mirrors.ustc.edu.cn
 * updates: mirrors.ustc.edu.cn
Warning: No matches found for: xauth
No Matches found
```

安装命令
```bash
yum install xauth
```

## 6、修改服务器上的配置
打开服务器上的/etc/ssh/sshd_config

然后将X11Forwarding以及X11UseLocalhost这两行修改为：
```bash
X11Forwarding yes
X11UseLocalhost no
```
另外如果服务器关闭了IPv6功能，那么还要将AddressFamily这一行修改为：
```bash
AddressFamily inet
```

## 7、在服务器上安装X11小工具（可选步骤，用于验证X11是否成功）
这步是为了验证X11是否配置成功并生效
在服务器上执行
```bash
yum install xorg-x11-apps
```

## 8、在Mac端连接服务器并启用X11转发功能
打开步骤4安装完成的XQuartz，然后选择XQuartz菜单的『应用程序』 - 『终端』
![](/posts/x11/run.jpg)

输入ssh连接命令
```bash
ssh -Y <用户名>@<服务器ip/域名>
```
连接后，如果终端窗口没有出现以下内容表示X11转发开启成功（这步我没验证出现，是查阅资料说有这个提醒，我的实测没转发成功也没这个提示）
```bash
X11 forwarding request failed on channel 0
```

## 9、测试运行X11验证小程序（可选）
步骤7中测试X11小程序派上用场了，虽然是可选步骤，为了保险，还是可以安装下一步一步测试
```bash
xeyes
xclock
```
运行之后稍等，Mac这边会弹出2个窗口的小程序，分别是一个会随光标转动的眼睛和一个会走动的时钟，如下图这样展示就表示成功了。
![](/posts/x11/eyes.jpg)![](/posts/x11/clock.jpg)

## 10、原理解析
当ssh连接简历完成并成功开启X11转发后，服务器默认会监听127.0.0.1(localhost)的6010端口

可以在服务器上查看DISPLAY环境变量
```bash
[root@javaMemoryDumpAnalyzer ~]# echo $DISPLAY
localhost:10.0
```

不过随着开的XQuaztr终端窗口通过ssh连接服务器越多，DISPLAY的值会递增，11.0、12.0...，第一个终端窗口才是10.0
```
DISPLAY环境变量中的值：  
localhost：表示X服务器的地址。  
10：表示端口自6000的偏移量，10即表示6010，开启了第二个XQuartz终端窗口并ssh连接服务器后，在这第二个终端窗口查看DISPLAY变量会显示11.0，表示6011，12.0表示6012，依次递增1。  
0：表示在X服务器上的第0个显示器上输出。
```
再继续在服务器上打开X应用，X应用就会和localhost:6010建立连接，然后服务器就会和客户端（Mac）建立起一条ssh隧道，对接客户端上的X服务器，从而实现服务器的X程序在客户端上显示的目的。

而Mac上的XQuartz可以看成是一个带窗口管理功能的X服务器。

## 11、结束语
最后自己需要的IBM jca分析工具也启动成功了。类似的linux GUI工具还有很多，如：Oracle家的linux安装软件，linux下的Wireshark，赛门铁克家的VCS等
![](/posts/x11/jca.jpg)

注意：  
X11转发对网络传输要求较高，建议在服务器与客户端之间网络稳定的情况下使用，否则网络不畅可能出现窗口卡顿或显示不全的情况  
一旦ssh掉线或者关闭XQuartz终端窗口，那么所有的X11应用也将被强制退出