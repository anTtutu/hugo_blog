---
title: "android下的termux模拟器安装openJDK和运行springboot项目"
date: 2021-03-10T00:29:47+08:00
tags: [ "android", "termux", "arm64", "springboot", "java" ]
description: "android下的termux模拟器安装openJDK和运行springboot项目"
categories: [ "android", "termux", "arm64", "springboot", "java" ]
toc: true
---

## 前言
2020年9月份打造好了termux，但是苦于jdk没法安装，只能简单的用ecj(eclipse的java，类似jdk的javac)，但是springboot或者tomcat的项目怎么跑啊?
今天为了做培训演示，找到了termux下的openJDK资源，记录下安装的经过。termux的安装和工具准备参考前一篇[android下安装termux模拟器-超便携linux](/post/2020-09-28-android_termux)

## 1、git下载openJDK的安装脚本
ssh登录termux，接着下载termux安装openJDK的脚本
```bash
git clone https://github.com/MasterDevX/Termux-Java.git
cd Termux-Java
chmod 700 installjava uninstall_java.sh
```
## 2、下载openJDK的包(可选)
因为步骤2中installjava会下载一个7、80M的openJDK的tar.gz包，为了减少失败，可以用wget先提前下载对应版本的包
```bash
dpkg --print-architecture
aarch64

wget https://github.com/Hax4us/java/releases/download/v8/jdk8_aarch64.tar.gz
```
调整下步骤2下载的installjava脚本，增加已下载tar.gz的判断  
把
```bash
wget https://github.com/Hax4us/java/releases/download/${tag}/jdk8_${archname}.tar.gz -q
```
修改成
```bash
if [ -f jdk8_${archname}.tar.gz ]; then
	ee "\e[32m[*] \e[34mOpen JDK-8 is exist."
else
    wget https://github.com/Hax4us/java/releases/download/${tag}/jdk8_${archname}.tar.gz -q
fi
```
## 3、安装
看看执行过程有没出错，正常的话应该安装完会出现success提示，如下图
```bash
bash installjava

Java was successfully installed!
```
![](/posts/termux/installjava_success.png)

## 4、测试
也可以参考下图
```bash
java -version
java version "1.8.0_152"
Java(TM) SE Runtime Environment (build 1.8.0_152-b16)
Java HotSpot(TM) 64-Bit Server VM (build 25.152-b16, mixed mode)

echo $JAVA_HOME
/data/data/com.termux/files/usr/share/jdk8
```
![](/posts/termux/java.png)

## 5、上传springboot项目
先添加springboot启动脚本
```bash
#!/bin/bash
SERVICE_HOME="$HOME/Java"
SERVICE_NAME="Z_testCode-0.0.1-SNAPSHOT"
SERVICE_JAR="Z_testCode-0.0.1-SNAPSHOT"
XMS="-Xms256M"
XMX="-Xmx512M"
tmpdir="$HOME/Java/tmp"

cd $SERVICE_HOME
PROG=$SERVICE_JAR
PIDFILE=$SERVICE_HOME/$SERVICE_JAR.pid
JARFILE=$SERVICE_HOME/$SERVICE_JAR.jar

status() {
    if [ -f $PIDFILE ]; then
        PID=$(cat $PIDFILE)
        if [ ! -x /proc/${PID} ]; then
            return 1
        else
            return 0
        fi
    else
        return 1
    fi
}

case "$1" in
    start)
        status
        RETVAL=$?
        if [ $RETVAL -eq 0 ]; then
            echo "-----$PIDFILE exists, process is already running or crashed"
            exit 1
        fi

        ##检测 java环境
        if [ ! -n $JAVA_HOME ]; then
           echo "-----Please check JAVA_HOME!"
           echo "-----Exist"
           exist 1
        else
           echo "-----Jave home: $JAVA_HOME"
           echo "-----Starting $PROG ..."
           nohup java -server $XMS $XMX -Djava.io.tmpdir="$tmpdir" -jar $JARFILE > $SERVICE_NAME.log 2>&1 &

           RETVAL=$?
           if [ $RETVAL -eq 0 ]; then
               echo "-----$PROG is started"
               echo $! > $PIDFILE
               exit 0
           else
               echo "-----Stopping $PROG"
               rm -f $PIDFILE
               exit 1
           fi
        fi
        ;;
    stop)
        echo "-----Shutting down $PROG"
        ps -ef |grep $SERVICE_NAME|grep -v grep |awk '{print $2}'|xargs kill -9

        #kill -9 `cat $PIDFILE`
        RETVAL=$?
        if [ $RETVAL -eq 0 ]; then
            rm -f $PIDFILE
        else
            echo "-----Failed to stopping $PROG"
        fi
        ;;
    status)
        status
        RETVAL=$?
        if [ $RETVAL -eq 0 ]; then
            PID=$(cat $PIDFILE)
            echo "-----$PROG is running ($PID)"
        else
            echo "-----$PROG is not running"
        fi
        ;;
    restart)
        $0 stop
        $0 start
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|status}"
        ;;
esac
```

## 6、启动springboot项目
```bash
chmod 700 startJar.sh
./startJar.sh start
```
注意步骤6脚本中有定义tmpdir，因为springboot启动的时候，会往linux的/tmp目录创建临时的缓存目录和文件，在termux下会报目录不存在，需要在classpath下自定义
```bash
tmpdir="$HOME/Java/tmp"
nohup java -server $XMS $XMX -Djava.io.tmpdir="$tmpdir" -jar $JARFILE > $SERVICE_NAME.log 2>&1 &
```
核对springboot的启动日志，是否正常
![](/posts/termux/springboot_start.png)

## 7、测试访问
测试springboot项目提前写好的接口
```bash
curl http://127.0.0.1:8090/test/demo
[{"id":1,"account":"test1","password":"password1","name":"张三1","sex":0,"company":"testCompany1"},
{"id":2,"account":"test2","password":"password2","name":"张三2","sex":1,"company":"testCompany2"},
{"id":3,"account":"test3","password":"password3","name":"张三3","sex":0,"company":"testCompany3"},
{"id":4,"account":"test4","password":"password4","name":"张三4","sex":1,"company":"testCompany4"},
{"id":5,"account":"test5","password":"password5","name":"张三5","sex":0,"company":"testCompany5"},
{"id":6,"account":"test6","password":"password6","name":"张三6","sex":1,"company":"testCompany6"},
{"id":7,"account":"test7","password":"password7","name":"张三7","sex":0,"company":"testCompany7"},
{"id":8,"account":"test8","password":"password8","name":"张三8","sex":1,"company":"testCompany8"},
{"id":9,"account":"test9","password":"password9","name":"张三9","sex":0,"company":"testCompany9"},
{"id":10,"account":"test10","password":"password10","name":"张三10","sex":1,"company":"testCompany10"}]
```
![](/posts/termux/test_springboot.png)
大功告成，现在springboot项目也起来了，访问了termux的mariadb，这些需要在写测试springboot项目提前配置好，这里没做介绍。  
termux安装参考前一篇[android下安装termux模拟器-超便携linux](/post/2020-09-28-android_termux)