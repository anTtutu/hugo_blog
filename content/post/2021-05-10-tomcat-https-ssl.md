---
title: "tomcat配置https：keytool生成证书与server.xml配置"
date: 2021-05-10T08:30:00+08:00
tags: [ "tomcat", "https", "java" ]
description: "tomcat 配置 https 完整流程：keytool 生成自签名证书、server.xml 的 Connector 配置与参数详解、常见注意点（名字与姓氏必须填域名），附新版 JDK/tomcat 的差异说明"
categories: [ "tomcat", "java" ]
toc: true
---

## 前言

内部系统要上 https，当时没有 CA 签发的证书，就用 keytool 做了自签名证书给 tomcat 配上。流程整理下，最后补上新版 JDK/tomcat 的差异说明——老环境照旧，新环境看最后一段。

## 1、生成安全证书

JDK 1.4 以后都自带 keytool，在 `<JAVA_HOME>\bin` 下：

```bash
keytool -genkeypair -alias "tomcat" -keyalg "RSA" -keystore "f:\tomcat.keystore"
```

参数说明：

- `-alias`：证书别名，之后引用都用它
- `-keyalg`：密钥算法，RSA
- `-keystore`：keystore 文件的存放位置

命令会交互式问一串信息，其中**「名字与姓氏」必须填域名**（比如 www.example.com），这是最容易踩的坑——填成自己的姓名，之后运行时证书的域名和实际访问的域名对不上，浏览器照样报证书警告。密码我输的是 tomcat（测试环境），其余按实际情况填。

执行完会生成自签名证书文件 `tomcat.keystore`，把它放到规划好的目录（我的放在 D:\Tools\Web\ssl\）。

## 2、配置 tomcat

打开 conf/server.xml，找到被注释的 8443 那段 Connector：

```xml
<!--
    <Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true"
               maxThreads="150" scheme="https" secure="true"
               clientAuth="false" sslProtocol="TLS" />
-->
```

去掉注释，加上 keystore 信息：

```xml
<Connector port="8443" protocol="HTTP/1.1" SSLEnabled="true"
           maxThreads="150" scheme="https" secure="true"
           clientAuth="false" sslProtocol="TLS"
           keystoreFile="D:\Tools\Web\ssl\tomcat.keystore"
           keystorePass="tomcat"
           ciphers="tomcat" />
```

参数说明：

| 属性 | 描述 |
| - | - |
| clientAuth | true 表示要求客户端出示证书（双向 SSL），一般单向认证用 false |
| keystoreFile | keystore 文件位置，绝对路径或相对 CATALINA_HOME；不设置则默认读当前用户目录下的 `.keystore` |
| keystorePass | keystore 密码，不设置默认 `changeit` |
| sslProtocol | 加解密协议，默认 TLS，一般不改 |
| ciphers | 可用的加密算法清单，逗号分隔，不设置则用所有可用的 |

启动 tomcat，浏览器访问 `https://localhost:8443/` 验证。自签名证书浏览器会提示不受信任，点继续访问即可（要消除提示得用 CA 签发的证书，流程一样，把 keystoreFile 换成签发的证书就行）。

## 3、新版本差异（JDK 9+ / tomcat 8.5+）

上面的写法在 JDK 8 + tomcat 6/7/8 没问题，新版本注意三点：

1. **keytool 默认格式变了**：JDK 9+ 生成的是 PKCS12 格式（`.p12`），不再是专有 JKS。加 `-storetype pkcs12` 是默认行为，老 JKS 文件也能被新版本识别，会有个迁移提示
2. **tomcat 8.5+ 推荐新配置写法**：Connector 只保留端口和 `SSLEnabled="true"`，证书细节挪到独立的 `SSLHostConfig` + `Certificate` 元素：

```xml
<Connector port="8443" protocol="org.apache.coyote.http11.Http11NioProtocol"
           maxThreads="150" SSLEnabled="true">
    <SSLHostConfig>
        <Certificate certificateKeystoreFile="conf/tomcat.keystore"
                     certificateKeystorePassword="tomcat"
                     type="RSA" />
    </SSLHostConfig>
</Connector>
```

3. **生产环境用 CA 证书**：自签名只适合内部测试，正式对外到 CA 申请免费证书（Let's Encrypt）或买商业证书，配置思路一样，把证书文件和密码换掉即可。

## 总结

tomcat 配 https 就两步：keytool 生成 keystore、server.xml 的 Connector 挂上证书信息。最关键的坑是「名字与姓氏」必须填域名；新版环境记得 tomcat 8.5+ 的 SSLHostConfig 写法和 PKCS12 格式，老文章里的 `-Djava.compiler` 时代配置就不用翻出来了。
