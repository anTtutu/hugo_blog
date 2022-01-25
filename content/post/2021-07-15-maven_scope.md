---
title: "maven的scope参数"
date: 2021-07-15T00:29:47+08:00
tag : [ "maven", "java" ]
description: "maven的scope参数"
categories: [ "maven", "java" ]
toc: true
---

## 1、用maven引用没进中央仓库的包
在使用maven的时候，如果我们要依赖一个本地的jar包的时候，通常都会使用\<scope\>system\</scope\>和\<systemPath\>\</systemPath\>来处理。  
例如：
```xml
<!--引用本地jar包-->
<dependency>
    <groupId>com.mytest</groupId>
    <artifactId>test</artifactId>
    <version>1.0</version>
    <scope>system</scope>
    <systemPath>${pom.basedir}/lib/test-1.0.jar</systemPath>
</dependency>
```

如果你仅仅是这么做了，在你使用SpringBoot打包插件生成jar包的时候，你会发现这个jar包不会被打进去，进而出现错误。  
这个就需要在maven插接中配置一个includeSystemScope属性：
```xml
<plugin>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-maven-plugin</artifactId>
    <configuration>
    	<!--设置为true，以便把本地的system的jar也包括进来-->
        <includeSystemScope>true</includeSystemScope>
    </configuration>
</plugin>
```

## 2、用maven打包可执行main函数的jar包
使用maven打可执行main的jar包怎么搞？
### 2.1、pom中添加配置信息
```xml
    <groupId>com.anttu.test</groupId>
    <artifactId>test</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.source>8</maven.compiler.source>
        <maven.compiler.target>8</maven.compiler.target>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    </properties>
 
    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <configuration>
                    <appendAssemblyId>false</appendAssemblyId>
                    <descriptorRefs>
                        <descriptorRef>jar-with-dependencies</descriptorRef>
                    </descriptorRefs>
                    <archive>
                        <manifest>
                            <mainClass>com.anttu.test.TestMain</mainClass>
                        </manifest>
                    </archive>
                </configuration>
                <executions>
                    <execution>
                        <id>make-assembly</id>
                        <phase>package</phase>
                        <goals>
                            <goal>single</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>

 <!--
 其中<mainClass>com.main.TestMain</mainClass>填写"包名.含有Main的class名"
 -->
```

### 2.2 可以直接编译
```bash
mvn assembly:assembly
#跳过测试 
mvn -Dmaven.test.skip=true  assembly:assembly
```

### 2.3、执行命令编译和打包
```bash
mvn clean package
```

### 2.4、运行
```bash
java -jar test-1.0-SNAPSHOT.jar
```

## 3、maven的scope有哪些
maven的scope一共包括：
compile、runtime、test、system、provided、import

### 3.1、compile
```xml
<dependency>
 	<groupId>org.apache.httpcomponents</groupId>
 	<artifactId>httpclient</artifactId>
 	<version>4.4.1</version>
 	<scope>compile</scope>
</dependency>
```
compile是默认值，当我们引入依赖时，如果标签没有指定，那么默认就是complie。  
compile表示被依赖项目需要参与当前项目的编译，包括后续的测试，运行周期也参与其中，同时打包的时候也会包含进去。是最常用的，所以也是默认的。

### 3.2、runtime
```xml
<dependency>
   <groupId>mysql</groupId>
   <artifactId>mysql-connector-java</artifactId>
   <version>5.1.46</version>
   <scope>runtime</scope>
 </dependency>
```
runtime表示被依赖项目无需参与项目的编译，不过后期的测试和运行周期需要其参与。与compile相比，跳过编译而已。  
数据库的驱动包一般都是runtime，因为在我们在编码时只会使用JDK提供的jdbc接口，而具体的实现是有对应的厂商提供的驱动(如mysql驱动)，实在运行时生效的，所以这类jar包无需参与项目的编译。

### 3.3、test
```xml
<dependency>
   <groupId>junit</groupId>
   <artifactId>junit</artifactId>
   <version>4.12</version>
   <scope>test</scope>
</dependency>
```
test表示只会在测试阶段使用，在src/main/java里面的代码是无法使用这些api的，并且项目打包时，也不会将"test"标记的打入"jar"包或者"war"包。

### 3.4、system
```xml
<dependency>
    <groupId>com.mytest</groupId>
    <artifactId>test</artifactId>
    <version>1.0</version>
    <scope>system</scope>
    <systemPath>${basedir}/lib/test-1.0.jar</systemPath>
</dependency>
```
system依赖不是由maven仓库，而是本地的jar包，因此必须配合systemPath标签来指定本地的jar包所在全路径。  
这类jar包默认会参与编译、测试、运行，但是不会被参与打包阶段。  
如果也想打包进去的话，需要在插件里做配置\<includeSystemScope\>true\</includeSystemScope\>，也就是我们本篇开题提到的问题。

### 3.5、provided
```xml
<dependency>
   <groupId>javax.servlet</groupId>
   <artifactId>javax.servlet-api</artifactId>
   <version>4.0.1</version>
   <scope>provided</scope>
</dependency>
```
provided表示的是在编译和测试的时候有效，在执行（mvn package）进行打包成war、jar包的时候不会加入，比如：servlet-api，因为servlet-api，tomcat等web服务器中已经存在，如果在打包进去，那么包之间就会冲突

### 3.6、import
```xml
<dependencyManagement>
  <dependencies>
	<dependency>
	    <groupId>org.springframework.boot</groupId>
	    <artifactId>spring-boot-dependencies</artifactId>
	    <version>2.1.1.RELEASE</version>
	    <type>pom</type>
	    <scope>import</scope>
	</dependency>
 </dependencies>
</dependencyManagement>
```
import比较特殊，他的作用是将其他模块定义好的 dependencyManagement 导入当前 Maven 项目 pom 的 dependencyManagement 中，都是配合\<type\>pom\</type\>来进行的。所以import作用的是pom类型，不是jar包。