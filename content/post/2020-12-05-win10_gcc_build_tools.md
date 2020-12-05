---
title: "Win10下新的gcc工具"
date: 2020-12-05T00:29:47+08:00
tags: [ "Win10", "gcc" ]
description: "Win10下新的gcc工具"
categories: [ "Win10", "gcc" ]
toc: true
---

## 1、前言
偶尔碰到从github download的开源项目需要gcc编译，以前用cygwin，cygwin是仿真模拟器，如果不想过于折腾的话，可以用mingw或者wls ubuntu。

不过mingw更加简单和小巧，cygwin或者wls都还需要再需要apg-get或者yum安装一些包，mingw更加简单，解压即用。

## 2、下载
现在64位系统居多，mingw有个分支版本mingw-64，建议下载这个  
[去sourceforge下载](https://sourceforge.net/projects/mingw-w64/files/mingw-w64/mingw-w64-release/)  

![](/posts/mingw/mingw-64.jpg)

![](/posts/mingw/mingw-get.jpg)

也可以通过install安装  
[install下载](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win32/Personal%20Builds/mingw-builds/installer/mingw-w64-install.exe)

![](/posts/mingw/mingw-64-install.jpg)

下面对几个选项给出说明 
参数|说明 
|-|-|
Version|制定版本号，从4.9.1-8.1.0，按需选择，没有特殊要求就用最新版吧  
Architecture|跟操作系统有关，64位系统选择x86_64，32位系统选择i686  
Threads|设置线程标准可选posix或win32  
Exception|设置异常处理系统，x86_64可选为seh和sjlj，i686为dwarf和sjlj  
Build revision|构建版本号，选择最大即可  

下载压缩包的话，选择合适位置解压，将mingw64/bin加入环境变量即可

# 3、离线包下载
前面2种方式都是只安装工具，但是类库需要在线安装，如果下载偏慢或者网速不够好容易失败，比如我就失败好多次，结果只好选择离线包下载  
[离线包下载](https://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/8.1.0/threads-posix/seh/x86_64-8.1.0-release-posix-seh-rt_v6-rev0.7z/download)  
离线包可是7z格式，可以直接解压到比如D:\mingw-64目录下，然后配置环境变量  

![](/posts/mingw/offline_install.jpg)

配置环境变量：  
![](/posts/mingw/set_path_1.jpg)
![](/posts/mingw/set_path_2.jpg)

# 3、验证
添加环境变量后，打开CMD，执行gcc -v  
能看到类似信息即说明安装成功  
![](/posts/mingw/gcc_check.jpg)

# 4、测试下gcc编译
1、在D:\创建一个hello.c的文件，然后用文本工具打开，新增测试代码hello world
```C++
#include <stdio.h>

int main(int argc, char argv[])
{
    printf("hello world!\n");
    
    getchar();

    return 0;
}
```
![](/posts/mingw/code_hello_world.jpg)

2、然后执行编译命令
```bash
gcc hello.c -o hello.exe
```
-o参数是给编译结果定义自己的名称，
如下简短方式也可以编译，只是生成的编译记过是a.exe
```bash
gcc hello.c
```
![](/posts/mingw/gcc_buid.jpg)

3、查看编译结果
![](/posts/mingw/build_result.jpg)

4、双击hello.exe或a.exe
![](/posts/mingw/hello.jpg)