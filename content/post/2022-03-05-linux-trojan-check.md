---
title: "Linux木马排查与入侵实战案例"
date: 2022-03-05T08:00:00+08:00
tags: [ "linux", "安全", "木马" ]
description: "Linux 服务器入侵后的木马排查清单：日志、用户、进程、文件完整性、网络、计划任务、后门与 rootkit 检查，附三次真实入侵处置实战"
categories: [ "linux", "安全" ]
toc: true
---

## 前言

在日常繁琐的运维工作中，对 linux 服务器进行安全检查是一个非常重要的环节。这篇整理如何检查 linux 系统是否遭受了入侵，以及几次真实的入侵处置过程。与[应急响应手册](/post/2026-09-27-linux-emergency-response/)配合食用更佳。

## 一、是否入侵检查（排查清单）

**1）检查系统日志**

```bash
# 检查系统错误登录日志，统计IP重试次数（last 查看系统登录日志，比如系统被 reboot 或登录情况）
last
```

**2）检查系统用户**

```bash
cat /etc/passwd                        # 查看是否有异常的系统用户
grep "0" /etc/passwd                   # 查看是否产生了新用户，UID和GID为0的用户
ls -l /etc/passwd                      # 查看 passwd 的修改时间，判断是否被悄悄添加用户
awk -F: '$3==0 {print $1}' /etc/passwd      # 查看是否存在特权用户
awk -F: 'length($2)==0 {print $1}' /etc/shadow   # 查看是否存在空口令账户
```

**3）检查异常进程**

```bash
ps -ef                                 # 注意UID为0的进程
lsof -p pid                            # 查看该进程所打开的端口和文件

# 检查隐藏进程
ps -ef | awk '{print $3}' | sort -n | uniq > 1
ls /proc | sort -n | uniq > 2
diff 1 2
```

**4）检查异常系统文件**

```bash
find / -uid 0 -perm -4000 -print       # 查找SUID程序
find / -size +10000k -print            # 查找超大文件
find / -name "…" -print                # 常见伪装名
find / -name ".." -print
find / -name "." -print
find / -name " " -print                # 空格文件名
```

**5）检查系统文件完整性**

```bash
rpm -qf /bin/ls
rpm -qf /bin/login
md5sum -b 文件名
md5sum -t 文件名
```

**6）检查RPM的完整性**

```bash
rpm -Va    # 注意相关的 /sbin /bin /usr/sbin /usr/bin
```

输出格式说明：S=文件大小不同；M=权限不同；5=MD5校验不同；D=设备号不匹配；L=readLink路径不匹配；U=用户归属不同；G=组归属不同；T=修改时间不同。

**7）检查网络**

```bash
ip link | grep PROMISC    # 正常网卡不该在 promisc 模式，可能存在 sniffer
lsof -i
netstat -nap              # 查看不正常打开的TCP/UDP端口
arp -a
```

**8）检查系统计划任务**

```bash
crontab -u root -l
cat /etc/crontab
ls /etc/cron.*
```

**9）检查系统后门**

```bash
cat /etc/crontab
ls /var/spool/cron/
cat /etc/rc.d/rc.local
ls /etc/rc.d
ls /etc/rc3.d
```

**10）检查系统服务**

```bash
chkconfig --list
rpcinfo -p    # 查看RPC服务
```

**11）检查rootkit**

```bash
rkhunter -c
chkrootkit -q
```

## 二、Linux系统被入侵/中毒的表象

常见的中毒表现在以下三个方面：

**1）服务器出去的带宽跑高**。服务器中毒后被别人利用，常见的是拿去当肉鸡攻击别人，或者外传数据。如果服务器出流量跑得很高，肯定有异常，需要及时检查。

**2）系统里产生多余的不明用户**。中毒或被入侵后会产生一些不明用户或者登录日志。

**3）开机启动不明服务、crond 里有来历不明的任务**。木马会随系统启动而启动，检查 /etc/rc.local 和 `crontab -l`。

## 三、实战案例一：一次中毒的完整处置

工作中碰到系统经常卡、有时远程连不上，检查发现不明系统进程，初步判断中毒：

1. 监控里检查这台服务器的带宽，发现**出方向带宽跑很高**，导致远程连接卡甚至连不上
2. 远程进入系统，`ps -aux` 查到不明进程，立刻 kill 掉
3. 检查开机启动项：

    ```bash
    chkconfig --list | grep 3:on    # 启动级别3的启动项
    more /etc/rc.local              # 发现被添加了很多未知项，注释掉
    ```

4. 还是有些卡，检查计划任务：

    ```bash
    crontab -l    # 看到很多来历不明的行，内容和 /etc/rc.local 差不多
    ```

    备份 /var/spool/cron/root 后删除 crontab 内容，停止 crond 并 `chkconfig crond off` 禁用开机启动

5. 检查登录日志（`last`），发现除 root 外还有其它用户登录过；检查 /etc/passwd 发现不明用户，`usermod -L xxx` 禁用并更新系统密码

**禁用/锁定用户登录的几种方法**：

```bash
usermod -L username    # 锁定用户
usermod -U username    # 解锁
passwd -l username     # 锁定用户
passwd -u username     # 解锁
# 或修改用户的 shell 为 /sbin/nologin（/etc/passwd文件里修改）
# 或在 /etc/ 下创建空文件 nologin，锁定除 root 之外的全部用户
```

## 四、实战案例二：webshell 反弹 shell 的处置

1. `top` 发现一个 python 程序占用了 95% 的 CPU
2. `ps -ef | grep python` 发现：

    ```txt
    python -c import pty;pty.spawn("/bin/sh")
    ```

    这是通过 webshell 反弹 shell 后获取真正的 tty shell 进行渗透，kill 掉这个进程

3. 发现 /var/spool/cron 下设置了 nobody 的定时任务，内容就是上面获取 getshell 的渗透命令，果断删除
4. `ss -a` 发现一个可疑 IP 及其进程，在 iptables 里禁止该 IP 的所有请求：

    ```bash
    iptables -I INPUT -s x.x.x.x -j DROP
    ```

## 五、实战案例三：命令被替换的 rootkit 入侵

一台服务器已启动 80 端口的 nginx，但执行 `lsof -i:80` 或 `ps -ef` 后**没有任何信息输出**！怀疑 ps 命令被人动了手脚：

```bash
which ps           # /bin/ps
ls -l /bin/ps
stat /bin/ps       # 发现 ps 命令的二进制文件在近期被改动过
```

解决办法：拷贝别的机器上的 /bin/ps 二进制文件覆盖本机的这个文件。

## 六、实战案例四：rootkit 用户态病毒的完整排查

某天发现 IDC 机房一台测试服务器流量异常，几乎占满机房总带宽：

1. `ps` 和 `top` 发现两个陌生名称的程序（如 mei34hu）占用了大部分 CPU——果断 kill，流量明显下降，但**不一会儿又恢复**了
2. 将这台测试机的外网关闭，远程通过跳板机内网登录
3. `ls /proc/进程号/exe` 查看陌生程序路径，再次 kill 后又生成新的进程名，路径在 PATH 变量的目录中随机变换（/bin、/sbin、/usr/bin）——还有后台主控程序在作怪
4. 查看 /bin、/sbin、/usr/bin 等目录下以 `.` 开头的隐藏文件，发现不少，且部分程序移除后会自动生成——还没找到主控程序
5. 用 strace 跟踪陌生程序：

    ```bash
    strace /bin/mei34hu
    ```

    结果程序居然**自杀**了（把自己进程文件干掉了）！再用 netstat 查不到任何对外网络连接，开始怀疑命令被修改过。`stat` 查看 ps、ls、netstat、pstree 等，发现修改时间都在最近 3 天内——传说中的 **rootkit 用户态病毒**！（这台机器装完系统后设置了弱口令密码，放到公网被人入侵）

6. 删除近 3 天修改过的程序文件并重启：

    ```bash
    find /bin -mtime -3 -type f | xargs rm -f
    find /usr/bin -mtime -3 -type f | xargs rm -f
    find /usr/sbin -mtime -3 -type f | xargs rm -f
    find /sbin -mtime -3 -type f | xargs rm -f
    ```

    然而重启后这些程序又好端端地运行起来——被设置了开机自启动

7. 查看系统启动项：

    ```bash
    find /etc/rc.d/ -mtime -3 ! -type d
    ```

    果然都被设置了开机自启动。再来一次删除（连同 /etc/rc.d 下的启动项）并重启，CPU 使用率恢复正常

8. 检查是否创建了除 root 以外的管理员账号：

    ```bash
    awk -F":" '{if($3 == 0) print $1}' /etc/passwd
    ```

    只有 root 一个，系统用户正常。但**系统被感染 rootkit 后已经不可靠，唯一的办法就是重装系统**

9. 常用命令程序的修复思路：找出命令所在的 rpm 包，强制卸载后重新安装：

    ```bash
    rpm -qf /bin/ps
    rpm -qf /bin/ls
    rpm -qf /bin/netstat
    rpm -qf /usr/bin/pstree
    rpm -e --nodeps ......          # 强制卸载上面查出的包
    yum install -y procps coreutils net-tools psmisc
    ```

    除此之外还可以：结合 /var/log/messages、/var/log/secure 仔细检查；用 `chattr +ai` 将几个重要目录改为不可添加和修改后再杀进程重启；chkrootkit 之类的工具再查一遍

## 七、怎样确保 linux 系统安全

1. **密码不要太简单**。用户名默认 + 密码简单是最容易被入侵的，像 `1q2w3e4r5t` 这种密码在扫描软件的字典里是通用的，很容易被扫出来
2. **不要使用默认的远程端口**。扫描的人都是先扫端口再猜密码，大 IP 段里开放 22 端口的机器都是目标，改掉默认端口是一项有效措施
3. **使用安全策略保护开放的端口**。用 iptables 或配置 /etc/hosts.deny、/etc/hosts.allow 做白名单；对 /etc/passwd、/etc/group、/etc/sudoers、/etc/shadow 等用户信息文件加锁（`chattr +ai`）
4. **禁 ping**：

    ```bash
    echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_all
    ```

## 总结

木马排查的思路要清楚，排查手段要熟练。遇到问题不要慌，静下心来细查系统日志，按「进程 → 文件 → 启动项 → 计划任务 → 日志」的链条顺藤摸瓜，基本都能定位到入侵路径。
