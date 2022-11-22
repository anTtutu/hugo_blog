---
title: "springboot常见兼容性错误"
date: 2022-11-22T00:29:47+08:00
tag : [ "springboot" ]
description: "springboot常见兼容性错误"
categories: [ "springboot" ]
toc: true
---

## 前言
springboot日常使用中有一些兼容性的错误，有时候没遇见过会让人无法摸到头脑，这里记录一些问题，后续不定期补充

## 1、mysql
### 1.1 Received fatal alert: protocol_version
因为更换了数据源才发现并记录，之前用的是mariadb8正常，换了docker mysql8就报错，不过为了减少无法定位的错建议采用完整的url连接串。
```java
Caused by: com.mysql.jdbc.exceptions.jdbc4.CommunicationsException: Communications link failure

The last packet successfully received from the server was 6 milliseconds ago.  The last packet sent successfully to the server was 5 milliseconds ago.

Caused by: javax.net.ssl.SSLException: Received fatal alert: protocol_version
```

原因：  
spring.database.url连接串需要增加useSSL=false
```java
spring.datasource.url=jdbc:mysql://localhost:3306/test?useUnicode=true&zeroDateTimeBehavior=convertToNull&characterEncoding=UTF-8&useSSL=false
```

### 1.2 Unknown system variable 'query_cache_size'
因为更换了数据源才发现并记录，之前用的是mariadb8正常，换了docker mysql8就报错记录。
```java
Unknown system variable 'query_cache_size'
```

原因：  
连接的数据库mysql是8.*版本, 但是mybatis用的是低于8.*的版本导致, 升级相同版本的包
```xml
<!-- mysql -->
<dependency>
    <groupId>mysql</groupId>
    <artifactId>mysql-connector-java</artifactId>
    <version>8.0.28</version>
</dependency>
```

## 2、maven
### 2.1 Failed to execute goal org.apache.maven.plugins:maven-resources-plugin:3.2.0
maven打包编译的时候报这个错，暂没找到具体根因，暂调整版本号可以解决问题
```java
Failed to execute goal org.apache.maven.plugins:maven-resources-plugin:3.2.0
```

原因：
maven的版本包冲突，具体详细原因暂时没查到，后续分析出了原理再更新
```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
        </plugin>

        <!--在这里修改版本-->
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-resources-plugin</artifactId>
            <version>2.4.3</version>
        </plugin>
        <!---->

    </plugins>
</build>
```

## 3、spring cache
spring cache碰到的执行错误，不影响启动
### 3.1 
```java
java.lang.IllegalStateException: No cache could be resolved for 'Builder[public com.sxt.entity.Teacher com.sxt.service.impl.TeacherServiceImpl.queryById(java.lang.Integer)] caches=[] | key=''member:'+#id' | keyGenerator='' | cacheManager='' | cacheResolver='' | condition='' | unless='#result == null' | sync='false'' using resolver 'org.springframework.cache.interceptor.SimpleCacheResolver@4ae15abe'. At least one cache should be provided per cache operation.
```

原因：  
@Cacheable缺少cacheNames参数
```java
// 第一种 在方法的@Cacheable增加cacheNames，如果还有其他方法没添加，需要挨个方法都增加，建议用第二种
public class TestQueryImpl implements TestQuery {

	@Cacheable(cacheNames = {"user"}, key = "#id")
    public User findById(BigInteger id){
        return userMapper.selectByPrimaryKey(id);
    }
}

// 第二种 在类名增加@CacheConfig(cacheNames = "***")，其他方法就不用挨个添加了
@Service
@Cacheable(cacheManager = "redisCacheManager")
@CacheConfig(cacheNames = "user")
public class TestQueryImpl implements TestQuery {

}
```

## 4、mybatis
### 4.1 org.apache.ibatis.binding.BindingException: Invalid bound statement (not found)
```java
org.apache.ibatis.binding.BindingException: Invalid bound statement (not found)
```

原因：  
* 1、target\classes下没编译出来*Mapper.xml，用mvn compile下或build下项目即可
* 2、xxxMapper.xml文件没有按照传统的maven架构进行放置，在pom增加resource, 参考下面示例
```xml
<build>
    <resources>
        <resource>
            <directory>src/main/java</directory>
            <includes>
                <include>**/*.properties</include>
                <include>**/*.xml</include>
            </includes>
            <filtering>false</filtering>
        </resource>
    </resources>
</build>
```
* 3、代码配置问题  
检查MapperScan
```java
@MapperScan({"com.*.mapper"})
```
检查namesapce, 一般通过点击跳转可以验证是否正确
```xml
<mapper namespace="com.**.user.mapper.UserMapper">
......
</mapper>
```
检查id，一般ide插件可以关联跳转
```
<select id="selectByPrimaryKey" resultMap="BaseResultMap" parameterType="java.lang.Long">
......
</select>
```
检查mybatis的配置
```yml
mybatis:
  mapperLocations: classpath:**/mapper/**/*Mapper.xml
  type-aliases-package: com.**.entity
```

to be continue...

## 5、官方文档
spring cache：<https://docs.spring.io/spring/docs/5.1.9.RELEASE/spring-framework-reference/integration.html#cache>  
spring：<https://docs.spring.io/spring-framework/docs/5.1.9.RELEASE/spring-framework-reference/>  
spring yml核心参数: <https://docs.spring.io/spring-boot/docs/current/reference/html/application-properties.html#appendix.application-properties>