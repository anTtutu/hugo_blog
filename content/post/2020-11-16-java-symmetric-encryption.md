---
title: "Java对称加密实战：DES、3DES与AES"
date: 2020-11-16T08:00:00+08:00
tags: [ "java", "加密" ]
description: "Java 对称加密实战：对称密码原理（分组模式/填充方式）、DES/3DES/AES 三种算法对比与 Java 完整实现代码"
categories: [ "java", "安全" ]
toc: true
---

## 前言

加解密是业务开发绕不开的需求，手机号、身份证、银行卡等敏感字段落库加密基本都是对称加密。这篇整理对称加密的原理和 DES、3DES、AES 三种算法的 Java 实现。

## 一、对称密码算法

对称密码算法是当今应用范围最广、使用频率最高的加密算法，不仅应用于软件行业，在硬件行业同样流行，各种基础设施凡是涉及到安全需求都会优先考虑对称加密算法。

**核心特征**：加密密钥和解密密钥相同，对于大多数对称密码算法，加解密过程互逆。

**特点**：算法公开、计算量小、加密速度快、加密效率高。

**弱点**：双方都使用同样密钥，安全性得不到保证。

### 加解密通信模型

![对称密码加解密通信模型](/posts/encrypt/model.png)

### 分组密码工作模式

对称密码有流密码和分组密码两种，现在普遍使用的是分组密码，五种工作模式：

1. **ECB**：电子密码本。最常用，每次加密均产生独立的密文分组，对其他密文分组不会产生影响——**相同的明文加密后产生相同的密文**
2. **CBC**：密文链接。常用，明文加密前需要先和前面的密文做异或运算——相同的明文加密后产生不同的密文
3. **CFB**：密文反馈
4. **OFB**：输出反馈
5. **CTR**：计数器

### 分组密码填充方式

1. NoPadding：无填充
2. PKCS5Padding
3. ISO10126Padding

### 常用对称密码算法

1. **DES**（Data Encryption Standard，数据加密标准）
2. **3DES**（Triple DES、DESede，进行三重 DES 加密的算法）
3. **AES**（Advanced Encryption Standard，高级加密标准，可有效抵御针对 DES 的攻击算法）

三种算法对比：

| 算法 | 密钥长度 | 默认密钥长度 | 工作模式 | 填充方式 |
| - | - | - | - | - |
| DES | 56 | 56 | ECB、CBC、PCBC、CTR、CTS、CFB、CFB8-CFB128、OFB、OFB8-OFB128 | NoPadding、PKCS5Padding、ISO10126Padding |
| 3DES | 112、168 | 168 | 同上 | 同上 |
| AES | 128、192、256 | 128 | 同上 | 同上 |

## 二、DES 算法

**特点**：密钥偏短（56位）、生命周期短（避免被破解），是对称加密算法领域中的典型算法。

**生成密钥**：

```java
KeyGenerator keyGen = KeyGenerator.getInstance("DES");  // 密钥生成器
keyGen.init(56);                                        // 初始化密钥生成器
SecretKey secretKey = keyGen.generateKey();             // 生成密钥
byte[] key = secretKey.getEncoded();                    // 密钥字节数组
```

**加密**：

```java
SecretKey secretKey = new SecretKeySpec(key, "DES");    // 恢复密钥
Cipher cipher = Cipher.getInstance("DES");              // Cipher 完成加密或解密工作类
cipher.init(Cipher.ENCRYPT_MODE, secretKey);            // 对 Cipher 初始化，加密模式
byte[] cipherByte = cipher.doFinal(data);               // 加密 data
```

**解密**：

```java
SecretKey secretKey = new SecretKeySpec(key, "DES");
Cipher cipher = Cipher.getInstance("DES");
cipher.init(Cipher.DECRYPT_MODE, secretKey);            // 解密模式
byte[] cipherByte = cipher.doFinal(data);               // 解密 data
```

可以发现加密解密只是设置了不同的模式而已。

## 三、3DES 算法

**特点**：将密钥长度增至 112 位或 168 位，通过增加迭代次数提高安全性。

**缺点**：处理速度较慢、密钥计算时间较长、加密效率不高。

```java
// 生成密钥：可指定密钥长度为 112 或 168，默认为 168
KeyGenerator keyGen = KeyGenerator.getInstance("DESede");
keyGen.init(168);
SecretKey secretKey = keyGen.generateKey();
byte[] key = secretKey.getEncoded();

// 加密
SecretKey secretKey = new SecretKeySpec(key, "DESede");
Cipher cipher = Cipher.getInstance("DESede");
cipher.init(Cipher.ENCRYPT_MODE, secretKey);
byte[] cipherByte = cipher.doFinal(data);

// 解密
cipher.init(Cipher.DECRYPT_MODE, secretKey);
byte[] cipherByte = cipher.doFinal(data);
```

## 四、AES 算法（推荐使用）

**特点**：高级加密标准，能够有效抵御已知的针对 DES 算法的所有攻击；密钥建立时间短、灵敏性好、内存需求低、安全性高。

```java
// 生成密钥：默认 128，获得无政策权限后可为 192 或 256
KeyGenerator keyGen = KeyGenerator.getInstance("AES");
keyGen.init(128);
SecretKey secretKey = keyGen.generateKey();
byte[] key = secretKey.getEncoded();

// 加密
SecretKey secretKey = new SecretKeySpec(key, "AES");
Cipher cipher = Cipher.getInstance("AES");
cipher.init(Cipher.ENCRYPT_MODE, secretKey);
byte[] cipherByte = cipher.doFinal(data);

// 解密
cipher.init(Cipher.DECRYPT_MODE, secretKey);
byte[] cipherByte = cipher.doFinal(data);
```

> 提示：`Cipher.getInstance("AES")` 默认等价于 `AES/ECB/PKCS5Padding`。生产环境建议显式指定为 `AES/CBC/PKCS5Padding` 或 `AES/GCM/NoPadding` 并配合随机 IV，避免 ECB 模式相同明文产生相同密文的特征被利用。

## 总结

新项目直接用 AES（128 位起步），存量 DES/3DES 系统在改造时迁移；模式上避开 ECB、密钥管理上不要硬编码在代码里——算法本身很安全，出问题的往往是使用姿势。
