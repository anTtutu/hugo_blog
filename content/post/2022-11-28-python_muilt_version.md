---
title: "python多版本管理工具"
date: 2022-11-22T00:29:47+08:00
tag : [ "python", "sdk" ]
description: "python多版本管理工具"
categories: [ "python", "sdk" ]
toc: true
---

## 前言
python多版本管理工具整理介绍

序号|工具名称|安装方式|说明|备注
-|-|-|-|-
1|pyenv|curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer \| bash|比较早出现的 python 多版本管理工具，目前不太活跃了|
2|virtualenv|pip install virtualenv|通过创建虚拟机方式管理|
3|anaconda|https://repo.anaconda.com/archive/|带了很多科学计算包的发行版，包含conda|
4|miniconda|https://repo.anaconda.com/miniconda/|不带科学计算包的mini版本，只有python和conda|
5|miniforge|https://github.com/conda-forge/miniforge|miniforge是由社区赞助、领导的，并且用GitHub托管所有的包，使用 （而且只用）conda-forge 作为（默认）下载channel，避开了Anaconda的repository|-

## 1、Conda自身管理
### 1.1 更新conda
```bash
# 更新anaconda
conda update conda
```
### 1.2 更新anaconda元数据包
```bash
# 更新anaconda元数据包
conda update anaconda
```

## 2、Python环境管理
```bash
# 创建一个新环境，并制定python解释器版本，没有会自动下载
# python27 是环境名称
# python=2.7 是要安装的包和版本，默认会为我们寻找2.7.x中的最新版本
# anaconda 是创建环境时同时要安装的包，这个可以不写
conda create -n python27 python=2.7 anaconda
conda create -n python36 python=3.6
conda create -n python37 python=3.7
 
# 更新Python，进入某个环境运行下面的命令，将更新当前环境的Python到最新分支版本。比如当前是3.5，更新后将会到最新的3.X
conda update python
```

## 3、虚拟环境管理
### 3.1 查看当前托管的所有虚拟环境列表
```bash
$ conda env list
# conda environments:
#
base                  *  /root/anaconda3
```
### 3.2 创建虚拟环境
```bash
# 创建一个名为myvenv 的环境，指定Python版本是3.10
# （不用管是3.10.x，conda会为我们自动寻找3.10.x中的最新版本）
conda create --name myvenv python=3.10
```
虚拟环境不会在当前环境下创建虚拟环境目录，所有的虚拟环境目录默认放在：/root/anaconda3/envs/

### 3.3 激活虚拟环境
```bash
activate myvenv        # for Windows
source activate myvenv # for Linux & Mac
conda activate myvenv  # 新版使用这个
```

### 3.4 退出虚拟环境
```bash
conda deactivate
```

### 3.5 导出依赖包
导出环境，它会把当前环境中安装的包以及版本号都导出去，这样你就可以拿到另外的机器上来重新构建一个相同的环境

导出的内容包括环境名称，安装渠道，该环境安装的包以及版本号。
```bash
# 首先进入名称叫做python36环境
conda activate myvenv 
# 导出当前环境到指定文件
conda env export > environment.yml  
# 通过环境文件建立环境，不需要指定环境名称，因为文件中包含名称字段
conda env create -f environment.yml
```

### 3.6 删除虚拟环境
```bash
# 方式一：
conda env remove --name myvenv
# 方式二：
conda remove -n myvenv --all
```

### 3.7 克隆虚拟环境
```bash
conda create -n myvenv2 --clone myvenv
```

## 4、包管理
### 4.1 安装包
```bash
conda install --name myvenv scipy # 安装包到指定环境中
conda install scipy # 安装包到当前环境中
conda install scipy=0.15.0  # 安装指定版本的包，到当前环境
conda install scipy curl # 安装多个包
conda install -c anaconda django # -c是指定渠道名称，也就是用哪个渠道安装django。
```

### 4.2 卸载包
```bash
# 卸载包
conda remove 包名  # 删除当前环境中的指定包
conda remove -n myvenv numpy # 删除指定环境中的指定包
conda remove -n myvenv --all # 删除指定环境中的所有包，等同于删除环境
```

### 4.3 更新包
```bash
conda update 包名  # 更新当前环境指定的包
conda update -n myvenv numpy # 更新指定环境中的指定包
```

### 4.4 查看当前packages
```bash
# 查看当前已经安装的packages
conda list
conda list -n myvenv # 查看指定环境中安装的所有包
```

### 4.5 查找可安装的包
精确查找
```
conda search --full-name <package_full_name>
# 例如：
conda search --full-name python
```
模糊查找
```bash
conda search jieba
# 支持正则
conda search *py*
```

## 5、镜像源管理
conda默认使用的是官方镜像源，是在国外，安装下载会很慢，所以强烈建议切换为国内镜像源。
### 5.1 查看当前镜像源配置
```bash
# 查看当前的镜像源
conda config --show channels
# 查看详细信息
conda config --show
```
default的地址默认就是官方地址，https://repo.anaconda.com/pkgs/main

### 5.2 添加清华大学镜像源
```bash
# 添加Anaconda的TUNA镜像
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
 
# 设置搜索时显示通道地址，这个可以不加，只是为了看一下是否从镜像站下载
conda config --set show_channel_urls yes
```
### 5.3 再次查看镜像地址
```bash
conda config --show channels
```

### 5.4 添加第三方镜像源
```bash
##  Conda Forge
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/
## msys2
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/msys2/
## bioconda
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/
## menpo
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/menpo/
## pytorch
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/pytorch/
``` 

### 5.5 其他镜像源

清华大学其他镜像源地址：https://mirrors.tuna.tsinghua.edu.cn/anaconda/

### 5.6 删除镜像源
```bash
conda config --remove channels <URL>  ## 删除原来的旧镜像
 
# 如下
conda config --remove channels default
conda config --remove channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/
conda config --remove channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/
```

### 5.7 清除索引缓存
运行 conda clean -i 清除索引缓存，保证用的是镜像站提供的索引。
```bash
conda clean -i
```

## 6、.condarc文件样例
```
vim /root/.condarc
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  msys2: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  bioconda: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  menpo: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch-lts: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  simpleitk: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
```

## 7、当conda中没有这个包时
会报错，如下：

PackagesNotFoundError: The following packages are not available from current channels:

### 7.1 方法一：使用pip安装
```bash
# 安装不在conda或者acaconda的包，当你安装的包不在conda管理范围的时候可以使用pip来安装
conda install pip  # 首先在当前环境中安装pip
pip install jieba   # 其次在通过PIP命令在当前环境中安装包
```

### 7.2 方法二：搜索包含该安装包的渠道
```bash
anaconda search  jieba
```
选择其中一个版本，我们选择了conda-forge/jieba模块

展示该版本的信息
```bash
anaconda show conda‐forge/jieba

找到对应的渠道信息，如上面最后一行，直接进行安装即可
```bash
conda install --channel https://conda.anaconda.org/conda-forge jieba
```
如果最开始你就知道要这个渠道模块，也可以这样直接安装：
```bash
conda install -c conda-forge jieba
```

### 7.3 方法三：去conda官网搜索包

说明：对于那些无法通过conda安装或者从Anaconda.org获得的包，我们通常可以用pip来安装包。

pip只是一个包管理器，所以它不能为你管理环境。pip甚至不能升级python，因为它不像conda一样把python当做包来处理。但是它可以安装一些conda安装不了的包，pip和conda都集成在Anaconda或miniconda里边。

另外你还可以去 官网 搜索：https://anaconda.org/

找到很多渠道

找到安装路径

再使用该安装路径安装即可：
```bash
conda install -c conda-forge jieba
```

### 7.4 方法四：去pypi下载安装包，手动安装

如果下载太慢，可以去官网下载，下载jieba的安装包，然后解压到pkgs目录上，参考链接：https://www.pianshen.com/article/18251601207/

官网链接：https://pypi.org/project/jieba/#files

解压之后，执行包里的setup.py文件也可以安装成功。
```bash
wget https://files.pythonhosted.org/packages/c6/cb/18eeb235f833b726522d7ebed54f2278ce28ba9438e3135ab0278d9792a2/jieba-0.42.1.tar.gz
tar xf jieba-0.42.1.tar.gz 
mv jieba-0.42.1 /root/anaconda3/pkgs/
cd /root/anaconda3/pkgs/jieba-0.42.1/
# 如果要安装到指定虚拟环境中，需要先激活环境，再执行install
source activate job_recommended
python setup.py install
```

## 8、去掉PS1前面的env name
1、通过将auto_activate_base参数设置为false实现
```bash
conda config --set auto_activate_base false
```

2、那要进入的话通过
```bash
conda activate base
```

3、如果反悔了还是希望base一直留着的话通过
```bash
conda config --set auto_activate_base true
```
可以来恢复