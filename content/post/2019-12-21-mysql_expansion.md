---
title: mysql集群在线无损扩容
date: 2019-12-21T21:46:20+08:00
tags: [ "mysql", "linux" ]
description: "mysql集群在线无损扩容"
categories: [ "mysql", "linux" ]
toc: true
---

### 收到数据库磁盘占比告警了
前提条件，磁盘采用lvm管理方式，做在线无损扩容才方便管理，其他方式没测试过

## 1、分配一个1T的新盘，HDD、SDD随规划选择
这个一般在磁阵或者云管理平台操作，不需要什么命令，一般都是图形化操作

## 2、查找新分配的1T新盘
```bash
fdisk -l     
lvmdiskscan
```
个人建议第二个命令，2个命令都会返回一堆查询值，怎么判断谁是新盘，谁是已使用的盘，这点有运维经验的人还是不成问题的，不详说

## 3、创建新PV
```bash
pvcreate /dev/sdd 
```
假设sdd表示新增的1T数据盘

## 4、加入到原来的VG
```bash
vgextend VolGroup /dev/sdd 
```
VolGroup表示原来的vg name

## 5、查看FE size
```bash
vgdisplay
```

## 6、新增PE到待扩容的空间
```bash
lvextend -l +23039 /dev/VolGroup/lv_mysql
```
(+23039为上一步查到的Free PE的大小)

也可以不用查看FE size直接100%
```bash
 lvcreate -n lv_data -l 100%FREE vg_data
```
新建lv，可以直接使用100%

## 7、调整文件系统大小
```bash
resize2fs /dev/VolGroup/lv_mysql 
```
根据磁盘大小等待的时间有长短,这一步需要耐心等待

## 注意，云服务器可能存在盘符跳变的坑
碰到一起案例，云服务器的盘符重启会自动变，比如刚添加时是sdc，但是可能下一次重启，sdc会变成sdd，但是背后的UUID并没变，需要采用UUID来
```bash
blkid
/dev/sdb1: UUID="******-3202-4d59-b101-b098988696f5" TYPE="ext4" 
/dev/sdc1: UUID="******-JAcw-YPuj-IOBe-fqZh-FdTJ-eKrJug" TYPE="LVM2_member" 
/dev/sde: UUID="*******-c4b6-4ac0-bbbf-3d7c21d6283b" TYPE="ext4" 
/dev/sdd: UUID="*******-1aTl-gv7a-yB69-gG2q-sX7y-p4nGRT" TYPE="LVM2_member" 
/dev/sda1: UUID="******-fef6-4075-941e-e7ce50fb3e50" TYPE="ext4" 
/dev/mapper/VolGroup-lv_mysql: UUID="*******-6b9a-4c0d-869c-5b0386a36d61" TYPE="ext4" 
```
提取到UUID后，可以把自动mount配置在/etc/fstab