---
title: "go多版本管理工具"
date: 2022-11-10T00:29:47+08:00
tag : [ "go" ]
description: "go多版本管理工具"
categories: [ "go" ]
toc: true
---

## 前言
在本地新旧项目并行开发的过程中，你大概率会遇到一个令人头疼的问题，如何同时使用两个不同版本的 Golang Runtime 进行开发呢？

在容器和 CI 流行的当前时代下，我们似乎已经习惯了用 docker run
来切换各种语言的版本，来完成不同项目的开发，基础类型项目的兼容性测试。配合一些支持远程调试的工具，体验似乎也还行。

但是在运行效率和复杂度上，相比本地环境而言，总归是高了那么一丢丢。

## 1、基于 Golang 的版本管理工具：voidint/g
不需要同时运行多个版本
```bash
#仓库
https://github.com/voidint/g
```

### 1.1、安装
作者推荐安装方式
```bash
curl -sSL https://raw.githubusercontent.com/voidint/g/master/install.sh | bash
```
PS: 如果g有占用需要特殊设置  
```
这里如果你是 oh-my-zsh的用户，那么你还需要做一件事，就是解决全局的 g
 命令的冲突，解决的方式有两种，第一种是在你的 .zshrc
文件末尾添加 unalias

1、
echo "unalias g" >> ~/.zshrc # 可选。若其他程序（如'git'）使用了'g'作为别名。

2、
则是调整 ~/.oh-my-zsh/plugins/git/git.plugin.zsh
中关于 g
的注册，将其注释或删除掉：
# alias g='git'
```

### 1.2、环境变量配置
window下配置如下环境变量，安装或切换时cmd要用管理有权限打开
```bat
G_EXPERIMENTAL=true
G_HOME=D:\go\install\g
G_MIRROR=https://golang.google.cn/dl/
GOPATH=D:\go\project
GOROOT=%G_HOME%\go
PATH=%GOROOT%\bin;%GOPATH%\bin
```
 
Linux下的配置
```bash
export G_EXPERIMENTAL=true
export G_HOME=/root/go/g
export G_MIRROR=https://golang.google.cn/dl/
export GOPATH=/root/go/project
export GOROOT=$G_HOME/go
export PATH=$GOROOT/bin:$GOPATH/bin:$PATH
```

参考配置.zshrc
```bash
# 我的 g 的bin目录调整到了 .gvm ,所以你可能需要一些额外的调整
export PATH="${HOME}/.gvm/bin:$PATH"
export GOROOT="${HOME}/.g/go"
export PATH="${HOME}/.g/go/bin:$PATH"
export G_MIRROR=https://gomirrors.org/
```

### 1.3、命令
```bash
g ls                 查看本地已安装的版本
g ls-remote stable   查询当前可供安装stable的版本
g install 1.16.7     安装指定版本
g ls-remote          查询可供安装的所有版本
g use 1.16.3         切换指定版本
g uninstall 1.14.7   卸载已安装的版本
g clean              清理下载文件
```

## 2、基于 BASH 的版本管理工具：gvm

### 2.1、安装
```bash
curl -sSL https://github.com/moovweb/gvm/raw/master/binscripts/gvm-installer | bash
```
安装成功
```
Cloning from https://github.com/moovweb/gvm.git to /home/ubuntu/.gvm
No existing Go versions detected
Installed GVM v1.0.22

Please restart your terminal session or to get started right away run
 `source /home/ubuntu/.gvm/scripts/gvm`
```

### 2.2、环境变量配置
```bash
export GO111MODULE=on
export GOPROXY=https://goproxy.io,direct
# or
# exort GOPROXY="https://goproxy.cn"
export GOPATH="$HOME/go"
PATH="$GOPATH/bin:$PATH"


export GO_BINARY_BASE_URL=https://golang.google.cn/dl/
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
export GOROOT_BOOTSTRAP=$GOROOT
```
PS：如果无法完成下载，需要清理缓存目录
gvm install go1.17.3 -B
，但是发现一切正常，就是无法完成版本下载或者切换。

解决这个问题其实也很简单，就是清除掉这个缓存内容：
```bash
rm -rf ~/.gvm/archive/go1.17.3.darwin-amd64.tar.gz
# or
rm -rf ~/.gvm/archive/
```

### 2.3、切换版本
```bash
gvm install go1.17.3 -B
gvm use go1.17.3
```

## 3、来自官方的解决方案：golang/dl
官方的方案就更有趣了：https://github.com/golang/dl。官方维护了自 1.5 以来到 1.17 的所有版本的更新软件包

### 3.1、安装
```bash
go get golang.org/dl/go1.17.3
go1.17.3 download
```

PS:
https://github.com/golang/dl/blob/master/internal/version/version.go中的写死的逻辑会让你安装的目录在用户目录的 sdk
文件夹中，所以如果你使用这种方式，export
的路径需要做一个调整

## 4、其他
此外，还有两个有趣的项目  
借鉴自 Rustup 的: <https://github.com/owenthereal/goup>  
借鉴 rbenv 和 pyenv 的: <https://github.com/syndbg/goenv>
