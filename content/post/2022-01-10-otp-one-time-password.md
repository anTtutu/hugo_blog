---
title: "OTP动态口令：原理与java实现"
date: 2022-01-10T08:00:00+08:00
tags: [ "安全", "java", "认证" ]
description: "OTP 一次性密码原理详解：时间同步/事件同步/挑战应答三种形式、TOTP 双因素认证完整流程、java 生成密钥与校验码的实现代码"
categories: [ "安全" ]
toc: true
---

## 前言

对外网开放的后台管理系统，只用静态口令认证有几个先天问题：用户为了好记会选有特征的密码、明文传输时可被截获、内部人员能拿到密码冒用。OTP（One-Time Password，一次性密码/动态口令）是最容易落地的双因素认证增强手段，这篇整理它的原理和一套 java 实现方案。

## 一、静态口令的风险

1. 便于记忆的密码往往有特征，容易被猜测和爆破
2. 非加密传输时认证信息可被直接截获
3. 合法授权者（包括内部人员）可以复制密码冒用，事后无法追责

静态口令从根本上无法确定「现在操作的人就是账户本人」。

## 二、OTP 的三种技术形式

OTP 是客户端与服务器通过**共享秘密**实现的强认证技术，由生成口令的令牌（硬件或 APP）和管理认证的服务端组成。按同步方式分三类：

| 形式 | 原理 | 典型载体 |
| - | - | - |
| 时间同步 | 令牌与服务器比对时间，每 60 秒生成一个新口令，对时钟精度和晶振频率要求高 | 硬件令牌、Google Authenticator |
| 事件同步 | 以事件次序 + 相同种子值作为输入，Hash 算出一致密码 | 计数型动态令牌 |
| 挑战/应答 | 服务端下发挑战码，令牌内置算法生成 6/8 位随机数，一次有效 | 刮刮卡、短信密码、部分动态令牌 |

时间同步实现最简单、终端普及度最高（手机 APP 即可），下面以它为主线。

## 三、时间同步（TOTP）的原理

![OTP 原理](/posts/otp/otp_principle.png)

客户端和服务器持有**相同的密钥**，基于**时间基数**用**相同的 Hash 算法**各自算出 6 位校验码。两边算出的码一致则验证通过——密钥从不上网传输，每分钟变化的只是校验码。

## 四、完整认证流程

![OTP 验证流程](/posts/otp/otp_flow.jpg)

三个角色：用户、手机端 APP（密钥载体+计算器）、服务端管理系统。注册时服务端生成密钥并以二维码形式交付给 APP，之后每次登录用「密码 + 6 位动态码」双因素验证。

## 五、java 实现

### 1. 用户注册：生成密钥并交付

```java
// 1.1 生成 OTP 密钥
String secretBase32 = TotpUtil.getRandomSecretBase32(64);

// 1.2 生成供 APP 扫描的字符串，约定格式：
// otpauth://totp/[客户端显示的账户信息]?secret=[secretBase32]
String totpProtocalString = TotpUtil.generateTotpString(operCode, host, secretBase32);

// 1.3 生成二维码图片并通过邮件发送给用户
String host = "noreply@example.com";
String filePath = f_temp;
String fileName = Long.toString(System.currentTimeMillis()) + ".png";
try {
    QRUtil.generateMatrixPic(totpProtocalString, 150, 150, filePath, fileName);
} catch (Exception e) {
    throw new RuntimeException("生成二维码图片失败:" + e.getMessage());
}

String content = "用户名：" + operCode + "</br>"
        + "系统使用密码 + 动态口令双因素认证的方式登录。</br>"
        + "请按以下方式激活动态口令：</br>"
        + "安装 Google Authenticator 后，扫描以下二维码激活。</br>"
        + "<img src=\"cid:image\">";
emailBaseLogic.sendWithPic(email, "账户开立通知", content, filePath + "/" + fileName);

// 1.4 将用户注册信息与 OTP 密钥一起入库
```

### 2. 客户端：扫码获取密钥

用户用 APP 扫描邮件中的二维码，客户端获取密钥，之后基于时间每分钟算出一个 6 位校验码：

![客户端 APP 演示](/posts/otp/otp_apps_demo.png)

### 3. 登录验证：服务端算码比对

用户输入用户名、密码和 APP 上的 6 位码。服务端按用户名取出密钥，用同样的算法算出此刻的校验码：

```java
String secretHex = "";
try {
    secretHex = HexEncoding.encode(Base32String.decode(secretBase32));
} catch (Base32String.DecodingException e) {
    LOGGER.error("解码" + secretBase32 + "出错，", e);
    throw new RuntimeException("解码Base32出错");
}

long X = 30;   // 30 秒一个周期

String steps = "0";
DateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
df.setTimeZone(TimeZone.getTimeZone("UTC"));   // 必须用 UTC 时间计算

long currentTime = System.currentTimeMillis() / 1000L;
try {
    long t = currentTime / X;
    steps = Long.toHexString(t).toUpperCase();
    while (steps.length() < 16) steps = "0" + steps;

    // HmacSHA1 生成 6 位 TOTP
    return generateTOTP(secretHex, steps, "6", "HmacSHA1");
} catch (final Exception e) {
    LOGGER.error("生成动态口令出错：" + secretBase32, e);
    throw new RuntimeException("生成动态口令出错");
}
```

比对客户端提交的码与服务端算出的码是否一致，一致则放行。生产上一般还会允许 ±1 个时间窗口的码（照顾手机时钟偏差），并对同一码做防重放标记。

## 总结

OTP 的安全性来自两点：密钥只通过二维码离线交付、口令一分钟一换且一次有效。落地时注意三点：服务端时间必须准（NTP）、验证要考虑时钟偏移窗口、同一动态码要用过即焚防重放。完整 demo 代码可参考开源实现 [otp-demo](https://github.com/suyin58/otp-demo)。

## 参考

- [OTP 动态口令实现](https://www.cnblogs.com/loveyou/p/6989064.html)
