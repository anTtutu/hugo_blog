---
title: "挖矿病毒2-分析和排查思路"
date: 2021-01-28T00:29:47+08:00
tags: [ "mine", "virus", "linux", "check" ]
description: "挖矿病毒2-分析和排查思路"
categories: [ "mine", "virus", "linux", "check" ]
toc: true
---

## 1、前言
1月23日晚上22点附近，公司群收到管理员说阿里云报了挖矿病毒的警告  
因此本人手里处理过2次挖矿病毒，针对挖矿病毒的杀毒和溯源，个人整理下心得，也有一部分思路来源网络整理

## 2、分析
### 2.1、top查看异常进程和占用率
![](/posts/virus/top2.png)
发现一个叫sh的进程名几乎占用全部的cpu资源

### 2.2、根据pid查找挖矿病毒的目录
当然用其他方法也可以找出，这里是当挖矿病毒正在运行时这么查找更加容易
![](/posts/virus/proc.png)
找到挖矿病毒的主体文件所在目录了/tmp/admin/sh

不过通常病毒文件会用隐藏目录，因此进入/tmp后需要用ls -lart查看隐藏目录  
最后锁定挖矿病毒主题文件.sh，其他文件经过分析，属于创建的脚本，用于给挖矿病毒主题创造有利的环境  
![](/posts/virus/dir.png)
大多数厉害的挖矿病毒是不会留下脚本的，需要自己根据蛛丝马迹找，能找到脚本可以把修改的地方针对性的还原，没法找到脚本就没法100%还原被修改的配置了

### 2.3、拿到挖矿主体二进制文件
查看是否加壳，用PEiD.0.95查看
![](/posts/virus/PE.png)
目前抓住的这个没有加壳，上一次的有加壳
![](/posts/virus/PE_info.png)
不过查看加壳与否我都没法脱壳的，只是用工具查看是否还有价值的信息，加了强壳的二进制查看的价值不大了

### 2.4、二进制查看
尝试是否能找到一点有用的信息  
比如这个没加壳的就容易看到一些有价值的信息
![](/posts/virus/byte.png)

### 2.5、有能力的可以上ida查看汇编信息
本人不才。。。只能看个图
不管是汇编视图还是二进制视图，因个人能力不足，无法查看更多有价值的信息
![](/posts/virus/ida1.png)
![](/posts/virus/ida2.png)

### 2.6、查找其他痕迹，查看感染来源
![](/posts/virus/last.png)

### 2.7、查看日志
![](/posts/virus/message.png)

### 2.8、病毒工具扫描
![](/posts/virus/warn1.png)
![](/posts/virus/warn2.png)

### 2.9、找守护挖矿的进程
可能是定时任务，也可能是其他二进制脚本
![](/posts/virus/kinsing.png)

## 3、排查思路
先找到病毒主体文件，然后需要有清晰的排查思路，结合搜集到的信息，可以去一些安全或者漏洞网站查询是否有人中招和排查经验，结合已经曝光的信息再加上自己的思路，可以事半功倍
### 3.1、top异常服务
有的挖矿病毒不会修改服务名，有的会隐藏成sysupdate、networkservice、sysguard这些看着像系统进程的名称，有的还会改成apache、php、mysql等服务名，需要凭职业经验分辨  
```bash
top
top > top.txt
vi top.txt
```

### 3.2、查看异常进程目录
```bash
ps -axuf | grep pid
ls /proc/{$pid}/
```

### 3.3、检查定时任务
```bash
/etc/crontab
/var/spool/cron/root
```
有修改的话需要还原

### 3.4、检查账号
```bash
/etc/passwd
/etc/shadow
```
有新增异常账号需要删除,需要留意特权账号uid=0的

### 3.5、检查sudo
```bash
/etc/sudoers
```
有新增的异常命令或者账号需要清理

### 3.6、检查环境变量
root账号的环境变量文件
```bash
~/.bash_profile
~/.bashrc
~/.cshrc
~/.tcshrc
~/.profile
/etc/profile
echo $PATH
```
有新增的话需要清理

其他业务账号的环境变量文件需要挨个检查下，因为已经发现本次是admin账号感染，这里就主要排查admin账号
```bash
/$HOME/.bash_profile
/$HOME/.bashrc
/$HOME/.cshrc
/$HOME/.tcshrc
/$HOME/.profile
echo $PATH
```

### 3.7、检查执行命令历史记录
大多数厉害的挖矿病毒会清理history -c，因此抱着试试看的想法还是检查下
```bash
.bash_history
```

如果服务器上还有其他服务，比如mysql redis mongodb等也需要排查下，比如勒索病毒就好这口
```bash
.rediscli_history
.mysql_history
.dbshell
```

### 3.8、检查新增的文件或命令
```bash
ls -lart /bin
ls -lart /sbin
ls -lart /usr/bin/
ls -lart /usr/sbin/
ls -lart /tmp
ls -lart /etc/init.d/
```

### 3.9、针对上一步可以采用修改日期排查法
```bash
# 查找777权限的文件
find . -name * -perm 777
# 按日期查找
find . -type f -newermt 2020-09-24 -ls
# 按时间范围查找
find . -newermt "2019-09-09 00:00:00" -not -newermt "2019-09-10 00:00:00+1"  
```

### 3.10、检查异常端口
```bash
netstat -antlp|more
arp -a
lsof -i
```

### 3.11、检查启动项
```bash
vi  /etc/inittab
id=3：initdefault  #系统开机后直接进入哪个运行级别

more /etc/rc.local 

# /etc/rc.d/rc[0~6].d 
ls -lart /etc/rc.d/rc0.d/
ls -lart /etc/rc.d/rc1.d/
ls -lart /etc/rc.d/rc2.d/
ls -lart /etc/rc.d/rc3.d/
ls -lart /etc/rc.d/rc4.d/
ls -lart /etc/rc.d/rc5.d/
ls -lart /etc/rc.d/rc6.d/

ls -lart /etc/rc.d/init.d/
```
清理异常启动项

### 3.12、检查计划任务
一般会隐藏
```bash
crontab -l
ls /etc/cron*
/etc/crontab
/var/spool/cron/root
/etc/anacrontab
/var/spool/anacron/*
```
清理和还原定时任务

### 3.13、异常目录
挖矿一般喜欢用.隐藏目录或者/tmp下
```bash
ls -lart /tmp | more
ls -lart ~ | more
ls -lart $HOME | more
```

### 3.14、检查安装的服务
```bash
chkconfig  --list | more
# 中文环境
chkconfig --list | grep "3:启用\|5:启用"
# 英文环境
chkconfig --list | grep "3:on\|5:on"
```

### 3.15、检查日志和分析

系统日志 日志默认存放位置：/var/log/

查看日志配置情况：more /etc/rsyslog.conf

日志文件|说明
-|-
/var/log/cron|记录了系统定时任务相关的日志
/var/log/cups|记录打印信息的日志
/var/log/dmesg|记录了系统在开机时内核自检的信息，也可以使用dmesg命令直接查看内核自检信息
/var/log/mailog|记录邮件信息
/var/log/message|记录系统重要信息的日志。这个日志文件中会记录Linux系统的绝大多数重要信息，如果系统出现问题时，首先要检查的就应该是这个日志文件
/var/log/btmp|记录错误登录日志，这个文件是二进制文件，不能直接vi查看，而要使用lastb命令查看
/var/log/lastlog|记录系统中所有用户最后一次登录时间的日志，这个文件是二进制文件，不能直接vi，而要使用lastlog命令查看
/var/log/wtmp|永久记录所有用户的登录、注销信息，同时记录系统的启动、重启、关机事件。同样这个文件也是一个二进制文件，不能直接vi，而需要使用last命令来查看
/var/log/utmp|记录当前已经登录的用户信息，这个文件会随着用户的登录和注销不断变化，只记录当前登录用户的信息。同样这个文件不能直接vi，而要使用w,who,users等命令来查询
/var/log/secure|记录验证和授权方面的信息，只要涉及账号和密码的程序都会记录，比如SSH登录，su切换用户，sudo授权，甚至添加用户和修改用户密码都会记录在这个日志文件中

### 3.16、其他有用的日志
apt-get安装日志
```bash
gedit /var/log/apt/term.log
cat /var/log/apt/history.log | more
/var/log/dpkg.log
```
yum安装日志和历史信息
```bash
# 查看yum安装软件日志的方法
/var/log/yum.log
# 查看yum使用的历史记录的方法
yum history info
```

### 3.17、检查安装的rpm包或者是否动过手脚
```bash
[root@docker-test ~]# rpm -Va
....L....  c /etc/pam.d/fingerprint-auth
....L....  c /etc/pam.d/password-auth
....L....  c /etc/pam.d/postlogin
....L....  c /etc/pam.d/smartcard-auth
....L....  c /etc/pam.d/system-auth
.M.......  g /var/log/dmesg
.M.......  g /var/log/dmesg.old
.......T.  c /etc/selinux/targeted/contexts/customizable_types
S.5....T.  c /etc/sysconfig/authconfig
.M.......  g /etc/pki/ca-trust/extracted/java/cacerts
.M.......  g /etc/pki/ca-trust/extracted/openssl/ca-bundle.trust.crt
.M.......  g /etc/pki/ca-trust/extracted/pem/email-ca-bundle.pem
.M.......  g /etc/pki/ca-trust/extracted/pem/objsign-ca-bundle.pem
.M.......  g /etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
.M.......  g /boot/initramfs-3.10.0-957.el7.x86_64.img
```
参数说明：
  
参数|含义
-|-
S|表示文件长度发生了变化
M|表示文件的访问权限或文件类型发生了变化
5|表示MD5校验和发生了变化
D|表示设备节点的属性发生了变化
L|表示文件的符号链接发生了变化
U|表示文件/子目录/设备节点的owner发生了变化
G|表示文件/子目录/设备节点的group发生了变化
T|表示文件最后一次的修改时间是发生了变化

### 3.18、检查命令的完整性
```bash
rpm -qf /bin/ls
```

### 3.19、检查hosts文件
```bash
/etc/hosts
```
清理异常的映射地址

### 3.20、检查.ssh文件
```bash
ls -lart ~/.ssh
ls -lart $HOME/.ssh
```
清理异常的pub key和ssh信任

### 3.21、检查防火墙-iptables
```bash
iptables --list
# centos
cat /etc/sysconfig/iptables-config
# ubuntu没有具体的规则文件，保存在内存中
```
清理异常的规则

### 3.22、检查别名
```bash
alias
```
清理异常的别名

## 4、加固
这里列举下部分比较容易的加固方式
### 4.1、条件提前做md5sum值
```bash
find / -user root -perm -2000 -print | xargs md5sum > 1.log
find / -user root -perm -4000 -print | xargs md5sum > 2.log
```
提前把关键文件的md5值搜集，后续可以比对

### 4.2、增加history的记录条数和详细信息
保存1W条history
```bash
HISTFILESIZE=2000 #设置保存历史命令的文件大小
HISTSIZE=10000    #保存历史命令条数
```
history记录详细信息
```bash
###### 加固历史命令显示 #########
USER_IP=`who -u am i 2>/dev/null | awk '{print $NF}' | sed -e 's/[()]//g'`
if [ "$USER_IP" = "" ]
then
USER_IP=`hostname`
fi
export HISTTIMEFORMAT="%F %T $USER_IP `whoami` "
shopt -s histappend
export PROMPT_COMMAND="history -a"
###### 加固历史命令显示 #########
```

## 5、挖矿病毒的参考
因为我发觉的2次挖矿病毒跟下面的部分表相很像但是又不完全一样，可能是变种或者改进了  
kinsing: https://blog.trendmicro.com.tw/?p=66511  
kinsing: https://blog.csdn.net/cfm_gavin/article/details/103803448  
sh: https://notes.daiyuhe.com/clear-linux-mining-virus/  
sh: https://blog.csdn.net/jabyn/article/details/111239735  
xr: https://www.freebuf.com/column/240100.html