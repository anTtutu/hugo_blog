---
title: "Win10下打包go工具增加icon"
date: 2020-12-26T00:29:47+08:00
tags: [ "Win10", "build" ]
description: "Win10下打包go工具增加icon"
categories: [ "Win10", "build" ]
toc: true
---

## 1、前言
go build默认产生的可执行文件没有图标icon，有时候挺丑的，想增加icon怎么办呢
![](/posts/icon/before.jpg)

## 2、方法1 - windres命令
怎么安装和使用minGW参考前一篇文章[Win10下新的gcc工具](/post/2020-12-05-win10_gcc_build_tools)

### 2.1、创建rc文件
以test.go举例, 假设打包文件名test.exe, ico文件名test.ico  
rc文件命名test.exe.rc

文件中输入
```txt
IDI_ICON1 ICON "test.ico"
```

### 2.2、执行windres命令创建syso文件
```golang
windres -o test.exe.syso test.exe.rc
```

### 2.3、执行go build
```golang
go build
```

## 3、方法2 - rsrc命令
需要先下载rsrc命令
```golang
go get github.com/akavel/rsrc
```

### 3.1、创建manifest文件
仍然以test.go举例，假设打包文件名test.exe，ico文件名test.ico  
manifest文件名test.exe.manifest

文件中输入
```xml
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
    <assemblyIdentity
    version="1.0.0.0"
    processorArchitecture="x86"
    name="controls"
    type="win32">
    </assemblyIdentity>

    <dependency>
        <dependentAssembly>
            <assemblyIdentity
            type="win32"
            name="Microsoft.Windows.Common-Controls"
            version="6.0.0.0"
            processorArchitecture="*"
            publicKeyToken="6595b64144ccf1df"
            language="*">
            </assemblyIdentity>
        </dependentAssembly>
    </dependency>
</assembly>
```

### 3.2、执行rsrc命令创建syso
```golang
rsrc -manifest test.exe.manifest -ico test.ico -o test.exe.syso
```

### 3.3、执行go build
```golang
go build
```
![](/posts/icon/result.jpg)

## 注：
测试发现，有的blog写的打包命令建议带参数：
```golang
go build -ldflags="-H windowsgui -w -s"
```
应该只有gui的程序才需要带，本文举例是非gui界面的，因此带了反而会出现无法正确运行。
![](/posts/icon/diff.jpg)
对比带了该参数比直接的go build打包出来的文件大小不一致，偏小很多，可能非gui的命令行程序不适合带这个参数。
![](/posts/icon/diff2.png)
比如用walk的gui go项目带了没问题。  
验证通过2、3步骤做了ico处理的，建议通过go build打包。

## 4、可以写打包脚本
创建build.bat
```bat
@echo off
Title build...                                              
Color 0A

REM 声明采用UTF-8编码
chcp 65001

:menu
echo =============================================
echo.
echo No.1-选择用minGW工具打包
echo.
echo No.2-选择用rsrc工具打包
echo.
echo =============================================

set /p user_input=请输入你的选择:

if %user_input% equ 1 goto 1

if %user_input% equ 2 goto 2

if %user_input% == '3' exit

pause

:: 1. minGW
:1
echo "请先安装好dev C++工具minGW"

echo windresing...
windres -o md5.exe.syso md5.exe.rc

echo building...
go build
goto end

:: 2.rsrc
:2
echo "需要先安装工具命令rsrc，命令：go get github.com/akavel/rsrc" 

echo rsrc manifesting...
rsrc -manifest md5.exe.manifest -o md5.exe.syso -ico md5.ico

echo building...
go build
goto end

:end
echo complete
```
