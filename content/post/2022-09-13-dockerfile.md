---
title: "dockerfile学习"
date: 2022-09-13T00:29:47+08:00
tag : [ "docker", " dockerfile" ]
description: "dockerfile学习"
categories: [ "docker", "dockerfile" ]
toc: true
---

## 前言
dockerfile学习整理

## 一、概述
Dockerfile 是一个用来构建镜像的文本文件，文本内容包含了一条条构建镜像所需的指令和说明。

[官方文档](https://docs.docker.com/engine/reference/builder/)  
[Dockerfile示例](https://github.com/dockerfile/)

![](/posts/docker/docker_framework.png)

## 二、Dockerfile结构
Dockerfile结构主要分为四部分：

* 基础镜像信息
* 维护者信息
* 镜像操作指令
* 容器启动时执行指令 （CMD/ENTRYPOINT)
>【温馨提示】Dockerfile每行支持一条指令，每条指令可携带多个参数(支持&&），支持使用以“#“号开头的注释（jason文件不支持#注释），但是也非必须满足上面的四点。

## 三、常用Dockerfile操作指令
* ARG—— 定义创建镜像过程中使用的变量 ，唯一一个可以在FROM之前定义 。
* FROM——基于某个镜像， * FROM前面只能有一个或多个ARG指令 。
* MAINTAINER（已弃用） —— 镜像维护者姓名或邮箱地址 。
* VOLUME —— 指定容器挂载点到宿主机自动生成的目录或其他容器
* RUN——执行镜像里的命令，跟在liunx执行命令一样，只需要在前面加上RUN关键词就行。
* COPY——复制本地（宿主机）上的文件到镜像。
* ADD——复制并解压（宿主机）上的压缩文件到镜像。
* ENV——设置环境变量。
* WORKDIR —— 为 RUN、CMD、ENTRYPOINT、COPY 和 * ADD 设置工作目录，就是切换目录 。
* USER —— 为RUN、CMD、和 ENTRYPOINT 执行命令指定运行用户。
* EXPOSE —— 声明容器的服务端口（仅仅是声明） 。
* CMD—— 容器启动后执行的命令 ，多个CMD只会执行最后一个，跟ENTRYPOINT的区别是，CMD可以作为ENTRYPOINT的参数，且会被yaml文件里的command覆盖。
* ENTRYPOINT—— 容器启动后执行的命令 ，多个只会执行最后一个。
* HEALTHCHECH —— 健康检查 。
* ONBUILD——它后面跟的是其它指令，比如 RUN, COPY 等，而这些指令，在当前镜像构建时并不会被执行。只有当以当前镜像为基础镜像，去构建下一级镜像的时候才会被执行。
* LABEL——LABEL 指令用来给镜像添加一些元数据（metadata），以键值对的形式 ，替换MAINTAINER。
### 1）镜像构建（docker build）
```bash
docker build -t text:v1 . --no-cache
# 要在构建后将映像标记到多个存储库中，请在运行命令-t时添加多个参数
docker build -t shykes/myapp:1.0.2 -t shykes/myapp:latest .

### 参数解释
# -t：指定镜像名称
# . ：当前目录Dockerfile
# -f：指定Dockerfile路径
#  --no-cache：不缓存
```
### 2）运行容器测试（docker run）
```bash
# 非交互式运行
docker run centos:7.4.1708 /bin/echo "Hello world"

### 交互式执行
# -t: 在新容器内指定一个伪终端或终端。
#-i: 允许你对容器内的标准输入 (STDIN) 进行交互。
# 会登录到docker环境中，交互式
docker run -it centos:7.4.1708 /bin/bash
# -d：后台执行，加了 -d 参数默认不会进入容器
docker run -itd centos:7.4.1708 /bin/bash

### 进入容器
# 在使用 -d 参数时，容器启动后会进入后台。此时想要进入容器，可以通过以下指令进入：
#docker exec -it ：推荐大家使用 docker exec -it 命令，因为此命令会退出容器终端，但不会导致容器的停止。
#docker attach：容器退出，会导致容器的停止。
docker exec -it  b2c0235dc53 /bin/bash
docker attach  b2c0235dc53
```
### 3）ARG
> 构建参数，与 ENV 作用一致。不过作用域不一样。ARG 设置的环境变量仅对 Dockerfile 内有效，也就是说只有 docker build 的过程中有效，构建好的镜像内不存在此环境变量。 唯一一个可以在FROM之前定义 。 构建命令 docker build 中可以用 --build-arg <参数名>=<值> 来覆盖。

语法格式：
```bash
ARG <参数名>[=<默认值>]
```
示例：
```bash
# 在FROM之前定义ARG，只在 FROM 中生效
ARG VERSION=laster
FROM centos:${VERSION}
# 在FROM之后使用，得重新定义，不需要赋值
ARG VERSION
RUN echo $VERSION >/tmp/image_version
```
### 4）FROM
> 定制的镜像都是基于 FROM 的镜像 ，【必选项】

语法格式：
```bash
FROM [--platform=<platform>] <image> [AS <name>]
FROM [--platform=<platform>] <image>[:<tag>] [AS <name>]
FROM [--platform=<platform>] <image>[@<digest>] [AS <name>]
```
> 如果引用多平台镜像，可选--platform标志可用于指定图像的平台。FROM例如，linux/amd64、 linux/arm64或windows/amd64。默认情况下，使用构建请求的目标平台。全局构建参数可用于此标志的值，例如允许您将阶段强制为原生构建平台 ( --platform=$BUILDPLATFORM)，并使用它交叉编译到阶段内的目标平台。

示例：
```bash
ARG VERSION=latest
FROM busybox:$VERSION
# FROM --platform="linux/amd64" busybox:$VERSION
ARG VERSION
RUN echo $VERSION > image_version
```
### 5）MAINTAINER（已弃用）
> 镜像维护者信息

语法格式：
```bash
MAINTAINER <name>
```
示例：
```bash
LABEL org.opencontainers.image.authors="SvenDowideit@home.org.au"
```
### 6）VOLUME
> 定义匿名数据卷。在启动容器时忘记挂载数据卷，会自动挂载到匿名卷。

作用：

* 避免重要的数据，因容器重启而丢失，这是非常致命的。
* 避免容器不断变大。
* 在启动容器 docker run 的时候，我们可以通过 -v 参数修改挂载点。
语法格式：
```bash
# 后面路径是容器内的路径，对应宿主机的目录是随机的
VOLUME ["<路径1>", "<路径2>"...]
VOLUME <路径>
```
示例：
```bash
FROM ubuntu
RUN mkdir /myvol
RUN echo "hello world" > /myvol/greeting
VOLUME /myvol
```
### 7）RUN
> 用于执行后面跟着的命令行命令。

语法格式：
```bash
RUN （shell形式，命令在 shell 中运行，默认/bin/sh -c在 Linux 或cmd /S /CWindows 上）
RUN ["executable", "param1", "param2"]（执行形式）
```
示例：
```bash
# 以下三种写法等价
RUN /bin/bash -c 'source $HOME/.bashrc; \
echo $HOME'

RUN /bin/bash -c 'source $HOME/.bashrc; echo $HOME'

RUN ["/bin/bash", "-c", "source $HOME/.bashrc; echo $HOME"]
```
### 8）COPY
拷贝（宿主机）文件或目录到容器中，跟ADD类似，但不具备自动下载或解压的功能 。 所有新文件和目录都使用 0 的 UID 和 GID 创建，除非可选--chown标志指定给定的用户名、组名或 UID/GID 组合以请求复制内容的特定所有权。

语法格式：
```bash
COPY [--chown=<user>:<group>] <src>... <dest>
COPY [--chown=<user>:<group>] ["<src>",... "<dest>"]
```
示例：
```bash
# 添加所有以“hom”开头的文件：
COPY hom* /mydir/
# ?替换为任何单个字符，例如“home.txt”。
COPY hom?.txt /mydir/
# 使用相对路径，并将“test.txt”添加到<WORKDIR>/relativeDir/：
COPY test.txt relativeDir/
# 使用绝对路径，并将“test.txt”添加到/absoluteDir/
COPY test.txt /absoluteDir/

# 修改文件权限
COPY --chown=55:mygroup files* /somedir/
COPY --chown=bin files* /somedir/
COPY --chown=1 files* /somedir/
COPY --chown=10:11 files* /somedir/
```
### 9）ADD
> 拷贝文件或目录到容器中，如果是URL或压缩包便会自动下载或自动解压 。

ADD 指令和 COPY 的使用格类似（同样需求下，官方推荐使用 COPY）。功能也类似，不同之处如下：

* ADD 的优点：在执行 <源文件> 为 tar 压缩文件的话，压缩格式为 gzip, bzip2 以及 xz 的情况下，会自动复制并解压到 <目标路径>。
* ADD 的缺点：在不解压的前提下，无法复制 tar 压缩文件。会令镜像构建缓存失效，从而可能会令镜像构建变得比较缓慢。具体是否使用，可以根据是否需要自动解压来决定。
语法格式：
```bash
ADD [--chown=<user>:<group>] <src>... <dest>
ADD [--chown=<user>:<group>] ["<src>",... "<dest>"]
```
示例：
```bash
# 通配符
ADD hom* /mydir/
# 相对路径，拷贝到WORKDIR目录下relativeDir/
ADD test.txt relativeDir/
# 绝对路径
ADD test.txt /absoluteDir/

# 更改权限
ADD --chown=55:mygroup files* /somedir/
ADD --chown=bin files* /somedir/
ADD --chown=1 files* /somedir/
ADD --chown=10:11 files* /somedir/
ADD 和 COPY 的区别和使用场景：

ADD 支持添加远程 url 和自动提取压缩格式的文件，COPY 只允许从本机中复制文件
COPY 支持从其他构建阶段中复制源文件(--from)
根据官方 Dockerfile 最佳实践，除非真的需要从远程 url 添加文件或自动提取压缩文件才用 ADD，其他情况一律使用 COPY
```
### 10）ENV
> 设置环境变量，定义了环境变量，那么在后续的指令中，就可以使用这个环境变量。

语法格式：
```bash
ENV <key1>=<value1> <key2>=<value2>...
# 省略"="此语法不允许在单个ENV指令中设置多个环境变量，并且可能会造成混淆。
ENV <key> <value>
```
示例：
```bash
ENV JAVA_HOME=/usr/local/jdk
ENV MY_NAME="John Doe" MY_DOG=Rex\ The\ Dog \
    MY_CAT=fluffy
# 此语法不允许在单个ENV指令中设置多个环境变量，并且可能会造成混淆。
ENV JAVA_HOME /usr/local/jdk
```
### 11）WORKDIR
> 指定工作目录。用 WORKDIR 指定的工作目录，会在构建镜像的每一层中都存在。（WORKDIR 指定的工作目录，必须是提前创建好的）。

语法格式：
```bash
WORKDIR <工作目录路径>
```
示例：
```bash
FROM busybox
ENV FOO=/bar
WORKDIR ${FOO}   # WORKDIR /bar
```
### 12）USER
>  用于指定执行后续命令的用户和用户组，这边只是切换后续命令执行的用户（用户和用户组必须提前已经存在）。

语法格式：
```bash
USER <用户名>[:<用户组>]
USER <UID>[:<GID>]
```
示例：
```bash
FROM busybox
RUN groupadd --system --gid=9999 admin && useradd --system --home-dir /home/admin --uid=9999 --gid=admin admin
USER admin:admin
# USER 9999:9999
```
### 13）EXPOSE
> 暴露端口 ，仅仅只是声明端口。

作用：

* 帮助镜像使用者理解这个镜像服务的守护端口，以方便配置映射。
* 在运行时使用随机端口映射时，也就是 docker run -P 时，会自动随机映射 EXPOSE 的端口。
语法格式：
```bash
# 默认情况下，EXPOSE假定 TCP。
EXPOSE <port> [<port>/<protocol>...]
```
示例：
```bash
EXPOSE 80/TCP 443/TCP
EXPOSE 80 443
EXPOSE 80/tcp
EXPOSE 80/udp
```
### 14）CMD
> 类似于 RUN 指令，用于运行程序，但二者运行的时间点不同：CMD 在构建镜像时不会执行，在容器运行 时运行。

语法格式：
```bash
CMD <shell 命令>
CMD ["<可执行文件或命令>","<param1>","<param2>",...] 
CMD ["<param1>","<param2>",...]  # 该写法是为 ENTRYPOINT 指令指定的程序提供默认参数
```
> 推荐使用第二种格式，执行过程比较明确。第一种格式实际上在运行的过程中也会自动转换成第二种格式运行，并且默认可执行文件是 sh。

示例：
```bash
CMD cat /etc/profile
CMD ["/bin/sh","-c","/etc/profile"]
```
>注意：如果 Dockerfile 中如果存在多个 CMD 指令，仅最后一个生效。

### 15）ENTRYPOINT
> 类似于 CMD 指令，但其不会被 docker run 的命令行参数指定的指令所覆盖，而且这些命令行参数会被当作参数送给 ENTRYPOINT 指令指定的程序。但是, 如果运行 docker run 时使用了 --entrypoint 选项，将覆盖 ENTRYPOINT 指令指定的程序。在k8s中command也会覆盖ENTRYPOINT 指令指定的程序

语法格式：
```bash
# exec形式，这是首选形式：
ENTRYPOINT ["executable", "param1", "param2"]
# 外壳形式：
ENTRYPOINT command param1 param2
```
示例：
```bash
FROM ubuntu
ENTRYPOINT ["top", "-b"]
# CMD作为ENTRYPOINT参数
CMD ["-c"]
# 与下面的等价
ENTRYPOINT ["top", "-b -c"]
ENTRYPOINT  top -b -c 
```
> 注意：如果 Dockerfile 中如果存在多个 ENTRYPOINT 指令，仅最后一个生效。

### 16）HEALTHCHECK
> 用于指定某个程序或者指令来监控 docker 容器服务的运行状态。

语法格式：
```bash
HEALTHCHECK [OPTIONS] CMD command（通过在容器内运行命令检查容器运行状况）
HEALTHCHECK NONE（禁用从基础映像继承的任何运行状况检查）
```
选项CMD有：

* --interval=DURATION（默认30s：）：间隔，频率
* --timeout=DURATION（默认30s：）：超时时间
* --start-period=DURATION（默认0s：）： 为需要时间引导的容器提供初始化时间， 在此期间探测失败将不计入最大重试次数。
* --retries=N（默认3：）：重试次数

命令的exit status指示容器的运行状况。可能的值为：

* 0：健康状态，容器健康且已准备完成。
* 1：不健康状态，容器工作不正常。
* 2：保留，不要使用此退出代码。

示例：
```bash
FROM nginx
MAINTAINER Securitit
HEALTHCHECK --interval=5s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1
CMD ["usr/sbin/nginx", "-g", "daemon off;"]
```
### 17）ONBUILD
> ONBUILD 是一个特殊的指令，它后面跟的是其它指令，比如 RUN, COPY 等，而这些指令，在当前镜像构建时并不会被执行。只有当以当前镜像为基础镜像，去构建下一级镜像的时候才会被执行。

语法格式：
```bash
ONBUILD <其它指令>
```
示例：
```bash
FROM node:slim
RUN mkdir /app
WORKDIR /app
ONBUILD COPY ./package.json /app
ONBUILD RUN [ "npm", "install" ]
ONBUILD COPY . /app/
CMD [ "npm", "start" ]
```
### 18）LABEL
> LABEL 指令用来给镜像添加一些元数据（metadata），以键值对的形式。用来替代MAINTAINER。

语法格式：
```bash
LABEL <key>=<value> <key>=<value> <key>=<value> ...
```
示例： 比如我们可以添加镜像的作者
```bash
LABEL org.opencontainers.image.authors="runoob"
```
## 四、ARG 和 ENV 的区别
* ARG 定义的变量只会存在于镜像构建过程，启动容器后并不保留这些变量
* ENV 定义的变量在启动容器后仍然保留
## 五、CMD，ENTRYPOINT，command，args场景测试
当用户同时在kubernetes中的yaml文件中写了command和args的时候，默认是会覆盖DockerFile中的命令行和参数，完整的情况分类如下：

### 1）command和args不存在场景测试
> 如果command和args都没有写，那么用DockerFile默认的配置。

Dockerfile
```bash
FROM centos

COPY test.sh /

RUN chmod +x /test.sh
### ENTRYPOINT将作为的子命令启动/bin/sh -c，它不会传递参数，要传递参数只能这样传参
# ENTRYPOINT ["/bin/sh","-c","/test.sh ENTRYPOINT"]
ENTRYPOINT ["/test.sh","ENTRYPOINT"]
CMD ["CMD"]
```
/tmp/test.sh
```bash
#!/bin/bash

echo $*
```
构建
```bash
docker build -t test1:v1 -f Dockerfile .
```
yaml编排
```yaml
cat << EOF > test1.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test
  template:
    metadata:
      labels:
        app: test
    spec:
      nodeName: local-168-182-110
      containers:
      - name: test
        image: test:v1
        #command: ['/bin/sh','-c','/test.sh']
        #args: ['args']
EOF
```
执行
```bash
kubectl apply -f test.yaml
```
### 2）command存在，但args存在场景测试
> 如果command写了，但args没有写，那么Docker默认的配置会被忽略而且仅仅执行.yaml文件的command（不带任何参数的）。
```yaml
cat << EOF > test2.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test2
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test2
  template:
    metadata:
      labels:
        app: test2
    spec:
      nodeName: local-168-182-110
      containers:
      - name: test2
        image: test:v1
        # ['/bin/sh','-c','/test.sh command','hello']，加了'/bin/sh','-c',也是不能外部传参，不会输出hello，只能通过这样传参，['/bin/sh','-c','/test.sh command']；CMD里面的参数会被忽略
        command: ['/test.sh']
        # command带参数
        # command: ['/test.sh','command']
        #args: ['args']
EOF
```
### 3）command不存在，但args存在场景测试
> 如果command没写，但args写了，那么Docker默认配置的ENTRYPOINT的命令行会被执行，但是调用的参数是.yaml中的args，CMD的参数会被覆盖，但是ENTRYPOINT自带的参数还是会执行的。
```yaml
cat << EOF > test3.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test3
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test3
  template:
    metadata:
      labels:
        app: test3
    spec:
      nodeName: local-168-182-110
      containers:
      - name: test3
        image: test:v1
        # ['/bin/sh','-c','/test.sh command','hello']，加了'/bin/sh','-c',也是不能外部传参，不会输出hello，只能通过这样传参，['/bin/sh','-c','/test.sh command']；CMD里面的参数会被忽略
        # command: ['/test.sh']
        # command带参数
        # command: ['/test.sh','command']
        args: ['args']
EOF
```
### 4）command和args都存在场景测试
> 如果如果command和args都写了，那么Docker默认的配置被忽略，使用.yaml的配置。
```yaml
cat << EOF > test4.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test4
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test4
  template:
    metadata:
      labels:
        app: test4
    spec:
      nodeName: local-168-182-110
      containers:
      - name: test4
        image: test:v1
        # ['/bin/sh','-c','/test.sh command','hello']，加了'/bin/sh','-c',也是不能外部传参，不会输出hello，只能通过这样传参，['/bin/sh','-c','/test.sh command']；CMD里面的参数会被忽略
        # command: ['/test.sh']
        # command带参数，command和args都会带上
        command: ['/test.sh','command']
        args: ['args']
EOF
```
