---
title: python工具-移除照片或视频背景
date: 2019-07-10T21:46:20+08:00
tags: [ "python" ]
description: "python工具-移除照片或视频背景"
categories: [ "python" ]
toc: true
---

## 前言
BackgroundRemover是一个命令行工具，用于从视频 和图像中删除背景
![](/posts/python/bgremover.png)

## 1、依赖
Requirements
python <= 3.6
python3.6-dev #or what ever version of python you using
torch and torchvision stable version (https://pytorch.org)
ffmpeg 4.4+
```bash
pip install python3.6-dev
pip install ffmpeg
pip install torch
```

## 2、安装
```bash
pip install backgroundremover
```

## 3、下载模型并设置

## 4、图片
从本地文件图像中删除背景
```bash
backgroundremover -i "/path/to/image.jpeg" -o "output.png"
```
### 高级用法
有时可以通过打开 alpha matting 来获得更好的结果
```bash
backgroundremover -i "/path/to/image.jpeg" -a -ae 15 -o "output.png"
```

切换模型u2netp, u2net, or u2net_human_seg
```bash
backgroundremover -i "/path/to/image.jpeg" -m "u2net_human_seg" -o "output.png"
```

## 5、视频
从视频中删除背景并制作透明mov
```bash
backgroundremover -i "/path/to/video.mp4" -tv -o "output.mov"
```

从本地视频中删除背景并将其覆盖在其他视频上
```bash
backgroundremover -i "/path/to/video.mp4" -tov -tv "/path/to/videtobeoverlayed.mp4" -o "output.mov"
```

从视频中删除背景并制作透明gif
```bash
backgroundremover -i "/path/to/video.mp4" -tg -o "output.gif"
```

制作遮罩键文件（绿屏覆盖）  
为制作蒙版文件
```bash
backgroundremover -i "/path/to/video.mp4" -mk -o "output.matte.mp4"
```

### 高级用法
更改视频的帧率（默认设置为 30）
```bash
backgroundremover -i "/path/to/video.mp4" -fr 30 -tv -o "output.mov"
```

更改视频的 gpu 批量大小（默认设置为 1）
```bash
backgroundremover -i "/path/to/video.mp4" -gb 4 -tv -o "output.mov"
```

更改处理视频的工作人员数量（默认设置为 1）
```bash
backgroundremover -i "/path/to/video.mp4" -wn 4 -tv -o "output.mov"
```

切换模型u2netp, u2net, or u2net_human_seg
```bash
backgroundremover -i "/path/to/video.mp4" -m "u2net_human_seg"-tv -o "output.mov"
```