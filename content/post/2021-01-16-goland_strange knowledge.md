---
title: "golang奇怪的知识点"
date: 2021-01-16T00:29:47+08:00
tags: [ "go" ]
description: "golang奇怪的知识点"
categories: [ "go" ]
toc: true
---

## 前言
golang里面的奇怪知识点总结，本人才疏学浅，可能总结得不到位或者有些纰漏，仅把学习golang知识的一些细节记录下，权当学习笔记  
最后的其他分类里面有很多几年前学习golang时候的一些基础规则，也放进来吧，当回顾下好了

## 1、包名带!
无意间发现包名有个别带!，不知道为啥，找了一下午资料也没找到合适的解答  
如下图：  
![](/posts/golang/package.jpg)

其实这个!是针对包名大写的字母才出现，比如上图的!e = E表示的是这个意思。  
对比mod里面的引用：
![](/posts/golang/package_mod.jpg)

## 2、GOROOT下包用途介绍
golang sdk的安装目录，目录结构如下
```bash
+---api
+---bin
+---doc
+---lib
+---misc
+---pkg
+---src
+---test
```
目录|说明
-|-
api|存放golang历史版本的api介绍txt文档
bin|存放golang的标准命令，可执行文件，如：go、godoc、gofmt
doc|存放goland标准库的html格式的文档，可以通过godoc命令启动web服务展示这些文档
lib|存放一些特殊的库文件
misc|存放一些辅助类的工具及其英文说明
pkg|存放golang标注库的所有归档文件，会出现一个计算机架构名称组合的文件夹，如windows_amd64、linux_amd64等，属于平台相关的目录。通过go install命令，go程序会被编译成平台相关的归档文件存放到其中。
src|存放golang自身标准库的源码文件
test|存放用于测试和验证go相关特性的文件，包含源码

## 3、GOPATH下包用途介绍
历史产物，原来设计者想把gopath当成workspace来管理的，windows系统举例：
```bash
tree /A | more
+---bin
+---pkg
|   +---mod
|   +---sumdb
+---src
```
目录|说明
-|-
bin|存放编译后的可执行文件，go install安装的可执行命令会存放到这里，如果只是普通第三方引用包的话会存放在pkg
pkg|存放一些第三方包或者编译的包临时文件，比如github.com上通过go get命令下载的包
src|早期golang1.11之前是当做go的workspace的，创建的项目一般都是固定存放GOPATH/src，1.11版本有了mod后，固定的存放开始慢慢放弃，但是历史产物还是存在的

GOPATH不同于GOROOT，GOROOT是golang的sdk安装目录，GOROOT下也有个bin目录。  
GOROOT基本上是官方的标准库代码  
GOPATH基本上是用户的工作区，用mod后GOPATH/src就在慢慢退化  

注：
只是放弃GOPATH的src创建项目的功能，不是GOPATH不需要配置，毕竟一些第三方包依赖和编译还是会使用pkg的

## 4、mod
go modules是golang的依赖包管理工具，只是出现得比较晚，1.11才面世，之前还有dep、glide、govendor等包管理工具，本人只接触过govendor  
dep是golang官方的一个实验项目，后2种属于第三方包管理工具，最后官方在1.11版本用mod统一进行了管理。  
可以参考官方对比: <https://github.com/golang/go/wiki/PackageManagementTools>

1.13版本开始默认使用Go Modules模式，也就是GO111MODULE=on默认是开启状态：  
### 4.1 一共有3种状态可以了解下 
环境变量参数|模式|说明
-|-|-
GO111MODULE=auto|默认模式|同时满足以下两个条件时使用Go Modules：<br>1、当前目录不在GOPATH/src/下<br>2、在当前目录或上层目录中存在go.mod文件
GO111MODULE=off|GOPATH模式|从不使用Go Modules。相反，它查找vendor目录和GOPATH以查找依赖项
GO111MODULE=on|GO MOdules模式|从不咨询GOPATH。GOPATH不再作为导入目录，但它仍然存储下载的依赖项（GOPATH/pkg/mod/）和已安装的命令（GOPATH/bin/），只移除了GOPATH/src/

### 4.2 配置Go Modules相关命令：  
#### windows设置命令：注释需要去掉
```golang
go env -w GO111MODULE=on //(or off，1.13后推荐开启on)
```
#### mac、linux设置命令：注释需要去掉
```bash
export GO111MODULE=on #(or off,1.13后推荐开启on)
```

1.13之前项目必须创建在GOPATH/src下面，比如GOPATH/src/myproject，有了mod后可以随意目录当做workspace创建自己的项目，早期的项目升级1.11版本后的golang sdk也可以升级改造成mod管理的。  

相关命令和介绍如下：
```bash
go mod init [MODULE_PATH]
```
初始化Go modules，它将会生成go.mod文件，需要注意的是MODULE_PATH填写的是模块引入路径，你可以根据自己的情况修改路径。  
在执行了上述步骤后，初始化工作已完成，我们打开go.mod文件看看，如下：
```golang
module [NODULE_PATH]

go 1.15
```
一个完整的复杂参考样例go.mod文件：
```golang
module my/thing
go 1.15
require other/thing v1.0.2 // 这是注释
require new/thing/v2 v2.3.4 // indirect
require (
  new/thing v2.3.4
  old/thing v0.0.0-20190603091049-60506f45cf65
)
exclude old/thing v1.2.3
replace bad/thing v1.4.5 => good/thing v1.4.5
```
### 4.3、go.mod目前有以下5个动词
动词|说明
-|-
module|用于定义当前项目的模块路径。
go|用于设置预期的Go版本。
require|用于设置一个特定的模块版本。
exclude|用于从使用中排除一个特定的模块版本。
replace|用于将一个模块版本替换为另外一个模块版本

### 特殊：
也许你会发现go.mod文件中部分依赖包后面会出现一个"// indirect"的标识(参考上面完整样例)。这个标识总是出现在require指令中。  

标识|含义  
-|-
//|与代码的行注释一样表示注释的开始，但这里不能使用多行/* 这是注释 */注释
indirect|表示间接的依赖

### 4.5、go.sum
go.sum是类似于比如dep的Gopkg.lock的一类文件，它详细罗列了当前项目直接或间接依赖的所有模块版本，并写明了那些模块版本的SHA-256哈希值以备Go在今后的操作中保证项目所依赖的那些模块版本不会被篡改。
```golang
example.com/apple v0.1.2 h1:WXkYYl6Yr3qBf1K79EBnL4mak0OimBfB0XUf9Vl28OQ= 
example.com/apple v0.1.2/go.mod h1:xHWCNGjB5oqiDr8zfno3MHue2Ht5sIBksp03qcyfWMU= 
example.com/banana v1.2.3 h1:qHgHjyoNFV7jgucU8QZUuU4gcdhfs8QW1kw68OD2Lag= 
example.com/banana v1.2.3/go.mod h1:HSdplMjZKSmBqAxg5vPj2TmRDmfkzw cTzAElWljhcU= 
example.com/banana/v2 v2.3.4 h1:zl/OfRA6nftbBK9qTohYBJ5xvw6C/oNKizR7cZGl3cI= 
example.com/banana/v2 v2.3.4/go.mod h1:eZbhyaAYD41SGSSsnmcpxVoRiQ/MPUTjUdIIOT9Um7Q= 
...
```

我们可以看到一个模块路径可能有如下两种：
```golang
example.com/apple v0.1.2 h1:WXkYYl6Yr3qBf1K79EBnL4mak0OimBfB0XUf9Vl28OQ= 
example.com/apple v0.1.2/go.mod h1:xHWCNGjB5oqiDr8zfno3MHue2Ht5sIBksp03qcyfWMU=
```
前者为Go modules打包整个模块包文件zip后再进行hash值，而后者为针对go.mod的hash值。他们两者，要不就是同时存在，要不就是只存在go.mod hash。

那什么情况下会不存在zip hash呢，就是当Go认为肯定用不到某个模块版本的时候就会省略它的zip hash，就会出现不存在zip hash，只存在go.mod hash的情况。

## 5、goproxy
因为google的关系，国内有些google.com域名下的服务是无法访问的，需要切换国内的代理  

常用的七牛云代理：https://goproxy.cn  

### direct参数：  
1、为特殊指示符，用于指示Go回源到模块版本的源地址去抓取(比如 GitHub 等)，当值列表中上一个Go module proxy返回404或410错误时，Go自动尝试列表中的下一个，遇见“direct”时回源，遇见EOF时终止并抛出类似“invalid version: unknown revision...”的错误  
2、可以拉去私有库

### 因此常见设置是：
```golang
GOPROXY="https://goproxy.cn,direct"
```

### windows设置命令：
```golang
go env -w GOPROXY=https://goproxy.cn,direct
```
mac、linux设置命令：
```golang
export GOPROXY=https://goproxy.cn,direct
```

## 6、日常可能用到的命令
### 6.1、go get
命令|说明
-|-
go get golang.org/x/text@latest|拉取最新的版本(优先择取tag)
go get golang.org/x/text@master|拉取master分支的最新commit
go get `golang.org/x/text@v0.3.2`|拉取tag为v0.3.2的commit
go get golang.org/x/text@342b2e|拉取hash为342b231的commit，最终会被转换为v0.3.2
go get -u |更新现有的依赖

### 6.2、语义化版本
语义化版本是一套由Gravatars创办者兼GitHub共同创办者Tom Preston-Werner所建立的约定。在这套约定下，语义化版本号及其更新方式包含了很多有用的信息。

语义化版本号格式为：X.Y.Z（主版本号.次版本号.修订号），使用方法如下：
- 1、进行不向下兼容的修改时，递增主版本号。
- 2、API保持向下兼容的新增及修改时，递增次版本号。  
- 3、修复问题但不影响API时，递增修订号。  

#### 举个例子:
有一个语义化版本号为：v2.3.4，则其主版本号为2，次版本为3，修订号为4。而前面的v是version（版本）的首字母，是Go语言惯例使用的，标准的语义化版本没有这个约定。如下图：
![](/posts/golang/version.png)
使用Go命令行工具或go.mod文件时，就可以使用语义化版本号来进行模块查询语义化版本号来进行模块查询，具体规则如下：  

模糊查看|语义化版本|含义
-|-|-
默认值|@latest|将匹配最新的可用标签版本或源码库的最新未标签版本。  
完全指定版本|@v1.2.3|将匹配该指定版本。  
版本前缀|@v1或@v1.2|将匹配具有该前缀的最新可用标签版本。  
版本比较|@<v1.2.3或@>=v1.5.6|将匹配最接近比较目标的可用标签版本。<br><则为小于该版本的最新版本，<br>>则为大于该版本的最旧版本。<br>当使用类Unix系统时，需用引号将字符串包裹起来以防止大于小于号被解释为重定向。<br>如：go get 'github.com/gin-gonic/gin@<v1.2.3'。  
指定某个commit|@c856192|将匹配该 commit 时的版本。  
指定某个分支|@master|将匹配该分支版本。

为了能让Go Modules的使用者能够从旧版本更方便地升级至新版本，Go语言官方提出了两个重要的规则：  
- 1、导入兼容性规则（import compatibility rule）：如果旧包和新包具有相同的导入路径，则新包必须向后兼容旧包。  
- 2、语义化导入版本规则（semantic import versioning rule）：每个不同主版本（即不兼容的包v1或v2）使用不同的导入路径，以主版本结尾，且每个主版本中最多一个。  

### 举个例子：
my/thing、my/thing/v2、my/thing/v3，而与Git分支的集成如下：
![](/posts/golang/git_branch.png)
### 6.3 go mod
命令|说明
-|-
go mod download|下载go.mod文件中指明的所有依赖
go mod tidy|整理现有的依赖
go mod graph|查看现有的依赖结构
go mod init|生成go.mod文件
go mod edit|编辑go.mod文件
go mod vendor|导出现有的所有依赖 (事实上 Go modules 正在淡化 Vendor 的概念)
go mod verify|校验一个模块是否被篡改过

## 7、其他
### 7.1、每一行不需要;结尾
如：源码来源于excelize  
```golang
func OpenFile(filename string) (*File, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	f, err := OpenReader(file)
	if err != nil {
		return nil, err
	}
	f.Path = filename
	return f, nil
}
```
### 7.2、不能有多余的import和变量，全局的可以  
静态检查，标红：  
![](/posts/golang/unused_import.jpg)
去掉多余的import后，正常：  
![](/posts/golang/normal_import.jpg)
### 7.3、只能有一个main package，相当于程序入口  
```golang
package main
```
### 7.4、{不能另起一行开头写
只能跟java默认的排版一样放函数名后面。如：源码来源于excelize
```golang
func OpenFile(filename string) (*File, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	f, err := OpenReader(file)
	if err != nil {
		return nil, err
	}
	f.Path = filename
	return f, nil
}
```
### 7.5、可以返回多个值
不是跟java一样多个值的话需要用对象，如：File和error，源码来源于excelize  
```golang
func OpenFile(filename string) (*File, error) {
	file, err := os.Open(filename)
	if err != nil {
		return nil, err
	}
	defer file.Close()
	f, err := OpenReader(file)
	if err != nil {
		return nil, err
	}
	f.Path = filename
	return f, nil
}
```
### 7.6、go只有一种循环for
如：源码来源于excelize  
```golang
func (f *File) UpdateLinkedValue() {
	for _, name := range f.GetSheetMap() {
		xlsx := f.workSheetReader(name)
		for indexR := range xlsx.SheetData.Row {
			for indexC, col := range xlsx.SheetData.Row[indexR].C {
				if col.F != nil && col.V != "" {
					xlsx.SheetData.Row[indexR].C[indexC].V = ""
					xlsx.SheetData.Row[indexR].C[indexC].T = ""
				}
			}
		}
	}
}
```
## 8、只有一个后自增i++，没有++i，同理自减也一样
如：源码来源于举例写的  
```golang
func bubbleSort(array []int) {
    for i := 0; i < len(array); i++ {
        for j := 0; j < len(array)-i-1; j++ {
            if array[j] > array[j+1] {
                array[j], array[j+1] = array[j+1], array[j]
            }
        }
    }
}
```
## 9、=与:=的使用区别  
=赋值  
:=声明并赋值

定义变量
```golang
var number int
```

定义变量并初始化值
```golang
var number int = 10
```

同时初始化多个变量
```golang
var number1, number2, number3 int = 1, 2, 3
```

可以直接忽略类型声明
```golang
var number1, number2, number3 = 1, 2, 3
```

还可以简化，省略var
```golang
number1, number2, number3 := 1, 2, 3
```

### 那最终=与:=还有其他区别么，有  
:=这个符号直接取代了var和type,这种形式叫做简短声明。不过它有一个限制，那就是它只能用在函数内部；在函数外部使用则会无法编译通过，所以一般用var方式来定义全局变量。  

:=只能在声明“局部变量”的时候使用，而“var”没有这个限制

## 10、首字母大小写
Go语言通过首字母的大小写来控制访问权限。无论是方法，变量，常量或是自定义的变量类型，如果首字母大写，则可以被外部包访问，反之则不可以。  

结构体中的字段名，如果首字母小写的话，则该字段无法被外部包访问和解析，比如，json解析  

### 简短整理就是：  
首字母大写 == public  
首字母小写 == private  
如：
```golang
package main

import (
	"encoding/json"
	"fmt"
)

type UserInfo struct {
	Name    string `json:"name,omitempty"`
	age     int    `json:"age,omitempty"`
	Address string `json:"address,omitempty"`
}

func main() {
	user := UserInfo{Name: "张三", age: 18, Address:"中国北京"}
	b, _ := json.Marshal(user)
	fmt.Println(string(b))
}

输出结果:
{"name":"张三","address":"中国北京"}
```

## 11、struct tag
结构体首字母小写，json无法获取属性，参考上面的介绍说明
```golang
package main

import (
	"encoding/json"
	"fmt"
)

type UserInfo struct {
	name    string
	age     int    `json:"age"`
	address string `json:"address"`
}

func main() {
	user := &UserInfo{name: "张三", age: 18, address: "中国北京"}

	b, _ := json.Marshal(user)
	fmt.Println(string(b))
}


输出结果:
{}
```

忽略空值"omitempty"  
```golang
package main

import (
	"encoding/json"
	"fmt"
)

type UserInfo struct {
	Name    string `json:"name,omitempty"`
	Age     int    `json:"age,omitempty"`
	Address string `json:"address,omitempty"`
}

func main() {
	user := &UserInfo{Name: "张三", Age: 18}
	b, _ := json.Marshal(user)
	fmt.Println(string(b))
}

输出结果:
{"name":"张三","age":18}
```

忽略字段"-"
```golang
package main

import (
	"encoding/json"
	"fmt"
)

type UserInfo struct {
	Name    string `json:"name,omitempty"`
	Age     int    `json:"age,omitempty"`
	Address string `json:"-"`
}

func main() {
	user := &UserInfo{Name: "张三", Age: 18, Address: "中国北京"}
	b, _ := json.Marshal(user)
	fmt.Println(string(b))
}

输出结果:
{"name":"张三","age":18}
```

## 12、...参数
表示不定参数  
笑话-题外话：第一次使用redis时，做批量写入，因为参数不定还闹过乌龙，以为...是展示不全导致的  
函数可变数量参数  
```golang
package main

import "fmt"

func main() {
   //multiParam 可以接受可变数量的参数
   multiParam("jerry", 1)
   multiParam("php", 1, 2)
}
func multiParam(name string, args ...int) {
   fmt.Println(name)
   //接受的参数放在args数组中
   for _, e := range args {
      fmt.Println(e)
   }
}
```

可变函数的参数
```golang
package main

import "fmt"

func main() {
    //multiParam 可以接受可变数量的参数
    multiParam("jerry", "herry")
    multiParam("php", "mysql", "js")
}
func multiParam(args ...string) {
    //接受的参数放在args数组中
    for _, e := range args {
        fmt.Println(e)
    }
}
```