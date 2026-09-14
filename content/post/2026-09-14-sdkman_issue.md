---
title: "sdkman与conda冲突问题解决"
date: 2026-09-14T00:29:47+08:00
tag : [ "sdkman", "conda" ]
description: "sdkman与conda冲突问题解决"
categories: [ "sdkman", "conda" ]
toc: true
---

## 前言

最近发现sdkman使用有点异常，执行sdk list的时候显示离线状态，无法查看支持的软件清单

## 1、分析

如何是发现问题经过：

```bash
(base) ➜  **** git:(dev-ui) sdk current
Current default versions:
ant 1.10.5-apache
gradle 9.4-apache
java 21-oracle-local
jmeter 5.1-apache
kotlin 2.3.20-local
maven 3.9.14-apache
mvnd 1.0.4-apache
tomcat 7-apache
(base) ➜  **** git:(dev-ui) sdk list
==== INTERNET NOT REACHABLE! ===================================================

 Some functionality is disabled or only partially available.
 If this persists, please enable the offline mode:

   $ sdk offline

================================================================================

This command is not available while offline.
(base) ➜  **** git:(dev-ui) sdk --help
==== INTERNET NOT REACHABLE! ===================================================

 Some functionality is disabled or only partially available.
 If this persists, please enable the offline mode:

   $ sdk offline

================================================================================


Invalid command: --help


NAME
    sdk - The command line interface (CLI) for SDKMAN!

SYNOPSIS
    sdk <subcommand> [candidate] [version]

DESCRIPTION
    SDKMAN! is a tool for managing parallel versions of multiple JVM related
    Software Development Kits on most Unix based systems. It provides a
    convenient Command Line Interface (CLI) and API for installing, switching,
    removing and listing Candidates.

SUBCOMMANDS & QUALIFIERS
    help         [subcommand]
    install      <candidate> [version] [path]
    uninstall    <candidate> <version>
    list         [candidate]
    use          <candidate> <version>
    config       no qualifier
    default      <candidate> [version]
    home         <candidate> <version>
    env          [init|install|clear]
    current      [candidate]
    upgrade      [candidate]
    version      no qualifier
    offline      [enable|disable]
    selfupdate   [force]
    update       no qualifier
    flush        [tmp|metadata|version]

EXAMPLES
    sdk install java 17.0.0-tem
    sdk help install


(base) ➜  **** git:(dev-ui) sdk update
==== INTERNET NOT REACHABLE! ===================================================

 Some functionality is disabled or only partially available.
 If this persists, please enable the offline mode:

   $ sdk offline

================================================================================

(base) ➜  **** git:(dev-ui) sdk version

SDKMAN!
script: 5.21.0
native: 0.7.21 (macos x86_64)

(base) ➜  **** git:(dev-ui) curl -vvv https://api.sdkman.io/2
* Host api.sdkman.io:443 was resolved.
* IPv6: (none)
* IPv4: 45.55.42.78
*   Trying 45.55.42.78:443...
* Connected to api.sdkman.io (45.55.42.78) port 443
* ALPN: curl offers h2,http/1.1
* (304) (OUT), TLS handshake, Client hello (1):
*  CAfile: /etc/ssl/cert.pem
*  CApath: none
* (304) (IN), TLS handshake, Server hello (2):
* (304) (IN), TLS handshake, Unknown (8):
* (304) (IN), TLS handshake, Certificate (11):
* (304) (IN), TLS handshake, CERT verify (15):
* (304) (IN), TLS handshake, Finished (20):
* (304) (OUT), TLS handshake, Finished (20):
* SSL connection using TLSv1.3 / AEAD-AES256-GCM-SHA384 / [blank] / UNDEF
* ALPN: server accepted http/1.1
* Server certificate:
*  subject: CN=*.sdkman.io
*  start date: Mar 28 00:00:00 2026 GMT
*  expire date: Oct 12 23:59:59 2026 GMT
*  subjectAltName: host "api.sdkman.io" matched cert's "*.sdkman.io"
*  issuer: C=GB; O=Sectigo Limited; CN=Sectigo Public Server Authentication CA DV R36
*  SSL certificate verify ok.
* using HTTP/1.x
> GET /2 HTTP/1.1
> Host: api.sdkman.io
> User-Agent: curl/8.7.1
> Accept: */*
>
* Request completely sent off
< HTTP/1.1 404 Not Found
< Server: nginx/1.19.10
< Date: Sun, 13 Sep 2026 10:05:16 GMT
< Content-Type: text/html
< Content-Length: 154
< Connection: keep-alive
<
<html>
<head><title>404 Not Found</title></head>
<body>
<center><h1>404 Not Found</h1></center>
<hr><center>nginx/1.19.10</center>
</body>
</html>
* Connection #0 to host api.sdkman.io left intact
(base) ➜  **** git:(dev-ui) sdk offline disable
Online mode re-enabled!
(base) ➜  **** git:(dev-ui) sdk list
==== INTERNET NOT REACHABLE! ===================================================

 Some functionality is disabled or only partially available.
 If this persists, please enable the offline mode:

   $ sdk offline

================================================================================

This command is not available while offline.
(base) ➜  **** git:(dev-ui) which -a curl
/usr/bin/curl
(base) ➜  **** git:(dev-ui) conda deactivate
➜  **** git:(dev-ui) sdk offline disable
Online mode re-enabled!
➜  **** git:(dev-ui) sdk list
[1]  + 25118 suspended
```

## 2、找问题

测试curl找需要联网才能访问的网页正常

后来分析到原来是miniconda的SSL覆盖了系统自带的SSL，那只能改造下还原SSL了，于是环境变量着手

```bash
## conda在sdkman前，然后sdk的环境变量初始化的时候加工下

## 9-sdkman
#####################################################################################################
#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# 保存 SDKMAN 原始的 sdk 函数，改名为 __sdk_original
eval "$(declare -f sdk | sed '1s/sdk/__sdk_original/')"
# 覆盖 sdk，先清 conda 证书变量，再调用原函数
sdk() {
  unset SSL_CERT_FILE REQUESTS_CA_BUNDLE CURL_CA_BUNDLE
  export PATH="$HOME/.sdkman/bin:$PATH"
  __sdk_original "$@"
}
#####################################################################################################
```

## 3、测试

如步骤1测试的，最后已经修复问题

```bash
(base) ➜  GitCode sdk version

SDKMAN!
script: 5.21.0
native: 0.7.21 (macos x86_64)

(base) ➜  GitCode which sdk
sdk () {
        unset SSL_CERT_FILE REQUESTS_CA_BUNDLE CURL_CA_BUNDLE
        export PATH="$HOME/.sdkman/bin:$PATH"
        __sdk_original "$@"
}
(base) ➜  GitCode
```