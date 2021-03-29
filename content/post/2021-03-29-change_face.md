---
title: "deepfacelab使用介绍"
date: 2021-03-29T00:29:47+08:00
tags: [ "python", "deepfacelab" ]
description: "deepfacelab使用介绍"
categories: [ "python", "deepfacelab" ]
toc: true
---

## 1、前言
应朋友要求，研究下deepfacelab的环境搭建和使用步骤，记录下中间的问题。先上传提纲，细节等忙完再整理

## 2、下载deepfacelab
```bash
git clone --depth=1 https://github.com/iperov/DeepFaceLab
```

## 3、执行如下步骤
### 1、2) extract images from video data_src.bat           --把源视频拆分成图片
### 2、3) extract images from video data_dst FULL FPS.bat  --把目标视频拆分成图片
### 3、4) data_src extract faces extract.bat               --从源图片中提取人脸，也叫切脸
### 4、5) data_dst extract faces extract.bat               --从目标图片中提取人脸
### 5、6) train Quick96.bat                                --训练模型，耗时，不会自己结束
>1、SAEHD模型做出来的视频质量更好，但是要求的配置更高。  
>2、退出后再次点击train Quick96.bat 可以继续训练，进度不会丢失
### 6、7) merge Quick96.bat                                --图片换脸
### 7、8) merged to mp4.bat                                --把图片合成视频