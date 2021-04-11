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

## 2、deepfacelab核心库
```bash
git clone --depth=1 https://github.com/iperov/DeepFaceLab
```
## 3、成熟的deepfacelab安装项目包
win10环境：  
软件磁力连接（迅雷复制下载）：magnet:?xt=urn:btih:3384316e126920d7e1cbd2acb16b9513a57b2645&dn=DeepFaceLab&tr=udp%3a%2f%2ftracker.coppersurfer.tk%3a6969%2fannounce

## 4、安装前的准备
1、如果用的步骤3中的成熟项目包只需要依赖python3  
2、如果用的步骤3中的核心库自行搭建的话，需要安装如下清单
```python
numpy
h5py
Keras
opencv-python
tensorflow-gpu
plaidml
plaidml-keras
scikit-image
tqdm
ffmpeg-python

nvidia-CUDA
```

## 5、执行如下步骤
本着快速应用的地步，优先选择步骤3的完整项目包
### 1、2) extract images from video data_src.bat           --把源视频拆分成图片


### 2、3) extract images from video data_dst FULL FPS.bat  --把目标视频拆分成图片
### 3、4) data_src extract faces extract.bat               --从源图片中提取人脸，也叫切脸
### 4、5) data_dst extract faces extract.bat               --从目标图片中提取人脸
### 5、6) train Quick96.bat                                --训练模型，耗时，不会自己结束
>1、SAEHD模型做出来的视频质量更好，但是要求的配置更高。  
>2、退出后再次点击train Quick96.bat 可以继续训练，进度不会丢失
### 6、7) merge Quick96.bat                                --图片换脸
### 7、8) merged to mp4.bat                                --把图片合成视频