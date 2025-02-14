---
title: "git删除历史提交记录"
date: 2022-12-19T00:29:47+08:00
tag : [ "git", "linux" ]
description: "git删除历史提交记录"
categories: [ "git", "linux" ]
toc: true
---

## 前言
git如果碰到敏感信息提交，需要清理历史提交记录，在不删库的前提下，如何亡羊补牢呢？可以用下面的重写分支操作清理提交历史记录

## 1、重写分支
```bash
git filter-branch --index-filter 'git rm -r --cached --ignore-unmatch src/main/resources/demo.txt' HEAD

# 如果出现冲突要增加-f
git filter-branch  -f --index-filter

# 管理reflog信息
git reflog expire --expire=now --all  

# 清理不必要的文件并优化本地存储库
git gc --prune=now  
git gc --aggressive --prune=now

# 强制推送主分支
git push --all --force
```