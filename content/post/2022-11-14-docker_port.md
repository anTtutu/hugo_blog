---
title: "docker修改运行的容器端口"
date: 2022-11-14T00:29:47+08:00
tag : [ "docker" ]
description: "docker修改运行的容器端口"
categories: [ "docker" ]
toc: true
---

## 前言
有时候docker容器已经运行了，发现端口占用或者冲突了，不方便删除重新运行容器，可以通过修改配置文件方式来调整端口

## 1、Linux
### 1.1 先停止容器
```bash
docker stop {容器的名称或者id}
```

### 1.2 然后查询完整的容器id
```bash
docker inspect {容器的名称或者id} | grep Id

# 比如如下示例
"Id": "cbe26510c276fa9a4487a8c2af8cbb49410f2a5305149d2b26eb8ce37c777d00"
```

### 1.3 打开hostconfig.json配置文件
```bash
vi /var/lib/docker/containers/{hash_of_the_container}/hostconfig.json

# 比如示例的Id
vi /var/lib/docker/containers/cbe26510c276fa9a4487a8c2af8cbb49410f2a5305149d2b26eb8ce37c777d00/hostconfig.json
```

### 1.4 还有不用完整的容器id也可以(可选，跟1.3相同)
```bash
cd /var/lib/docker/containers/{hash_of_the_container}*

# 比如示例的
cd /var/lib/docker/containers/cbe26510c276*

vi hostconfig.json
```

### 1.5 修改hostconfig.json配置文件
在 hostconfig.json 配置文件中，找到 "PortBindings":{} 这个配置项，然后进行修改。
HostPort 对应的端口代表 宿主机 的端口。

PS:
建议容器使用什么端口，宿主机就映射什么端口，方便以后管理。当然，具体情况，具体分析。

```json
{
    "PortBindings": {
        "8502/tcp": [
            {
                "HostIp": "",
                "HostPort": "8502"
            }
        ],
        "8505/tcp": [
            {
                "HostIp": "",
                "HostPort": "8505"
            }
        ]
    }
}
```

### 1.6 修改config.v2.json或config.json
如果 config.v2.json 配置文件或者 config.json 配置文件中也记录了端口，也需要进行修改，如果没有，就不需要改。

只需要修改 "ExposedPorts": {} 相关之处。
```json
{
    "Args": [],
    "Config": {
        "ExposedPorts": {
            "8502/tcp": {},
            "8505/tcp": {}
        },
        "Entrypoint": [
            "/bin/sh"
        ]
    }
}
```

### 1.7 然后重启容器
最后重启 docker
```bash
# 重启 docker
service docker restart
# 或者
systemctl restart docker
```

### 1.8 查询修改的端口
查看容器相关配置信息：
```bash
docker inspect {容器的名称或者 id }
# 比如示例
docker inspect cbe26510c276
```

### 1.9 启动容器
检查端口已经修改，可以启动容器了
```bash
docker start {容器的名称或者 id }
# 比如：
docker start cbe26510c276
```

## 2、Mac
Mac要麻烦一些，因为在 Docker for MacOS 中，容器的宿主机并不是 MacOS 本身，而是在 MacOS 中运行的一个 VM 虚拟机
。虚拟机的路径可以通过查看 Docker Desktop 的配置界面 Disk image location 配置获得。

那么我们如何进入这个虚拟机呢？

### 1.1 启动justincormack/nsenter1
最简单的方式是采用 justincormack/nsenter1 进入，这个镜像只有 101KB，已经非常小了。
```bash
docker run -it --rm --privileged --pid=host justincormack/nsenter1
```
参数|说明
-|-
–rm|表示在退出的时候就自动删除该容器；
–privileged|表示允许该容器访问宿主机（也就是我们想要登录的 VM ）中的各种设备；
–pid=host|表示允许容器共享宿主机的进程命名空间（namespace），或者通俗点儿解释就是允许容器看到宿主机中的各种进程；
然后再进入 /var/lib/docker/containers 目录修改 config.v2.json 配置文件和 hostconfig.json 配置文件即可。整体来说，在 MacOS 上除了进入 /var/lib/docker/containers 目录时，进入方式有所不同以外，修改配置文件方式和上文一样。需要注意的是，修改的时候请使用 vi 编辑器，因为这个镜像没有安装 vim 编辑器的。

### 2.2 进入容器
```bash
docker exec -it {justincormack/nsenter1容器id} /bin/bash
```

### 2.3 修改config.v2.json和hostconfig.json
剩下的步骤跟linux一样
```bash
vi /var/lib/docker/containers/a7377587b9f08cfe87af9a8ffa4da0f90bf07fb0a1cd6833a5ffcd9c37b842d0/config.v2.json

vi /var/lib/docker/containers/a7377587b9f08cfe87af9a8ffa4da0f90bf07fb0a1cd6833a5ffcd9c37b842d0/hostconfig.json
```