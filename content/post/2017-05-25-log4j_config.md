---
title: Log4j参数整理
date: 2017-05-25T21:46:20+08:00
tags: [ "log4j", "java" ] 
description: "Log4j参数整理"
categories: [ "log4j", "java" ]
toc: true
---

## 前言
Log4j 1.x的知识点回顾，2015年8月5日，Apache的Logging Services项目管理委员会宣布Log4j 1.x已经结束生命周期，建议升级 Log4j 2.x。
## 1. 配置文件
Log4J配置文件的基本格式如下：
```properties
#配置根Logger
log4j.rootLogger  =   [ level ]   ,  appenderName1 ,  appenderName2 ,  …

#配置日志信息输出目的地Appender
log4j.appender.appenderName  =  fully.qualified.name.of.appender.class 
　　log4j.appender.appenderName.option1  =  value1 
　　… 
　　log4j.appender.appenderName.optionN  =  valueN 

#配置日志信息的格式（布局）
log4j.appender.appenderName.layout  =  fully.qualified.name.of.layout.class 
　　log4j.appender.appenderName.layout.option1  =  value1 
　　… 
　　log4j.appender.appenderName.layout.optionN  =  valueN 
```
## 2、日志输出级别
其中 [level] 共有5级，如下：
```properties
FATAL       0  
ERROR       3  
WARN        4  
INFO        6  
DEBUG       7 
```
## 3、Appender
为日志输出目的地，Log4j提供的appender有以下几种：
```properties
org.apache.log4j.ConsoleAppender（控制台），
org.apache.log4j.FileAppender（文件），
org.apache.log4j.DailyRollingFileAppender（每天产生一个日志文件），
org.apache.log4j.RollingFileAppender（文件大小到达指定尺寸的时候产生一个新的文件），
org.apache.log4j.WriterAppender（将日志信息以流格式发送到任意指定的地方）
```
## 4、Layout
日志输出格式，Log4j提供的layout有以下几种：
```properties
org.apache.log4j.HTMLLayout（以HTML表格形式布局），
org.apache.log4j.PatternLayout（可以灵活地指定布局模式），
org.apache.log4j.SimpleLayout（包含日志信息的级别和信息字符串），
org.apache.log4j.TTCCLayout（包含日志产生的时间、线程、类别等等信息）
```
## 5、打印参数
Log4J采用类似C语言中的printf函数的打印格式格式化日志信息，如下:
```properties
%m 输出代码中指定的消息
%p 输出优先级，即DEBUG，INFO，WARN，ERROR，FATAL 
%r 输出自应用启动到输出该log信息耗费的毫秒数 
%c 输出所属的类目，通常就是所在类的全名 
%t 输出产生该日志事件的线程名 
%n 输出一个回车换行符，Windows平台为“/r/n”，Unix平台为“/n” 
%d 输出日志时间点的日期或时间，默认格式为ISO8601，也可以在其后指定格式，比如：%d{yyyyMMdd HH:mm:ss,SSS}，输出类似：2002年10月18日 22:10:28,921  
%l 输出日志事件的发生位置，包括类目名、发生的线程，以及在代码中的行数。举例：Testlog4.main(TestLog4.java:10) 
%x 输出和当前线程相关联的NDC(嵌套诊断环境),尤其用到像java servlets这样的多客户多线程的应用中。
%% 输出一个"%"字符
%F 输出日志消息产生时所在的文件名称
%L 输出代码中的行号
```
## 6、格式
可以在%与模式字符之间加上修饰符来控制其最小宽度、最大宽度、和文本的对齐方式。如：
```properties
1)%20c：指定输出category的名称，最小的宽度是20，如果category的名称小于20的话，默认的情况下右对齐。
2)%-20c:指定输出category的名称，最小的宽度是20，如果category的名称小于20的话，"-"号指定左对齐。
3)%.30c:指定输出category的名称，最大的宽度是30，如果category的名称大于30的话，就会将左边多出的字符截掉，但小于30的话也不会有空格。
4)%20.30c:如果category的名称小于20就补空格，并且右对齐，如果其名称长于30字符，就从左边较远输出的字符截掉。
```
## 7、完整的demo
下面给出的Log4J配置文件实现了输出到控制台，文件，回滚文件，发送日志邮件，输出到数据库日志表，自定义标签等全套功能。
```properties  
log4j.rootLogger=DEBUG,CONSOLE,A1,im   
#DEBUG,CONSOLE,FILE,ROLLING_FILE,MAIL,DATABASE  
log4j.addivity.org.apache=true  
###################   
# Console Appender   
###################   
log4j.appender.CONSOLE=org.apache.log4j.ConsoleAppender   
log4j.appender.Threshold=DEBUG   
log4j.appender.CONSOLE.Target=System.out   
log4j.appender.CONSOLE.layout=org.apache.log4j.PatternLayout   
log4j.appender.CONSOLE.layout.ConversionPattern=[framework] %d - %c -%-4r [%t] %-5p %c %x - %m%n   
#log4j.appender.CONSOLE.layout.ConversionPattern=[start]%d{DATE}[DATE]%n%p[PRIORITY]%n%x[NDC]%n%t[THREAD] n%c[CATEGORY]%n%m[MESSAGE]%n%n  
#####################   
# File Appender   
#####################   
log4j.appender.FILE=org.apache.log4j.FileAppender   
log4j.appender.FILE.File=file.log   
log4j.appender.FILE.Append=false   
log4j.appender.FILE.layout=org.apache.log4j.PatternLayout   
log4j.appender.FILE.layout.ConversionPattern=[framework] %d - %c -%-4r [%t] %-5p %c %x - %m%n   
# Use this layout for LogFactor 5 analysis  
########################   
# Rolling File   
########################   
log4j.appender.ROLLING_FILE=org.apache.log4j.RollingFileAppender   
log4j.appender.ROLLING_FILE.Threshold=ERROR   
log4j.appender.ROLLING_FILE.File=rolling.log   
log4j.appender.ROLLING_FILE.Append=true   
log4j.appender.ROLLING_FILE.MaxFileSize=10KB   
log4j.appender.ROLLING_FILE.MaxBackupIndex=1   
log4j.appender.ROLLING_FILE.layout=org.apache.log4j.PatternLayout   
log4j.appender.ROLLING_FILE.layout.ConversionPattern=[framework] %d - %c -%-4r [%t] %-5p %c %x - %m%n  
####################   
# Socket Appender   
####################   
log4j.appender.SOCKET=org.apache.log4j.RollingFileAppender   
log4j.appender.SOCKET.RemoteHost=localhost   
log4j.appender.SOCKET.Port=5001   
log4j.appender.SOCKET.LocationInfo=true   
# Set up for Log Facter 5   
log4j.appender.SOCKET.layout=org.apache.log4j.PatternLayout   
log4j.appender.SOCET.layout.ConversionPattern=[start]%d{DATE}[DATE]%n%p[PRIORITY]%n%x[NDC]%n%t[THREAD]%n%c[CATEGORY]%n%m[MESSAGE]%n%n  
########################   
# Log Factor 5 Appender   
########################   
log4j.appender.LF5_APPENDER=org.apache.log4j.lf5.LF5Appender   
log4j.appender.LF5_APPENDER.MaxNumberOfRecords=2000  
########################   
# SMTP Appender   
#######################   
log4j.appender.MAIL=org.apache.log4j.net.SMTPAppender   
log4j.appender.MAIL.Threshold=FATAL   
log4j.appender.MAIL.BufferSize=10   
log4j.appender.MAIL.From=testl@sohu.com  
log4j.appender.MAIL.SMTPHost=smtp.sohu.com   
log4j.appender.MAIL.Subject=Log4J Message   
log4j.appender.MAIL.To=test@sohu.com  
log4j.appender.MAIL.layout=org.apache.log4j.PatternLayout   
log4j.appender.MAIL.layout.ConversionPattern=[framework] %d - %c -%-4r [%t] %-5p %c %x - %m%n  
########################   
# JDBC Appender   
#######################   
log4j.appender.DATABASE=org.apache.log4j.jdbc.JDBCAppender   
log4j.appender.DATABASE.URL=jdbc:mysql://localhost:3306/test   
log4j.appender.DATABASE.driver=com.mysql.jdbc.Driver   
log4j.appender.DATABASE.user=root   
log4j.appender.DATABASE.password=   
log4j.appender.DATABASE.sql=INSERT INTO LOG4J (Message) VALUES ('[framework] %d - %c -%-4r [%t] %-5p %c %x - %m%n')   
log4j.appender.DATABASE.layout=org.apache.log4j.PatternLayout   
log4j.appender.DATABASE.layout.ConversionPattern=[framework] %d - %c -%-4r [%t] %-5p %c %x - %m%n  
log4j.appender.A1=org.apache.log4j.DailyRollingFileAppender   
log4j.appender.A1.File=SampleMessages.log4j   
log4j.appender.A1.DatePattern=yyyyMMdd-HH'.log4j'   
log4j.appender.A1.layout=org.apache.log4j.xml.XMLLayout  
###################   
#自定义Appender   
###################   
log4j.appender.im = net.cybercorlin.util.logger.appender.IMAppender  
log4j.appender.im.host = mail.cybercorlin.net   
log4j.appender.im.username = username   
log4j.appender.im.password = password   
log4j.appender.im.recipient = corlin@yeqiangwei.com  
log4j.appender.im.layout=org.apache.log4j.PatternLayout   
log4j.appender.im.layout.ConversionPattern =[framework] %d - %c -%-4r [%t] %-5p %c %x - %m%n
```