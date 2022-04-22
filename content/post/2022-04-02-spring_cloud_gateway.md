---
title: "SpringCloud GateWay的一些细节注意"
date: 2022-04-02T00:29:47+08:00
tag : [ "java", "springcloud" ]
description: "SpringCloud GateWay的一些细节注意"
categories: [ "java", "springcloud" ]
toc: true
---

## 前言
spring cloud 2.* 的路由用的是 gateway 方案，不再是 1.* 时代的 zuul 了，不过也带来了新问题，这里整理下近期优化 gateway 的鉴权带来的爬坑记录

## 1、理解 gateway 与 zuul 比较
SpringCloud Gateway 是 Spring Cloud 的一个全新项目，该项目是基于 Spring 5.0，Spring Boot 2.0 和 Project Reactor 等技术开发的网关，它旨在为微服务架构提供一种简单有效的统一的 API 路由管理方式。

SpringCloud Gateway 作为 Spring Cloud 生态系统中的网关，目标是替代 Zuul，在Spring Cloud 2.0以上版本中，没有对新版本的Zuul 2.0以上最新高性能版本进行集成，仍然还是使用的Zuul 2.0之前的非Reactor模式的老版本。而为了提升网关的性能，SpringCloud Gateway是基于WebFlux框架实现的，而WebFlux框架底层则使用了高性能的Reactor模式通信框架Netty。

Spring Cloud Gateway 的目标，不仅提供统一的路由方式，并且基于 Filter 链的方式提供了网关基本的功能，例如：安全，监控/指标，和限流。

## 2、差异点
SpringCloud官方，对SpringCloud Gateway 特征介绍如下：

* （1）基于 Spring Framework 5，Project Reactor 和 Spring Boot 2.0
* （2）集成 Hystrix 断路器
* （3）集成 Spring Cloud DiscoveryClient
* （4）Predicates 和 Filters 作用于特定路由，易于编写的 Predicates 和 Filters
* （5）具备一些网关的高级功能：动态路由、限流、路径重写

从以上的特征来说，和Zuul的特征差别不大。SpringCloud Gateway和Zuul主要的区别，还是在底层的通信框架上。

简单说明一下上文中的三个术语：
### 2.1 Filter（过滤器）
和Zuul的过滤器在概念上类似，可以使用它拦截和修改请求，并且对上游的响应，进行二次处理。过滤器为org.springframework.cloud.gateway.filter.GatewayFilter类的实例。

### 2.2 Route（路由）
网关配置的基本组成模块，和Zuul的路由配置模块类似。一个Route模块由一个 ID，一个目标 URI，一组断言和一组过滤器定义。如果断言为真，则路由匹配，目标URI会被访问。

### 2.3 Predicate（断言）
这是一个 Java 8 的 Predicate，可以使用它来匹配来自 HTTP 请求的任何内容，例如 headers 或参数。断言的输入类型是一个 ServerWebExchange。

## 3、缺少一个 bean 的自动装配
gateway 里面采用采用了Feign组件调用接口进行JWT权限认证，报出如下错误
```java
feign.codec.DecodeException: No qualifying bean of type 
'org.springframework.boot.autoconfigure.http.HttpMessageConverters'
 available: expected at least 1 bean which qualifies as autowire candidate. Dependency annotations:
  {@org.springframework.beans.factory.annotation.Autowired(required=true)}
	at feign.AsyncResponseHandler.decode(AsyncResponseHandler.java:119) ~[feign-core-10.10.1.jar:na]
	Suppressed: reactor.core.publisher.FluxOnAssembly$OnAssemblyException: 
Error has been observed at the following site(s):
	|_ checkpoint ⇢ org.springframework.cloud.gateway.filter.WeightCalculatorWebFilter 
    [DefaultWebFilterChain]
	|_ checkpoint ⇢ org.springframework.boot.actuate.metrics.web.reactive.server.MetricsWebFilter 
    [DefaultWebFilterChain]
	|_ checkpoint ⇢ HTTP GET "/***/***" [ExceptionHandlingWebHandler]
```
从报错信息来看，找不到装配的bean，尝试手动注入，代码如下：
```java
@Bean
@ConditionalOnMissingBean
public HttpMessageConverters messageConverters(ObjectProvider<HttpMessageConverter<?>> converters) {
    return new HttpMessageConverters(converters.orderedStream().collect(Collectors.toList()));
}
```

## 4、引入 redission
和常规引入Redisson非常相似，需要根据自己的spring-boot版本引入对应的Redisson版本，但是不一样的是，如果是spring cloud getway，使用webflux的话，那么需要排除Redisson包内部的spring-boot-start-web
```xml
<dependency>
    <groupId>org.redisson</groupId>
    <artifactId>redisson-spring-boot-starter</artifactId>
    <version>3.14.0</version>
    <exclusions>
        <exclusion>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </exclusion>
        <exclusion>
            <groupId>org.redisson</groupId>
            <artifactId>redisson-spring-data-23</artifactId>
        </exclusion>
    </exclusions>
</dependency>

<dependency>
    <groupId>org.redisson</groupId>
    <artifactId>redisson-spring-data-22</artifactId>
    <version>3.14.0</version>
</dependency>
```

## 5、参考
gateway: <https://www.cnblogs.com/crazymakercircle/p/11704077.html>  
Feign: <https://blog.csdn.net/CharlesZKQ/article/details/112213110>  
Redisson: <https://blog.csdn.net/u013658328/article/details/112789307>
