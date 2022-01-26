---
title: "caffeine和springcache"
date: 2021-10-11T00:29:47+08:00
tag : [ "caffeine", "java", "cache" ]
description: "caffeine和springcache"
categories: [ "caffeine", "java", "cache" ]
toc: true
---

## 前言
说到caffeine，一般会对比 google 家的 guava，这里只做浅析。  
### 缓存
缓存分为本地缓存和远端缓存。  
常见的远端缓存有Redis，MongoDB；  
本地缓存一般使用map的方式保存在本地内存中。  

一般我们在业务中操作缓存，都会操作缓存和数据源两部分。  
如：put数据时，先插入DB，再删除原来的缓存；get数据时，先查缓存，命中则返回，没有命中时，需要查询DB，再把查询结果放入缓存中。  
如果访问量大，我们还得兼顾本地缓存的线程安全问题。  
必要的时候也要考虑缓存的回收策略。

### Guava
Guava Cache 是google guava中的一个内存缓存模块，用于将数据缓存到JVM内存中。他很好的解决了上面提到的几个问题。
* 很好的封装了get、put操作，能够集成数据源；
* 线程安全的缓存，与ConcurrentMap相似，但前者增加了更多的元素失效策略，后者只能显示的移除元素；
* Guava Cache提供了三种基本的缓存回收方式：  
                基于容量回收、定时回收和基于引用回收。  
                    定时回收有两种：按照写入时间，最早写入的最先回收；  
                                 按照访问时间，最早访问的最早回收；
* 监控缓存加载/命中情况

Guava Cache的架构设计灵感ConcurrentHashMap，在简单场景中可以通过HashMap实现简单数据缓存，但如果要实现缓存随时间改变、存储的数据空间可控则缓存工具还是很有必要的。  
Cache存储的是键值对的集合，不同时是还需要处理缓存过期、动态加载等算法逻辑，需要额外信息实现这些操作，对此根据面向对象的思想，还需要做方法与数据的关联性封装，主要实现的缓存功能有：
* 自动将节点加载至缓存结构中，当缓存的数据超过最大值时，使用LRU算法替换；
* 它具备根据节点上一次被访问或写入时间计算缓存过期机制，缓存的key被封装在WeakReference引用中，缓存的value被封装在WeakReference或SoftReference引用中；
* 还可以统计缓存使用过程中的命中率、异常率和命中率等统计数据。
* 当缓存的数据超过最大值时，使用LRU算法替换。

### Caffeine
Caffeine Cache它也是站在巨人的肩膀上-Guava Cache，借着他的思想优化了算法发展而来  

说到优化，Caffeine Cache到底优化了什么呢？Caffeine 因使用 Window TinyLfu 回收策略，提供了一个近乎最佳的命中率。
### 淘汰算法特点
刚提到guava基于LRU封装，常见的缓存淘汰算法还有FIFO，LFU。
#### FIFO：
先进先出，在这种淘汰算法中，先进入缓存的会先被淘汰，会导致命中率很低。
#### LRU：
最近最少使用算法，每次访问数据都会将其放在我们的队尾，如果需要淘汰数据，就只需要淘汰队首即可。仍然有个问题，如果有个数据在 1 分钟访问了 1000次，再后 1 分钟没有访问这个数据，但是有其他的数据访问，就导致了我们这个热点数据被淘汰。
#### LFU：
最近最少频率使用，利用额外的空间记录每个数据的使用频率，然后选出频率最低进行淘汰。这样就避免了 LRU 不能处理时间段的问题。

上面三种策略各有利弊，实现的成本也是一个比一个高，同时命中率也是一个比一个好。Guava Cache虽然有这么多的功能，但是本质上还是对LRU的封装，如果有更优良的算法，并且也能提供这么多功能，相比之下就相形见绌了。
### 局限性
#### LFU的局限性：
在 LFU 中只要数据访问模式的概率分布随时间保持不变时，其命中率就能变得非常高。  
比如有部新剧出来了，我们使用 LFU 给他缓存下来，这部新剧在这几天大概访问了几亿次，这个访问频率也在我们的 LFU 中记录了几亿次。  
但是新剧总会过气的，比如一个月之后这个新剧的前几集其实已经过气了，但是他的访问量的确是太高了，其他的电视剧根本无法淘汰这个新剧，所以在这种模式下是有局限性。

#### LRU的优点和局限性：
LRU可以很好的应对突发流量的情况，因为他不需要累计数据频率。但LRU通过历史数据来预测未来是局限的，它会认为最后到来的数据是最可能被再次访问的，从而给与它最高的优先级。

### 结论
在现有算法的局限性下，会导致缓存数据的命中率或多或少的受损，而命中率又是缓存的重要指标。  
HighScalability网站刊登了一篇文章，由前Google工程师发明的W-TinyLFU——一种现代的缓存。  
Caffeine Cache就是基于此算法而研发。  
Caffeine 因使用 Window TinyLfu 回收策略，提供了一个近乎最佳的命中率。

## 1、参数介绍
### 1.1 guava
guava常见参数解读：
```java
LoadingCache<Object, Object> userCache = CacheBuilder.newBuilder()
         // 基于容量回收。缓存的最大数量。超过就取MAXIMUM_CAPACITY = 1 << 30。依靠LRU队列recencyQueue来进行容量淘汰
        .maximumSize(1000)
         // 基于容量回收。但这是统计占用内存大小，maximumWeight与maximumSize不能同时使用。设置最大总权重
        .maximumWeight(1000)
         // 设置权重（可当成每个缓存占用的大小）
        .weigher((o, o2) -> 5)
         // 软弱引用（引用强度顺序：强软弱虚）
         // -- 弱引用key
        .weakKeys()
         // -- 弱引用value
        .weakValues()
         // -- 软引用value
        .softValues()
         // 过期失效回收
         // -- 没读写访问下，超过5秒会失效(非自动失效，需有任意getput方法才会扫描过期失效数据)
        .expireAfterAccess(5L, TimeUnit.SECONDS)
         // -- 没写访问下，超过5秒会失效(非自动失效，需有任意putget方法才会扫描过期失效数据)
        .expireAfterWrite(5L, TimeUnit.SECONDS)
         // 没写访问下，超过5秒会失效(非自动失效，需有任意putget方法才会扫描过期失效数据。但区别是会开一个异步线程进行刷新，刷新过程中访问返回旧数据)
        .refreshAfterWrite(5L, TimeUnit.SECONDS)
         // 移除监听事件
        .removalListener(removal -> {
             // 可做一些删除后动作，比如上报删除数据用于统计
             System.out.printf("触发删除动作，删除的key=%s%n", removal);
        })
         // 并行等级。决定segment数量的参数，concurrencyLevel与maxWeight共同决定
        .concurrencyLevel(16)
         // 开启缓存统计。比如命中次数、未命中次数等
        .recordStats()
         // 所有segment的初始总容量大小
        .initialCapacity(512)
         // 用于测试，可任意改变当前时间。参考：https://www.geek-share.com/detail/2689756248.html
        .ticker(new Ticker() {
             @Override
             public long read() {
                     return 0;
                    }
        })
        .build(new CacheLoader<Object, Object>() {
             @Override
             public Object load(Object name) {
                     // 在cache找不到就取数据
                     return String.format("重新load（%s）：%s", System.currentTimeMillis(), name);
                    }
        });

 // 简单使用
 userCache.put("hello", "world");
 System.out.println(userCache.get("hello"));
```

### 1.2 caffeine
caffeine常见参数解读：
```
initialCapacity=[integer]: 初始的缓存空间大小   
maximumSize=[long]: 缓存的最大条数
maximumWeight=[long]: 缓存的最大权重
expireAfterAccess=[duration]: 最后一次写入或访问后经过固定时间过期
expireAfterWrite=[duration]: 最后一次写入后经过固定时间过期
refreshAfterWrite=[duration]: 创建缓存或者最近一次更新缓存后经过固定的时间间隔，刷新缓存

weakKeys: 打开key的弱引用
weakValues：打开value的弱引用
softValues：打开value的软引用
recordStats：开发统计功能

注意：
expireAfterWrite和expireAfterAccess同时存在时，以expireAfterWrite为准。
maximumSize和maximumWeight不可以同时使用
weakValues和softValues不可以同时使用
```

## 2、使用注解来对cache增删改查
我们可以使用spring提供的@Cacheable、@CachePut、@CacheEvict等注解来方便的使用caffeine缓存。

如果使用了多个cache，比如redis、caffeine等，必须指定某一个CacheManage为@primary，在@Cacheable注解中没指定 cacheManager 则使用标记为primary的那个。

### 2.1 cache方面的注解主要有以下5个：
* @Cacheable 触发缓存入口（这里一般放在创建和获取的方法上，@Cacheable注解会先查询是否已经有缓存，有会使用缓存，没有则会执行方法并缓存）
* @CacheEvict 触发缓存的eviction（用于删除的方法上）
* @CachePut 更新缓存且不影响方法执行（用于修改的方法上，该注解下的方法始终会被执行）
* @Caching 将多个缓存组合在一个方法上（该注解可以允许一个方法同时设置多个注解）
* @CacheConfig 在类级别设置一些缓存相关的共同配置（与其它缓存配合使用）

#### 2.1.1 说一下@Cacheable 和 @CachePut的区别：
* @Cacheable：它的注解的方法是否被执行取决于Cacheable中的条件，方法很多时候都可能不被执行。
* @CachePut：这个注解不会影响方法的执行，也就是说无论它配置的条件是什么，方法都会被执行，更多的时候是被用到修改上。

#### 2.1.2 简要介绍Cacheable类中各个方法的使用：
```java
public @interface Cacheable {

    /**
     * 要使用的cache的名字
     */
    @AliasFor("cacheNames")
    String[] value() default {};

    /**
     * 同value()，决定要使用那个/些缓存
     */
    @AliasFor("value")
    String[] cacheNames() default {};

    /**
     * 使用SpEL表达式来设定缓存的key，如果不设置默认方法上所有参数都会作为key的一部分
     */
    String key() default "";

    /**
     * 用来生成key，与key()不可以共用
     */
    String keyGenerator() default "";

    /**
     * 设定要使用的cacheManager，必须先设置好cacheManager的bean，这是使用该bean的名字
     */
    String cacheManager() default "";

    /**
     * 使用cacheResolver来设定使用的缓存，用法同cacheManager，但是与cacheManager不可以同时使用
     */
    String cacheResolver() default "";

    /**
     * 使用SpEL表达式设定出发缓存的条件，在方法执行前生效
     */
    String condition() default "";

    /**
     * 使用SpEL设置出发缓存的条件，这里是方法执行完生效，所以条件中可以有方法执行后的value
     */
    String unless() default "";

    /**
     * 用于同步的，在缓存失效（过期不存在等各种原因）的时候，如果多个线程同时访问被标注的方法
     * 则只允许一个线程通过去执行方法
     */
    boolean sync() default false;

}
```

#### 2.1.3 基于注解的使用方式
```java
import com.rickiyang.learn.entity.User;
import org.springframework.cache.annotation.CacheEvict;
import org.springframework.cache.annotation.CachePut;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

/**
 * @author: Anttu
 * @date: 2021/10/11
 * @description: 本地cache
 */
@Service
public class UserCacheService {


    /**
     * 查找
     * 先查缓存，如果查不到，会查数据库并存入缓存
     * @param id
     */
    @Cacheable(value = "userCache", key = "#id", sync = true)
    public void getUser(long id){
        //查找数据库
    }

    /**
     * 更新/保存
     * @param user
     */
    @CachePut(value = "userCache", key = "#user.id")
    public void saveUser(User user){
        //todo 保存数据库
    }


    /**
     * 删除
     * @param user
     */
    @CacheEvict(value = "userCache",key = "#user.id")
    public void delUser(User user){
        //todo 保存数据库
    }
}
```

## 3、springboot中默认的缓存
* SpringBoot 1.x版本中的默认本地cache是Guava Cache。  
* 在2.x（Spring Boot 2.0(spring 5) ）版本中已经用Caffeine Cache取代了Guava Cache。毕竟有了更优的缓存淘汰策略。

## 4、springboot中使用caffeine
### 4.1 pom中配置依赖
```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>
<dependency>
    <groupId>com.github.ben-manes.caffeine</groupId>
    <artifactId>caffeine</artifactId>
    <version>2.6.2</version>
</dependency>
```

### 4.2 配置文件注入相关参数
#### properties
```properties
spring.cache.cache-names=cache1
spring.cache.caffeine.spec=initialCapacity=50,maximumSize=500,expireAfterWrite=10s
```
#### yaml
```yaml
spring:
  cache:
    type: caffeine
    cache-names:
    - userCache
    caffeine:
      spec: maximumSize=1024,refreshAfterWrite=60s
```
##### 注：
上面 properties 和 yaml 任选其一

### 4.3 注解开启缓存支持
添加@EnableCaching注解：
```java
@SpringBootApplication
@EnableCaching
public class SingleDatabaseApplication {

    public static void main(String[] args) {
        SpringApplication.run(SingleDatabaseApplication.class, args);
    }
}
```

### 4.4 cache config实现
1. 如果使用refreshAfterWrite配置,必须指定一个CacheLoader,不用该配置则无需这个bean,如上所述,该CacheLoader将关联被该缓存管理器管理的所有缓存,所以必须定义为CacheLoader<Object, Object>,自动配置将忽略所有泛型类型。
```java
import com.github.benmanes.caffeine.cache.CacheLoader;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

/**
 * @author: Anttu
 * @date: 2021/10/11
 * @description:
 */
@Configuration
public class CacheConfig {

    /**
     * 相当于在构建LoadingCache对象的时候 build()方法中指定过期之后的加载策略方法
     * 必须要指定这个Bean，refreshAfterWrite=60s属性才生效
     * @return
     */
    @Bean
    public CacheLoader<String, Object> cacheLoader() {
        CacheLoader<String, Object> cacheLoader = new CacheLoader<String, Object>() {
            @Override
            public Object load(String key) throws Exception {
                return null;
            }
            // 重写这个方法将oldValue值返回回去，进而刷新缓存
            @Override
            public Object reload(String key, Object oldValue) throws Exception {
                return oldValue;
            }
        };
        return cacheLoader;
    }
}
```

2. 一般情况下你也可以选择使用bean的方式来初始化Cache实例
```java
import com.github.benmanes.caffeine.cache.CacheLoader;
import com.github.benmanes.caffeine.cache.Caffeine;
import org.apache.commons.compress.utils.Lists;
import org.springframework.cache.CacheManager;
import org.springframework.cache.caffeine.CaffeineCache;
import org.springframework.cache.support.SimpleCacheManager;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * @author: Anttu
 * @date: 2021/10/11
 * @description:
 */
@Configuration
public class CacheConfig {

    /**
     * 创建基于Caffeine的Cache Manager
     * 初始化一些key存入
     * @return
     */
    @Bean
    @Primary
    public CacheManager caffeineCacheManager() {
        SimpleCacheManager cacheManager = new SimpleCacheManager();
        ArrayList<CaffeineCache> caches = Lists.newArrayList();
        List<CacheBean> list = setCacheBean();
        for(CacheBean cacheBean : list){
            caches.add(new CaffeineCache(cacheBean.getKey(),
                    Caffeine.newBuilder().recordStats()
                            .expireAfterWrite(cacheBean.getTtl(), TimeUnit.SECONDS)
                            .maximumSize(cacheBean.getMaximumSize())
                            .build()));
        }
        cacheManager.setCaches(caches);
        return cacheManager;
    }

    /**
     * 初始化一些缓存的 key
     * @return
     */
    private List<CacheBean> setCacheBean(){
        List<CacheBean> list = Lists.newArrayList();
        CacheBean userCache = new CacheBean();
        userCache.setKey("userCache");
        userCache.setTtl(60);
        userCache.setMaximumSize(10000);

        CacheBean deptCache = new CacheBean();
        deptCache.setKey("userCache");
        deptCache.setTtl(60);
        deptCache.setMaximumSize(10000);

        list.add(userCache);
        list.add(deptCache);

        return list;
    }

    class CacheBean {
        private String key;
        private long ttl;
        private long maximumSize;

        public String getKey() {
            return key;
        }

        public void setKey(String key) {
            this.key = key;
        }

        public long getTtl() {
            return ttl;
        }

        public void setTtl(long ttl) {
            this.ttl = ttl;
        }

        public long getMaximumSize() {
            return maximumSize;
        }

        public void setMaximumSize(long maximumSize) {
            this.maximumSize = maximumSize;
        }
    }

}
```

## 5、缓存统计
与Guava Cache的统计一样。
```bash
Cache<String, Object> cache = Caffeine.newBuilder()
    .maximumSize(10_000)
    .recordStats()
    .build();
```
通过使用Caffeine.recordStats(), 可以转化成一个统计的集合. 通过 Cache.stats() 返回一个CacheStats。CacheStats提供以下统计方法：
```java
hitRate();            //返回缓存命中率
evictionCount();      //缓存回收数量
averageLoadPenalty(); //加载新值的平均时间
```

## 6、缓存填充策略
Caffeine Cache提供了三种缓存填充策略：手动、同步加载和异步加载。
### 6.1 手动加载
在每次get key的时候指定一个同步的函数，如果key不存在就调用这个函数生成一个值。

```java
/**
 * 手动加载
 * @param key
 * @return
 */
public Object manulOperator(String key) {
    Cache<String, Object> cache = Caffeine.newBuilder()
        .expireAfterWrite(1, TimeUnit.SECONDS)
        .expireAfterAccess(1, TimeUnit.SECONDS)
        .maximumSize(10)
        .build();
    //如果一个key不存在，那么会进入指定的函数生成value
    Object value = cache.get(key, t -> setValue(key).apply(key));
    cache.put("hello",value);

    //判断是否存在如果不存返回null
    Object ifPresent = cache.getIfPresent(key);
    //移除一个key
    cache.invalidate(key);
    return value;
}

public Function<String, Object> setValue(String key){
    return t -> key + "value";
}
```

### 6.2 同步加载
构造Cache时候，build方法传入一个CacheLoader实现类。实现load方法，通过key加载value。

```java
/**
 * 同步加载
 * @param key
 * @return
 */
public Object syncOperator(String key){
    LoadingCache<String, Object> cache = Caffeine.newBuilder()
        .maximumSize(100)
        .expireAfterWrite(1, TimeUnit.MINUTES)
        .build(k -> setValue(key).apply(key));
    return cache.get(key);
}

public Function<String, Object> setValue(String key){
    return t -> key + "value";
}
```

### 6.3. 异步加载
AsyncLoadingCache是继承自LoadingCache类的，异步加载使用Executor去调用方法并返回一个CompletableFuture。异步加载缓存使用了响应式编程模型。

如果要以同步方式调用时，应提供CacheLoader。要以异步表示时，应该提供一个AsyncCacheLoader，并返回一个CompletableFuture。

```java
/**
 * 异步加载
 * @param key
 * @return
 */
public Object asyncOperator(String key){
    AsyncLoadingCache<String, Object> cache = Caffeine.newBuilder()
        .maximumSize(100)
        .expireAfterWrite(1, TimeUnit.MINUTES)
        .buildAsync(k -> setAsyncValue(key).get());

    return cache.get(key);
}

public CompletableFuture<Object> setAsyncValue(String key){
    return CompletableFuture.supplyAsync(() -> {
        return key + "value";
    });
}
```

## 7、缓存回收策略
Caffeine提供了3种回收策略：基于大小回收，基于时间回收，基于引用回收。
### 7.1 基于大小的过期方式
基于大小的回收策略有两种方式：一种是基于缓存大小，一种是基于权重。

```java
// 根据缓存的计数进行驱逐
LoadingCache<String, Object> cache = Caffeine.newBuilder()
    .maximumSize(10000)
    .build(key -> function(key));


// 根据缓存的权重来进行驱逐（权重只是用于确定缓存大小，不会用于决定该缓存是否被驱逐）
LoadingCache<String, Object> cache1 = Caffeine.newBuilder()
    .maximumWeight(10000)
    .weigher(key -> function1(key))
    .build(key -> function(key));
```
#### 注意：
maximumWeight与maximumSize不可以同时使用。

### 7.2 基于时间的过期方式
Caffeine提供了三种定时驱逐策略：
* expireAfterAccess(long, TimeUnit):在最后一次访问或者写入后开始计时，在指定的时间后过期。假如一直有请求访问该key，那么这个缓存将一直不会过期。
* expireAfterWrite(long, TimeUnit): 在最后一次写入缓存后开始计时，在指定的时间后过期。
* expireAfter(Expiry): 自定义策略，过期时间由Expiry实现独自计算。
缓存的删除策略使用的是惰性删除和定时删除。这两个删除策略的时间复杂度都是O(1)。

```java
// 基于固定的到期策略进行退出
LoadingCache<String, Object> cache = Caffeine.newBuilder()
    .expireAfterAccess(5, TimeUnit.MINUTES)
    .build(key -> function(key));
LoadingCache<String, Object> cache1 = Caffeine.newBuilder()
    .expireAfterWrite(10, TimeUnit.MINUTES)
    .build(key -> function(key));

// 基于不同的到期策略进行退出
LoadingCache<String, Object> cache2 = Caffeine.newBuilder()
    .expireAfter(new Expiry<String, Object>() {
        @Override
        public long expireAfterCreate(String key, Object value, long currentTime) {
            return TimeUnit.SECONDS.toNanos(seconds);
        }

        @Override
        public long expireAfterUpdate(@Nonnull String s, @Nonnull Object o, long l, long l1) {
            return 0;
        }

        @Override
        public long expireAfterRead(@Nonnull String s, @Nonnull Object o, long l, long l1) {
            return 0;
        }
    }).build(key -> function(key));
```

### 7.3 基于引用的过期方式
Java中四种引用类型

引用类型|被垃圾回收时间|用途|生存时间
-|-|-|-
强引用StrongReference|从来不会|对象的一般状态|JVM停止运行时终止
软引用SoftReference|在内存不足时|对象缓存|内存不足时终止
弱引用WeakReference|在垃圾回收时|对象缓存|gc运行后终止
虚引用PhantomReference|从来不会|可以用虚引用来跟踪对象被垃圾回收器回收的活动，当一个虚引用关联的对象被垃圾收集器回收之前会收到一条系统通知|JVM停止运行时终止

```java
// 当key和value都没有引用时驱逐缓存
LoadingCache<String, Object> cache = Caffeine.newBuilder()
    .weakKeys()
    .weakValues()
    .build(key -> function(key));

// 当垃圾收集器需要释放内存时驱逐
LoadingCache<String, Object> cache1 = Caffeine.newBuilder()
    .softValues()
    .build(key -> function(key));
```

#### 注意：
AsyncLoadingCache不支持弱引用和软引用。
* Caffeine.weakKeys()： 使用弱引用存储key。如果没有其他地方对该key有强引用，那么该缓存就会被垃圾回收器回收。由于垃圾回收器只依赖于身份(identity)相等，因此这会导致整个缓存使用身份 (==) 相等来比较 key，而不是使用 equals()。
* Caffeine.weakValues() ：使用弱引用存储value。如果没有其他地方对该value有强引用，那么该缓存就会被垃圾回收器回收。由于垃圾回收器只依赖于身份(identity)相等，因此这会导致整个缓存使用身份 (==) 相等来比较 key，而不是使用 equals()。
* Caffeine.softValues() ：使用软引用存储value。当内存满了过后，软引用的对象以将使用最近最少使用(least-recently-used ) 的方式进行垃圾回收。由于使用软引用是需要等到内存满了才进行回收，所以我们通常建议给缓存配置一个使用内存的最大值。 softValues() 将使用身份相等(identity) (==) 而不是equals() 来比较值。

Caffeine.weakValues()和Caffeine.softValues()不可以一起使用。

## 8、参考和引用
Caffeine：https://blog.csdn.net/a953713428/article/details/92159746  
Guava：https://blog.csdn.net/a953713428/article/details/91672602