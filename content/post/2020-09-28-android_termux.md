---
title: "android下安装termux模拟器-超便携linux"
date: 2020-09-28T00:29:47+08:00
tags: [ "android", "termux" ]
description: "android下安装termux模拟器-超便携linux"
categories: [ "android", "termux" ]
toc: true
---

## 前言
临近2020年国庆8天长假，因需要安装信息安全管理软件，由自带mbp更换公司的matebook新笔记本，想着还是用android机配置一套服务器环境更加便携，便试试找下不需要root的android模拟器，没想到还真找到了。  

有2套方案：  

序号|App|备注
|-|-|-|
1|linux deploy|android下完美运行linux神器，需要root
2|termux|另外一个android下的linux模拟器神器，不需root

## 1、准备
android手机一部，建议用吃灰的手机，不需要太新也不需要太旧，建议android版本5.0或者以上，android版本7.0比较好。

分类|名称|说明|备注
|-|-|-|-|
手机|Huawei Honor V8|Android 7.0/EMUI5.0.1|手头的一台可以自用的测试机
笔记本|MBP|Macos 10.14.6|可选，windows笔记本也可以
SSH|iterm2|任意版本|ssh用，windows下用putty、xshell也可，怎么顺手怎么来
应用市场|Google Play Store<br>酷安|任意版本|下载termux和termux免费插件

## 2、安装
可以通过Google Play、F-Droid、酷安3个途径下载apk  
第一选择：Google Play，需要FQ  
第二选择：F-Droid，官网，不需要FQ  
第三选择：酷安，不需要FQ  

Termux官网和Github地址：  
[termux官网](https://termux.com/ "termux官网")  
[termux Github](https://github.com/termux/termux-app "termux Github")  

## 3、下载
Huawei手机之前的型号都是自带google服务框架的，前几年的手机不用担心去掉了服务框架，不过从被实体清单打压后的机型可能要安装，不过可以先进腾讯应用宝市场安装Google Play Store和Go谷歌安装器

[Go谷歌安装器下载地址](https://sj.qq.com/myapp/detail.htm?apkName=com.goplaycn.googleinstall "Go谷歌安装器下载地址")  
可以检测Google服务框架是否存在

[Google Play Store下载地址](https://sj.qq.com/myapp/detail.htm?apkName=com.android.vending "Google Play下载地址")
Google Play Store官方的apk，无需FQ下载 -- 下架了选酷安

[Google Play Store的termux下载地址](https://play.google.com/store/apps/details?id=com.termux "Google Play的termux下载地址")  
开始需要FQ，但是版本进度和插件比较清晰

[F-Droid的termux下载地址](https://f-droid.org/packages/com.termux/ "F-Droid的termux下载地址")  
官方下载，需要通过apk方式安装

[酷安的termux下载地址](https://www.coolapk.com/apk/com.termux "酷安的termux下载地址")  
版本进度比Google Play Store稍慢

## 4、安装APK
这里没什么难度  
![](/posts/termux/app_list.JPG)
![](/posts/termux/apk_right.JPG)

APP介绍  

APP|介绍|备注
|-|-|-|
andronix|linux发行版安装工具|需要非常好的网速，发行版本安装包偏大，个人是用不上那么多的功能，未选择
AnyConnect|Cisco的VPN客户端|公司的VPN，远程办公用

Termux是一个Android下一个高级的终端模拟器,开源且不需要root，支持apt管理软件包，十分方便安装软件包，完美支持Python、PHP、Ruby、Nodejs、MySQL等。随着智能设备的普及和性能的不断提升，如今的手机、平板等的硬件标准已达到了初级桌面计算机的硬件标准，用心去打造DIY的话完全可以把手机变成一个强大的极客工具。

第一次启动Termux的时候需要从远程服务器加载数据，然而可能会遇到这种问题：

```bash
Ubable to install
Termux was unable to install the bootstrap packages.
Check your network connection and try again.
```
解决方式：  
1、FQ  
2、Wifi和4G来回切换试试

## 5、简单上手
Termux除了支持apt命令外，还在此基础上封装了pkg命令，pkg命令向下兼容apt命令。apt命令大家应该都比较熟悉了，这里直接简单的介绍下pkg命令:
```bash
pkg search <query>              # 搜索包
pkg install <package>           # 安装包
pkg uninstall <package>         # 卸载包
pkg reinstall <package>         # 重新安装包
pkg update                      # 更新源
pkg upgrade                     # 升级软件包
pkg list-all                    # 列出可供安装的所有包
pkg list-installed              # 列出已经安装的包
pkg show <package>              # 显示某个包的详细信息
pkg files <package>             # 显示某个包的相关文件夹路径
```

除了通过上述的pkg命令安装软件以外，如果我们有.deb软件包文件，也可以使用dpkg进行安装。
```bash
dpkg -i ./package.de         # 安装 deb 包
dpkg --remove [package name] # 卸载软件包
dpkg -l                      # 查看已安装的包
man dpkg                     # 查看详细文档
```

## 6、安装个人需要的软件包
Package|介绍|安装命令|备注
|-|-|-|-|
vim|vim|pkg install vim|vi
ssh|ssh|pkg install openssh|ssh
curl|curl|pkg install curl|curl
wget|wget|pkg install wget|wget
git|git|pkg install git|git
subversion|svn|pkg install subversion|svn
clang|clang|pkg install clang|clang
ecj|eclipse java|pkg install ecj|eclipse java
man|帮助|pkg install man|帮助
python3|推荐py3|pkg install python|py2使用场景不多了，需要安装的话pkg install python2，不过pip命令容易跟py3混淆，建议需要配置下
golang|go语言|pkg install go|个人学习的go语言
nodejs|推荐nodejs-lts|pkg install nodejs-lts|nodejs版本会提示错误无法安装下去
MariaDB(mysql)|mysql|pkg install mariadb|mysql
redis|redis|pkg install redis|redis
mongodb|mongodb|无法顺利安装，需要使用其他开发者改造的安装文件，[参考](https://github.com/its-pointless/gcc_termux)|pkg install curl<br>curl -LO https://its-pointless.github.io/setup-pointless-repo.sh<br>chmod 700 setup-pointless-repo.sh<br>bash setup-pointless-repo.sh<br>pkg update
nginx|nginx|pkg install nginx|nginx
hugo|hugo|pkg install hugo|golang static blog, hugo
asciinema|asciinema|pip install asciinema|command line player，python

验证
```bash
npm -V
node -V
python -V
ecj -version
go version
curl www.baidu.com
wget 
git --version
nginx -v
hugo version
asciinema play https://asciinema.org/a/difqlgx86ym6emrmd8u62yqu8
```
如果assiinema执行播放报错，可能是python的lolcat module不存在，不过经过阅读源码发现，去掉这个字符集判断也可以的。  
于是  
```bash
vi /data/data/com.termux/files/usr/lib/python3.8/site-packages/asciinema/__main__.py
```
```python
def main():
#if locale.nl_langinfo...
# print("asciinema...
# sys.exit(1)
```
把报错的字符集检查判断注释即可，因为termux字符集就是UTF-8的，查看字符集命令
```bash
echo $LANG
en_US.UTF-8
```
![](/posts/termux/sdk_list.JPG)

## 7、环境安装完毕后，开始通过ssh控制termux
毕竟电脑端用键盘打字方便很多
```bash
passwd   #给当前用户设置密码，2次输入相同密码后
ifconfig #提取当前wifi的ip地址，比如192.168.*.*, 保证电脑和手机是同一个wifi即可
whoami   #提取当前termux的用户，一般格式u0_*
sshd     #启动ssh服务，也可以设置开机启动，个人先简单操作
```
![](/posts/termux/ifconfig.JPG)
电脑端操作ssh，可以用密码也可以配置ssh证书登录，个人先用密码方式
```bash
ssh $(whoami)@192.168.*.* -p 8022 #ssh termux账号@termux IP，8022端口，不是标准的22端口
```
连上后，比手机的键盘打字方便多了
![](/posts/termux/ssh.png)

## 8、开始用ssh操作termux的一些服务
### 8.1 设置mysql的root帐号密码
```bash
# 登录Termux用户，
mysql -u $(whoami)
```
```sql
-- 修改root密码的SQL语句
use mysql;
set password for 'root'@'localhost' = password('你设置的密码');

-- 刷新权限并退出
flush privileges;
exit;
```

### 8.2 启停mysql
```bash
# 启动mysql
mysqld
# 优雅的停
kill -QUIT mysql_PID
```

### 8.3 启停redis
```bash
# 启动redis服务
redis-server
# 登录redis
redis-cli
# 优雅的停
kill -QUIT redis_PID
```

### 8.4 启动nginx
```bash
# 启动nginx
nginx 
# 优雅的停
kill -QUIT nginx_PID
```

### 8.5 启动mongodb
需要配置好启动配置文件，否则可能提示无法创建db
```yaml
systemLog:
    destination: file
    logAppend: true
    path: mongodb/logs/mongodb.log

storage:
    dbPath: mongodb/db
    journal:
        enabled: true

processManagement:
    fork: true
```
```bash
# 启动mongodb
mongod -f ./mongodb/conf/mongodb/conf
# 优雅的停
kill -QUIT mongodb_PID
```
mysql
![](/posts/termux/mysql_server.JPG)
![](/posts/termux/mysql_databases.JPG)
redis
![](/posts/termux/redis.JPG)
mongodb
![](/posts/termux/mongodb.png)

## 9、基本功能完成，还有很多进阶设置和玩法待开发和更新进来(未完待续)
未完待续，待补充进阶设置和玩法