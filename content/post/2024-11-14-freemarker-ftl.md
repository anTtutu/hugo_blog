---
title: "FreeMarker FTL语法速查：从插值到宏的完整笔记"
date: 2024-11-14T08:00:00+08:00
tags: [ "freemarker", "java", "模板引擎" ]
description: "FreeMarker FTL 常用标签与语法速查笔记：字符/日期/数字输出、assign 声明、运算符与优先级、if/switch/list/Map 集合操作、include/import、compress/escape、macro 宏与 nested 嵌套"
categories: [ "java", "模板引擎" ]
toc: true
---

## 前言

FreeMarker 在老项目和邮件模板、报表模板场景里依然大量存在。FTL 语法细节多、容易忘，这篇按「输出 → 运算 → 流程控制 → 集合 → 指令 → 宏」的顺序整理成速查笔记。

> 基本原则：**所有标签必须闭合**，否则 FreeMarker 无法解析。注释格式 `<#-- 注释内容 -->`，不会输出。

## 一、字符输出

```ftl
${emp.name?if_exists}            <#-- 变量存在输出，否则不输出 -->
${emp.name!}                     <#-- 同上 -->
${emp.name?default("xxx")}       <#-- 变量不存在，取默认值xxx -->
${emp.name!"xxx"}                <#-- 同上 -->
```

**常用内建函数**：

```ftl
${"123<br>456"?html}     <#-- HTML编码，转义特殊字符 -->
${"str"?cap_first}       <#-- 首字母大写 -->
${"Str"?lower_case}      <#-- 转小写 -->
${"Str"?upper_case}      <#-- 转大写 -->
${"str"?trim}            <#-- 去前后空白 -->
```

**字符串拼接的两种方式**：

```ftl
${"hello${emp.name!}"}   <#-- 插值拼接 -->
${"hello"+emp.name!}     <#-- +号连接 -->
```

**截取子串**：

```ftl
<#assign str = "abcdefghijklmn"/>
${str?substring(0,4)}    <#-- abcd -->
${str[0]}${str[4]}       <#-- ae -->
${str[1..4]}             <#-- bcde -->
${str?index_of("n")}     <#-- 返回指定字符的索引 -->
```

## 二、日期与数字输出

**日期**：

```ftl
${emp.date?string('yyyy-MM-dd')}
```

**数字**（以 20 为例）：

```ftl
${emp.name?string.number}    <#-- 20 -->
${emp.name?string.currency}  <#-- ￥20.00 -->
${emp.name?string.percent}   <#-- 20% -->
${1.222?int}                 <#-- 小数转int，输出1 -->
```

**数字默认输出格式**：

```ftl
<#setting number_format="percent"/>
<#assign answer=42/>
#{answer}              <#-- 4200% -->
${answer?string.number}    <#-- 42 -->
```

**数字格式化插值** `#{expr;format}`，format 可以是 `mX`（小数部分最小X位）/ `MX`（小数部分最大X位）：

```ftl
<#assign x=2.582/>
<#assign y=4/>
#{x; M2}    <#-- 2.58 -->
#{y; M2}    <#-- 4 -->
#{x; m2}    <#-- 2.58 -->
#{y; m2}    <#-- 4.0 -->
```

## 三、声明变量（assign / global）

```ftl
<#assign foo=false/>                  <#-- 布尔值不加引号 -->
${foo?string("yes","no")}             <#-- true输出yes，false输出no -->

<#assign name=value>
<#assign name1=value1 name2=value2 nameN=valueN>
<#assign name in namespacehash>
```

**global 全局赋值**：在所有 namespace 中可见。若被当前页面的 assign 覆盖（`<#global x=2><#assign x=1>`），当前页面里 global 的值被隐藏，可通过 `${.globals.x}` 访问：

```ftl
<#global name=value>
<#global name1=value1 nameN=valueN>
```

## 四、运算符

**比较运算符**：`=` 或 `==` 相等；`>` 或 `gt` 大于；`>=` 或 `gte`；`<` 或 `lt`；`<=` 或 `lte`。

**算术运算符**：`+ - * / %`。注意：运算符两边必须是数字；使用 `+` 时如果一边是数字一边是字符串，会自动把数字转为字符串连接，`${3 + "5"}` 结果是 `35`。

**逻辑运算符**：`&&`、`||`、`!`，只能作用于布尔值。

**优先级**（由高到低）：`!` → 内建函数 `?` → `* / %` → `- +` → 比较 → 相等 → `&&` → `||` → 数字范围 `..`。开发中建议用括号严格区分，可读性好、出错少。

## 五、流程控制

**if 判断**（注意 `elseif` 不加空格）：

```ftl
<#if condition>
...
<#elseif condition2>
...
<#else>
...
</#if>
```

空值判断：`<#if photoList??>...</#if>`。

值得注意的是 `${..}` 只能用于文本部分，**不能用于表达式**：

```ftl
<#if ${isBig}>Wow!</#if>      <#-- 错误 -->
<#if "${isBig}">Wow!</#if>    <#-- 错误 -->
<#if isBig>Wow!</#if>         <#-- 正确 -->
```

**switch**（条件可为数字，可为字符串）：

```ftl
<#switch value>
  <#case refValue1>
    ...
    <#break>
  <#case refValue2>
    ...
    <#break>
  <#default>
    ...
</#switch>
```

## 六、集合与循环

**遍历集合**：

```ftl
<#list empList! as emp>
  ${emp.name!}
</#list>

<#-- 按下标遍历 -->
<#list 0..(empList!?size-1) as i>
  ${empList[i].name!}
</#list>
```

**循环状态变量**（与 jstl 类似）：`empList?size` 集合长度；`emp_index` 当前索引（int）；`emp_has_next` 是否存在下一个对象（boolean）。用 `<#break>` 跳出循环：`<#if emp_index = 0><#break></#if>`。

**集合长度判断**（判断相等时只要一个 `=`）：

```ftl
<#if empList?size != 0></#if>
```

**数字区间**：

```ftl
<#assign l=0..100/>      <#-- 0~100 集合，支持反递增如 100..2 -->
<#list 0..100 as i>      <#-- 等效于 for(int i=0; i<=100; i++) -->
  ${i}
</#list>
```

**创建与连接集合**：

```ftl
<#list ["星期一", "星期二", "星期三"] as x>
<#list ["星期一","星期二","星期三"] + ["星期四","星期五"] as x>   <#-- 连接运算 -->
```

集合元素也可以是表达式：`[2 + 2, [1, 2, 3, 4], "whatnot"]`。截取子集合：`empList[3..5]` 返回第 4~6 个元素。

**元素查找**：

```ftl
<#assign x = ["red", 16, "blue", "cyan"]>
${x?seq_contains("blue")?string("yes", "no")}    <#-- yes -->
${x?seq_contains("yellow")?string("yes", "no")}  <#-- no -->
${x?seq_contains(16)?string("yes", "no")}        <#-- yes -->
${x?seq_contains("16")?string("yes", "no")}      <#-- no，注意类型严格区分 -->

<#assign x = ["red", 16, "blue", "cyan", "blue"]>
${x?seq_index_of("blue")}    <#-- 2，第一次出现的索引 -->
```

**排序**：

```ftl
<#list movies?sort as movie>                        <#-- 按元素首字母排序 -->
<#list movies?sort_by("showtime") as movie>          <#-- 按属性升序 -->
<#list movies?sort_by(["name"])?reverse as movie>    <#-- 按属性降序 -->
```

**Map 对象**：

```ftl
<#-- 创建map -->
<#assign scores = {"语文":86,"数学":78}>
<#-- Map连接运算（同key覆盖） -->
<#assign scores = {"语文":86,"数学":78} + {"数学":87,"Java":93}>
<#-- 元素输出两种方式 -->
${emp.name}
${emp["name"]}
```

## 七、转义与特殊格式

FreeMarker 支持的转义字符：`\"`、`\'`、`\\`、`\n`、`\r`、`\t`、`\b`、`\f`、`\l`（<）、`\g`（>）、`\a`（&）、`\{`、`\xCode`（4位16进制 Unicode）。

如果某段文本包含大量特殊符号，可以在字符串引号前加 `r` 标记，后面的内容直接输出：

```ftl
${r"${foo}"}      <#-- 输出 ${foo} -->
${r"C:/foo/bar"}  <#-- 输出 C:/foo/bar -->
```

## 八、include / import / compress / escape

**include**（类似 JSP 的包含指令）：

```ftl
<#include "/test.ftl" encoding="UTF-8" parse=true>
<#-- encoding 编码格式；parse 是否作为ftl语法解析（默认true，false则以文本引入）。
     注意 ftl 里布尔值直接赋值 parse=true，而不是 parse="true" -->
```

**import**（导入文件后可使用被导入文件里的宏组件，"my" 被称作 namespace）：

```ftl
<#import "/libs/mylib.ftl" as my>
```

**compress**（压缩空白空间和空白的行）及空白控制指令：

```ftl
<#compress>
...
</#compress>
<#t>    <#-- 去掉左右空白和回车换行 -->
<#lt>   <#-- 去掉左边空白和回车换行 -->
<#rt>   <#-- 去掉右边空白和回车换行 -->
<#nt>   <#-- 取消上面的效果 -->
```

**escape/noescape**（body 区的插值自动加上 escape 表达式，不影响字符串内的插值）：

```ftl
<#escape x as x?html>
  First name: ${firstName}
  <#noescape>Last name: ${lastName}</#noescape>
  Maiden name: ${maidenName}
</#escape>
<#-- 等效于：
     ${firstName?html}
     ${lastName}
     ${maidenName?html} -->
```

**setting**（设置整个系统的环境）：`locale`、`number_format`、`boolean_format`、`date_format / time_format / datetime_format`、`time_zone`、`classic_compatible`：

```ftl
<#setting locale="en_US">
${1.2}    <#-- 输出1.2（匈牙利locale下是1,2） -->
```

## 九、macro 宏指令

**例子1：带参数与默认值的宏**

```ftl
<#-- 定义宏 -->
<#macro test foo bar="Bar" baaz=-1>
  Text: ${foo}, ${bar}, ${baaz}
</#macro>

<#-- 使用宏 -->
<@test foo="a" bar="b" baaz=5*5/>    <#-- Text: a, b, 25 -->
<@test foo="a" bar="b"/>             <#-- Text: a, b, -1 -->
<@test foo="a" baaz=5*5-2/>          <#-- Text: a, Bar, 23 -->
<@test foo="a"/>                     <#-- Text: a, Bar, -1 -->
```

**例子2：循环输出的宏**

```ftl
<#macro list title items>
  ${title}
  <#list items as x>
    *${x}
  </#list>
</#macro>

<@list items=["mouse", "elephant", "python"] title="Animals"/>
<#-- 输出：Animals *mouse *elephant *python -->
```

**例子3：nested 嵌套宏**

```ftl
<#macro border>
  <table>
    <#nested>
  </table>
</#macro>

<@border>
  <tr><td>hahaha</td></tr>
</@border>
<#-- 输出：
<table>
  <tr><td>hahaha</td></tr>
</table> -->
```

**例子4：nested 中使用多个循环变量**

```ftl
<#macro repeat count>
  <#list 1..count as x>
    <#nested x, x/2, x==count>    <#-- 指定三个循环变量 -->
  </#list>
</#macro>

<@repeat count=4; c, halfc, last>
  ${c}. ${halfc}<#if last> Last!</#if>
</@repeat>
<#-- 输出：
1. 0.5
2. 1
3. 1.5
4. 2 Last! -->
```

**return 结束宏**：

```ftl
<#macro book>
  spring
  <#return>
  j2ee
</#macro>

<@book />
<#-- 输出 spring，return 之后的 j2ee 不会输出 -->
```

## 总结

FTL 的心智模型：`${}` 管输出、`<#...>` 管指令、`<@...>` 管宏调用，三者覆盖了日常 90% 的模板场景。容易踩的坑记住三个：标签必须闭合、`${}` 不能进表达式、数字与字符串的 `+` 是拼接不是加法。

---

## 相关阅读

- [SpringBoot接入FreeMarker完整指南](/post/2024-11-21-springboot-freemarker-integration/)
- [SpringBoot接入Thymeleaf完整指南](/post/2024-11-28-springboot-thymeleaf-integration/)
