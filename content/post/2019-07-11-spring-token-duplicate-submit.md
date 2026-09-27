---
title: "SpringMVC全局token防止重复提交"
date: 2019-07-11T08:00:00+08:00
tags: [ "java", "springmvc", "防重复提交" ]
description: "SpringMVC 防重复提交方案：自定义 @Token 注解 + 拦截器，进入页面存 token、提交时校验销毁，解决 ajax 和移动端场景下 redirect 方案失效的重复提交问题，附完整代码"
categories: [ "java", "spring" ]
toc: true
---

## 前言

表单重复提交是老问题：用户手快点了两下提交、网络卡顿刷新重发，数据就插了两条。最常见的解法是提交完成后 redirect 跳转，但它解决不了 ajax 提交和移动端提交的场景（没有页面可跳）。通行的做法是用 token：django 等框架内置了这套机制，SpringMVC 需要自己搭，这篇把完整实现整理出来（思路参考了网上的经典方案，见文末参考）。

## 1、token 防重的逻辑

给需要防重的 URL 挂一个拦截器：

1. **进入页面**（GET 请求渲染表单）时，拦截器生成一个随机 UUID 放进 session，页面表单里带上这个 token
2. **提交数据**时，token 随表单一起提交，拦截器比对表单里的 token 和 session 里的 token：一致则放行并**销毁 session 里的 token**；再提交第二次，session 里已经没有 token 了，判定为重复提交，直接拦下

因为 token 用完即焚，同一个表单第二次提交必然对不上号，这就是防重的核心。

## 2、自定义 @Token 注解

```java
import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

/**
 * 防重复提交注解：
 * save=true   进入页面的方法上标记，生成 token 放入 session
 * remove=true 提交处理的方法上标记，校验并销毁 token
 */
@Target(ElementType.METHOD)
@Retention(RetentionPolicy.RUNTIME)
public @interface Token {
    boolean save() default false;
    boolean remove() default false;
}
```

## 3、拦截器 TokenInterceptor

```java
import java.lang.reflect.Method;
import java.util.UUID;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.method.HandlerMethod;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

/**
 * token 拦截器：配合 @Token 注解实现防重复提交
 */
public class TokenInterceptor extends HandlerInterceptorAdapter {

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response,
                             Object handler) throws Exception {
        if (handler instanceof HandlerMethod) {
            HandlerMethod handlerMethod = (HandlerMethod) handler;
            Method method = handlerMethod.getMethod();
            Token annotation = method.getAnnotation(Token.class);
            if (annotation != null) {
                boolean needSaveSession = annotation.save();
                if (needSaveSession) {
                    // 进入页面：生成 token 放入 session
                    request.getSession(false).setAttribute("token", UUID.randomUUID().toString());
                }
                boolean needRemoveSession = annotation.remove();
                if (needRemoveSession) {
                    // 提交数据：先校验，重复则拦截
                    if (isRepeatSubmit(request)) {
                        return false;
                    }
                    // 校验通过，销毁 session 里的 token
                    request.getSession(false).removeAttribute("token");
                }
            }
            return true;
        } else {
            return super.preHandle(request, response, handler);
        }
    }

    /**
     * 重复提交判断：session 无 token、请求无 token、两者不一致，都算重复
     */
    private boolean isRepeatSubmit(HttpServletRequest request) {
        String serverToken = (String) request.getSession(false).getAttribute("token");
        if (serverToken == null) {
            return true;
        }
        String clientToken = request.getParameter("token");
        if (clientToken == null) {
            return true;
        }
        if (!serverToken.equals(clientToken)) {
            return true;
        }
        return false;
    }
}
```

## 4、注册拦截器

spring-mvc 配置文件：

```xml
<mvc:interceptors>
    <!-- Token 拦截器，防止用户重复提交数据 -->
    <mvc:interceptor>
        <mvc:mapping path="/**"/>
        <bean class="com.example.web.spring.TokenInterceptor"/>
    </mvc:interceptor>
</mvc:interceptors>
```

## 5、使用方法

两个注解配合用：

```java
/** 进入页面：save=true 生成 token */
@Token(save = true)
@RequestMapping(value = "/add", method = RequestMethod.GET)
public String add(Model model) { ... }

/** 提交数据：remove=true 校验并销毁 token */
@Token(remove = true)
@RequestMapping(value = "/save", method = RequestMethod.POST)
public String save(UserForm form) { ... }
```

页面表单里加上隐藏域：

```html
<input type="hidden" name="token" value="${token}" />
```

搞定。之后用户再怎么疯狂点提交、刷新重发，第二次开始都会被拦截器拦下来。

## 6、几点补充

1. **token 存 session 有前提**：应用是单机或有 session 共享（redis 集中存储），多机无共享 session 时 token 校验会随机会失败，这时把 token 挪到 redis（用户维度）是常见改造
2. **ajax 场景**：拦截器 return false 时最好统一返回一个约定 JSON（而不是空白页），前端据此提示「请勿重复提交」
3. **前端配合**：提交时按钮置灰 + loading 态，能挡掉 90% 的手快，后端 token 兜底剩下的 10%
4. 这套思路是框架无关的，django 的 CSRF 中间件、laravel 的 CSRF token 本质都是「页面发 token、提交验 token、用完即焚」

## 参考

- [Spring MVC 防重复提交（token 方式）](http://blog.icoolxue.com/submitted-by-spring-mvc-to-prevent-data-duplication/)
