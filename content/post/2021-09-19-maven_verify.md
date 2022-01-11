---
title: "maven校验依赖包CVE漏洞"
date: 2021-09-19T00:29:47+08:00
tag : [ "maven" ]
description: "maven校验依赖包CVE漏洞"
categories: [ "maven" ]
toc: true
---

## 前言
maven也可以校验依赖包是有有CVE漏洞

## 1、maven检测依赖包CVE漏洞
```bash
mvn verify -DskipTests=true
```
```xml        
<build>
    <plugins>
        <!-- owasp check CVE 检查依赖包是否有漏洞  command: mvn verify -->
        <plugin>
            <groupId>org.owasp</groupId>
            <artifactId>dependency-check-maven</artifactId>
            <version>6.5.1</version>
            <executions>
                <execution>
                    <goals>
                        <goal>check</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

## 2、检测结果demo
第一次执行因下载CVE数据有些慢
```java
[INFO] Checking for updates
[INFO] NVD CVE requires several updates; this could take a couple of minutes.
[INFO] Processing Started for NVD CVE - 2002
[INFO] Processing Started for NVD CVE - 2003
[INFO] Processing Started for NVD CVE - 2004
[INFO] Processing Started for NVD CVE - 2005
[INFO] Processing Started for NVD CVE - 2006
[INFO] Processing Started for NVD CVE - 2007
[INFO] Processing Started for NVD CVE - 2008
[INFO] Processing Started for NVD CVE - 2009
[INFO] Download Started for NVD CVE - 2011
[INFO] Processing Complete for NVD CVE - 2003  (6463 ms)
[INFO] Processing Started for NVD CVE - 2010
[INFO] Processing Complete for NVD CVE - 2004  (11047 ms)
[INFO] Download Complete for NVD CVE - 2011  (7409 ms)
[INFO] Processing Started for NVD CVE - 2011
[INFO] Processing Complete for NVD CVE - 2002  (13764 ms)
[INFO] Download Started for NVD CVE - 2012
[INFO] Processing Complete for NVD CVE - 2005  (15621 ms)
[INFO] Processing Complete for NVD CVE - 2007  (19261 ms)
[INFO] Processing Complete for NVD CVE - 2006  (20250 ms)
[INFO] Processing Complete for NVD CVE - 2008  (21929 ms)
[INFO] Processing Complete for NVD CVE - 2009  (22060 ms)
[INFO] Processing Complete for NVD CVE - 2010  (18460 ms)
[INFO] Processing Complete for NVD CVE - 2011  (16711 ms)
[INFO] Download Complete for NVD CVE - 2012  (29449 ms)
[INFO] Processing Started for NVD CVE - 2012
[INFO] Download Started for NVD CVE - 2013
[INFO] Processing Complete for NVD CVE - 2012  (11136 ms)
[INFO] Download Complete for NVD CVE - 2013  (11719 ms)
[INFO] Processing Started for NVD CVE - 2013
[INFO] Download Started for NVD CVE - 2014
[INFO] Processing Complete for NVD CVE - 2013  (10187 ms)
[INFO] Download Complete for NVD CVE - 2014  (9931 ms)
[INFO] Processing Started for NVD CVE - 2014
[INFO] Download Started for NVD CVE - 2015
[INFO] Processing Complete for NVD CVE - 2014  (8125 ms)
[INFO] Download Complete for NVD CVE - 2015  (40871 ms)
[INFO] Processing Started for NVD CVE - 2015
[INFO] Download Started for NVD CVE - 2016
[INFO] Processing Complete for NVD CVE - 2015  (6863 ms)
[INFO] Download Complete for NVD CVE - 2016  (19813 ms)
[INFO] Processing Started for NVD CVE - 2016
[INFO] Download Started for NVD CVE - 2017
[INFO] Processing Complete for NVD CVE - 2016  (8025 ms)
[INFO] Download Complete for NVD CVE - 2017  (18304 ms)
[INFO] Processing Started for NVD CVE - 2017
[INFO] Download Started for NVD CVE - 2018
[INFO] Processing Complete for NVD CVE - 2017  (8180 ms)
[INFO] Download Complete for NVD CVE - 2018  (16151 ms)
[INFO] Processing Started for NVD CVE - 2018
[INFO] Download Started for NVD CVE - 2019
[INFO] Processing Complete for NVD CVE - 2018  (8065 ms)
[INFO] Download Complete for NVD CVE - 2019  (10331 ms)
[INFO] Processing Started for NVD CVE - 2019
[INFO] Download Started for NVD CVE - 2020
[INFO] Processing Complete for NVD CVE - 2019  (7590 ms)
[INFO] Download Complete for NVD CVE - 2020  (12443 ms)
[INFO] Processing Started for NVD CVE - 2020
[INFO] Download Started for NVD CVE - 2021
[INFO] Processing Complete for NVD CVE - 2020  (8986 ms)
[INFO] Download Complete for NVD CVE - 2021  (6878 ms)
[INFO] Processing Started for NVD CVE - 2021
[INFO] Download Started for NVD CVE - 2022
[INFO] Download Complete for NVD CVE - 2022  (1316 ms)
[INFO] Processing Started for NVD CVE - 2022
[INFO] Processing Complete for NVD CVE - 2022  (27 ms)
[INFO] Processing Complete for NVD CVE - 2021  (8479 ms)
[INFO] Download Started for NVD CVE - Modified
[INFO] Download Complete for NVD CVE - Modified  (2517 ms)
[INFO] Processing Started for NVD CVE - Modified
[INFO] Processing Complete for NVD CVE - Modified  (488 ms)
...
[INFO] Analysis Started
[INFO] Finished Archive Analyzer (0 seconds)
[INFO] Finished File Name Analyzer (0 seconds)
[INFO] Finished Jar Analyzer (0 seconds)
[INFO] Finished Dependency Merging Analyzer (0 seconds)
[INFO] Finished Version Filter Analyzer (0 seconds)
[INFO] Finished Hint Analyzer (0 seconds)
[INFO] Created CPE Index (2 seconds)
[INFO] Finished CPE Analyzer (2 seconds)
[INFO] Finished False Positive Analyzer (0 seconds)
[INFO] Finished NVD CVE Analyzer (0 seconds)
[INFO] Finished Sonatype OSS Index Analyzer (2 seconds)
[INFO] Finished Vulnerability Suppression Analyzer (0 seconds)
[INFO] Finished Dependency Bundling Analyzer (0 seconds)
[INFO] Analysis Complete (6 seconds)
[INFO] Writing report to: /XXX/target/dependency-check-report.html
[WARNING] 

One or more dependencies were identified with known vulnerabilities in XXX:

bcprov-jdk15on-1.57.jar (pkg:maven/org.bouncycastle/bcprov-jdk15on@1.57, cpe:2.3:a/:bouncycastle:bouncy-castle-crypto-package:1.57:*:*:*:*:*:*:*, cpe:2.3:a/:bouncycastle:bouncy_castle_crypto_package:1.57:*:*:*:*:*:*:*, cpe:2.3:a/:bouncycastle:legion-of-the-bouncy-castle:1.57:*:*:*:*:*:*:*, cpe:2.3:a/:bouncycastle:legion-of-the-bouncy-castle-java-crytography-api:1.57:*:*:*:*:*:*:*, cpe:2.3:a/:bouncycastle:the_bouncy_castle_crypto_package_for_java:1.57:*:*:*:*:*:*:*) : CVE-2017-13098, CVE-2018-1000180, CVE-2018-1000613, CVE-2020-15522, CVE-2020-26939

See the dependency-check report for more details.

[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 12.874 s
[INFO] Finished at: 2022-01-10T16:44:57+08:00
[INFO] ------------------------------------------------------------------------
```
上图报告已经找到java安全工具包bouncycastle-1.57版本存在的CVE漏洞