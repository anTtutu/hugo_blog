---
title: "@FeignClient属性详解与bean重名冲突处理"
date: 2021-12-15T08:00:00+08:00
tags: [ "springcloud", "feign", "java" ]
description: "OpenFeign @FeignClient 注解全属性中文详解（value/name/contextId/qualifier/url/fallback 等），附 RequestInterceptor 统一授权示例与 contextId 解决同名 bean 冲突的实战"
categories: [ "springcloud", "java" ]
toc: true
---

## 前言

微服务项目里 OpenFeign 是最常用的声明式 HTTP 客户端，但 `@FeignClient` 的属性含义很多人只停留在 `value` 上。这篇整理注解的全属性解读，以及一个常见的坑：**多个 FeignClient 指向同一个服务时的 bean 重名冲突**。

## 一、@FeignClient 全属性解读

```java
@Target({ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Documented
public @interface FeignClient {

    /**
     * 1、value 与 name 互为别名，两者二选一即可
     * 2、当 contextId 没有值的时候，会默认获取（value/name）的值
     * 3、当未指定 url 请求地址的时候，最终会通过 ribbon-loadbalancer 工具，
     *    从注册中心选取 service-id 等于 value 的服务作为请求地址
     */
    @AliasFor("name")
    String value() default "";

    /**
     * serviceId 已作废，其目的与 value 一致。如果设置了 serviceId，
     * 则 value/name 皆以 serviceId 为准
     */
    @Deprecated
    String serviceId() default "";

    /**
     * 1、当 contextId 没有值的时候，会默认获取（value/name）的值
     * 2、当 qualifier 没有值的时候，会将 '${contextId}FeignClient' 作为
     *    feign 的 bean 组件别名
     */
    String contextId() default "";

    /** 同 value，二选一 */
    @AliasFor("value")
    String name() default "";

    /**
     * feign 的 bean 组件别名，拥有最高优先级；
     * 当 qualifier 为空时，取 '${contextId}FeignClient' 作为 bean 的名称
     */
    String qualifier() default "";

    /**
     * 1、设置 url 以后，后续发起 http 调用时，直接读取该地址作为请求目标；
     * 2、未设置 url 时，借助 ribbon-loadbalancer 组件，根据 (value/name)
     *    从注册中心的服务列表中选中 service-id 匹配的目标服务
     */
    String url() default "";

    boolean decode404() default false;

    Class<?>[] configuration() default {};

    Class<?>[] fallback() default void.class;

    Class<?>[] fallbackFactory() default void.class;

    /**
     * 目标服务器对应的资源 uri（FeignClient 下所有方法相同的 path 前缀）
     */
    String path() default "";

    boolean primary() default true;
}
```

属性速查：

属性|作用
-|-
value / name|目标服务名（注册中心里的 service-id），互为别名
contextId|bean 的上下文标识，默认取 value/name；**解决同名 bean 冲突的关键**
qualifier|bean 别名，优先级最高，为空时取 `${contextId}FeignClient`
url|直连地址，设置后不走注册中心负载均衡
decode404|404 是否抛 FeignException（false 时解码为 null/实体）
configuration|自定义配置类（编解码器、重试等）
fallback / fallbackFactory|熔断降级回退实现
path|统一路径前缀
primary|是否标记为 primary bean

## 二、实战：bean 重名冲突

**场景**：项目里需要调用本项目中定义的另一个 Feign 接口，两个 `@FeignClient` 指向了同一个服务名。因为 springboot 版本问题，使用配置文件配置 `allow-bean-definition-overriding=true` 不起作用，启动直接报 bean 重名。

**解决方案**：在 Feign 接口上加 `contextId` 区分。注意 contextId 不能和业务层的 bean 同名：

```java
package com.example.demo.feign;

import com.example.demo.common.core.web.ServerResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;

@FeignClient(name = "demo-admin-server", contextId = "SysDeptFeign")
@RequestMapping("/sysDept")
public interface SysDeptFeign {

    /**
     * 根据ID查询所有子部门
     * @param deptId 部门ID
     * @return 部门列表
     */
    @GetMapping("/findChildrenDeptById/{deptId}")
    ServerResponse findChildrenDeptById(@PathVariable Long deptId);

}
```

加了 `contextId` 后，两个指向同一服务的 Feign 接口各自生成独立的 bean，冲突解除。

## 三、完整使用示例

### 3.1 开启 FeignClient 扫描

```java
@Configuration
@EnableFeignClients(basePackages = "com.example")
public class FeignConfiguration {
}
```

### 3.2 RequestInterceptor 统一添加授权 Header

```java
@Slf4j
@Component(value = "core_feign_interceptor")
@AllArgsConstructor
public class FeignInterceptor implements RequestInterceptor {
    private final ClientTokenTemplate clientTokenTemplate;

    /**
     * feign请求添加header
     * @param requestTemplate
     */
    @Override
    public void apply(RequestTemplate requestTemplate) {
        // 如果token中的类型加入了验证, 则设置rdc token
        Collection<String> authHeaders = requestTemplate.headers().get(TokenConstant.AUTH_TYPE);
        if (CollectionUtils.isNotEmpty(authHeaders) && authHeaders.contains(TokenConstant.CLIENT_AUTH)) {
            requestTemplate.header("Authorization", clientTokenTemplate.getRedisToken().getAccess_token());
        } else {
            AuthInfo authInfo = BizContext.getValue(Constants.BizContextKey.AUTH);
            if (authInfo != null && !StringUtils.isEmpty(authInfo.getAccess_token())) {
                requestTemplate.header("Authorization", authInfo.getAccess_token());
            }
        }
    }
}
```

### 3.3 文件服务的客户端实现

`url` + `path` 组合的典型用法——不走注册中心，直接指向网关地址，并声明统一前缀：

```java
/**
 * 文件服务客户端
 */
@ConditionalOnProperty(name = {"gateway.host", "gateway.apis.file-service"})
@FeignClient(value = "demo-file-service", url = "${gateway.host}/${gateway.apis.file-service}", path = "/api/v2/files")
public interface RdcFileClient {

    /**
     * 获取文件信息
     * @param fileId 文件ID
     * @return 文件内容
     */
    @GetMapping(value = "/{fileId}", headers = TokenConstant.GATEWAY_AUTH_HEADER)
    PluginFileInfoResponse getFileInfo(@PathVariable String fileId);

    /**
     * 上传文件
     */
    @PostMapping(value = "/", headers = TokenConstant.GATEWAY_AUTH_HEADER, consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    PluginFileInfoResponse uploadFile(MultipartFile file);

    /**
     * 获取下载地址
     */
    @GetMapping(value = "/{fileId}/download-url", headers = TokenConstant.GATEWAY_AUTH_HEADER)
    String getDownloadUrl(@PathVariable String fileId);

    /**
     * 批量获取文件详情
     */
    @PostMapping(value = "/batchInfos", headers = TokenConstant.GATEWAY_AUTH_HEADER,
            produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
    List<PluginFileInfoResponse> batchGetFileDetail(JSONObject object);

    /**
     * 删除缓存的文件
     */
    @DeleteMapping(value = "/{fileId}", headers = TokenConstant.GATEWAY_AUTH_HEADER)
    Object delFile(@PathVariable String fileId);
}
```

## 总结

记住三条：`value/name` 指定目标服务；**同一服务多个 Feign 接口时必须用 `contextId` 区分**（比开 bean 覆盖开关干净得多）；直连场景用 `url` + `path` 组合。
