---
title: "docker网络模式"
date: 2022-11-10T00:29:47+08:00
tag : [ "docker" ]
description: "docker网络模式"
categories: [ "docker" ]
toc: true
---

## 前言
docker 的网络模式整理

## 1、查看所有容器的 IP
```bash
docker inspect --format='{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq)
```

```bash
Anttus-MacBook-Pro:shell $ docker inspect --format='{{.Name}} - {{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(docker ps -aq)
/etcd - 172.17.0.6
/minio1 - 172.17.0.2
/getting-started-latest - 172.17.0.3
/nginx1.22.0 - 172.17.0.12
/go-docker-v1 - 172.17.0.9
/java-docker-v1 - 172.17.0.7
/nodejs-docker-v1 - 172.17.0.8
/python-docker-v1 - 172.17.0.4
/mongo6 - 172.17.0.11
/redis7 - 172.17.0.5
/mysql8 - 172.17.0.10
```

## 2、查看指定容器的ip网络配置包含网络，ip等
```bash
docker inspect containerId
```

```bash
Anttus-MacBook-Pro:shell $ docker inspect b055811ce23c
[
    {
        "Id": "b055811ce23cf53d3b5e2cf193c0cd4a22a5befbf101bdd940662ecbe64ccc2c",
        "Created": "2022-09-06T08:50:31.6648081Z",
        "Path": "docker-entrypoint.sh",
        "Args": [
            "mysqld"
        ],
        "State": {
            "Status": "running",
            "Running": true,
            "Paused": false,
            "Restarting": false,
            "OOMKilled": false,
            "Dead": false,
            "Pid": 2724,
            "ExitCode": 0,
            "Error": "",
            "StartedAt": "2022-09-17T12:02:29.756584113Z",
            "FinishedAt": "2022-09-17T12:02:27.248114859Z"
        },
        "Image": "sha256:ff3b5098b416cc4294d8d5c43c2f0f8251e91711347318e73cb290ffe2783bcb",
        "ResolvConfPath": "/var/lib/docker/containers/b055811ce23cf53d3b5e2cf193c0cd4a22a5befbf101bdd940662ecbe64ccc2c/resolv.conf",
        "HostnamePath": "/var/lib/docker/containers/b055811ce23cf53d3b5e2cf193c0cd4a22a5befbf101bdd940662ecbe64ccc2c/hostname",
        "HostsPath": "/var/lib/docker/containers/b055811ce23cf53d3b5e2cf193c0cd4a22a5befbf101bdd940662ecbe64ccc2c/hosts",
        "LogPath": "/var/lib/docker/containers/b055811ce23cf53d3b5e2cf193c0cd4a22a5befbf101bdd940662ecbe64ccc2c/b055811ce23cf53d3b5e2cf193c0cd4a22a5befbf101bdd940662ecbe64ccc2c-json.log",
        "Name": "/mysql8",
        "RestartCount": 0,
        "Driver": "overlay2",
        "Platform": "linux",
        "MountLabel": "",
        "ProcessLabel": "",
        "AppArmorProfile": "",
        "ExecIDs": null,
        "HostConfig": {
            "Binds": [
                "/Users/Downloads/Docker/mysql/config/my.cnf:/etc/mysql/my.cnf",
                "/Users/Downloads/Docker/mysql/data:/usr/data",
                "/Users/Downloads/Docker/mysql/log:/logs",
                "/Users/Downloads/Docker/mysql/localtime:/etc/localtime"
            ],
            "ContainerIDFile": "",
            "LogConfig": {
                "Type": "json-file",
                "Config": {}
            },
            "NetworkMode": "bridge",
            "PortBindings": {
                "3306/tcp": [
                    {
                        "HostIp": "",
                        "HostPort": "3306"
                    }
                ]
            },
            "RestartPolicy": {
                "Name": "always",
                "MaximumRetryCount": 0
            },
            "AutoRemove": false,
            "VolumeDriver": "",
            "VolumesFrom": null,
            "CapAdd": null,
            "CapDrop": null,
            "CgroupnsMode": "private",
            "Dns": [],
            "DnsOptions": [],
            "DnsSearch": [],
            "ExtraHosts": null,
            "GroupAdd": null,
            "IpcMode": "private",
            "Cgroup": "",
            "Links": null,
            "OomScoreAdj": 0,
            "PidMode": "",
            "Privileged": true,
            "PublishAllPorts": false,
            "ReadonlyRootfs": false,
            "SecurityOpt": [
                "label=disable"
            ],
            "UTSMode": "",
            "UsernsMode": "",
            "ShmSize": 67108864,
            "Runtime": "runc",
            "ConsoleSize": [
                0,
                0
            ],
            "Isolation": "",
            "CpuShares": 0,
            "Memory": 0,
            "NanoCpus": 0,
            "CgroupParent": "",
            "BlkioWeight": 0,
            "BlkioWeightDevice": [],
            "BlkioDeviceReadBps": null,
            "BlkioDeviceWriteBps": null,
            "BlkioDeviceReadIOps": null,
            "BlkioDeviceWriteIOps": null,
            "CpuPeriod": 0,
            "CpuQuota": 0,
            "CpuRealtimePeriod": 0,
            "CpuRealtimeRuntime": 0,
            "CpusetCpus": "",
            "CpusetMems": "",
            "Devices": [],
            "DeviceCgroupRules": null,
            "DeviceRequests": null,
            "KernelMemory": 0,
            "KernelMemoryTCP": 0,
            "MemoryReservation": 0,
            "MemorySwap": 0,
            "MemorySwappiness": null,
            "OomKillDisable": null,
            "PidsLimit": null,
            "Ulimits": null,
            "CpuCount": 0,
            "CpuPercent": 0,
            "IOMaximumIOps": 0,
            "IOMaximumBandwidth": 0,
            "MaskedPaths": null,
            "ReadonlyPaths": null
        },
        "GraphDriver": {
            "Data": {
                "LowerDir": "/var/lib/docker/overlay2/262b7fe49ceef30a815f7acd398efd160a8575276a26bd3ed5fe8d03b89c64f5-init/diff:/var/lib/docker/overlay2/f9793fa9c30e39c82416c7664ba9f1bded7164da0eedc04db5f9d34e8ae524bd/diff:/var/lib/docker/overlay2/8bd9971c98c7afafafb6af93fe793eb01881a3e28a25e166cce5037d1867f3a6/diff:/var/lib/docker/overlay2/718e2486037cff064644cfe79f7e0710364ed8b18a2813c501fc921872e154a7/diff:/var/lib/docker/overlay2/d4239c0d55a03ec8e29d9e7a4fcd7aab5f081c4a564eb341d1065f9d0df24429/diff:/var/lib/docker/overlay2/e393d409b7557dac52f8e497f8743ef9663b6037abe9a4edd8cdd66bad9de964/diff:/var/lib/docker/overlay2/1bb134141159fe08fa4dc08b7404e92b103242319663ecee72f5e4aff61c3a40/diff:/var/lib/docker/overlay2/ed42a23c02fe373db201fcc49bf0bd80ee663766ac400aa101163a42ea6ba469/diff:/var/lib/docker/overlay2/d4e972b8eae083ea8c8dc28538c2d92b2e63e4849c348e47783725cbfd42eafa/diff:/var/lib/docker/overlay2/b23c6d2cb95f018ab8ade60d15a40f9bd4eca5568cdae22b10a75b4b22bb8608/diff:/var/lib/docker/overlay2/36e999dce4bab3eee5d5a74b607ee845ebd8b95707222b9f0e57f5d40922b1ce/diff:/var/lib/docker/overlay2/b0f8ffee4114eb3d1797566ab320c34e38e71780e532cadb8d327f03c5a49593/diff",
                "MergedDir": "/var/lib/docker/overlay2/262b7fe49ceef30a815f7acd398efd160a8575276a26bd3ed5fe8d03b89c64f5/merged",
                "UpperDir": "/var/lib/docker/overlay2/262b7fe49ceef30a815f7acd398efd160a8575276a26bd3ed5fe8d03b89c64f5/diff",
                "WorkDir": "/var/lib/docker/overlay2/262b7fe49ceef30a815f7acd398efd160a8575276a26bd3ed5fe8d03b89c64f5/work"
            },
            "Name": "overlay2"
        },
        "Mounts": [
            {
                "Type": "bind",
                "Source": "/Users/Downloads/Docker/mysql/localtime",
                "Destination": "/etc/localtime",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            },
            {
                "Type": "bind",
                "Source": "/Users/Downloads/Docker/mysql/config/my.cnf",
                "Destination": "/etc/mysql/my.cnf",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            },
            {
                "Type": "bind",
                "Source": "/Users/Downloads/Docker/mysql/log",
                "Destination": "/logs",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            },
            {
                "Type": "bind",
                "Source": "/Users/Downloads/Docker/mysql/data",
                "Destination": "/usr/data",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            },
            {
                "Type": "volume",
                "Name": "eda1141a1129e17676fc14b6cfedc975c01b8cef030d3042df9543ae0c133ba6",
                "Source": "/var/lib/docker/volumes/eda1141a1129e17676fc14b6cfedc975c01b8cef030d3042df9543ae0c133ba6/_data",
                "Destination": "/var/lib/mysql",
                "Driver": "local",
                "Mode": "",
                "RW": true,
                "Propagation": ""
            }
        ],
        "Config": {
            "Hostname": "b055811ce23c",
            "Domainname": "",
            "User": "",
            "AttachStdin": false,
            "AttachStdout": false,
            "AttachStderr": false,
            "ExposedPorts": {
                "3306/tcp": {},
                "33060/tcp": {}
            },
            "Tty": false,
            "OpenStdin": false,
            "StdinOnce": false,
            "Env": [
                "MYSQL_PASSWORD=test123456",
                "character-set-server=utf8",
                "collation-server=utf8_general_ci",
                "MYSQL_ROOT_PASSWORD=root123456",
                "MYSQL_USER=mysql",
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "GOSU_VERSION=1.14",
                "MYSQL_MAJOR=8.0",
                "MYSQL_VERSION=8.0.30-1.el8",
                "MYSQL_SHELL_VERSION=8.0.30-1.el8"
            ],
            "Cmd": [
                "mysqld"
            ],
            "Image": "mysql:8.0",
            "Volumes": {
                "/var/lib/mysql": {}
            },
            "WorkingDir": "",
            "Entrypoint": [
                "docker-entrypoint.sh"
            ],
            "OnBuild": null,
            "Labels": {}
        },
        "NetworkSettings": {
            "Bridge": "",
            "SandboxID": "c6b894c6e93f77d1373c596b7e0b739e9077496ae8fd0f9ac4a0e332cd9ff64b",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "Ports": {
                "3306/tcp": [
                    {
                        "HostIp": "0.0.0.0",
                        "HostPort": "3306"
                    }
                ],
                "33060/tcp": null
            },
            "SandboxKey": "/var/run/docker/netns/c6b894c6e93f",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "632055c898d3becb5e76e5216cd471daed266f115ab84c18dd4f64da4adbf189",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.8",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:08",
            "Networks": {
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "df04e694c73a176ccca94ab55253f9ac8937658faf87c4a23a1215e98c114e28",
                    "EndpointID": "632055c898d3becb5e76e5216cd471daed266f115ab84c18dd4f64da4adbf189",
                    "Gateway": "172.17.0.1",
                    "IPAddress": "172.17.0.8",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:08",
                    "DriverOpts": null
                }
            }
        }
    }
]
Anttus-MacBook-Pro:shell $
```

## 3、查看容器的ip
```bash
docker exec -it containerId ip addr
```

```bash
# 类似ip addr命令执行，需要带ip 命令才可以执行，否则会报错，下面样例仅供参考
$ ip addr
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP qlen 1000
    link/ether 00:50:56:87:3e:b8 brd ff:ff:ff:ff:ff:ff
    inet 10.10.235.111/24 brd 10.10.235.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::250:56ff:fe87:3eb8/64 scope link 
       valid_lft forever preferred_lft forever
3: docker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP 
    link/ether 02:42:b2:e3:13:75 brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.1/24 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:b2ff:fee3:1375/64 scope link 
       valid_lft forever preferred_lft forever
7: vethaaab889@if6: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP 
    link/ether 8e:8e:10:a1:a0:92 brd ff:ff:ff:ff:ff:ff link-netnsid 1
    inet6 fe80::8c8e:10ff:fea1:a092/64 scope link 
       valid_lft forever preferred_lft forever
9: veth56dcf1b@if8: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP 
    link/ether 6e:ac:31:5f:68:32 brd ff:ff:ff:ff:ff:ff link-netnsid 2
    inet6 fe80::6cac:31ff:fe5f:6832/64 scope link 
       valid_lft forever preferred_lft forever
15: veth6e7ba4f@if14: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master docker0 state UP 
    link/ether 22:ba:45:08:19:78 brd ff:ff:ff:ff:ff:ff link-netnsid 4
    inet6 fe80::20ba:45ff:fe08:1978/64 scope link 
       valid_lft forever preferred_lft forever
You have new mail in /var/spool/mail/root

```

## 4、docker 的网络模式及区别
### 4.1 docker的四种网络模式
None --- 不为容器进行任何网络配置，容器不能访问外部网络，内部存在回路地址,这个Docker容器没有网卡、IP、路由等信息，只有lo 网络接口。需要我们自己为Docker容器添加网卡、配置IP等。

Container --- 将容器的网络栈合并到一起，可与其他容器共享IP地址和端口范围等。而不是和宿主机共享,两个容器除了网络方面，其他的如文件系统、进程列表等还是隔离的。

Host --- 与主机共享网络。

Bridge --- 默认网络模式，通过主机和容器的端口映射（iptable转发）来通信。桥接是在主机上，一般叫docker0。

### 4.2 查看存在的网络配置
```bash
docker network ls
```

```bash
Anttus-MacBook-Pro:shell $ docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
df04e694c73a   bridge    bridge    local
6fed755b2279   host      host      local
6528a1017fc2   none      null      local
```

 ### 4.3 docker容器启动时可通过--network  指定网络配置
 ```bash
 docker run --name elasticsearch -it --network host elasticsearch:7.6.1
 ```