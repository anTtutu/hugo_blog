---
title: "java锁体系与ReentrantLock详解"
date: 2022-07-18T08:00:00+08:00
tags: [ "java", "并发" ]
description: "java 锁体系梳理：七种锁分类维度、ReentrantLock 的可重入/可中断/公平锁特性与验证代码、核心方法解析与使用注意事项"
categories: [ "java" ]
toc: true
---

## 前言

面试和实际编码里 java 锁都是绕不开的话题。这篇先按维度把常见锁的分类理清楚，再聚焦 ReentrantLock：它的四个高级特性分别解决 synchronized 的什么短板，配可运行的验证代码，最后是核心方法与注意事项。

## 一、java 常见锁的七种分类

按不同维度，锁可以分成下面几组——同一把锁在不同维度下有不同名字：

| 维度 | 分类 | 说明 |
| - | - | - |
| 竞争是否排队 | 公平锁 / 非公平锁 | synchronized 和 ReentrantLock 默认都是非公平锁，非公平可以避免线程唤醒的空档期、提高吞吐 |
| 同线程能否重复获取 | 可重入锁 / 不可重入锁 | ReentrantLock 对同一线程可重入，不会自己锁死自己 |
| 能否被多线程共享 | 共享锁 / 独占锁 | ReentrantReadWriteLock 中读锁是共享锁、写锁是排他锁 |
| 等待期能否被中断 | 可中断锁 / 不可中断锁 | ReentrantLock 的 `lockInterruptibly()` 支持中断 |
| 是否锁住资源 | 悲观锁 / 乐观锁 | synchronized 是悲观；CAS（如 Atomic 系列）是乐观 |
| 等待方式 | 自旋锁 / 阻塞锁 | 自旋避免上下文切换，但空耗 CPU |
| - | 偏向锁/轻量级锁/重量级锁 | synchronized 的锁升级路径（JDK 15 起偏向锁已废弃） |

## 二、ReentrantLock 的四个高级特性

ReentrantLock 实现了 Lock 接口，作用与 synchronized 一样是线程安全，但多了四个 synchronized 没有的能力。

### 1. 可重入：同一线程可反复加锁

```java
/**
 * 可重入测试：getHoldCount 输出 0 1 2 1 0
 */
public class ReentrantLockTest {

    private static ReentrantLock lock = new ReentrantLock();

    public static void main(String[] args) {
        System.out.println(lock.getHoldCount());   // 0
        lock.lock();
        System.out.println(lock.getHoldCount());   // 1
        lock.lock();
        System.out.println(lock.getHoldCount());   // 2 —— 再次进入没有死锁
        lock.unlock();
        System.out.println(lock.getHoldCount());   // 1
        lock.unlock();
        System.out.println(lock.getHoldCount());   // 0
    }
}
```

递归场景同样成立，holdCount 随递归层数增加、随逐层 unlock 归零：

```java
/**
 * 递归方法验证可重入性
 */
public class ReentrantLockTest {

    private static ReentrantLock lock = new ReentrantLock();

    public static void main(String[] args) {
        reentrantAccess();
    }

    public static void reentrantAccess() {
        lock.lock();
        try {
            System.out.println("被递归调用了");
            if (lock.getHoldCount() < 5) {
                reentrantAccess();
                System.out.println(lock.getHoldCount());
            }
        } finally {
            lock.unlock();
        }
    }
}
```

### 2. 阻塞同步 + 等待可中断

持有锁的线程长期不释放时，等待方可以选择放弃等待去干别的事——这是 synchronized 做不到的：

```java
/**
 * lockInterruptibly() 响应中断测试
 */
public class InterceptLockTest implements Runnable {

    private ReentrantLock lock = new ReentrantLock();

    @Override
    public void run() {
        System.out.println(Thread.currentThread().getName() + "尝试获取锁");
        try {
            lock.lockInterruptibly();          // 等待期间可被 interrupt 打断
            try {
                System.out.println(Thread.currentThread().getName() + "成功获取到了锁");
                Thread.sleep(100000);
            } catch (Exception e) {
                System.out.println(Thread.currentThread().getName() + "业务方法执行期间异常");
            } finally {
                lock.unlock();
            }
        } catch (Exception e) {
            System.out.println(Thread.currentThread().getName() + "等待获取锁时候被中断异常");
        }
    }

    public static void main(String[] args) throws InterruptedException {
        InterceptLockTest task = new InterceptLockTest();
        Thread t1 = new Thread(task);
        Thread t2 = new Thread(task);
        t1.start();
        t2.start();
        Thread.sleep(2000);
        t1.interrupt();    // t1 若在等待锁则直接退出等待
    }
}
```

### 3. 公平锁：按申请顺序获取

```java
ReentrantLock lock = new ReentrantLock(true);   // true = 公平锁
```

多线程竞争时严格按申请锁的先后顺序依次获得，避免线程饥饿（代价是吞吐下降）。

### 4. 锁可绑定多个条件

一个 ReentrantLock 可以创建多个 `Condition`，实现不同线程队列的精细唤醒——对应 Object 的 wait/notify 只有一个等待队列的短板。

## 三、核心方法解析

| 方法 | 行为 |
| - | - |
| `lock()` | 获取锁，拿不到就等；**不可中断**，死锁时会无限等待 |
| `tryLock()` | 尝试获取，拿不到立即返回 false |
| `tryLock(long, TimeUnit)` | 限时等待，超时放弃返回 false |
| `lockInterruptibly()` | 相当于无限等待版的 tryLock，但等待期间可被中断 |
| `unlock()` | 释放锁 |

## 四、两个注意事项

1. **异常不会自动释放锁**。synchronized 块抛异常时 JVM 会释放监视器锁，ReentrantLock 不会——必须 `try...finally` 中手动 unlock：

```java
lock.lock();
try {
    // 业务
} finally {
    lock.unlock();
}
```

2. **tryLock() 自带插队属性**。即使构造的是公平锁，`tryLock()` 拿锁时发现锁空闲会直接获取而不是排队——需要严格公平的场景避免混用。

## 五、虚拟线程时代的锁选型（JDK 21）

JDK 21 正式引入虚拟线程后，「synchronized 还是 ReentrantLock」的选型逻辑发生了实质变化：

**1. pinning 问题。** 虚拟线程运行在少量载体线程（carrier）上，正常阻塞时会自动卸载让出载体线程。但在 **synchronized 块/方法内阻塞时，虚拟线程会被「钉住」（pinning）在载体线程上无法卸载**——大量虚拟线程排队等同一把 synchronized 锁时，载体线程被占死，整个服务吞吐崩塌。而 `ReentrantLock` 阻塞等待时能正确释放载体线程：

```java
// JDK 21 上应避免：阻塞 IO 放在 synchronized 内
synchronized (lock) {
    socket.write(data);        // 阻塞 IO + synchronized = pinning 风险
}

// 推荐：改用 ReentrantLock
lock.lock();
try {
    socket.write(data);        // 阻塞时虚拟线程正常卸载
} finally {
    lock.unlock();
}
```

> JDK 24 的 JEP 491 已让 synchronized 不再导致 pinning，但 JDK 21 上这是真实的架构约束：IO 密集 + 虚拟线程场景，阻塞临界区一律优先 ReentrantLock。

**2. 偏向锁已成历史。** 第一节锁分类里提到的偏向锁，因维护成本高于收益，JDK 15 已默认禁用并弃用，后续版本彻底移除——「轻量级 → 偏向」的升级路径在新版本不复存在。

**3. synchronized 并没有过时。** 纯内存短临界区（懒加载单例、简单计数保护）不受 pinning 影响，synchronized 依然简洁高效；需要 tryLock 超时、可中断、公平队列、多 Condition，或运行在虚拟线程的阻塞场景，才是 ReentrantLock 的主场。

## 总结

ReentrantLock 相对 synchronized 的价值在「可控制」：可中断、可限时、可公平、可多条件。但代价是必须手动 unlock、写法更繁琐。默认场景用 synchronized（JIT 优化后性能已无差距），需要 tryLock 超时、可中断等待、公平队列或多 Condition 时再上 ReentrantLock；JDK 21 虚拟线程上线后，再加一条：**阻塞型临界区优先 ReentrantLock**。

---

## 相关阅读

- [JDK 8到21迁移指南](/post/2026-09-27-jdk8-to-21-migration-guide/)
- [java OOM的种类整理](/post/2018-05-08-oom/)
