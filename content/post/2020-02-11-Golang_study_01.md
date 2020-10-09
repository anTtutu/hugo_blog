---
title: Golang学习笔记01 - 关键字和基础数据类型介绍
date: 2020-02-11T21:46:20+08:00
tags: [ "golang" ]
description: "Golang学习笔记"
categories: [ "golang" ]
toc: true
---

记录自己的Golang学习笔记

# 一、Golang关键字和介绍
## 25个关键字:
```go
break     default      func     interface    select
case      defer        go       map          struct
chan      else         goto     package      switch
const     fallthrough  if       range        type
continue  for          import   return       var
```
#### 针对自己不太熟悉的关键字说明下，虽然以后用着会熟悉，但是提前了解不是坏事
## 1、break:
跳出循环
```go
func main() {
    //跳出循环
    for i := 0; i < 10; i++ {
        fmt.Println(i)
        if i == 6 {
            break
        }
    }
}

---------------------------------
0
1
2
3
4
5
6

Process finished with exit code 0
```

## 2、switch case default:
switch分支流程控制语句
```go
func main() {
    //写法1：
    switch i := 6; i {
    case 1, 3, 5, 7, 9:
        fmt.Println("奇数5")
    case 2, 4, 6, 8, 10:
        fmt.Println("偶数")
    default:
        fmt.Println("other", i)
    }

    //写法2：
    finger := 2
    switch finger {
    case 1:
        fmt.Println("大拇指")
    case 2:
        fmt.Println("食指")
    case 3:
        fmt.Println("中指")
    case 4:
        fmt.Println("无名指")
    case 5:
        fmt.Println("小指")
    default:
        fmt.Println("无效的数字")
    }

    //写法3：
    age := 30
    switch {
    case age < 24:
        fmt.Println("学习阶段")
    case age >= 24 && age < 60:
        fmt.Println("工作阶段")
    case age > 60:
        fmt.Println("退休阶段")
    default:
        fmt.Println("活着真好")
    }
}

---------------------------------
偶数
食指
工作阶段

Process finished with exit code 0
```

## 3、func:
函数
```go
//1、带返回值的函数
func add(a, b int) int {
    return a + b
}

//2、多个返回值的函数
func vals() (int, int) {
    return 3, 7
}

//3、没返回值的函数
func query () {
    fmt.Println("query success.")
}
```

## 4、interface:
接口
```go
type Dog interface {
    Category()
}

type Ha struct {
    Name string
}

func (h Ha) Category() {
    fmt.Println("狗子")
}

func main() {
    h := Ha{"二哈"}
    h.Category()
    test(h)
}

func test(a Dog) {
    fmt.Println("成功调用啦")
}

---------------------------------
狗子
成功调用啦

Process finished with exit code 0
```

## 5、select:
A "select" statement chooses which of a set of possible send or receive operations will proceed. It looks similar to a "switch" statement but with the cases all referring to communication operations.  
一个select语句用来选择哪个case中的发送或接收操作可以被立即执行。它类似于switch语句，但是它的case涉及到channel有关的I/O操作。
```go
//select基本用法
select {
case <- chan1:
// 如果chan1成功读到数据，则进行该case处理语句
case chan2 <- 1:
// 如果成功向chan2写入数据，则进行该case处理语句
default:
// 如果上面都没有成功，则进入default处理流程
}
```

## 6、defer:  
A "defer" statement invokes a function whose execution is deferred to the moment the surrounding function returns, either because the surrounding function executed a return statement, reached the end of its function body, or because the corresponding goroutine is panicking.  
一个defer语句在函数返回、函数结束或者对应的goroutine发生panic的时候defer就会执行。  
在golang中，我们使用defer语句来进行一些错误处理和收尾工作，它的作用类似java里面finally关键字的作用
```go
func CopyFile(dstName, srcName string) (written int64, err error) {
    src, err := os.Open(srcName)
    if err != nil {
        return
    }
    defer src.Close()

    dst, err := os.Create(dstName)
    if err != nil {
        return
    }
    defer dst.Close()

    // other codes
    return io.Copy(dst, src)
}
```
列举2个简单demo:  
demo1: 理解延迟
```go
func main() {
    // demo1
    defer fmt.Println("hello")
    fmt.Println("world")
}

--------------------------------
world
hello

Process finished with exit code 0
```
demo2: 理解defer、return、返回值的顺序  
1、多个defer的执行顺序为“后进先出”；  
2、defer、return、返回值三者的执行逻辑应该是：return最先执行，return负责将结果写入返回值中；接着defer开始执行一些收尾工作；最后函数携带当前返回值退出。
```go
func main() {
    // demo2
    fmt.Println("c return:", *(c())) // 打印结果为 c return: 2
}

func c() *int {
    var i int
    defer func() {
        i++
        fmt.Println("c defer2:", i) // 打印结果为 c defer: 2
    }()
    defer func() {
        i++
        fmt.Println("c defer1:", i) // 打印结果为 c defer: 1
    }()
    return &i
}

---------------------------------
c defer1: 1
c defer2: 2
c return: 2

Process finished with exit code 0
```

## 7、go:
轻松开启高并发，一直都是golang语言引以为豪的功能点。golang通过goroutine实现高并发，而开启goroutine的钥匙正是go关键字。开启并发执行的语法格式是：
```go
func main() {
    go testName()
    fmt.Println("main method")
    time.Sleep(time.Second)
}

func testName () {
    fmt.Println("test method")
}

---------------------------------
main method
test method

Process finished with exit code 0
```

## 8、map:
map是映射关系容器为map，其内部使用散列表（hash）实现，一种无序的基于key-value的数据结构，Go语言中的map是引用类型，必须初始化才能使用。
```go
func main() {
    //1、声明map
    scoreMap := make(map[string]int, 8)
    scoreMap["张三"] = 90
    scoreMap["小明"] = 100
    fmt.Println(scoreMap)
    fmt.Println(scoreMap["小明"])
    fmt.Printf("type of a:%T\n", scoreMap)

    //2、遍历map
    for k, v := range scoreMap {
        fmt.Printf("key[%s] - value[%d]\n", k, v)
    }

    //3、遍历map只要key或者value
    for k := range scoreMap {
        fmt.Printf("key[%s]\n", k)
    }

    for _, v := range scoreMap {
        fmt.Printf("value[%d]\n", v)
    }

    //4、判断某个key是否存在  特殊写法：value, ok := map[key]
    // 如果key存在ok为true,v为对应的值；不存在ok为false,v为值类型的零值
    v, ok := scoreMap["张三"]
    if ok {
        fmt.Println(v)
    } else {
        fmt.Println("查无此人")
    }

    //5、删除某个key
    //将小明:100从map中删除
    delete(scoreMap, "小明")
    for k,v := range scoreMap{
        fmt.Printf("key[%s] - value[%d]\n", k, v)
    }
}

---------------------------------
map[小明:100 张三:90]
100
type of a:map[string]int

key[张三] - value[90]
key[小明] - value[100]

key[张三]
key[小明]
value[90]
value[100]

90

key[张三] - value[90]

Process finished with exit code 0
```

## 9、struct:
结构体，跟C++一样，有C++基础好理解
```go
// 1、定义一个结构体 demo1
type Person struct {
    name string
    city string
    age  int8
}

// 2、定义一个结构体 demo2
type Person1 struct {
    name, city string
    age        int8
}


/**
 * @Author: Anttu
 * @Date: 2020-02-12 09:47
 */
func main() {
    // 3、结构体实例化
    var p1 Person
    p1.name = "张三"
    p1.city = "北京"
    p1.age = 18
    fmt.Printf("p1=%v\n", p1)  //p1={张三 北京 18}
    fmt.Printf("p1=%#v\n", p1) //p1=main.person{name:"张三", city:"北京", age:18}

    // 4、匿名结构体
    var user struct { Name string; Age int }
    user.Name = "李四"
    user.Age = 20
    fmt.Printf("%#v\n", user)

    // 5、创建指针类型的结构体  我们通过使用new关键字对结构体进行实例化，得到的是结构体的地址
    var p2 = new(Person)
    fmt.Printf("%T\n", p2)     //*main.person
    fmt.Printf("p2=%#v\n", p2) //p2=&main.person{name:"", city:"", age:0}

    // 6、给结构体属性赋值    对结构体指针直接使用.来访问结构体的成员
    var p3 = new(Person)
    p3.name = "小王子"
    p3.age = 28
    p3.city = "上海"
    fmt.Printf("p3=%#v\n", p3) //p3=&main.person{name:"小王子", city:"上海", age:28}

    // 7、取结构体的地址实例化    使用&对结构体进行取地址操作相当于对该结构体类型进行了一次new实例化操作
    p4 := &Person{}
    fmt.Printf("%T\n", p4)     //*main.person
    fmt.Printf("p4=%#v\n", p4) //p4=&main.person{name:"", city:"", age:0}
    p4.name = "赵六"
    p4.age = 30
    p4.city = "成都"
    fmt.Printf("p4=%#v\n", p4) //p4=&main.person{name:"赵六", city:"成都", age:30}

    // 8、结构体初始化
    var p5 Person
    fmt.Printf("p5=%#v\n", p5) //p5=main.person{name:"", city:"", age:0}

    // 9、使用键值对初始化结构体
    p6 := Person{
        name: "小王子",
        city: "北京",
        age:  18,
    }
    fmt.Printf("p6=%#v\n", p6) //p6=main.person{name:"小王子", city:"北京", age:18}

    // 10、也可以对结构体指针进行键值对初始化
    p7 := &Person{
        name: "小王子",
        city: "北京",
        age:  18,
    }
    fmt.Printf("p7=%#v\n", p7) //p7=&main.person{name:"小王子", city:"北京", age:18}

    // 11、当某些字段没有初始值的时候，该字段可以不写
    p8 := &Person{
        city: "北京",
    }
    fmt.Printf("p8=%#v\n", p8) //p8=&main.person{name:"", city:"北京", age:0}

    // 12、使用值的列表初始化结构体
    // 需要注意：
    //必须初始化结构体的所有字段。
    //初始值的填充顺序必须与字段在结构体中的声明顺序一致。
    //该方式不能和键值初始化方式混用。
    p9 := &Person{
        "王校长",
        "北京",
        28,
    }
    fmt.Printf("p9=%#v\n", p9) //p9=&main.person{name:"王校长", city:"北京", age:28}

    // 13、结构体内存布局探讨   结构体占用一块连续的内存
    type test struct {
        a int8
        b int8
        c int8
        d int8
    }
    n := test{
        1, 2, 3, 4,
    }
    fmt.Printf("n.a %p\n", &n.a)
    fmt.Printf("n.b %p\n", &n.b)
    fmt.Printf("n.c %p\n", &n.c)
    fmt.Printf("n.d %p\n", &n.d)
}

---------------------------------
p1={张三 北京 18}
p1=main.Person{name:"张三", city:"北京", age:18}

struct { Name string; Age int }{Name:"李四", Age:20}

*main.Person
p2=&main.Person{name:"", city:"", age:0}

p3=&main.Person{name:"小王子", city:"上海", age:28}

*main.Person
p4=&main.Person{name:"", city:"", age:0}
p4=&main.Person{name:"赵六", city:"成都", age:30}

p5=main.Person{name:"", city:"", age:0}

p6=main.Person{name:"小王子", city:"北京", age:18}

p7=&main.Person{name:"小王子", city:"北京", age:18}

p8=&main.Person{name:"", city:"北京", age:0}

p9=&main.Person{name:"王校长", city:"北京", age:28}

n.a 0xc00009e120
n.b 0xc00009e121
n.c 0xc00009e122
n.d 0xc00009e123

Process finished with exit code 0
```

## 10、if else:
流程控制语句
```go
//1、if条件判断基本写法
    score := 65
    if score >= 90 {
        fmt.Println("A")
    } else if score > 75 {
        fmt.Println("B")
    } else {
        fmt.Println("C")
    }

    //2、if条件判断特殊写法
    if score := 65; score >= 90 {
        fmt.Println("A")
    } else if score > 75 {
        fmt.Println("B")
    } else {
        fmt.Println("C")
    }

---------------------------------
C
C

Process finished with exit code 0
```

## 11、goto:
跳转到指定标签
```go
func main() {
    //1、双层嵌套for循环跳出
    var breakFlag bool
    for i := 0; i < 10; i++ {
        for j := 0; j < 10; j++ {
            if j == 2 {
                // 设置退出标签
                breakFlag = true
                break
            }
            fmt.Printf("%v-%v\n", i, j)
        }
        // 外层for循环判断
        if breakFlag {
            break
        }
    }

    //2、改用goto方便、简化很多
    for i := 0; i < 10; i++ {
        for j := 0; j < 10; j++ {
            if j == 2 {
                // 设置退出标签
                goto breakTag
            }
            fmt.Printf("%v-%v\n", i, j)
        }
    }
    return
    // 标签
breakTag:
    fmt.Println("结束for循环")
}

---------------------------------
0-0
0-1

0-0
0-1
结束for循环

Process finished with exit code 0
```

## 12、package:
包，有内置包，比如fmt、os、io等
