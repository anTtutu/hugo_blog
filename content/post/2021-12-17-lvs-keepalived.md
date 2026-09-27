---
title: "LVS+Keepalived原理与安装配置实战"
date: 2021-12-17T08:00:00+08:00
tags: [ "linux", "lvs", "keepalived", "负载均衡" ]
description: "LVS+Keepalived 高可用负载均衡实战：keepalived 的 Layer3/4/7 检测原理、LVS(piranha) 安装与 lvs.cf 配置、RealServer 的 ARP 抑制与 lo 别名配置、keepalived 主从配置与 lvsrs 脚本"
categories: [ "linux", "架构" ]
toc: true
---

## 前言

LVS + Keepalived 是经典的四层负载均衡高可用方案：LVS 负责流量转发，Keepalived 负责健康检查与主备切换。这篇整理两者的原理与完整安装配置过程（文中的 IP 均为示例地址）。

## 一、Keepalived 的三种工作方式

Keepalived 工作在 IP/TCP 协议栈的 IP 层、TCP 层及应用层，对应 Layer3、Layer4、Layer7 三种检测方式：

- **Layer3（IP层）**：Keepalived 定期向服务器群中的服务器发送 ICMP 数据包（即 Ping），如果发现某台服务器的 IP 地址没有激活，便报告这台服务器失效并将它从服务器群中剔除。典型例子是某台服务器被非法关机。Layer3 以服务器的 IP 地址是否有效作为服务器工作正常与否的标准。
- **Layer4（TCP层）**：主要以 TCP 端口的状态来决定服务器工作是否正常。如 web server 的服务端口一般是 80，如果 Keepalived 检测到 80 端口没有启动，则将这台服务器从服务器群中剔除。
- **Layer7（应用层）**：工作在具体的应用层，比 Layer3、Layer4 要复杂一点，在网络上占用的带宽也要大一些。Keepalived 根据用户的设定检查服务器程序的运行是否正常（例如请求一个特定 URL 比对返回内容），与设定不符则剔除。

## 二、LVS 安装（Active/Standby 模式）

LVS 部署两台，为 Active/Standby 模式：

```bash
yum install ipvsadm -y
yum install piranha -y
```

### 1. lvs.cf 配置

编辑 `/etc/sysconfig/ha/lvs.cf`（示例：三组 virtual service，每组 3 台 RealServer，DR 直接路由模式，wlc 加权最小连接调度，健康检查用 GET 一个探活页面比对 "OK"）：

```txt
service = lvs
primary = 192.168.1.190
primary_private = 172.16.0.190          # lvs 主服务器心跳地址
backup_active = 1
backup = 192.168.1.191
backup_private = 172.16.0.191           # lvs 备服务器心跳地址
heartbeat = 1
heartbeat_port = 539
keepalive = 4
deadtime = 12
debug_level = NONE
rsh_command = ssh
network = direct                        # DR 直接路由模式
# Tcp port 80 for portal
virtual portal1v1 {
        active = 1
        address = 192.168.1.100 eth0:1  # VIP
        vip_nmask = 255.255.255.0
        port = 80
        persistent = 1800
        pmask = 255.255.255.255
        send = "GET /iwl/.lvs.html\n"   # 健康检查请求
        expect = "OK"                   # 期望响应
        load_monitor = none
        scheduler = wlc                 # 加权最小连接调度
        protocol = tcp
        timeout = 5
        reentry = 10
        quiesce_server = 0
        server potral1 {
                address = 192.168.1.10
                active = 1
                weight = 100
        }
        server potral2 {
                address = 192.168.1.11
                active = 1
                weight = 100
        }
        server potral3 {
                address = 192.168.1.12
                active = 1
                weight = 100
        }
}
# portal1v2、portal1v3 配置类似，分别绑定 eth1:1（192.168.2.100）与 eth2:1（192.168.3.100），
# 对应的 RealServer 为 192.168.2.10~12、192.168.3.10~12
```

### 2. 客户端（RealServer）配置

所有 RealServer 添加 ARP 抑制参数，`vi /etc/sysctl.conf`：

```txt
net.ipv4.conf.all.arp_ignore = 1
net.ipv4.conf.all.arp_announce = 2
net.ipv4.conf.lo.arp_ignore = 1
net.ipv4.conf.lo.arp_announce = 2
```

保存后 `sysctl -p` 生效。再在 `/etc/rc.local` 中添加 lo 别名（每对应一组 VIP 加一行）：

```bash
ifconfig lo:0 192.168.1.100 broadcast 192.168.1.100 netmask 255.255.255.255 up
ifconfig lo:1 192.168.2.100 broadcast 192.168.2.100 netmask 255.255.255.255 up
ifconfig lo:2 192.168.3.100 broadcast 192.168.3.100 netmask 255.255.255.255 up
```

```bash
sh /etc/rc.d/rc.local    # 使回环地址生效
```

> 注意：如果重启网络，回环别名会消失，需要重新执行此脚本，切记。

### 3. 健康检查探活页面

在应用侧发布探活页面（示例为 jboss + apache 前置）：

```bash
# apache 的 uriworkermap.properties 添加
/iwl/.lvs.html=jboss

# 部署探活 war 并写入检查内容
cat > .lvs.html <<EOF
OK
EOF

# 验证：返回 "OK" 说明配置成功
GET http://192.168.1.10/iwl/.lvs.html
```

### 4. LVS 常用命令

```bash
/etc/init.d/pulse start|restart|stop|status   # pulse 服务管理，status 可查看 lvs 状态
ipvsadm -Ln    # 查看当前的 lvs 转发状态列表（-L 列表输出，-n 以数字显示地址和端口）
watch ipvsadm -Ln    # 实时查看状态
```

`ipvsadm -Ln` 输出示例：

```txt
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  192.168.1.100:80 wlc persistent 1800
  -> 192.168.1.10:80              Route   100    1          66
  -> 192.168.1.11:80              Route   100    1          97
  -> 192.168.1.12:80              Route   100    1          97
```

## 三、经验：MAC 缓存导致 VIP 切换后网络不通

两台 VS 互备时，当一台 VS 接管 LVS 服务，可能出现网络不通——因为路由器的 MAC 缓存表里无法及时刷新，关于 VIP 的 MAC 地址还是替换前 VS 的 MAC。两种解决方法：

1. 修改新 VS 的 MAC 地址
2. 使用 send_arp / arping 命令强制刷新：

    ```bash
    /sbin/arping -I eth0 -c 3 -s ${vip} ${gateway_ip} > /dev/null 2>&1
    # 例如
    /sbin/arping -I eth0 -c 3 -s 192.168.1.6 192.168.1.1
    ```

> 最好让机房调整路由 MAC 缓存表的刷新频率。

## 四、Keepalived 安装与配置

```bash
wget http://www.keepalived.org/software/keepalived-1.2.2.tar.gz
tar zxvf keepalived-1.2.2.tar.gz
cd keepalived-1.2.2
./configure
make && make install
mkdir /etc/keepalived
cp /usr/local/etc/keepalived/keepalived.conf /etc/keepalived/keepalived.conf
cp /usr/local/etc/sysconfig/keepalived /etc/sysconfig/keepalived
cp /usr/local/etc/rc.d/init.d/keepalived /etc/init.d/keepalived
ln -s /usr/local/sbin/keepalived /usr/bin/keepalived
```

### 主节点配置 /etc/keepalived/keepalived.conf

```txt
! Configuration File for keepalived
global_defs {
   notification_email {
     admin@example.com
   }
   notification_email_from admin@example.com
   smtp_server smtp.example.com
   smtp_connect_timeout 30
   router_id LVS_DEVEL
}

vrrp_script Monitor_Nginx {
  script "/home/app/bin/monitor_nginx"
  interval 2
  weight 2
}

vrrp_instance VI_1 {
    state MASTER                  # 负载均衡器的角色
    interface eth0                # 承载VIP地址的物理接口
    virtual_router_id 51          # 虚拟路由器的ID号，每个热备组保持相同
    mcast_src_ip 192.168.10.44
    priority 101                  # 竞选优先级，数字越大优先级越高
    advert_int 1                  # 通告间隔秒数（心跳频率）
    authentication {              # 本VRRP组的认证信息
        auth_type PASS
        auth_pass 1111
    }
    track_script {
        Monitor_Nginx
    }
    virtual_ipaddress {           # 热备所针对的虚拟地址（VIP），可以有多行
        192.168.10.75
    }
}
```

**从节点**只需要改 `state BACKUP` 和更低的 `priority` 即可。

用 `ip addr` 命令可以查看 VIP 地址是否已生效。

### RealServer 的 lvsrs 脚本

创建 lvsrs 脚本放到 /etc/init.d/ 下，用于配置虚拟 IP 和取消 ARP 应答：

```bash
#!/bin/bash
# 配置虚拟IP，取消arp应答
VIP=192.168.1.100
. /etc/rc.d/init.d/functions
case "$1" in
start)
       ifconfig lo:0 $VIP netmask 255.255.255.255 broadcast $VIP up
       /sbin/route add -host $VIP dev lo:0
       echo "1" >/proc/sys/net/ipv4/conf/lo/arp_ignore
       echo "2" >/proc/sys/net/ipv4/conf/lo/arp_announce
       echo "1" >/proc/sys/net/ipv4/conf/all/arp_ignore
       echo "2" >/proc/sys/net/ipv4/conf/all/arp_announce
       sysctl -p >/dev/null 2>&1
       echo "RealServer Start OK"
       ;;
stop)
       ifconfig lo:0 down
       route del $VIP >/dev/null 2>&1
       echo "0" >/proc/sys/net/ipv4/conf/lo/arp_ignore
       echo "0" >/proc/sys/net/ipv4/conf/lo/arp_announce
       echo "0" >/proc/sys/net/ipv4/conf/all/arp_ignore
       echo "0" >/proc/sys/net/ipv4/conf/all/arp_announce
       echo "RealServer Stoped"
       ;;
*)
       echo "Usage: $0 {start|stop}"
       exit 1
esac
exit 0
```

## 总结

LVS+Keepalived 方案的三个关键点：RealServer 的 **ARP 抑制**（arp_ignore/arp_announce）保证 DR 模式下响应不旁路；**探活页面**（send/expect）做 Layer7 健康检查；主备切换时记得处理**路由 MAC 缓存**问题。掌握这三点，整套方案的配置就顺了。
