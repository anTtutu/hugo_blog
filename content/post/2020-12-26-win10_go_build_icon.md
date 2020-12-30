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
测试发现，有些打包命令建议带参数：
```golang
go build -ldflags="-H windowsgui -w -s"
```
会导致打包出来的文件无法执行，可能是windowsgui这个导致的，而且对比比直接go build出来的文件偏小  
直接go build打包的文件也会带ico并正确执行。
