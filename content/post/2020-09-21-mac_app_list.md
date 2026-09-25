---
title: "Mac下的工具软件"
date: 2020-09-21T00:29:47+08:00
tags: [ "mac", "app" ]
description: "Mac下的工具软件"
categories: [ "mac", "app" ]
toc: true
---

## 前言

本文最早写于2020年9月，当时准备给自己的 mbp2015 升级固态硬盘（换成西数蓝盘 sn550 1T），为了保险，把手头的工具 App 清单备份下来。

> 2026-09-24 更新：按当前机器实际安装的 App 全量重写了这篇清单（170+ 个），按类目重新归类。图标统一从各 App 安装包内（`*.app/Contents/Resources/AppIcon.icns`）提取并转换成 256x256 PNG，和当年手工整理的方式保持一致；系统自带 App、用户目录下的 App 也一并收录并标注了来源。下载地址只保留官方/项目主页，个别已停止维护或查不到官网的以「—」标注。另补充了 SDK 运行环境、CLI 开发工具与 AI 编程 CLI 三节（见文末）：SDK 图标来自官网高清资源/官方 GitHub 头像，AI CLI 图标取自各官方 GitHub 组织头像，少数无官方图标的以「—」标注。

## 1、开发 IDE 与编辑器

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|IntelliJ IDEA|![](/posts/app/idea.png)|Java 开发主力 IDE|收费，[官网下载地址](https://www.jetbrains.com/idea/)
2|GoLand|![](/posts/app/goland.png)|Go 语言开发 IDE|收费，[官网下载地址](https://www.jetbrains.com/go/)
3|PyCharm|![](/posts/app/pycharm.png)|Python 开发 IDE|收费，[官网下载地址](https://www.jetbrains.com/pycharm/)
4|DataGrip|![](/posts/app/datagrip.png)|JetBrains 出品的数据库多方言客户端|收费，[官网下载地址](https://www.jetbrains.com/datagrip/)
5|Android Studio|![](/posts/app/androidstudio.png)|谷歌官方安卓开发 IDE|免费，[官网下载地址](https://developer.android.com/studio)
6|HBuilderX|![](/posts/app/hbuildx.png)|DCloud 出品的前端 IDE，uni-app 开发利器|免费，[官网下载地址](https://dcloud.io/hbuilderx.html)
7|Cursor|![](/posts/app/cursor.png)|基于 VS Code 的 AI 代码编辑器|免费，[官网下载地址](https://cursor.com)
8|Trae CN|![](/posts/app/trae.png)|字节跳动出品的 AI 编程 IDE（国内版）|免费，[官网下载地址](https://www.trae.cn)
9|CodeBuddy CN|![](/posts/app/codebuddy.png)|腾讯云 AI 编程助手（国内版）|免费，[官网下载地址](https://copilot.tencent.com)
10|Codex++（含管理工具）|![](/posts/app/codexpp.png)|OpenAI Codex CLI 的第三方增强客户端，另装有配套管理工具|—
11|CC Switch|![](/posts/app/ccswitch.png)|Claude Code / Codex 供应商配置切换工具|免费开源，[GitHub](https://github.com/search?q=cc-switch)
12|Sublime Text|![](/posts/app/sublime.png)|轻量快速的文本编辑器|半免费，[官网下载地址](https://www.sublimetext.com)
13|Typora|![](/posts/app/typora.png)|Markdown 所见即所得编辑器，写博客用|收费，[官网下载地址](https://typora.io)
14|Obsidian|![](/posts/app/obsidian.png)|本地优先的双链笔记库，知识管理|免费，[官网下载地址](https://obsidian.md)
15|JProfiler|![](/posts/app/jprofiler.png)|Java 性能剖析（CPU/内存）工具|收费，[官网下载地址](https://www.ej-technologies.com/products/jprofiler/overview.html)
16|Eclipse Memory Analyzer|![](/posts/app/memoryanalyzer.png)|Java 堆转储（heap dump）分析工具|免费开源，[官网下载地址](https://eclipse.dev/mat/)
17|Xcode|![](/posts/app/xcode.png)|苹果官方 IDE，iOS/macOS 开发（位于 ~/Downloads）|免费，Mac App Store
18|Visual Studio Code - Insiders|![](/posts/app/vscodeins.png)|微软开源编辑器抢先版（位于 ~/Downloads）|免费，[官网下载地址](https://code.visualstudio.com/insiders/)
19|GCViewer|![](/posts/app/gcviewer.png)|Java GC 日志可视化分析（位于 ~/Downloads）|免费开源，[GitHub 下载地址](https://github.com/chewiebug/GCViewer)
20|Godot|![](/posts/app/godot.png)|开源 2D/3D 游戏引擎（位于 ~/Downloads）|免费开源，[官网下载地址](https://godotengine.org)

## 2、开发辅助与版本管理

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|Docker Desktop|![](/posts/app/docker.png)|容器引擎桌面版，本地起中间件必备|免费，[官网下载地址](https://www.docker.com/products/docker-desktop/)
2|Sourcetree|![](/posts/app/sourcetree.png)|免费的 Git 图形化客户端|免费，[官网下载地址](https://www.sourcetreeapp.com)
3|Cornerstone|![](/posts/app/cornerstone.png)|Mac 上的老牌 SVN 客户端|收费，[官网下载地址](https://www.assembla.com/home)
4|Beyond Compare|![](/posts/app/beyondcompare.png)|文件/目录逐行对比合并工具|收费，[官网下载地址](https://www.scootersoftware.com)
5|Hex Fiend|![](/posts/app/hexfiend.png)|开源的十六进制编辑器|免费开源，[GitHub 下载地址](https://github.com/ridiculousfish/HexFiend)
6|PlistEdit Pro|![](/posts/app/plisteditpro.png)|macOS plist 属性列表编辑器|收费，[官网下载地址](https://www.fatcatsoftware.com/plisteditpro/)
7|StarUML|![](/posts/app/staruml.png)|UML 建模绘图工具|收费，[官网下载地址](https://staruml.io)
8|Axure RP 9|![](/posts/app/axurerpr.png)|产品原型设计工具|收费，[官网下载地址](https://www.axure.com)
9|draw.io|![](/posts/app/drawio.png)|免费的流程图/架构图绘制工具|免费开源，[官网下载地址](https://www.drawio.com)
10|WebReaver|![](/posts/app/webreaver.png)|Mac 上的 Web 安全扫描工具|—
11|Stacio|![](/posts/app/stacio.png)|半开源半商业的本地/远程 SSH 管理工具，内置 Monaco 编辑器|[GitHub 地址](https://github.com/search?q=stacio)
12|Go2Shell|![](/posts/app/go2shell.png)|从 Finder 当前目录快速打开终端|免费，—
13|支付宝开放平台开发助手|![](/posts/app/alipaydev.png)|支付宝小程序/开放平台调试工具|免费，[开放平台地址](https://open.alipay.com)
14|Python 3.8（含 IDLE）|![](/posts/app/python.png)|python.org 官方安装包运行环境|免费，[官网下载地址](https://www.python.org)
15|MacPorts（含 Python 3.13/3.14）|![](/posts/app/macports.png)|包管理器 MacPorts 安装的 Python 多版本环境|免费开源，[官网下载地址](https://www.macports.org)
16|Claude Code URL Handler|![](/posts/app/claude.png)|Claude Code CLI 的 URL 协议处理器（位于 ~/Applications）|免费，[官网下载地址](https://claude.com/claude-code)
17|微信支付商户平台证书工具|![](/posts/app/wxpaycert.png)|微信支付商户平台 API 证书生成/管理工具（位于 ~/Downloads）|免费，[商户平台地址](https://pay.weixin.qq.com)
18|Chrome Apps|—|Chrome 创建的网页应用快捷方式集合（位于 ~/Applications）|—

## 3、浏览器

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|Google Chrome|![](/posts/app/chrome.png)|主力浏览器|免费，[官网下载地址](https://www.google.com/chrome/)
2|Firefox|![](/posts/app/firefox.png)|Mozilla 开源浏览器|免费，[官网下载地址](https://www.mozilla.org/firefox/)
3|Microsoft Edge|![](/posts/app/microsoftedge.png)|微软 Chromium 内核浏览器|免费，[官网下载地址](https://www.microsoft.com/edge)

## 4、终端与远程连接

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|iTerm2|![](/posts/app/iterm2.png)|替换系统自带 Terminal 的本地终端神器|免费，[官网下载地址](https://iterm2.com)
2|SecureCRT|![](/posts/app/securecrt.png)|经典的服务器 SSH/Telnet 终端|收费，[官网下载地址](https://www.vandyke.com)
3|Termo|![](/posts/app/termo.png)|新一代 SSH 终端（SwiftTerm 内核）|—
4|cmux|![](/posts/app/cmux.png)|跨平台后台 GUI 自动化/多会话窗口管理|—
5|AnyDesk|![](/posts/app/anydesk.png)|轻量远程桌面控制|免费，[官网下载地址](https://anydesk.com)
6|向日葵 SunloginClient|![](/posts/app/sunlogin.png)|国产远程控制，国内远控首选|免费，[官网下载地址](https://sunlogin.oray.com)
7|Windows App|![](/posts/app/windowsapp.png)|微软官方远程桌面客户端（原 Microsoft Remote Desktop），连 Windows 虚拟机用|免费，Mac App Store
8|AirServer|![](/posts/app/airserver.png)|Mac 变身 AirPlay/投屏接收端|收费，[官网下载地址](https://www.airserver.com)
9|ApowerMirror|![](/posts/app/apowermirror.png)|手机屏幕镜像投射到 Mac|—，[官网下载地址](https://apowermirror.com)
10|蒲公英（Oray）|![](/posts/app/pgyer.png)|异地组网/内网穿透客户端，配合 nas 远程访问|免费，[官网下载地址](https://pgy.oray.com)
11|FileZilla|![](/posts/app/filezilla.png)|经典开源 FTP/SFTP 客户端（位于 ~/Downloads）|免费开源，[官网下载地址](https://filezilla-project.org)

## 5、抓包与网络调试

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|Charles|![](/posts/app/charles.png)|HTTP/HTTPS 抓包代理，接口调试必备|收费，[官网下载地址](https://www.charlesproxy.com)
2|Reqable|![](/posts/app/reqable.png)|新一代 API 抓包调试工具，Charles 的替代品|免费增值，[官网下载地址](https://reqable.com)
3|Wireshark|![](/posts/app/wireshark.png)|网络协议分析神器|免费开源，[官网下载地址](https://www.wireshark.org)
4|Little Snitch|![](/posts/app/littlesnitchconfiguration.png)|应用级出站防火墙，监控每个 App 的网络连接|收费，[官网下载地址](https://www.obdev.at/products/littlesnitch/)
5|KnockKnock|![](/posts/app/knockknock.png)|Objective-See 出品的持久化项安全检查（位于 ~/Downloads）|免费，[官网下载地址](https://objective-see.com/products/knockknock.html)

## 6、数据库与中间件

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|Navicat Premium|![](/posts/app/navicatpremium.png)|多数据库统一连接管理客户端|收费，[官网下载地址](https://www.navicat.com)
2|Another Redis Desktop Manager|![](/posts/app/ardm.png)|开源的 Redis 图形化客户端|免费开源，[GitHub 下载地址](https://github.com/qishibo/AnotherRedisDesktopManager)
3|Redis Desktop Manager|![](/posts/app/redisdesktop.png)|老牌 Redis 图形化客户端|—

## 7、虚拟机与移动设备

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|Parallels Desktop|![](/posts/app/parallelsdesktop.png)|Mac 虚拟机龙头，跑 Windows 最顺滑|收费，[官网下载地址](https://www.parallels.com)
2|VMware Fusion|![](/posts/app/vmwarefusion.png)|老牌 Mac 虚拟机，现已对个人免费|免费（个人版），[官网下载地址](https://www.vmware.com/products/fusion.html)
3|爱思助手 i4Tools|![](/posts/app/i4tools.png)|iOS 设备管理/刷机/备份助手|免费，[官网下载地址](https://www.i4.cn)
4|Cydia Impactor|![](/posts/app/impactor.png)|iOS 侧载安装工具|—
5|iExplorer|![](/posts/app/iexplorer.png)|iPhone 文件浏览/导出|收费，[官网下载地址](https://macroplant.com/iexplorer)
6|iMazing|![](/posts/app/imazing.png)|iOS 设备备份与管理|收费，[官网下载地址](https://imazing.com)
7|PhoneClean|![](/posts/app/phoneclean.png)|iOS 设备垃圾清理工具|—
8|Joyoshare iPasscode Unlocker|![](/posts/app/joyoshare.png)|iOS 锁屏密码解锁工具|收费，[官网下载地址](https://www.joyoshare.com)
9|Android File Transfer|![](/posts/app/androidfiletransfer.png)|谷歌官方安卓设备文件传输|免费，[官网下载地址](https://www.android.com/filetransfer/)

## 8、网络代理与 VPN

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|ClashX|![](/posts/app/clashx.png)|Mac 代理客户端（Clash 内核）|免费开源，[GitHub 下载地址](https://github.com/yichengchen/clashX)
2|Surge|![](/posts/app/surge.png)|Mac 网络调试/代理/抓包套件|收费，[官网下载地址](https://nssurge.com)
3|V2rayU|![](/posts/app/v2rayu.png)|v2ray 图形化客户端|免费开源，[GitHub 下载地址](https://github.com/yanue/V2rayU)
4|dev-sidecar|![](/posts/app/devsidecar.png)|开发者边车，本地证书加速 GitHub 等站点|免费开源，[GitHub 下载地址](https://github.com/docmirror/dev-sidecar)
5|CorpLink|![](/posts/app/corplink.png)|火山引擎企业零信任 VPN 客户端，办公接入用|免费，[官网地址](https://www.volcengine.com/product/corplink)
6|iTop VPN|![](/posts/app/itopvpn.png)|VPN 工具|—
7|VPN Plus|![](/posts/app/vpnplus.png)|群晖 Synology 官方 VPN 客户端，连 nas 用|免费，[官网下载地址](https://www.synology.com)
8|Cisco AnyConnect|![](/posts/app/cisioanyconnect.png)|思科企业 VPN 客户端（位于 /Applications/Cisco）|免费，[官网地址](https://www.cisco.com)

## 9、网盘与同步

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|OneDrive|![](/posts/app/onedrive.png)|微软个人网盘同步|免费，[官网下载地址](https://onedrive.live.com)
2|坚果云 Nutstore|![](/posts/app/nutstore.png)|国内最好用的同步网盘，文档同步首选|免费增值，[官网下载地址](https://www.jianguoyun.com)
3|阿里云盘 aDrive|![](/posts/app/adrive.png)|阿里云盘官方客户端|免费，[官网下载地址](https://www.alipan.com)
4|百度网盘|![](/posts/app/naidunetdisk.png)|百度网盘客户端|免费增值，[官网下载地址](https://pan.baidu.com)
5|城通网盘 CTFile|![](/posts/app/ctfile.png)|城通网盘客户端|免费，[官网下载地址](https://www.ctfile.com)
6|夸克网盘|![](/posts/app/quark.png)|夸克网盘客户端|免费，[官网下载地址](https://pan.quark.cn)
7|天翼云盘|![](/posts/app/cloud189.png)|电信天翼云盘客户端|免费，[官网下载地址](https://cloud.189.cn)
8|腾讯微云 Weiyun|![](/posts/app/weiyun.png)|腾讯微云客户端|免费，[官网下载地址](https://www.weiyun.com)

## 10、下载工具

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|迅雷 Thunder|![](/posts/app/thunder.png)|老牌多协议下载器|免费增值，[官网下载地址](https://www.xunlei.com)
2|Free Download Manager|![](/posts/app/freedownloadmanager.png)|免费多线程下载器|免费，[官网下载地址](https://www.freedownloadmanager.org)
3|Motrix|![](/posts/app/motrix.png)|开源全能下载器（aria2 内核），颜值高|免费开源，[官网下载地址](https://motrix.app)
4|Ghost Downloader|![](/posts/app/ghostdownloader.png)|跨平台多线程下载器|免费，—
5|Downie 4|![](/posts/app/downie.png)|视频网站下载神器，支持站点超多|收费，[官网下载地址](https://software.charliemonroe.net/downie/)
6|哔哩下载姬 downkyi|![](/posts/app/bilidownload.png)|B 站视频下载工具|免费开源，[GitHub 下载地址](https://github.com/leiurayer/downkyi)

## 11、图像与设计

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|Sketch|![](/posts/app/sketch.png)|Mac 上的 UI 设计工具|订阅制，[官网下载地址](https://www.sketch.com)
2|OmniGraffle|![](/posts/app/omnigraffle.png)|专业绘图/示意图/线框图工具|收费，[官网下载地址](https://www.omnigroup.com/omnigraffle)
3|亿图 EdrawMax|![](/posts/app/edrawmax.png)|综合办公绘图，流程图/组织结构图/平面图|免费增值，[官网下载地址](https://www.edrawsoft.cn)
4|Monodraw|![](/posts/app/monodraw.png)|ASCII 字符画绘制工具，画架构图很酷|收费，[官网下载地址](https://monodraw.helftone.com)
5|Icons8|![](/posts/app/icons8.png)|图标/插画素材桌面客户端|免费增值，[官网下载地址](https://icons8.com)
6|Optimage|![](/posts/app/optimage.png)|图片无损压缩优化|收费，[官网下载地址](https://optimage.app)
7|Squash|![](/posts/app/squash.png)|图片压缩工具|—
8|Squeezer|![](/posts/app/squeezer.png)|拖拽式图片压缩（菜单栏常驻）|—
9|Shrinker Pro|![](/posts/app/shrinkerpro.png)|图片批量缩放/压缩|—
10|Kompakt|![](/posts/app/kompakt.png)|菜单栏拖拽即压的图片压缩小工具|—
11|JPEGmini Pro|![](/posts/app/jpegminipro.png)|JPEG 智能有损压缩，减体积不损观感|收费，[官网下载地址](https://www.jpegmini.com)
12|PhotoMill X|![](/posts/app/photomill.png)|批量改名/格式转换/加水印|—
13|FigrCollage|![](/posts/app/figrcollage.png)|照片拼贴墙生成工具|—
14|HEIC Converter for Mac|![](/posts/app/geicconverter.png)|iPhone 的 HEIC 照片转 JPG/PNG|—
15|Clearview|![](/posts/app/clearview.png)|漫画/图片集阅读器|—
16|EdgeView 2|![](/posts/app/edgeview2.png)|强大的图片浏览器，替代系统预览|—
17|miniQpicview|![](/posts/app/miniqpicview.png)|轻量快速看图小工具|—
18|Grids|![](/posts/app/gridsforinstagram.png)|Instagram 桌面客户端，看图用|—，[官网下载地址](https://gridsapp.net)

## 12、截图、取色与 OCR

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|macshot|![](/posts/app/macshot.png)|截图美化工具，带外壳阴影|免费，—
2|Xnip|![](/posts/app/xnip.png)|截图/滚动长截图/标注|免费增值，—
3|Pikka|![](/posts/app/pikka.png)|屏幕取色器，色板管理|—
4|iOCR|![](/posts/app/iocr.png)|图片文字识别（OCR）工具|—
5|QR Capture|![](/posts/app/qrcapture.png)|屏幕二维码框选识别|—
6|QR Wizard|![](/posts/app/qrwizard.png)|二维码生成/识别|—
7|QRCode Wizard|![](/posts/app/qrcodewizard.png)|二维码工具|—

## 13、音视频与 GIF

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|IINA|![](/posts/app/iina.png)|macOS 最优雅的视频播放器（mpv 内核）|免费开源，[官网下载地址](https://iina.io)
2|VideoProc|![](/posts/app/videoproc.png)|视频转码/剪辑/压缩/下载一体|免费增值，[官网下载地址](https://www.videoproc.com)
3|Permute 3|![](/posts/app/permute.png)|音视频格式批量转换|收费，[官网下载地址](https://software.charliemonroe.net/permute/)
4|GIF Brewery 3|![](/posts/app/gifbrewery.png)|视频片段转 GIF|—
5|Gifox|![](/posts/app/gifox.png)|屏幕录制区域转 GIF，录动效用|收费，[官网下载地址](https://gifox.io)
6|QuickRecorder|![](/posts/app/quickrecorder.png)|开源轻量录屏工具|免费开源，—

## 14、办公与笔记

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|XMind|![](/posts/app/xmind.png)|思维导图，新版|免费增值，[官网下载地址](https://xmind.cn)
2|XMind ZEN|![](/posts/app/xmindzen.png)|XMind ZEN 分支版本|—
3|MindNode Next|![](/posts/app/mindnodenext.png)|颜值最高的思维导图（订阅版）|订阅制，[官网下载地址](https://www.mindnode.com)
4|有道云笔记|![](/posts/app/youdaonote.png)|网易云笔记，多端同步|免费增值，[官网下载地址](https://note.youdao.com)
5|SoftMaker FreeOffice 2024|![](/posts/app/softmaker.png)|免费办公套件（TextMaker/PlanMaker/Presentations，位于套件目录）|免费，[官网下载地址](https://www.freeoffice.com)
6|Keynote|![](/posts/app/keynote.png)|苹果演示文稿（iWork）|免费，[官网下载地址](https://www.apple.com/keynote/)
7|Numbers|![](/posts/app/numbers.png)|苹果电子表格（iWork）|免费，[官网下载地址](https://www.apple.com/numbers/)
8|Pages|![](/posts/app/pages.png)|苹果文字处理（iWork）|免费，[官网下载地址](https://www.apple.com/pages/)
9|亿图项目 EdrawProject|![](/posts/app/edrawproject.png)|项目管理/甘特图工具|免费增值，[官网下载地址](https://www.edrawsoft.cn)

## 15、IM 通讯与协作

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|微信|![](/posts/app/wechat.png)|国民聊天工具|免费，[官网下载地址](https://weixin.qq.com)
2|企业微信|![](/posts/app/wxwork.png)|企业办公 IM|免费，[官网下载地址](https://work.weixin.qq.com)
3|QQ|![](/posts/app/qq.png)|老牌聊天工具|免费，[官网下载地址](https://im.qq.com)
4|Telegram|![](/posts/app/telegram.png)|加密聊天，频道订阅|免费，[官网下载地址](https://telegram.org)
5|钉钉 DingTalk|![](/posts/app/dingding.png)|阿里企业办公 IM|免费，[官网下载地址](https://www.dingtalk.com)
6|飞书 Lark|![](/posts/app/lark.png)|字节出品协作办公套件（国内版）|免费，[官网下载地址](https://www.feishu.cn)
7|LarkPlus|![](/posts/app/larkplus.png)|钉钉企业版客户端|—
8|腾讯会议|![](/posts/app/metting.png)|视频会议|免费，[官网下载地址](https://meeting.tencent.com)
9|Foxmail|![](/posts/app/foxmail.png)|腾讯出品的邮件客户端|免费，[官网下载地址](https://www.foxmail.com)
10|Twitterrific|![](/posts/app/twitterific.png)|老牌 Twitter 第三方客户端（已停止维护）|—

## 16、系统增强与维护

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|Mos|![](/posts/app/mos.png)|鼠标平滑滚动，外接鼠标必备|免费开源，[官网下载地址](https://mos.caldis.me)
2|iStat Menus|![](/posts/app/istatmenus.png)|菜单栏系统资源监控|收费，[官网下载地址](https://bjango.com/mac/istatmenus/)
3|App Cleaner 9|![](/posts/app/appcleaner.png)|App 彻底卸载/残留清理|—（MacCleaner 套件组件）
4|MacCleaner 4 Pro 套件|![](/posts/app/maccleaner.png)|Nektony 清理套件（含 App Cleaner 9/Disk Expert 6/Duplicate File Finder 8/Funter 7/Memory Cleaner 5，位于套件目录）|收费，[官网下载地址](https://nektony.com)
5|OnyX|![](/posts/app/onyx.png)|系统维护与清理老牌工具|免费，[官网下载地址](https://www.titanium-software.fr)
6|BetterZip|![](/posts/app/betterzip.png)|压缩包预览/快速解压|收费，[官网下载地址](https://macitbetter.com)
7|The Unarchiver|![](/posts/app/unarchiver.png)|全格式解压工具|免费，[官网下载地址](https://theunarchiver.com)
8|赤友 NTFS 助手|![](/posts/app/aoyountfs.png)|NTFS 移动硬盘读写挂载|收费，—
9|balenaEtcher|![](/posts/app/balenaetcher.png)|系统镜像烧录到 U 盘/SD 卡|免费开源，[官网下载地址](https://balena.io/etcher)
10|Carbon Copy Cloner|![](/posts/app/ccc.png)|磁盘克隆/定时备份|收费，[官网下载地址](https://bombich.com)
11|XQuartz|![](/posts/app/xquartz.png)|X11 窗口服务，跑 Unix 图形程序用（位于 /Applications/Utilities）|免费开源，[官网下载地址](https://xquartz.org)
12|LittleClean|![](/posts/app/littleclean.png)|轻量清理小工具（位于 ~/Downloads）|—

## 17、娱乐与游戏

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|Dead Cells|![](/posts/app/deadcells.png)|死亡细胞，肉鸽平台跳跃|收费，[Steam 商店](https://store.steampowered.com/app/588650/Dead_Cells/)
2|Factorio|![](/posts/app/factorio_gear.png)|异星工厂，自动化流水线（另存有 factorio 2/3 多个版本副本）|收费，[官网下载地址](https://factorio.com)

## 18、系统自带 App（/System/Applications）

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|Safari|![](/posts/app/sys_safari.png)|系统默认浏览器|系统自带
2|App Store|![](/posts/app/sys_appstore.png)|应用商店|系统自带
3|Mail|![](/posts/app/sys_mail.png)|系统邮件客户端|系统自带
4|Messages|![](/posts/app/sys_messages.png)|iMessage 信息|系统自带
5|FaceTime|![](/posts/app/sys_facetime.png)|视频通话|系统自带
6|Maps|![](/posts/app/sys_maps.png)|地图|系统自带
7|Photos|![](/posts/app/sys_photos.png)|照片管理|系统自带
8|Preview|![](/posts/app/sys_preview.png)|预览，看图/PDF/标注|系统自带
9|QuickTime Player|![](/posts/app/sys_quicktimeplayer.png)|视频播放/录屏|系统自带
10|Notes|![](/posts/app/sys_notes.png)|备忘录|系统自带
11|Reminders|![](/posts/app/sys_reminders.png)|提醒事项|系统自带
12|Calendar|![](/posts/app/sys_calendar.png)|日历|系统自带
13|Contacts|![](/posts/app/sys_contacts.png)|通讯录|系统自带
14|Calculator|![](/posts/app/sys_calculator.png)|计算器|系统自带
15|Clock|![](/posts/app/sys_clock.png)|时钟/世界时间/闹钟|系统自带
16|Music|![](/posts/app/sys_music.png)|Apple Music|系统自带
17|TV|![](/posts/app/sys_tv.png)|Apple TV|系统自带
18|Podcasts|![](/posts/app/sys_podcasts.png)|播客|系统自带
19|Books|![](/posts/app/sys_books.png)|图书|系统自带
20|Dictionary|![](/posts/app/sys_dictionary.png)|系统词典|系统自带
21|Font Book|![](/posts/app/sys_fontbook.png)|字体册|系统自带
22|Freeform|![](/posts/app/sys_freeform.png)|无边记，自由画板|系统自带
23|Weather|![](/posts/app/sys_weather.png)|天气|系统自带
24|Stocks|![](/posts/app/sys_stocks.png)|股市|系统自带
25|News|![](/posts/app/sys_news.png)|新闻|系统自带
26|Home|![](/posts/app/sys_home.png)|家庭，智能家居中枢|系统自带
27|Passwords|![](/posts/app/sys_passwords.png)|密码，iCloud 钥匙串管理|系统自带
28|Shortcuts|![](/posts/app/sys_shortcuts.png)|快捷指令|系统自带
29|Stickies|![](/posts/app/sys_stickies.png)|便签|系统自带
30|Time Machine|![](/posts/app/sys_timemachine.png)|系统备份|系统自带
31|Automator|![](/posts/app/sys_automator.png)|自动化工作流|系统自带
32|Image Capture|![](/posts/app/sys_imagecapture.png)|图像捕捉，导入扫描仪/相机|系统自带
33|Photo Booth|![](/posts/app/sys_photobooth.png)|拍照/特效|系统自带
34|VoiceMemos|![](/posts/app/sys_voicememos.png)|语音备忘录|系统自带
35|FindMy|![](/posts/app/sys_findmy.png)|查找设备|系统自带
36|Mission Control|![](/posts/app/sys_missioncontrol.png)|调度中心|系统自带
37|Launchpad|![](/posts/app/sys_launchpad.png)|启动台|系统自带
38|TextEdit|![](/posts/app/sys_textedit.png)|文本编辑|系统自带
39|System Settings|![](/posts/app/sys_systemsettings.png)|系统设置|系统自带
40|Siri|![](/posts/app/sys_siri.png)|语音助手|系统自带
41|Chess|![](/posts/app/sys_chess.png)|国际象棋|系统自带
42|Image Playground|![](/posts/app/sys_imageplayground.png)|AI 图像游乐场（生成趣味图）|系统自带
43|iPhone Mirroring|![](/posts/app/sys_iphonemirroring.png)|iPhone 镜像，Mac 上操作手机|系统自带
44|Tips|![](/posts/app/sys_tips.png)|使用技巧|系统自带

## 19、系统自带实用工具（/System/Applications/Utilities）

序号|App名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|Terminal|![](/posts/app/sys_terminal.png)|系统自带终端|系统自带
2|Activity Monitor|![](/posts/app/sys_activitymonitor.png)|活动监视器，进程/资源监控|系统自带
3|Disk Utility|![](/posts/app/sys_diskutility.png)|磁盘工具，分区/抹掉/急救|系统自带
4|Console|![](/posts/app/sys_console.png)|控制台，查系统日志|系统自带
5|Screenshot|![](/posts/app/sys_screenshot.png)|截屏工具|系统自带
6|Screen Sharing|![](/posts/app/sys_screensharing.png)|屏幕共享|系统自带
7|Digital Color Meter|![](/posts/app/sys_digitalcolormeter.png)|数码测色计|系统自带
8|Grapher|![](/posts/app/sys_grapher.png)|函数绘图器|系统自带
9|Script Editor|![](/posts/app/sys_scripteditor.png)|脚本编辑器（AppleScript）|系统自带
10|System Information|![](/posts/app/sys_systeminformation.png)|系统信息，硬件规格|系统自带
11|AirPort Utility|![](/posts/app/sys_airportutility.png)|AirPort 基站工具|系统自带
12|Audio MIDI Setup|![](/posts/app/sys_audiomidisetup.png)|音频 MIDI 设置|系统自带
13|Bluetooth File Exchange|![](/posts/app/sys_bluetoothfileexchange.png)|蓝牙文件交换|系统自带
14|Boot Camp Assistant|![](/posts/app/sys_bootcampassistant.png)|启动转换助理|系统自带
15|ColorSync Utility|![](/posts/app/sys_colorsyncutility.png)|色彩同步工具|系统自带
16|Migration Assistant|![](/posts/app/sys_migrationassistant.png)|迁移助理|系统自带
17|Print Center|![](/posts/app/sys_printcenter.png)|打印中心|系统自带
18|VoiceOver Utility|![](/posts/app/sys_voiceoverutility.png)|VoiceOver 实用工具|系统自带

## 20、SDK 与运行环境

序号|名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|JDK 8（Oracle 1.8.0_251）|![](/posts/app/java.png)|老项目维护用的 Oracle JDK 8（x86_64，Rosetta 运行）|[官网下载地址](https://www.oracle.com/java/technologies/downloads/)
2|JDK 21（Oracle）|![](/posts/app/java.png)|主力 LTS 版本，SDKMAN 管理（本地安装包导入）|[官网下载地址](https://www.oracle.com/java/technologies/downloads/)
3|JDK 25（Oracle）|![](/posts/app/java.png)|最新版本，SDKMAN 管理|[官网下载地址](https://www.oracle.com/java/technologies/downloads/)
4|Go 1.26.2|![](/posts/app/go.png)|GVM 管理的 Go 工具链|[官网下载地址](https://go.dev/dl/)
5|Node.js v22.22.1|![](/posts/app/nodejs.png)|NVM 管理的 Node LTS，含 npm 10.9.4 与 corepack|[官网下载地址](https://nodejs.org)
6|Bun 1.3.11|![](/posts/app/bun.png)|新一代一体化 JS 运行时/打包器（npm 全局安装）|[官网下载地址](https://bun.sh)
7|Python 3.13.5|![](/posts/app/python.png)|系统自带 Python3|[官网地址](https://www.python.org)
8|Python 3.8|![](/posts/app/python.png)|python.org 官方安装包版本（/Applications，含 IDLE）|[官网下载地址](https://www.python.org/downloads/)
9|Python 3.13 / 3.14|![](/posts/app/macports.png)|MacPorts 安装的多版本（/Applications/MacPorts）|[官网地址](https://www.macports.org)
10|Rust 1.94.1|![](/posts/app/rust.png)|rustup 管理的 Rust 工具链，含 cargo/clippy/rustfmt/rust-analyzer|[官网下载地址](https://www.rust-lang.org/tools/install)
11|Maven 3.5.4 / 3.9.10 / 3.9.14|![](/posts/app/maven.png)|Java 构建工具，SDKMAN 管理多版本|[官网下载地址](https://maven.apache.org)
12|Gradle 9.4|![](/posts/app/gradle.png)|Java/Android 构建工具，SDKMAN 管理|[官网下载地址](https://gradle.org)
13|Kotlin 2.3.20|![](/posts/app/kotlin.png)|Kotlin 编译器，SDKMAN 管理|[官网下载地址](https://kotlinlang.org)
14|Ant 1.10.5|![](/posts/app/ant.png)|老牌 Java 构建工具，SDKMAN 管理|[官网下载地址](https://ant.apache.org)
15|mvnd 0.7.1 / 1.0.3 / 1.0.4|![](/posts/app/maven.png)|Maven 守护进程（Maven Daemon），构建提速，SDKMAN 管理|[GitHub 下载地址](https://github.com/apache/maven-mvnd)
16|Tomcat 7|![](/posts/app/tomcat.png)|老版本 Servlet 容器，SDKMAN 管理|[官网下载地址](https://tomcat.apache.org)
17|JMeter 5.1 / 5.6|![](/posts/app/jmeter.png)|Apache 压测工具，SDKMAN 管理|[官网下载地址](https://jmeter.apache.org)
18|Subversion|![](/posts/app/svn.png)|brew 安装的 SVN 命令行|[官网下载地址](https://subversion.apache.org)
19|Miniconda（conda 25.7.0）|![](/posts/app/conda.png)|Python 发行版/环境管理器，含 Python 3.13.5 环境|[官网下载地址](https://docs.conda.io/en/latest/miniconda.html)
20|GraalVM（JDK 8/17/21）|![](/posts/app/graalvm.png)|Oracle 高性能 JDK 发行版，含 Native Image（dev_tools 下）|[官网下载地址](https://www.graalvm.org)

## 21、CLI 开发工具

序号|名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|Homebrew|![](/posts/app/brew.png)|macOS 包管理器，本机 /usr/local（Intel 架构）|[官网下载地址](https://brew.sh)
2|SDKMAN!|![](/posts/app/sdkman.png)|JVM 系 SDK/工具多版本管理器（java/maven/gradle/kotlin 等）|[官网下载地址](https://sdkman.io)
3|GVM|—|Go 版本管理器|[GitHub 下载地址](https://github.com/moovweb/gvm)
4|NVM|![](/posts/app/nvm.png)|Node 版本管理器|[GitHub 下载地址](https://github.com/nvm-sh/nvm)
5|rustup|![](/posts/app/rust.png)|Rust 工具链管理器|[官网下载地址](https://rustup.rs)
6|Hugo v0.164.0|![](/posts/app/hugo.png)|本博客静态站点生成器（go install 安装）|[官网下载地址](https://gohugo.io)
7|gopls|![](/posts/app/go.png)|Go 官方 LSP 语言服务器，IDE 补全跳转靠它|[GitHub 下载地址](https://github.com/golang/tools)
8|migrate|![](/posts/app/migrate.png)|数据库 schema 迁移 CLI|[GitHub 下载地址](https://github.com/golang-migrate/migrate)
9|py7zr|—|pipx 安装的 7z 压缩/解压 CLI|[GitHub 下载地址](https://github.com/miurank/py7zr)
10|asciinema|![](/posts/app/asciinema.png)|终端会话录制与回放（miniconda 环境安装）|免费开源，[官网下载地址](https://asciinema.org)
11|uv / uvx|![](/posts/app/uv.png)|Astral 出品的极速 Python 包管理器|免费开源，[GitHub 下载地址](https://github.com/astral-sh/uv)
12|Nuitka|![](/posts/app/nuitka.png)|Python 编译器，编译为 C 提升性能|免费开源，[GitHub 下载地址](https://github.com/Nuitka/Nuitka)
13|pyright|![](/posts/app/pyright.png)|微软出品 Python 静态类型检查/LSP|免费开源，[GitHub 下载地址](https://github.com/microsoft/pyright)
14|aria2|![](/posts/app/aria2.png)|多协议多线程命令行下载器|免费开源，[GitHub 下载地址](https://github.com/aria2/aria2)
15|crane|—|容器镜像操作 CLI（go-containerregistry）|免费开源，[GitHub 下载地址](https://github.com/google/go-containerregistry)
16|Graphviz（dot）|![](/posts/app/graphviz.png)|DOT 语言绘图工具（MacPorts 安装）|免费开源，[官网下载地址](https://graphviz.org)
17|jdtls|![](/posts/app/eclipse-jdtls.png)|Eclipse JDT Language Server，Java 版的 gopls（位于 ~/Downloads/dev_tools）|免费开源，[GitHub 下载地址](https://github.com/eclipse-jdtls/eclipse.jdt.ls)
18|gh|![](/posts/app/gh.png)|GitHub 官方命令行（dev_tools 下 v2.96.0）|免费开源，[GitHub 下载地址](https://github.com/cli/cli)
19|helm|![](/posts/app/helm.png)|Kubernetes 包管理 CLI（dev_tools 下 v4.2.4）|免费开源，[官网下载地址](https://helm.sh)

## 22、AI 编程 CLI（npm 全局）

序号|名称|图标|简单介绍|下载地址
|-|-|-|-|-|
1|Claude Code 2.1.150|![](/posts/app/claude.png)|Anthropic 官方终端 AI 编程助手，日常主力|[npmjs 地址](https://www.npmjs.com/package/@anthropic-ai/claude-code)
2|OpenAI Codex CLI 0.116.0|![](/posts/app/codex.png)|OpenAI 官方终端编程 Agent|[npmjs 地址](https://www.npmjs.com/package/@openai/codex)
3|Gemini CLI 0.49.0|![](/posts/app/gemini.png)|Google 官方 Gemini 终端助手|[npmjs 地址](https://www.npmjs.com/package/@google/gemini-cli)
4|OpenCode 1.17.7|![](/posts/app/opencode.png)|开源终端 AI 编程 Agent（opencode-ai）|[npmjs 地址](https://www.npmjs.com/package/opencode-ai)
5|iFlow CLI 0.5.18|![](/posts/app/iflow.png)|iFlow 心流 AI 编程 CLI|[npmjs 地址](https://www.npmjs.com/package/@iflow-ai/iflow-cli)
6|Qoder CLI 0.2.15|![](/posts/app/qoder.png)|Qoder AI 编程 CLI|[npmjs 地址](https://www.npmjs.com/package/@qoder-ai/qodercli)
7|pi coding agent 0.84.2|![](/posts/app/pi.png)|pi 终端编程 Agent|[npmjs 地址](https://www.npmjs.com/package/@earendil-works/pi-coding-agent)
8|OpenSpec 1.4.0|![](/posts/app/openspec.png)|规格驱动开发（Spec-Driven Development）工具|[npmjs 地址](https://www.npmjs.com/package/@fission-ai/openspec)
9|spec-kit（specify）|![](/posts/app/speckit.png)|Google 出品的规格驱动开发 CLI（pipx 安装）|[GitHub 下载地址](https://github.com/google/spec-kit)
10|OpenClaw 2026.3.12|![](/posts/app/openclaw.png)|开源个人 AI 助手框架（Claw）|[npmjs 地址](https://www.npmjs.com/package/openclaw)
11|ClawHub 0.8.0|![](/posts/app/clawhub.png)|OpenClaw 生态的 Skill/插件市场 CLI|[npmjs 地址](https://www.npmjs.com/package/clawhub)
12|CodeGraph 0.9.5|![](/posts/app/codegraph.png)|代码知识图谱 CLI（tree-sitter 解析，MCP 服务）|[npmjs 地址](https://www.npmjs.com/package/@colbymchenry/codegraph)
13|agent-database-cli 0.2.24|![](/posts/app/adbcli.png)|AI 数据库助手 CLI|[npmjs 地址](https://www.npmjs.com/package/agent-database-cli)
14|dbx-cli 0.1.3|![](/posts/app/dbxcli.png)|数据库 CLI 工具|[npmjs 地址](https://www.npmjs.com/package/@jianzhangg/dbx-cli)
15|drawio MCP Server 0.1.17|![](/posts/app/drawio.png)|draw.io 的 MCP 服务，AI 画图用|[npmjs 地址](https://www.npmjs.com/package/@next-ai-drawio/mcp-server)
16|claude-skill-antivirus 2.1.3|![](/posts/app/skillav.png)|Claude Skills 安全扫描|[npmjs 地址](https://www.npmjs.com/package/claude-skill-antivirus)
17|skill-checker 0.2.0|![](/posts/app/skillchecker.png)|Claude Skills 质量检测|[npmjs 地址](https://www.npmjs.com/package/skill-checker)
18|skilllens 0.1.1|![](/posts/app/skilllenscli.png)|Claude Skills 浏览查看|[npmjs 地址](https://www.npmjs.com/package/skilllens)
