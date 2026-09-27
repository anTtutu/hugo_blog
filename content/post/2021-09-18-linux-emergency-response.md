---
title: "Linux应急响应手册：从了解情况到输出报告的完整流程"
date: 2021-09-18T08:00:00+08:00
tags: [ "linux", "安全", "应急响应" ]
description: "Linux/Windows 应急响应完整流程手册：情况了解、风险遏制、异常连接、进程、账号、文件、启动项、计划任务、日志排查与工具清单"
categories: [ "linux", "安全" ]
toc: true
---

## 前言

整理一份应急响应的完整流程手册，覆盖从接到告警到输出报告的全过程，Linux 为主、Windows 为辅。整体流程为：了解情况 → 遏制传播 → 排查取证 → 恢复业务 → 跟踪总结。

注意：实际应急情况复杂，需根据现场灵活处置；操作前先征得授权；整个过程中不要被现场人员的描述误导，必要的话亲自检测，不要完全相信听来的东西。

## 1. 了解情况

1. **发生时间**：询问发现异常事件的具体时间，后续的操作要基于此时间点进行追踪分析。
2. **受影响系统类型**：
    - windows / linux
    - 财务系统 / OA系统 / 官网，系统重要性，是否可关停
    - 是否有弱口令，远程管理端口是否开放
    - 都开放了什么端口，有什么服务，服务是否存在风险性
3. **异常情况**：
    - 文件被加密
    - 设备无法正常启动
    - 勒索信息展示
    - CPU利用率过高
    - 网页挂马/黑链
    - 对外发送异常请求
    - 对外发送垃圾短信
4. **已有的处置措施**：
    - 之前是否存在此类问题
    - 是否在出现问题后配置了新的策略
    - 是否已有第三方进行了应急处理，处理结果是什么
5. **系统架构/网络拓扑**：是否能提供网络拓扑图。
6. **日志**：能否提供服务器日志、应用日志（重点 web 日志）、数据库日志。
7. **已有的安全设备**：终端杀软、防火墙、WAF、流量分析设备。
8. **基本的应急处置方案**：临时处置方案、勒索病毒处置预案、挖矿程序处置预案、网页挂马处置预案、DDOS处置预案、内部数据泄露处置预案等。
9. **应急报表**：包含下述应急方法、端口开放情况及各端口应用分析、处置建议。

## 2. 遏制传播风险

- 禁止被感染主机使用U盘、移动硬盘，如必须使用做好备份
- 禁用所有无线/有线网卡或直接拔网线
- 关闭相关端口
- 划分隔离网络区域
- 封存主机，相关数据备份
- 被感染主机应用服务下线、部分功能暂停
- 被感染主机相关账号降权、更改密码

**勒索病毒处置核心是止损**，这点非常重要：

1. 通过各类检查设备和资产发现，确定感染面
2. 通过网络访问控制设备或断网隔离感染区域，避免病毒扩散
3. 迅速启动杀毒或备份恢复措施，恢复受感染主机的业务，恢复生产（保障业务的关键动作）
4. 启动或部署监测设备，针对病毒感染进行全面监测，避免死灰复燃
5. 在生产得到恢复并无蔓延之后，收集所有相关的样本、日志等，开展技术分析，寻找感染源头，并制定整改计划

## 3. 已知高危漏洞排查

可与下面的步骤同时进行，扫描高危漏洞。但要注意扫描产生的大量日志不要影响漏洞排查。

## 4. 系统基本信息

- Windows：查看当前系统的补丁信息

    ```cmd
    systeminfo
    ```

- Linux：列出系统arp表（重点查看网关mac地址）、文件搜索

    ```bash
    arp -a
    find / -name ".asp"
    ```

**重点关注**：

1. 系统内是否有非法账户
2. 系统中是否含有异常服务程序
3. 系统是否存在部分文件被篡改，或发现有新的文件
4. 系统安全日志中的非正常登录情况
5. 网站日志中是否有非授权地址访问管理页面记录
6. 根据进程、连接等信息关联的程序，查看木马活动信息
7. 假如系统的命令（例如 netstat、ls 等）被替换，需要下载新的或者从其他未感染的主机拷贝新的命令再排查
8. 发现可疑可执行的木马文件，不要急于删除，先打包备份一份
9. 发现可疑的文本木马文件，使用文本工具对其内容进行分析，包括回连IP地址、加密方式、关键字（以便扩大整个目录的文件特征提取）等

## 5. 异常连接排查

- Windows：

    ```cmd
    netstat -ano | findstr ESTABLISH
    ```

    参数说明：`-a` 显示所有网络连接、路由表和网络接口信息；`-n` 以数字形式显示地址和端口号；`-o` 显示与每个连接相关的所属进程 ID；`-r` 显示路由表；`-s` 显示按协议统计信息。状态说明：LISTENING 侦听、ESTABLISHED 建立连接、CLOSE_WAIT 对方主动关闭连接或网络异常导致连接中断。

    ```cmd
    netstat -ano | findstr "port"    :: 查看端口对应的pid
    netstat -nb                       :: 显示创建每个连接或侦听端口时涉及的可执行程序（需管理员权限，查可疑程序非常有帮助）
    ```

- Linux：

    ```bash
    lsof -i
    lsof -i | grep -E "LISTEN|ESTABLISHED"
    netstat -antlp
    netstat -an
    ```

    参数说明：`-a` 显示所有连线中的 Socket；`-n` 直接使用 IP 地址而不通过域名服务器；`-t` 显示 TCP 连线状况；`-u` 显示 UDP 连线状况；`-p` 显示正在使用 Socket 的程序识别码和程序名称；`-s` 显示网络工作信息统计表。

## 6. 正在运行的异常进程排查

- Windows：
    1. 任务管理器查看异常进程
    2. 根据 netstat 定位出的异常进程 pid，再定位进程名：

        ```cmd
        tasklist | findstr 11223
        wmic process | findstr "xx.exe"       :: 获取进程的全路径
        wmic process where processid="2345" delete   :: 关闭某个进程
        ```

    3. `开始->运行->msinfo32->软件环境->正在运行任务` 查看进程详细信息（路径、进程ID、文件创建日期、启动时间等）

- Linux：
    1. 查找进程 pid：`netstat -antlp` 先找出可疑进程的端口，`lsof -i:port` 定位可疑进程 pid
    2. 通过 pid 查找文件：linux 每个进程都有一个对应的目录

        ```bash
        cd /proc/pid号
        ls -ail | grep exe      # exe 对应的就是该 pid 程序的路径
        ```

    3. 查看各进程占用的内存和 cpu：`top`
    4. 显示当前进程信息：`ps`；精确查找：`ps -ef | grep apache`
    5. 结束进程：`kill -9 pid`
    6. 查看进程树，查找异常进程是否有父进程：`pstree -p`
    7. 直接搜索异常进程名查找其位置：`find / -name 'xxx'`

## 7. 异常账号排查

- Windows：
    1. `lusrmgr.msc` 图形化查看账户和用户组
    2. `net user` 查看当前账户；`net user Guest` 查看某个账户详细信息
    3. `net localgroup administrators` 查看当前组
    4. `query user` 查看当前系统会话（是否有人使用远程终端登录）；`logoff ID` 踢出该用户

- Linux：
    1. `w`：查看 utmp 日志，获得当前正在登录账户的信息及地址
    2. `last | more`：获得系统前 N 次的登录记录（数据源 /var/log/wtmp、/var/log/btmp）
    3. `cat /etc/passwd`：查找攻击者创建或异常的用户。重点关注第 3、4 列的用户标识号和组标识号，以及倒数一、二列的用户主目录和命令解析程序。最后一列若为 nologin 表示不能登录，可结合 bash_history 排查。每行 7 个字段：`用户名:口令:用户标识号:组标识号:注释性描述:主目录:登录Shell`
    4. `cat /etc/shadow`：一般系统账号都没有密码，找**最长的那几个**，很可能就是黑客添加的后门账户。格式：`用户名:加密密码:密码最后一次修改日期:两次密码修改间隔:密码有效期:密码修改到期警告天数:密码过期后宽限天数:账号失效时间:保留`
    5. `lastlog` 查看所有账户最后一次登录时间
    6. `lastb` 显示用户登录错误的记录（检查暴力破解）
    7. `who` 查看当前登录用户（tty 本地登录、pts 远程登录）；`uptime` 查看登录时长与负载
    8. 禁用账户：`usermod -L user`（/etc/shadow 第二栏为 ! 开头即锁定）；解锁 `usermod -U user`
    9. 删除用户：`userdel -r user`（-r 完全删除，-f 强制）。若遇到删除后创建同名用户提示已存在，手动删除 /etc/passwd、/etc/shadow、/etc/group 里用户相关字段，以及 /home 对应目录和 /var/spool/mail 下的文件

## 8. 异常文件分析

- Windows：
    1. 右键文件属性查看文件时间
    2. `%UserProfile%\Recent` 分析最近使用的文档快捷方式
    3. 按文件时间属性排序定位可疑文件：黑客通过菜刀类工具改变的是**修改时间**，所以修改时间在创建时间之前的明显是可疑文件

- Linux：
    1. 分析文件日期：`stat xx.asp`
    2. 按修改时间查找文件：

        ```bash
        find ./ -mtime 0                        # 最近24小时内修改过的文件
        find ./ -mtime 1                        # 前48~24小时修改过的文件
        find ./ -mtime 0 -o -mtime 1 -o -mtime 2    # 逐天累加
        find ./ -mtime 0 -name "*.php"          # 24小时内被修改的 php 文件
        ```

    3. 敏感目录的文件分析（/tmp、/usr/bin、/usr/sbin 等）：`ls -alt /tmp/ | head -n 10` 按时间顺序查看
    4. 特殊权限文件查找：

        ```bash
        find / -name "*.jsp" -perm 777
        find / -perm 777 | more
        ```

    5. 隐藏文件（以 `.` 开头）：`ls -ar | grep "^\."`
    6. `chattr +i / -i` 添加/去除文件不可修改权限，`lsattr` 查看。设置了该参数的文件任何人删除都需要先去掉此权限（挖矿木马常用来锁自己的文件）
    7. `chattr +a / -a` 添加/去除只追加权限：只能追加不能删除，且不能通过编辑器追加
    8. 查看ssh相关目录有无可疑公钥：Redis（6379）未授权入侵可直接向目标主机导入公钥。目录：`/etc/ssh`、`~/.ssh/`

## 9. 启动项排查

- Windows：
    1. `msconfig` 查看开机启动有无异常文件
    2. 开机启动文件夹：

        ```txt
        C:\ProgramData\Microsoft\Windows\Start Menu\Programs\StartUp
        C:\Users\<用户名>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup
        ```

    3. 注册表启动项（开始->运行->regedit），特别注意以下三项，检查右侧是否有启动异常的项目，如有请删除：

        ```txt
        HKEY_CURRENT_USER\software\microsoft\windows\currentversion\run
        HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Run
        HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Runonce
        ```

- Linux：
    1. 查看开机启动项内容：`ls -alt /etc/init.d/`（/etc/init.d 是 /etc/rc.d/init.d 的软连接）
    2. 启动项文件：`more /etc/rc.local`；`ls -l /etc/rc.d/rc3.d/`；`ll /etc | grep rc`

## 10. 计划任务排查（定时任务）

- Windows：`taskschd.msc`（或 程序->附件->系统工具->任务计划程序）

- Linux：
    1. `crontab -l` 查看当前用户计划任务，是否有后门木马启动信息
    2. `crontab -u <-l, -r, -e>`：-u 指定用户、-l 列出、-r 删除、-e 编辑（编辑的是 /var/spool/cron 下对应用户的 cron 文件，也可以直接修改 /etc/crontab）
    3. `ls -al /etc/cron*`、`cat /etc/crontab` 查看 etc 目录任务计划相关文件
    4. 注意以 `.` 开头的隐藏计划任务文件，要用 `ls -al` 查看
    5. **入侵排查重点目录**：

        ```txt
        /var/spool/cron/*
        /etc/crontab
        /etc/cron.d/*
        /etc/cron.daily/*
        /etc/cron.hourly/*
        /etc/cron.monthly/*
        /etc/cron.weekly/
        /etc/anacrontab
        /var/spool/anacron/*
        ```

        小技巧：`more /etc/cron.daily/*` 查看目录下所有文件

## 11. 日志排查

- Windows：
    1. 查看防护设备的日志
    2. `eventvwr.msc` 打开日志管理器
    3. 查看暴力破解问题，筛选事件 ID（win2008 为 4625）

- Linux：
    1. `cat /root/.bash_history | more` 查看历史命令（每个账户目录下都有，可直接在 / 下搜索 .bash_history）
    2. 如有 `/var/log/secure` 日志，可进行暴力破解溯源；ubuntu 建议使用 `lastb` 和 `last`
    3. 常见日志：

        ```txt
        /var/log/message  系统启动后的信息和错误日志
        /var/log/secure   与安全相关的日志信息
        /var/log/maillog  与邮件相关的日志信息
        /var/log/cron     与定时任务相关的日志信息
        /var/log/spooler  UUCP和news设备相关日志信息
        /var/log/boot.log 进程启动和停止相关的日志消息
        ```

    4. 系统日志相关配置文件为 /etc/rsyslog.conf，主要找 wget/ssh/scp/tar/zip、添加账户修改密码一类的操作

- web 服务器：
    1. 无论任何 web 服务器，都需要关注 access_log、error_log
    2. apache 日志位置：在 httpd.conf 中搜索未被注释的、以 CustomLog 为起始的行即指定了日志的存储位置：

        ```bash
        grep -i CustomLog httpd.conf | grep -v ^#
        ```

    3. IIS 日志默认存储于 `%systemroot%\system32\LogFiles\W3SVC`，命名为 exYYMMDD.log，也可通过站点属性->W3C扩展日志文件格式->属性->日志文件目录确认

- 数据库：`cat mysql.log | grep union`

## 12. 恢复阶段

此阶段以业务方为主，仅提供建议：

1. webshell/异常文件清除（相关样本取样截图留存）
2. 恢复网络
3. 应用功能恢复
4. 补丁升级
5. 提供安全加固措施

## 13. 跟踪总结

1. 分析事件原因：攻击来源 IP、攻击行为分析（弱口令、可导致命令执行的漏洞等）
2. 输出应急报告
3. 事后观察
4. 提供加固建议

## 附1：常用安全工具

windows 下常用的安全工具：

工具|主要功能|下载地址
--|--|--
河马|webshell查杀|<http://www.shellpub.com/>
PCHunter|可查看进程、内核、服务等|<http://www.xuetr.com/>
火绒剑|可查看进程、内核、服务等|<https://www.huorong.cn/>
D盾|查找恶意文件以及webshell|<http://www.d99net.net/>
ProcessExplorer|Windows系统和应用程序监视工具|<https://docs.microsoft.com/en-us/sysinternals/downloads/process-explorer>
processhacker|类似ProcessExplorer|<https://processhacker.sourceforge.io/downloads.php>
autoruns|可查看windows在启动或登录时启动的程序|<https://docs.microsoft.com/en-us/sysinternals/downloads/autoruns>
microsoft network monitor|轻量级的无线抓包|<https://www.microsoft.com/en-us/download/details.aspx?id=4865>
VirSCAN.org|在线病毒分析平台|<http://www.virscan.org/language/zh-cn/>
腾讯哈勃分析系统|在线病毒分析平台|<https://habo.qq.com/>
Jotti|在线病毒分析平台|<https://virusscan.jotti.org/>

linux 下不方便操作时，可以把文件拷出来用 windows 的工具检测：

工具|主要功能|下载地址
--|--|--
Chkrootkit|查找检测rootkit后门|<http://www.chkrootkit.org/>
rootkit hunter|查找检测rootkit后门|<http://rkhunter.sourceforge.net/>

## 附2：实战经验要点

1. **处理前先 kill 掉病毒进程**，避免插入的U盘被加密
2. 如果日志分析阶段遇到困难，可对代码进行 webshell 查杀，可能会有惊喜
3. PC Hunter 数字签名颜色说明：黑色=微软签名的驱动程序；蓝色=非微软签名的驱动程序；红色=驱动检测到的可疑对象（隐藏服务、进程、被挂钩函数）
4. ProcessExplorer：子父进程一目了然；属性中的关键信息 [映像]->[路径/命令行/工作目录/自启动位置/父进程/用户/启动时间]、[TCP/IP]、[安全]->[权限]；进程启动时为绿色，结束时为红色
5. chkrootkit：检测是否被植入后门/木马/rootkit、检测系统命令是否正常、检测登录日志。安装 `rpm -ivh chkrootkit-*.rpm`，检测 `chkrootkit -n`，发现异常会报出 "INFECTED" 字样
6. rkhunter：系统命令（Binary）检测（含 MD5 校验）、Rootkit 检测、本机敏感目录/系统配置/服务异常检测、三方应用版本检测
7. RPM check 检查：`./rpm -Va > rpm.log`，可以据此发现 ps、pstree、netstat、sshd 等系统关键进程是否被篡改
