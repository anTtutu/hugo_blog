---
title: "golang奇怪的知识"
date: 2021-01-16T00:29:47+08:00
tags: [ "golang" ]
description: "golang奇怪的知识"
categories: [ "golang" ]
toc: true
---

## 1、前言
golang里面的奇怪知识总结，本人才疏学浅，可能总结得不到位或者有些纰漏，仅把学习golang知识的一些细节记录下，权当学习笔记  
最后的其他分类里面有很多几年前学习golang时候的一些基础规则，也放进来吧，当回顾下好了

## 2、包名带!
无意间发现包名有个别带!，不知道为啥，找了一下午资料也没找到合适的解答
如下图：  
![](/posts/golang/package.jpg)

其实这个!是针对包名大写的字母才出现，比如上图的!e = E表示的是这个意思。
对比mod里面的引用：
![](/posts/golang/package_mod.jpg)

## 3、GOROOT
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

## 4、GOPATH
历史产物，原来设计者想把gopath当成workspace来管理的，windows系统举例
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
src|早期golang1.11之前是当做go的workspace的，创建的项目一般都是固定存放这里，1.11版本有了mod后，这里开始慢慢放弃，但是历史产物还是存在的

GOPATH不同于GOROOT，GOROOT是golang的sdk安装目录，GOROOT下也有个bin目录。  
GOROOT基本上是官方的标准库代码  
GOPATH基本上是用户的工作区，用mod后GOPATH就在慢慢退化  

注：
只是放弃GOPATH的src创建项目的功能，不是GOPATH放弃，毕竟一些第三方包依赖和编译还是会使用pkg的

## 5、mod
go modules是golang的依赖包管理工具，只是出现得比较晚，1.11才面世，之前还有dep、glide、govendor等包管理工具，本人只接触过govendor  
dep是golang官方的一个实验项目，后2种属于第三方包管理工具，最后官方在1.11版本用mod统一进行了管理。  
可以参考官方对比(https://github.com/golang/go/wiki/PackageManagementTools)

有了mod后，GOPATH开始慢慢退化，之前项目必须创建在GOPATH/src下面，比如GOPATH/src/myproject，mod可以让你随意目录创建自己的项目，早期的项目采用1.11版本后的golang sdk也可以升级改造成mod管理。

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

## 6、日常可能用到的命令
### 6.1、go get
命令|说明
-|-
go get golang.org/x/text@latest|拉取最新的版本(优先择取tag)
go get golang.org/x/text@master|拉取master分支的最新commit
go get golang.org/x/text@v0.3.2|拉取tag为v0.3.2的commit
go get golang.org/x/text@342b2e|拉取hash为342b231的commit，最终会被转换为v0.3.2
go get -u |更新现有的依赖

### 6.2、go mod
命令|说明
-|-
go mod download|下载go.mod文件中指明的所有依赖
go mod tidy|整理现有的依赖
go mod graph|查看现有的依赖结构
go mod init|生成go.mod文件
go mod edit|编辑go.mod文件
go mod vendor|导出现有的所有依赖 (事实上 Go modules 正在淡化 Vendor 的概念)
go mod verify|校验一个模块是否被篡改过

### 7、其他
1、每一行不需要;结尾，如：源码来源于excelize  
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
2、不能有多余的import和变量，全局的可以  
静态检查，标红：  
![](/posts/golang/unused_import.jpg)
去掉多余的import后，正常：  
![](/posts/golang/normal_import.jpg)
3、只能有一个main package，相当于程序入口  
```golang
package main
```
4、{不能另起一行开头写，只能跟java默认的排版一样放函数名后面  
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
5、可以返回多个值，不是跟java一样多个值的话需要用对象，如：File和error，源码来源于excelize  
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
6、go只有一种循环for，如：源码来源于excelize  
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
## 7、只有一个后自增i++，没有++i，同理自减也一样，如：  
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
## 8、=与:=的使用区别  
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

那最终=与:=还有其他区别么，有  
:=这个符号直接取代了var和type,这种形式叫做简短声明。不过它有一个限制，那就是它只能用在函数内部；在函数外部使用则会无法编译通过，所以一般用var方式来定义全局变量。  

:=只能在声明“局部变量”的时候使用，而“var”没有这个限制

## 9、首字母大小写
Go语言通过首字母的大小写来控制访问权限。无论是方法，变量，常量或是自定义的变量类型，如果首字母大写，则可以被外部包访问，反之则不可以。  

结构体中的字段名，如果首字母小写的话，则该字段无法被外部包访问和解析，比如，json解析  

简短整理就是：  
首字母大写 == public  
首字母小写 == private
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

## 10、struct tag
结构体首字母小写，json无法获取属性，参考9的说明
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

忽略空值  
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

忽略字段
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