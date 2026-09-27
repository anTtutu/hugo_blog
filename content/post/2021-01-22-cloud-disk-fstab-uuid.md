---
title: "云服务器盘符跳变：fstab用UUID挂载避免启动失败"
date: 2021-01-22T08:00:00+08:00
tags: [ "linux", "云服务", "运维" ]
description: "linux 云服务器 /dev/sdd 盘符跳变成 /dev/sde 的处理：设备名挂载 + 1 1 启动检查导致重启失败的事故复盘，改用 UUID/lvm 挂载与非系统盘 0 0 的最佳实践"
categories: [ "linux" ]
toc: true
---

## 前言

2020-03-28 碰到一个云服务器的问题：`/dev/sdd` 盘符跳变成了 `/dev/sde`，因为 fstab 里还写着旧设备名还带启动检查，直接导致服务器重启失败。记录下处理过程和以后的挂载规范。

## 1、事故经过

出问题的 fstab 长这样：

```txt
# /etc/fstab
UUID=adc76f7c-fef6-4075-941e-e7ce50fb3e50  /         ext4  defaults  1 1
tmpfs    /dev/shm    tmpfs    defaults        0 0
devpts   /dev/pts    devpts   gid=5,mode=620  0 0
sysfs    /sys        sysfs    defaults        0 0
proc     /proc       proc     defaults        0 0

/dev/mapper/VolGroup-lv_mysql  /data      ext4  defaults  1 1
#/dev/sdd                      /dbbackup  ext4  defaults  1 1
UUID=ee7bdf7f-c4b6-4ac0-bbbf-3d7c21d6283b  /dbbackup  ext4  0 0
```

问题出在 `/dev/sdd`：原来这块盘有 1T，fstab 里按设备名挂载到 /dbbackup，而且最后两个参数是 `1 1`（开机 fsck 检查）。后来扩容新加了一块 500G 的盘，**云平台重新分配设备名时，新盘占了 sdd 的位置，原 sdd 顺移成了 sde**——fstab 里写的 `/dev/sdd` 现在指向的是新盘，挂载失败、fsck 检查也失败，重启直接卡死进不了系统。

## 2、处理

两个改动：

**1、挂载路径不用 /dev/sdX 设备名，改用 UUID 或 lvm**

设备名是云平台分配的，扩容、卸载重挂都可能变化；UUID 是文件系统生成时固定的，不会跳变。查询 UUID 用 blkid：

```bash
blkid /dev/sde
# /dev/sde: UUID="ee7bdf7f-c4b6-4ac0-bbbf-3d7c21d6283b" TYPE="ext4"
```

fstab 里改成：

```txt
UUID=ee7bdf7f-c4b6-4ac0-bbbf-3d7c21d6283b  /dbbackup  ext4  defaults  0 0
```

多块盘的场景更建议直接上 LVM（像上面 /data 用的 `/dev/mapper/VolGroup-lv_mysql`），后续扩容也只是加 PV 扩 LV，不存在盘符问题。

**2、非启动必须的挂载目录，最后一列的检查参数用 0 0**

fstab 最后两个字段的含义：倒数第二个 `1 1` 中的 1 表示开机 dump 备份，最后一个表示开机 fsck 检查顺序（根分区必须 1，其他 2，不检查 0）。数据盘不是系统启动的必需依赖，设成 `0 0`，就算盘有问题也只是挂不上，不会卡住整个开机流程。

另外顺手确认了 SELinux 是 disabled——生产环境如果不是必须用 SELinux，关掉能少很多权限类怪问题。

## 3、以后的挂载规范

1. 云盘挂载一律写 UUID（`blkid` 查询）或走 LVM，永远不写 `/dev/sdX`
2. 数据盘 fstab 最后两位用 `0 0`，只有根分区保留 `1 1`
3. 改完 fstab 别急着重启，先 `mount -a` 验证一遍没报错，再执行重启

## 总结

设备名是会变的，UUID 不会。这次幸好是能挂控制台救援模式的时代，改一行 fstab 就救回来了；fstab 写错导致起不来的事故在云上非常常见，把挂载规范固定下来就能彻底避开。
