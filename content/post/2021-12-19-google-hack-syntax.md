---
title: "Google Hacking：搜索引擎语法的信息收集技巧"
date: 2021-12-19T08:00:00+08:00
tags: [ "安全", "渗透测试" ]
description: "Google Hacking 常用搜索语法：用 filetype/intitle/inurl/site 等操作符发现暴露的登录页、密码文件、备份文件与目录列表，附自查防护建议"
categories: [ "安全" ]
toc: true
---

## 前言

Google Hacking 指用搜索引擎的高级语法发现互联网上意外暴露的敏感信息——登录页、密码表格、备份文件、目录列表。对渗透测试者它是信息收集的第一步；对运维和开发，它的价值在于**自查**：用同样的语法搜自己域名，看看有没有不该暴露的东西。

## 一、常用操作符

| 操作符 | 作用 | 示例 |
| - | - | - |
| `site:` | 限定站点 | `site:example.com admin` |
| `filetype:` / `ext:` | 限定文件类型 | `filetype:xls 密码` |
| `intitle:` | 标题包含关键词 | `intitle:"index of"` |
| `inurl:` | URL 包含关键词 | `inurl:admin login` |
| `allinurl:` | URL 包含全部关键词 | `allinurl:auth_user_file.txt` |
| `intext:` | 正文包含关键词 | `intext:"password"` |
| `""` | 精确短语 | `"Login:" "password="` |
| `-` | 排除 | `filetype:xls -site:example.com` |

## 二、典型用法

**搜暴露的账号密码文件**：

```txt
"Login: " "password =" filetype:xls
filetype:xls inurl:"password.xls"     # 常见变体："admin.xls"
filetype:xls username password email  # 表格中同时含用户名密码列
```

**搜服务器上的敏感文件**：

```txt
allinurl:auth_user_file.txt          # 暴露的认证文件
intitle:"Index of" master.passwd     # 密码页面索引
index of /backup                     # 目录列表暴露的备份
intitle:index.of people.lst
intitle:index.of passwd.bak          # 密码备份文件
intitle:"Index of" pwd.db            # 数据库密码文件
intitle:"Index of .. etc" passwd     # 安装密码建立页面
index.of passlist.txt
index.of secret                      # 机密文档（.gov 类型网站除外）
"# PhpMyAdmin MySQL-Dump" filetype:txt   # 导出的含敏感数据的 php 页面
```

**搜暴露的登录入口**：

```txt
intitle:login password               # 登录关键词在标题中的页面
```

## 三、用法背后的思路

三条主线：**文件类型**（filetype 定向找 xls/txt/log）、**目录列表**（intitle:"index of" 找配错索引的目录）、**特征字符串**（报错信息、软件默认页面、导出文件头）。实际组合时把目标域名、公司名、系统特征词与这三类操作符交叉，命中率远高于裸搜。

## 四、自查建议

拿这些语法搜自己的域名（`site:yourcompany.com` + 上述特征），重点排查：

1. 有没有可被搜索引擎索引的备份文件、导出的 xls、日志文件
2. 测试环境/管理后台是否暴露在公网且可被索引
3. Web 服务器是否开启了目录列表（Directory Index）
4. 敏感目录加认证 + `robots.txt` 并不够——真正有效的是**不要把敏感文件放在 Web 根目录**，必要时加 `X-Robots-Tag` 响应头

搜索引擎只是「收录了已经暴露的东西」——Google Hacking 挖出的每个结果，本质都是一个低级但真实的配置失误。

## 总结

语法本身不难，难在组合的想象力。渗透前用十几分钟做一轮 Google Hacking，经常比扫端口更快拿到入口；反过来，定期用同样的语法自查自家域名，是最便宜的安全巡检。
