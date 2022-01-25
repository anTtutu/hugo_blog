---
title: mysql低版本源代码安装
date: 2018-08-14T21:46:20+08:00
tags: [ "mysql", "linux" ] 
description: "mysql低版本源代码安装"
categories: [ "mysql", "linux" ]
toc: true
---

## 前言
如果不使用最新版本的mysql，但是低版本的mysql官方不提供编译好的安装包，只能自己编译安装了。以下步骤和参数针对5.6、5.7生效，新版本有变动请阅读官方文档介绍。

## 1、环境检测
使用下面的命令检查是否安装有MySQL Server
```bash
rpm -qa | grep mysql
有的话通过下面的命令来卸载掉
rpm -e mysql   //普通删除模式
rpm -e --nodeps mysql    // 强力删除模式，如果使用上面命令删除时，提示有依赖的其它文件，则用该命令可以对其进行强力删除
```

## 2、下载源码
```bash
wget http://cdn.mysql.com/Downloads/MySQL-5.6/mysql-5.6.32.tar.gz
tar xvf mysql-5.6.32.tar.gz
cd mysql-5.6.32
```
或者web下载  
历史各版本下载：(https://downloads.mysql.com/archives/community/)  
Source Code -> Generic Linux 通用tar包

## 3、安装编译环境
安装编译代码需要的包
```bash
yum -y install make gcc-c++ cmake bison-devel ncurses-devel
```

## 4、开始编译
编译安装，取决服务器性能，时间会比较久，请耐心等待
```bash
cmake \
-DCMAKE_INSTALL_PREFIX=/data/mysql \
-DMYSQL_DATADIR=/data/mysql/data \
-DSYSCONFDIR=/data/mysql \
-DWITH_MYISAM_STORAGE_ENGINE=1 \
-DWITH_INNOBASE_STORAGE_ENGINE=1 \
-DWITH_MEMORY_STORAGE_ENGINE=1 \
-DWITH_READLINE=1 \
-DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock \
-DMYSQL_TCP_PORT=3306 \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DEXTRA_CHARSETS=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci
 
make && make install
```

## 5、创建用户
设置权限
使用下面的命令查看是否有mysql用户及用户组
```
cat /etc/passwd 查看用户列表
cat /etc/group  查看用户组列表
```
如果没有就创建
```
groupadd mysql
useradd -g mysql mysql
```
修改/usr/local/mysql权限
```
chown -R mysql:mysql /data/mysql/
```

## 6、初始化配置
进入安装路径
```bash
cd /data/mysql/
```
进入安装路径，执行初始化配置脚本，创建系统自带的数据库和表
```
scripts/mysql_install_db --basedir=/data/mysql --datadir=/data/mysql/data --user=mysql
```

### 6.1 配置my.cnf
打开my.cnf后，在文件内的[mysqld]下增加如下两行设置:
```bash
character_set_server=utf8mb4
init_connect='SET NAMES utf8mb4'
```
注：在启动MySQL服务时，会按照一定次序搜索my.cnf，先在/etc目录下找，找不到则会搜索"$basedir/my.cnf"，在本例中就是 /usr/local/mysql/my.cnf，这是新版MySQL的配置文件的默认位置

### 6.2 启动MySQL
添加服务，拷贝服务脚本到init.d目录，并设置开机启动
```bash
cp support-files/mysql.server /etc/init.d/mysql
chkconfig mysql on
service mysql start  --启动MySQL
```
### 6.3 配置环境变量
MySQL启动成功后，root默认没有密码，我们需要设置root密码。  
设置之前，我们需要先设置PATH，要不不能直接调用mysql  
修改/etc/profile文件，在文件末尾添加
```bash
PATH=/data/mysql/bin:$PATH
export PATH
关闭文件，运行下面的命令，让配置立即生效
source /etc/profile
```
现在，我们可以在终端内直接输入mysql进入，mysql的环境了  
执行下面的命令修改root密码
```bash
mysql -uroot 
mysql> SET PASSWORD = PASSWORD('**********');
```
若要设置root用户可以远程访问，执行
```bash
mysql> GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '**********' WITH GRANT OPTION;
```
红色的password为远程访问时，root用户的密码，可以和本地不同。
### 6.4 配置防火墙
防火墙的3306端口默认没有开启，若要远程访问，需要开启这个端口
```bash
打开/etc/sysconfig/iptables
在最后一行添加：
-A INPUT -m state --state NEW -m tcp -p -dport 3306 -j ACCEPT
```
然后保存，并关闭该文件，在终端内运行下面的命令，刷新防火墙配置：
```bash
service iptables restart
```
 
OK，一切配置完毕，你可以访问你的MySQL了~