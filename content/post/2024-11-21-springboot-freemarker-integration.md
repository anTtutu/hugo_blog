---
title: "SpringBoot接入FreeMarker完整指南：依赖、配置与可运行样例"
date: 2024-11-21T08:00:00+08:00
tags: [ "java", "springboot", "freemarker" ]
description: "SpringBoot 集成 FreeMarker 完整流程：starter 依赖、spring.freemarker 全部常用配置项详解、Controller 渲染样例、全局共享变量注入、数字/日期格式化等高频踩坑点，附可运行 demo"
categories: [ "java", "springboot" ]
toc: true
---

## 前言

FTL 模板语法在 [FreeMarker常用语法与指令详解](/post/2024-11-14-freemarker-ftl/)里整理过了，这篇解决另一半问题：怎么把 FreeMarker 接进 SpringBoot。依赖、配置、渲染、全局变量，配一套能直接跑的样例。

## 1、引入依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-freemarker</artifactId>
</dependency>
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-web</artifactId>
</dependency>
```

starter 会自动带上 freemarker 核心包和 `FreeMarkerAutoConfiguration`，不加任何配置就能跑。

## 2、目录结构

```
src/main/java
  └── com.example.demo
      ├── DemoApplication.java
      └── controller/PageController.java
src/main/resources
  ├── application.yml
  ├── static/                  # 静态资源（css/js）
  └── templates/               # 模板默认目录（classpath:/templates/）
      ├── index.ftl
      ├── user/
      │   └── detail.ftl
      └── common/
          ├── header.ftl
          └── footer.ftl
```

约定就三条：模板放 `classpath:/templates/`，后缀 `.ftl`，Controller 返回视图名不带后缀。

## 3、配置说明

```yaml
spring:
  freemarker:
    enabled: true
    # 模板加载位置，多个用逗号分隔，jar 内外混部时都列出
    template-loader-path: classpath:/templates/
    suffix: .ftl
    charset: UTF-8
    check-template-location: true
    # 开发期关缓存（改模板刷新即生效），生产记得开回 true
    cache: false
    expose-request-attributes: false
    expose-session-attributes: false
    expose-spring-macro-helpers: true
    # FreeMarker 原生 Settings，直接透传
    settings:
      # 防止数字被格式化成 1,000 千分位（高频坑）
      number_format: 0.##
      datetime_format: yyyy-MM-dd HH:mm:ss
      date_format: yyyy-MM-dd
      time_format: HH:mm:ss
      # null 值不抛异常，显示空
      classic_compatible: true
      template_update_delay: 0

server:
  port: 8080
```

几个配置说下我的用法：

| 配置 | 作用 | 建议 |
| - | - | - |
| `cache` | 模板缓存 | 生产开 true，开发关掉 |
| `template-loader-path` | 模板目录 | 保持默认，模板外置部署时加 `file:/app/templates/` |
| `settings.classic_compatible` | null 不报错 | 能兜底，但也会把模板里写错的变量名藏住，看团队情况 |
| `settings.number_format` | 数字格式 | 必配 `0.##`，不然金额显示成 `1,000.5` |
| `suffix` | 视图后缀 | 改成 `.html` 的话设计稿可以直接当模板用 |

## 4、Controller 写法

### 4.1 返回视图名 + Model（最常用）

```java
/**
 * 页面控制器：演示 Model 数据渲染与模板复用
 */
@Controller
@RequestMapping("/page")
public class PageController {

    /** 用户列表页：Model 属性直接在 ftl 中按名访问 */
    @GetMapping("/users")
    public String users(Model model) {
        List<Map<String, Object>> users = new ArrayList<>();
        Map<String, Object> u1 = new HashMap<>();
        u1.put("name", "Anttu");
        u1.put("age", 28);
        u1.put("vip", true);
        users.add(u1);

        model.addAttribute("title", "用户列表");
        model.addAttribute("users", users);
        return "user/detail";      // -> classpath:/templates/user/detail.ftl
    }

    /** 首页 */
    @GetMapping("/index")
    public String index() {
        return "index";
    }
}
```

### 4.2 ModelAndView 写法

```java
@GetMapping("/mv")
public ModelAndView mv() {
    ModelAndView mv = new ModelAndView("index");
    mv.addObject("title", " ModelAndView 渲染");
    return mv;
}
```

### 4.3 注意

同一个项目里接口和页面共存时，接口用 `@RestController` 或者方法上加 `@ResponseBody`，不然返回的字符串会被当成视图名去找模板。

## 5、模板样例（templates/user/detail.ftl）

```ftl
<#-- 公共头尾引入 -->
<#include "../common/header.ftl">

<h1>${title}</h1>
<table border="1">
    <tr><th>姓名</th><th>年龄</th><th>VIP</th></tr>
    <#list users as u>
    <tr>
        <td>${u.name!""}</td>
        <td>${u.age!0}</td>
        <td>
            <#if u.vip?? && u.vip>
                <span style="color:red">是</span>
            <#else>
                否
            </#if>
        </td>
    </tr>
    </#list>
</table>
当前时间：${.now?string("yyyy-MM-dd HH:mm:ss")}
<#include "../common/footer.ftl">
```

启动访问 `http://localhost:8080/page/users` 就能看到结果。

## 6、全局共享变量

站点名、备案号、版本号这种全站变量，不要在每个 Controller 里重复塞，注册一次全部模板可用：

```java
/**
 * FreeMarker 全局配置：注入全站共享变量与共享方法
 */
@Configuration
public class FreemarkerConfig {

    @Autowired
    private freemarker.template.Configuration freemarkerConfiguration;

    @PostConstruct
    public void init() {
        Map<String, Object> shared = new HashMap<>();
        shared.put("siteName", "Anttu Blog");
        shared.put("version", "v1.2.0");
        // 模板里直接 ${site.siteName} 使用
        freemarkerConfiguration.setSharedVariable("site", shared);

        // 也可以注入共享方法，模板里 ${moneyCents(1050)}
        try {
            freemarkerConfiguration.setSharedVariable("moneyCents",
                    new MoneyCentsMethod());
        } catch (TemplateModelException e) {
            throw new IllegalStateException("注册共享方法失败", e);
        }
    }
}
```

```ftl
<footer>${site.siteName} ${site.version}</footer>
```

## 7、踩过的坑

1. **数字变千分位**：`1000` 显示成 `1,000`。全局配 `settings.number_format: 0.##`，或者单处 `${num?c}`
2. **null 直接 500**：`${user.name}` 遇到 user 是 null 就抛异常。要么 `classic_compatible: true` 兜底，要么规范写 `${user.name!""}`、判空 `<#if user??>`
3. **改模板不生效**：`cache: true` 缓存了，开发期改 false
4. **jar 包内模板找不到**：`template-loader-path` 配成了文件路径，打 jar 后要用 `classpath:` 前缀
5. **和 Thymeleaf 共存打架**：两个 starter 同时引入，视图解析器抢视图名，按前缀区分或者只留一个
6. **静态资源 404**：模板里引用 css/js 用 `/css/xxx` 从根开始写

## 8、和 Thymeleaf 怎么选

| 维度 | FreeMarker | Thymeleaf |
| - | - | - |
| 模板形态 | 纯文本模板，HTML 只是用途之一 | 原生 HTML，设计稿直接浏览器能预览 |
| 性能 | 文本替换，快 | 稍重一点，缓存后差距很小 |
| 语法 | `<#if>` 指令风格 | `th:*` 属性风格 |
| 邮件/代码生成等非 HTML | 强项 | 不合适 |
| Spring 官方态度 | 一等支持 | 一等支持，文档示例更多 |

我的结论：页面渲染选 Thymeleaf 顺手（原型即模板）；生成邮件、代码片段、配置文件这类非 HTML 的文本，FreeMarker 更合适。两个一起用也不冲突，各干各的。Thymeleaf 的接入写在 [SpringBoot接入Thymeleaf完整指南](/post/2024-11-28-springboot-thymeleaf-integration/)里。

## 相关阅读

- [FreeMarker常用语法与指令详解](/post/2024-11-14-freemarker-ftl/)
- [SpringBoot接入Thymeleaf完整指南](/post/2024-11-28-springboot-thymeleaf-integration/)
