---
title: "渗透测试的部分资料"
date: 2022-05-25T00:29:47+08:00
tag : [ "testing" ]
description: "渗透测试的部分资料"
categories: [ "testing" ]
toc: true
---

## 前言
整理了一些渗透测试的资料，方便查阅。

## 1、漏洞扫描

### 1.1 xray

xray 是一款功能强大的安全评估工具，由多名经验丰富的一线安全从业者呕心打造而成，主要特性有:

- **检测速度快**。发包速度快; 漏洞检测算法高效。
- **支持范围广**。大至 OWASP Top 10 通用漏洞检测，小至各种 CMS 框架 POC，均可以支持。
- **代码质量高**。编写代码的人员素质高, 通过 Code Review、单元测试、集成测试等多层验证来提高代码可靠性。
- **高级可定制**。通过配置文件暴露了引擎的各种参数，通过修改配置文件可以极大的客制化功能。
- **安全无威胁**。xray 定位为一款安全辅助评估工具，而不是攻击工具，内置的所有 payload 和 poc 均为无害化检查。

目前支持的漏洞检测类型包括:

- XSS漏洞检测 (key: xss)
- SQL 注入检测 (key: sqldet)
- 命令/代码注入检测 (key: cmd-injection)
- 目录枚举 (key: dirscan)
- 路径穿越检测 (key: path-traversal)
- XML 实体注入检测 (key: xxe)
- 文件上传检测 (key: upload)
- 弱口令检测 (key: brute-force)
- jsonp 检测 (key: jsonp)
- ssrf 检测 (key: ssrf)
- 基线检查 (key: baseline)
- 任意跳转检测 (key: redirect)
- CRLF 注入 (key: crlf-injection)
- Struts2 系列漏洞检测 (高级版，key: struts)
- Thinkphp系列漏洞检测 (高级版，key: thinkphp)
- POC 框架 (key: phantasm)

#### [设计理念](https://docs.xray.cool/#/?id=设计理念)

1. 发最少的包做效果最好的探测。

   如果一个请求可以确信漏洞存在，那就发一个请求。如果两种漏洞环境可以用同一个 payload 探测出来，那就 不要拆成两个。

2. 允许一定程度上的误报来换取扫描速度的提升

   漏洞检测工具无法面面俱到，在漏报和误报的选择上必然要选择误报。如果在使用中发现误报比较严重，可以进行反馈。

- 尽量不用时间盲注等机制检测漏洞。

  时间检测受影响因素太多且不可控，而且可能会影响其他插件的运行。因此除非必要（如 sql）请尽量使用与时间无关的 payload。

- 尽量不使用盲打平台

  如果一个漏洞能用回显检测就用回显检测，因为盲打平台增加了漏洞检测过程的不确定性和复杂性。

- 耗时操作谨慎处理

  全局使用 Context 做管理，不会因为某个请求而导致全局卡死。

#### [简易架构](https://docs.xray.cool/#/?id=简易架构)

整体来看，扫描器这类工具大致都是由三部分组成：

1. 来源处理
2. 漏洞检测
3. 结果输出

##### [来源处理](https://docs.xray.cool/#/?id=来源处理)

这一部分的功能是整个漏洞检测的入口，在 xray 中我们定义了 5 个入口，分别是

- HTTP 被动代理
- 简易爬虫
- 单个 URL
- URL列表的文件
- 单个原始 HTTP 请求文件

##### [漏洞检测](https://docs.xray.cool/#/?id=漏洞检测)

这一部分是引擎的核心功能，用于处理前面 来源处理 部分产生的标准化的请求。用户可以针对性的启用插件，配置扫描插件的参数，配置 HTTP 相关参数等。

##### [结果输出](https://docs.xray.cool/#/?id=结果输出)

漏洞扫描和运行时的状态统称为结果输出，xray 定义了如下几种输出方式:

- Stdout (屏幕输出, 默认开启)
- JSON 文件输出
- HTML 报告输出
- Webhook 输出

#### [代理模式](https://docs.xray.cool/#/tutorial/webscan_proxy?id=使用-xray-代理模式进行漏洞扫描)

##### [生成 ca 证书](https://docs.xray.cool/#/tutorial/webscan_proxy?id=生成-ca-证书)

在浏览器使用 https 协议通信的情况下，必须要得到客户端的信任，才能建立与客户端的通信。

这里的突破口就是 ca 证书。只要自定义的 ca 证书得到了客户端的信任，xray 就能用该 ca 证书签发各种伪造的服务器证书，从而获取到通信内容。

运行 `./xray_darwin_amd64 genca` 即可生成 ca 证书，保存为 `ca.crt` 和 `ca.key` 两个文件。

运行命令之后，将在当前文件夹生成 `ca.crt` 和 `ca.key` 两个文件。

本命令只需要第一次使用的时候运行即可，如果文件已经存在再次运行会报错，需要先删除本地的 `ca.crt` 和 `ca.key` 文件。

```bash
Last login: Sun Apr 17 01:24:34 on ttys000
mannix@MannixdeMacBook-Pro-2 ~ % cd Desktop/xray_darwin_amd64
mannix@MannixdeMacBook-Pro-2 xray_darwin_amd64 % ./xray_darwin_amd64 genca

____  ___.________.    ____.   _____.___.
\   \/  /\_   __   \  /  _  \  \__  |   |
 \     /  |    _  _/ /  /_\  \  /   |   |
 /     \  |    |   \/    |    \ \____   |
\___/\  \ |____|   /\____|_   / / _____/
      \_/       \_/        \_/  \/

Version: 1.8.4/a47961e0/COMMUNITY-ADVANCED
Licensed to tangshoupu, license is valid until 2022-08-03 08:00:00
```

![image-20220417134619810](https://cdn.jsdelivr.net/gh/Asura88/Mannix/img/202204171346877.png)

##### [安装 ca 证书](https://docs.xray.cool/#/tutorial/webscan_proxy?id=安装-ca-证书)

双击 `ca.crt`，然后按照下图的步骤操作。

右上角搜索 `x-ray`，可以看到一条记录，有一个红叉，被标记为不受信任的。

![image-20220417140809490](https://cdn.jsdelivr.net/gh/Asura88/Mannix/img/202204171408560.png)

然后双击这条记录，将 `SSL` 那一项改为始终信任，然后点击左上角关闭窗口，输入密码授权。

![image-20220417140918077](https://cdn.jsdelivr.net/gh/Asura88/Mannix/img/202204171409126.png)

##### [启动代理](https://docs.xray.cool/#/tutorial/webscan_proxy?id=启动代理)

第一次启动 xray 之后，当前目录会生成 `config.yml` 文件，选择文件编辑器打开，并按照下方说明修改。

- `mitm` 中 `restriction` 中 `hostname_allowed` 增加 `testphp.vulnweb.com`

```
mitm:
  ...
  restriction:                          
    hostname_allowed:                   # 允许访问的 Hostname，支持格式如 t.com、*.t.com、1.1.1.1、1.1.1.1/24、1.1-4.1.1-8
    - testphp.vulnweb.com
```

因为我们的测试目标站就是 `http://testphp.vulnweb.com`，增加这个过滤之后，xray 将只会扫描该站的流量，避免扫描到非授权目标站点。

- 设定漏洞扫描结果的输出，这里选择使用 html 文件输出，所以命令行后面要增加 `--html-output xray-testphp.html`。

```bash
./xray_darwin_amd64 webscan --listen 127.0.0.1:7777 --html-output xray-testphp.html
```

```bash
mannix@MannixdeMacBook-Pro-2 xray_darwin_amd64 % ./xray_darwin_amd64 webscan --listen 127.0.0.1:7777 --html-output xray-testphp.html

____  ___.________.    ____.   _____.___.
\   \/  /\_   __   \  /  _  \  \__  |   |
 \     /  |    _  _/ /  /_\  \  /   |   |
 /     \  |    |   \/    |    \ \____   |
\___/\  \ |____|   /\____|_   / / _____/
      \_/       \_/        \_/  \/

Version: 1.8.4/a47961e0/COMMUNITY-ADVANCED
Licensed to tangshoupu, license is valid until 2022-08-03 08:00:00

[INFO] 2022-04-17 14:14:56 [default:entry.go:213] Loading config file from config.yaml

Enabled plugins: [crlf-injection upload shiro sqldet ssrf xxe struts baseline cmd-injection redirect xss thinkphp brute-force dirscan jsonp path-traversal phantasm fastjson]

[INFO] 2022-04-17 14:14:56 [phantasm:phantasm.go:180] 358 pocs have been loaded (debug level will show more details)
[INFO] 2022-04-17 14:14:56 [shiro:shiro.go:64] found shiro key in config, merge its with the default key list
[INFO] 2022-04-17 14:14:56 [shiro:shiro.go:72] shiro key count 1115
These plugins will be disabled as reverse server is not configured, check out the reference to fix this error.
Ref: https://docs.xray.cool/#/configration/reverse
Plugins:
	fastjson/fastjson/deserialization
	poc-yaml-dlink-cve-2019-16920-rce
	poc-yaml-jenkins-cve-2018-1000600
	poc-yaml-jira-cve-2019-11581
	poc-yaml-jira-ssrf-cve-2019-8451
	poc-yaml-mongo-express-cve-2019-10758
	poc-yaml-pandorafms-cve-2019-20224-rce
	poc-yaml-saltstack-cve-2020-16846
	poc-yaml-solr-cve-2017-12629-xxe
	poc-yaml-supervisord-cve-2017-11610
	poc-yaml-weblogic-cve-2017-10271
	ssrf/ssrf/default
	struts/s2-052/default
	xxe/xxe/blind


[INFO] 2022-04-17 14:14:57 [collector:mitm.go:215] loading cert from ./ca.crt and ./ca.key
[INFO] 2022-04-17 14:14:57 [collector:mitm.go:270] starting mitm server at 127.0.0.1:7777
```

![image-20220417141619539](https://cdn.jsdelivr.net/gh/Asura88/Mannix/img/202204171416609.png)

##### [配置代理](https://docs.xray.cool/#/tutorial/webscan_proxy?id=配置代理)

##### [开始扫描](https://docs.xray.cool/#/tutorial/webscan_proxy?id=开始扫描)

#### [爬虫模式](https://docs.xray.cool/#/tutorial/webscan_basic_crawler?id=使用-xray-基础爬虫模式进行漏洞扫描)

爬虫模式是模拟人工去点击网页的链接，然后去分析扫描，和代理模式不同的是，爬虫不需要人工的介入，访问速度要快很多，但是也有一些缺点需要注意

- xray 的基础爬虫不能处理 js 渲染的页面

##### [启动爬虫](https://docs.xray.cool/#/tutorial/webscan_basic_crawler?id=启动爬虫)

###### 基础爬虫

```bash
./xray_darwin_amd64 webscan --basic-crawler http://testphp.vulnweb.com/ --html-output xray-crawler-testphp.html
```

###### 高级爬虫

> 需要结合爬虫工具 Rad 共同使用

```bash
./xray_darwin_amd64 webscan --browser-crawler http://testphp.vulnweb.com/ --html-output xray-crawler-testphp.html
```

##### [登录后的网站扫描](https://docs.xray.cool/#/tutorial/webscan_basic_crawler?id=登录后的网站扫描)

如果用的是代理模式，只要浏览器是登录状态，那么漏洞扫描收到的请求也都是登录状态的请求。但对于普通爬虫而言，就没有这么“自动化”了， 但是可以通过配置 Cookie 的方式实现登录后的扫描。

打开配置文件，修改 `http` 配置部分的 `Headers` 项:

```
http:
  headers:
    Cookie: key=value
```

上述配置将为所有请求（包括爬虫和漏洞扫描）增加一条 Cookie `key=value`

#### [服务扫描](https://docs.xray.cool/#/tutorial/service_scan?id=使用-xray-进行服务扫描)

xray 中最常见的是 web 扫描，但是 xray 将会逐渐开放服务扫描的相关能力，目前主要是服务扫描相关的 poc。老版本升级的用户请注意配置文件需要加入服务扫描的相关 poc 名字，目前只有一个 tomcat-cve-2020-1938 ajp 协议任意文件检测 poc。

参数配置目前比较简单，输入支持两种方式，例如:

```bash
快速检测单个目标
./xray servicescan --target 127.0.0.1:8009

批量检查的 1.file 中的目标, 一行一个目标，带端口
./xray servicescan --target-file 1.file 
```

其中 1.file 的格式为一个行一个 service，如

```
10.3.0.203:8009
127.0.0.1:8009
```

也可以将结果输出到报告或json文件中

```bash
将检测结果输出到 html 报告中
./xray servicescan --target 127.0.0.1:8009 --html-output service.html
./xray servicescan --target-file 1.file --html-output service.html

将检测结果输出到 json 文件中
./xray servicescan --target 127.0.0.1:8099 --json-output 1.json 
```

```
NAME:
    servicescan - Run a service scan task

USAGE:
    servicescan [command options] [arguments...]

OPTIONS:
   --target value       specify the target, for example: host:8009
   --target-file value  load targets from a local file, one target a line
   --json-output FILE   output xray results to FILE in json format
   --html-output FILE   output xray result to `FILE` in HTML format
```

#### HTTP 配置

对于 web 扫描来说，http 协议的交互是整个过程检测过程的核心。因此这里的配置将影响到引擎进行 http 发包时的行为。

```
http:
  proxy: ""                             # 漏洞扫描时使用的代理，如: http://127.0.0.1:8080。 如需设置多个代理，请使用 proxy_rule 或自行创建上层代理
  proxy_rule: []                        # 漏洞扫描使用多个代理的配置规则, 具体请参照文档
  dial_timeout: 5                       # 建立 tcp 连接的超时时间
  read_timeout: 10                      # 读取 http 响应的超时时间，不可太小，否则会影响到 sql 时间盲注的判断
  max_conns_per_host: 50                # 同一 host 最大允许的连接数，可以根据目标主机性能适当增大
  enable_http2: false                   # 是否启用 http2, 开启可以提升部分网站的速度，但目前不稳定有崩溃的风险
  fail_retries: 0                       # 请求失败的重试次数，0 则不重试
  max_redirect: 5                       # 单个请求最大允许的跳转数
  max_resp_body_size: 2097152           # 最大允许的响应大小, 默认 2M
  max_qps: 500                          # 每秒最大请求数
  allow_methods:                        # 允许的请求方法
  - HEAD
  - GET
  - POST
  - PUT
  - PATCH
  - DELETE
  - OPTIONS
  - CONNECT
  - TRACE
  - MOVE
  - PROPFIND
  headers:
    User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:78.0) Gecko/20100101 Firefox/78.0
    # Cookie: key=value
```

##### [漏洞扫描用的代理](https://docs.xray.cool/#/configration/http?id=漏洞扫描用的代理-proxy)

配置该项后漏洞扫描发送请求时将使用代理发送，支持 `http`, `https` 和 `socks5` 三种格式，如:

```
http://127.0.0.1:1111
https://127.0.0.1:1111
socks5://127.0.0.1:1080
```

如果代理需要认证，可以使用下面的格式 `http://user:password@127.0.0.1:1111`

##### [多代理配置](https://docs.xray.cool/#/configration/http?id=多代理配置)

在漏洞扫描的时候，可能想不同的域名使用不同的代理，设置多个代理切换等，可以通过 `proxy_rule` 字段来配置。需要注意的是，`proxy` 配置将优先于本配置。

```
proxy_rule:
  - match: "*host1"
    servers:
      - addr: "http://127.0.0.1:8001"
        weight: 1
      - addr: "http://127.0.0.1:8002"
        weight: 2
  - match: "*"
    servers:
      - addr: "http://127.0.0.1:8003"
        weight: 1
      - addr: "http://127.0.0.1:8004"
        weight: 5
```

- match: 请求的 url 的主机名如果匹配，就使用本条规则。
  - 如果是 `*`，则代表可以匹配所有。所以一定要将 `*` 放在最后面，上面没有匹配到的域名都将使用这个配置。
  - 如果没有任何一条可以匹配，这个请求将不会使用代理。
- addr: 代理服务器的地址，同 `proxy` 的配置。
- weight: 代理服务器的权重，如果 `servers` 中配置了多个代理服务器，设置权重可以均衡负载，比如权重是 `3:7`，则代表每 10 个请求，有 3 个选择 server1，有 7 个选择 server2。要注意的是，这里是 round bin 算法，前 3 个一定发往 server1，后面 7 个一定发往 server2，然后继续循环，不是每个请求都是基于权重随机的。

##### [限制发包速度](https://docs.xray.cool/#/configration/http?id=限制发包速度-max_qps)

默认值 500， 因为最大允许每秒发送 500 个请求。一般来说这个值够快了，通常是为了避免被ban，会把该值改的小一些，极限情况支持设置为 1， 表示每秒只能发送一个请求。

#### 软件获取

##### xray

```http
https://download.xray.cool/

https://download.xray.cool/xray

https://download.xray.cool/xray/1.8.4

https://github.com/chaitin/xray

https://github.com/chaitin/xray/releases

https://github.com/chaitin/xray/releases/tag/1.8.4
```

> - 新增如下热门漏洞 poc，感谢师傅们的提交，更新后即可自动加载
>
>   - apache-storm-unauthorized-access.yml
>   - confluence-cve-2021-26085-arbitrary-file-read.yml
>   - dahua-cve-2021-33044-authentication-bypass.yml
>   - exchange-cve-2021-41349-xss.yml
>   - gocd-cve-2021-43287.yml
>   - grafana-default-password.yml
>   - hikvision-unauthenticated-rce-cve-2021-36260.yml
>   - jellyfin-cve-2021-29490.yml
>   - jinher-oa-c6-default-password.yml
>   - kingdee-eas-directory-traversal.yml
>   - pentaho-cve-2021-31602-authentication-bypass.yml
>   - qilin-bastion-host-rce.yml
>   - secnet-ac-default-password.yml
>   - spon-ip-intercom-file-read.yml
>   - spon-ip-intercom-ping-rce.yml
>
> - yaml 脚本部分更新
>
>   - 增加了 http request 和 response 的 raw_header 方法
>
>   - 增加了 bicontains 和 faviconHash 函数
>
>   - 增加了 payloads 结构
>
>   - 增加了 http path 的表达能力，使用 `^` 来访问绝对路径
>
>   - 文档更新
>
>      
>
>     更新 PR
>        
>     - 更新了上面新增的内容
>     - 更新了如何处理转义字符的说明，并提出了 multipart 中`\r\n` 的解决方法
>     - 更新了 http path 如何使用的文档
>     - 更新了 payload 如何使用的文档
>     - 更新了 webhook 的部分内容

##### Rad

```http
https://download.xray.cool/

https://download.xray.cool/rad

https://download.xray.cool/rad/0.4

https://github.com/chaitin/rad

https://github.com/chaitin/rad/releases

https://github.com/chaitin/rad/releases/tag/0.4
```

> - 优化爬取效果，更强力更全面的页面分析能力，更优策略。
> - 优化调度，爬取过程更快速顺畅。
> - 将过滤分为`加入爬取队列`、`发送请求`、`输出结果`三部分配置，可以方便的控制各个环节的过滤。
> - 体验细节优化。

#### 正版授权

```
# xray license
# user_name: 南风向晚
# user_id: 05401157dde901314d34ba8e848dc5b2
# license_id: 1d7a9cec586e3b266f5dae9c68fd787c
# distribution: COMMUNITY-ADVANCED
# not_valid_before: 2021-08-03
# not_valid_after: 2022-08-03

AkTaFrP8/RnAYMjNKusPfREn2lGBVHf9gUkWnh/CR+UI65sfnwFPT80bxVQf0j8M9NorYJIDv4YAgtah+bI5n9AZ0XUo3t3uI8azU7IO241f/xmtnTmK3Vi90v04SiD+jsYlJOMysVur51mKDcklYjQayqrQxv/iVJNaImjoFMku5dMGTWD5Vxab/TTCfP6xEvk9OWoWkAo7aW8MJEmn9KbegdTw1M0TzbDcrdJpZFaC+7wbps2Leks62NTdhSS72ZWR0xiX9Ooxu6DXuJNO9dbIhG23fjcVb9HxYsOnvUDezanF7EDpBBs7ivGxjdot+vodOzJRqi2Yxa6qkZvMvN/Tsf2R/gjYtRkBmqAkRABofGGlIeMCAqS43wI7ivzpGXQy2EG02TnV2Ezb0A8GNaipEeDxLScbhtJ+6CuT22mSOmQHsLIW5FwqHgcfOjPupP2r29b1D+QaUgMppgsnZy4uOWOL4VRQjYtqhnwzpu9QC9eYQ6WKl6bVshIqz0MUN46bFVr8BpGqAm2T7e+NJJbYtSwVr/cOJSVaOHd2yyzSPGXa0kHBzs5t3SUGb7j5KE1ZRFG8kfbE9IyyZumjsGAOorUV+O2zri4zk+B/WvZVz1x9WoH9pUh3xpYYfo7feElrdDdSSnpFMHdqMmt6WUc=
```

![image-20220417190155033](https://cdn.jsdelivr.net/gh/Asura88/Mannix/img/202204171901176.png)

### 1.2 Acunetix

#### 软件获取

```http
https://www.acunetix.com/support/build-history/

https://www.little2pig.work/archives/awvs147220401065

https://www.fahai.org/index.php/archives/138/

https://www.fahai.org/index.php/archives/146/

bash <(curl -sk https://pan.fahai.org/d/Awvs/check.sh) xrsec/awvs

URL: https://server_ip:3443/#/login
UserName: awvs@awvs.lan
PassWord: Awvs@awvs.lan
```

> #### Acunetix Build History
>
> #### Version 14 build 14.7.220401065 for Windows, Linux and macOS – 1st April 2022
>
> #### New Vulnerability checks
>
> - Test for [Spring4Shell vulnerability](https://www.acunetix.com/blog/web-security-zone/critical-alert-spring4shell-rce-cve-2022-22965-in-spring/) ([CVE-2022-22965](https://tanzu.vmware.com/security/cve-2022-22965))

#### 和谐办法

> 注意：软件需要默认安装。

1. 修改本地HOSTS文件，增加以下2条域名解析：

   ```
   127.0.0.1 updates.acunetix.com
   127.0.0.1 erp.acunetix.com
   ```

2. 停止awvs服务，将license_info.json和wa_data.dat文件复制到以下目录：

   ```
   Windows : C:\ProgramData\Acunetix\shared\license
   Linux   : /home/acunetix/.acunetix/data/license/
   Mac     : /Applications/Acunetix.app/Contents/Resources/data/license/
   ```

3. 复制完后设置 license_info.json 为只读模式。注：也是最重要的一步！！！无论哪个系统都要。
4. 开启awvs服务，完毕。

```http
https://pan.fahai.org/d/Awvs/check.sh
```

```bash
#!/usr/bin/env bash

# set -ex

Echo_c() {
  echo "\033[1;33m$1\033[0m"
}

check() {
  Echo_c " Starting cracking"
  curl -s -o awvs_listen.zip https://www.fahai.org/usr/uploads/2021/09/734242510.zip
  docker cp awvs_listen.zip awvs:/awvs/
  docker exec -it awvs /bin/bash -c "unzip -o /awvs/awvs_listen.zip -d /home/acunetix/.acunetix/data/license/"
  docker exec -it awvs /bin/bash -c "chmod 444 /home/acunetix/.acunetix/data/license/license_info.json"
  docker exec -it awvs /bin/bash -c "chown acunetix:acunetix /home/acunetix/.acunetix/data/license/wa_data.dat"
  docker exec -it awvs /bin/bash -c "rm /awvs/awvs_listen.zip"
  docker exec -it awvs /bin/bash -c "echo '127.0.0.1 updates.acunetix.com' > /awvs/.hosts"
  docker exec -it awvs /bin/bash -c "echo '127.0.0.1 erp.acunetix.com' >> /awvs/.hosts"
  docker restart awvs
  rm awvs_listen.zip
  Echo_c " Crack over!"
}

logs() {
  docker logs awvs 2>&1 | head -n 23
}

main() {
  Echo_c " Start Install"
  Echo_c " 本操作会删除所有名字包含 awvs 的容器，5秒后将执行";sleep 5
  docker pull "$1":latest
  if [ ! -n "$(docker ps -aq --filter name=awvs)" ]; then
    if [ ! -n "$(docker ps -aq --filter publish=3443)" ]; then
      docker run -itd --name awvs -p 3443:3443 --restart=always $1:latest;check
      logs
    else
      docker run -itd --name awvs -p 3444:3443 --restart=always $1:latest;check
      Echo_c " Please visit https://127.0.0.1:3444"
    fi
  else
    docker rm -f $(docker ps -aq --filter name=awvs)
    docker run -itd --name awvs -p 3443:3443 --restart=always $1:latest
    check
    logs
  fi
}
main $1
```

## 2、漏洞利用

### 2.1 注入漏洞

#### sqlmap

sqlmap 是一个开源的渗透测试工具，可以用来自动化的检测，利用SQL注入漏洞，获取数据库服务器的权限。它具有功能强大的检测引擎,针对各种不同类型数据库的渗透测试的功能选项，包括获取数据库中存储的数据，访问操作系统文件甚至可以通过带外数据连接的方式执行操作系统命令。

##### 软件获取

```http
https://sqlmap.org/

https://github.com/sqlmapproject/sqlmap

https://github.com/sqlmapproject/sqlmap/releases

https://github.com/sqlmapproject/sqlmap/archive/refs/heads/master.zip
```

##### 使用手册

```http
https://github.com/sqlmapproject/sqlmap/wiki/Usage

https://wooyun.kieran.top/#!/drops/25.sqlmap%E7%94%A8%E6%88%B7%E6%89%8B%E5%86%8C

https://wooyun.kieran.top/#!/drops/59.sqlmap%E7%94%A8%E6%88%B7%E6%89%8B%E5%86%8C%5B%E7%BB%AD%5D

https://wooyun.kieran.top/#!/drops/460.%E4%BD%BF%E7%94%A8sqlmap%E4%B8%ADtamper%E8%84%9A%E6%9C%AC%E7%BB%95%E8%BF%87waf

https://wooyun.kieran.top/#!/drops/505.SQLMAP%E8%BF%9B%E9%98%B6%E4%BD%BF%E7%94%A8
```

```bash
python3 sqlmap.py -r 1.txt --level=5 --risk=3 -v 3 --random-agent [--chunk] [--proxy="http://127.0.0.1:8008"]
```