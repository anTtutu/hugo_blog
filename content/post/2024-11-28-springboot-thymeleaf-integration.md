---
title: "SpringBoot接入Thymeleaf完整指南：语法速查、布局复用与可运行样例"
date: 2024-11-28T08:00:00+08:00
tags: [ "java", "springboot", "thymeleaf" ]
description: "SpringBoot 集成 Thymeleaf 完整流程：依赖与配置、th:* 常用语法速查表、布局复用 th:fragment/th:replace、表单绑定与校验展示、内置工具对象，附可运行样例及与 FreeMarker 的选型对比"
categories: [ "java", "springboot" ]
toc: true
---

## 前言

Thymeleaf 是 Spring 官方文档里默认的模板引擎，最大的卖点是**原生 HTML 模板**：模板文件不经过引擎也能直接用浏览器打开看排版，设计稿改改就能当模板用。FreeMarker 那套见 [接入指南](/post/2024-11-21-springboot-freemarker-integration/) 和 [语法详解](/post/2024-11-14-freemarker-ftl/)，这篇给 Thymeleaf 同样的一套。

## 1、引入依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-thymeleaf</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

模板默认放 `classpath:/templates/`，后缀 `.html`。

## 2、配置

```yaml
spring:
  thymeleaf:
    enabled: true
    prefix: classpath:/templates/
    suffix: .html
    mode: HTML               # HTML/XML/TEXT/JAVASCRIPT；Thymeleaf 3 默认 HTML
    encoding: UTF-8
    cache: true              # 开发期改 false，改模板即时生效
    check-template-location: true
```

`mode: HTML` 在 Thymeleaf 3 下对未闭合标签容忍度很高，老版本那种要配 legacyhtml5 的做法不用了。

## 3、第一个页面

Controller（和 FreeMarker 写法一样，SpringMVC 的视图层跟引擎无关）：

```java
/**
 * 用户页面控制器
 */
@Controller
@RequestMapping("/page")
public class PageController {

    @GetMapping("/users")
    public String users(Model model) {
        List<User> users = userService.list();
        model.addAttribute("title", "用户列表");
        model.addAttribute("users", users);
        return "user/list";      // -> classpath:/templates/user/list.html
    }
}
```

模板 `templates/user/list.html`：

```html
<!DOCTYPE html>
<html xmlns:th="http://www.thymeleaf.org">
<head>
    <title th:text="${title}">默认标题（静态预览时显示）</title>
</head>
<body>
<h1 th:text="${title}">用户列表</h1>
<table border="1">
    <tr><th>姓名</th><th>年龄</th><th>VIP</th></tr>
    <tr th:each="u : ${users}">
        <td th:text="${u.name}">张三</td>
        <td th:text="${u.age}">20</td>
        <td>
            <span th:if="${u.vip}" style="color:red">是</span>
            <span th:unless="${u.vip}">否</span>
        </td>
    </tr>
</table>
</body>
</html>
```

注意每个 `<td>` 里的「张三」「20」，那是静态预览用的假数据。Thymeleaf 的 `th:*` 都是 HTML 属性，这个文件直接双击打开浏览器就能看排版，这是它最舒服的地方。

## 4、常用语法速查

| 需求 | 写法 |
| - | - |
| 输出文本（转义） | `th:text="${user.name}"` |
| 输出原文（不转义，慎用） | `th:utext="${htmlContent}"` |
| 内联表达式 | `<p>你好 [[${user.name}]]</p>`（转义）；`[(${...})]` 不转义 |
| 循环 | `th:each="u, st : ${users}"`，状态对象 `st.index/count/odd/even` |
| 判断 | `th:if` / `th:unless` / `th:switch` + `th:case` |
| 链接 | `th:href="@{/users/{id}(id=${u.id})}"` → `/users/3`，自动带 contextPath |
| 对象取值 | `th:object="${user}"` 之后用 `*{name}`、`*{age}` |
| 默认值 | `th:text="${user.nick} ?: '匿名'"` |
| 日期格式化 | `th:text="${#temporals.format(user.birthday, 'yyyy-MM-dd')}"` |
| 引入片段 | `th:replace="~{common/header :: nav}"` |

## 5、布局复用

`common/layout.html`：

```html
<nav th:fragment="nav">
    <a href="/">首页</a> <a href="/page/users">用户</a>
</nav>

<footer th:fragment="footer">
    <p th:text="${'© ' + #dates.format(#temporals.createNow(), 'yyyy')} + ' Anttu Blog'">© 2024</p>
</footer>
```

页面里引用（replace 是用片段整体替换宿主标签，insert 是插入内容）：

```html
<body>
<nav th:replace="~{common/layout :: nav}"></nav>
<main>...页面内容...</main>
<footer th:replace="~{common/layout :: footer}"></footer>
</body>
```

片段还能传参，做「同结构不同数据」的布局。

## 6、表单绑定和校验展示

```java
/**
 * 用户表单：GET 渲染 + POST 提交绑定与校验
 */
@Controller
public class UserFormController {

    @GetMapping("/form")
    public String form(Model model) {
        model.addAttribute("userForm", new UserForm());
        return "user/form";
    }

    @PostMapping("/form")
    public String submit(@Valid UserForm userForm, BindingResult result, Model model) {
        if (result.hasErrors()) {
            return "user/form";          // 回显错误
        }
        return "redirect:/page/users";
    }
}
```

```html
<form th:action="@{/form}" th:object="${userForm}" method="post">
    <input type="text" th:field="*{name}" />
    <p th:if="${#fields.hasErrors('name')}"
       th:errors="*{name}" style="color:red"></p>
    <input type="email" th:field="*{email}" />
    <p th:if="${#fields.hasErrors('email')}" th:errors="*{email}"></p>
    <button type="submit">提交</button>
</form>
```

`th:field` 一次干了三件事：`id`、`name`、`value`，等价于手写 `th:id + th:name + th:value`。配合 `@Valid` + `BindingResult` 做校验回显是标准套路。

## 7、内置工具对象

| 对象 | 常用 |
| - | - |
| `#temporals` | `#temporals.format(date,'yyyy-MM-dd')`、`createNow()`（3.1+；旧版用 `#dates`） |
| `#strings` | `isEmpty()`、`toUpperCase()`、`substring()`、`replace()` |
| `#numbers` | `#numbers.formatDecimal(price, 1, 2)` |
| `#lists/#maps` | `isEmpty()`、`size()` |
| `#fields` | 表单校验：`hasErrors('name')`、`errors('*')` |

## 8、踩坑记录

1. **改模板不生效**：`cache: true` 缓存了，开发期关掉或者上 `spring-boot-devtools`
2. **`th:text` 和 `th:utext` 别搞混**：含 HTML 的富文本用 `utext`，不然标签会显示成转义后的字符串；反过来用户输入千万别 `utext`，XSS 就这么来的
3. **3.1 起删掉了 `#request`/`#session`**：模板里直接拿 URL 参数的老写法没了，老老实实在 Controller 里传
4. **模板要合法 HTML**：HTML 模式容忍度高，但 XML 模式下未闭合标签直接报错
5. **`th:field` 必须在 `th:object` 里用**：漏了 `th:object="${userForm}"` 的话 `*{name}` 解析为空
6. **URL 记得用 `@{}`**：手写 `href="/users"` 会丢 contextPath

## 9、和 FreeMarker 怎么选

| 维度 | Thymeleaf | FreeMarker |
| - | - | - |
| 模板形态 | 原生 HTML，设计稿即模板 | 纯文本指令模板，脱离 HTML 没法预览 |
| 学习曲线 | th:* 属性比较直觉 | `<#if>` 指令 + `?string` 这类内建函数，体系更大 |
| 性能 | 3.0 之后接近，略低 | 文本替换引擎，快 |
| 非 HTML 场景（邮件/代码生成） | 弱，TEXT 模式能用但别扭 | 强项，天生纯文本 |
| Spring 生态 | 官方文档默认，示例最多 | 一等支持但示例少 |
| 和设计协作 | 明显占优，前后端可以并行 | 要跑起来才能看效果 |

我的用法：渲染页面用 Thymeleaf，生成邮件、代码片段、配置文件这类纯文本用 FreeMarker，两个共存不冲突。FreeMarker 那边的完整对比也在 [接入指南](/post/2024-11-21-springboot-freemarker-integration/) 里有一份。

## 相关阅读

- [SpringBoot接入FreeMarker完整指南](/post/2024-11-21-springboot-freemarker-integration/)
- [FreeMarker常用语法与指令详解](/post/2024-11-14-freemarker-ftl/)
