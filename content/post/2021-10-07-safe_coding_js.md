---
title: "前端编码安全"
date: 2021-10-07T00:29:47+08:00
tag : [ "前端", "编码安全"]
description: "前端编码安全"
categories: [ "前端", "编码安全"]
toc: true
---

##### 前端js开发     -- 转自腾讯github

<a id="1.1"></a>
# I. 代码实现

<a id="1.1.1"></a>
## 1.1 原生DOM API的安全操作

**1.1.1【必须】HTML标签操作，限定/过滤传入变量值**

- 使用`innerHTML=`、`outerHTML=`、`document.write()`、`document.writeln()`时，如变量值外部可控，应对特殊字符（`&, <, >, ", '`）做编码转义，或使用安全的DOM API替代，包括：`innerText=`

```javascript
// 假设 params 为用户输入， text 为 DOM 节点
// bad：将不可信内容带入HTML标签操作
const { user } = params;
// ...
text.innerHTML = `Follow @${user}`;

// good: innerHTML操作前，对特殊字符编码转义
function htmlEncode(iStr) {
	let sStr = iStr;
	sStr = sStr.replace(/&/g, "&amp;");
	sStr = sStr.replace(/>/g, "&gt;");
	sStr = sStr.replace(/</g, "&lt;");
	sStr = sStr.replace(/"/g, "&quot;");
	sStr = sStr.replace(/'/g, "&#39;");
	return sStr;
}

let { user } = params;
user = htmlEncode(user);
// ...
text.innerHTML = `Follow @${user}`;

// good: 使用安全的DOM API替代innerHTML
const { user } = params;
// ...
text.innerText = `Follow @${user}`;
```

**1.1.2【必须】HTML属性操作，限定/过滤传入变量值**

- 使用`element.setAttribute(name, value);`时，如第一个参数值`name`外部可控，应用白名单限定允许操作的属性范围。

- 使用`element.setAttribute(name, value);`时，操作`a.href`、`ifame.src`、`form.action`、`embed.src`、`object.data`、`link.href`、`area.href`、`input.formaction`、`button.formaction`属性时，如第二个参数值`value`外部可控，应参考*JavaScript页面类规范1.3.1*部分，限定页面重定向或引入资源的目标地址。

```javascript
// good: setAttribute操作前，限定引入资源的目标地址
function addExternalCss(e) {
	const t = document.createElement('link');
	t.setAttribute('href', e),
	t.setAttribute('rel', 'stylesheet'),
	t.setAttribute('type', 'text/css'),
	document.head.appendChild(t)
}

function validURL(sUrl) {
    return !!((/^(https?:\/\/)?[\w\-.]+\.(qq|tencent)\.com($|\/|\\)/i).test(sUrl) || (/^[\w][\w/.\-_%]+$/i).test(sUrl) || (/^[/\\][^/\\]/i).test(sUrl));
}

let sUrl = "https://evil.com/1.css"
if (validURL(sUrl)) {
	addExternalCss(sUrl);
}
```

<a id="1.1.2"></a>
## 1.2 流行框架/库的安全操作

**1.2.1【必须】限定/过滤传入jQuery不安全函数的变量值**

- 使用`.html()`、`.append()`、`.prepend()`、`.wrap()`、`.replaceWith()`、`.wrapAll()`、`.wrapInner()`、`.after()`、`.before()`时，如变量值外部可控，应对特殊字符（`&, <, >, ", '`）做编码转义。
- 引入`jQuery 1.x（等于或低于1.12）、jQuery2.x（等于或低于2.2）`，且使用`$()`时，应优先考虑替换为最新版本。如一定需要使用，应对传入参数值中的特殊字符（`&, <, >, ", '`）做编码转义。

```javascript
// bad：将不可信内容，带入jQuery不安全函数.after()操作
const { user } = params;
// ...
$("p").after(user);

// good: jQuery不安全函数.html()操作前，对特殊字符编码转义
function htmlEncode(iStr) {
	let sStr = iStr;
	sStr = sStr.replace(/&/g, "&amp;");
	sStr = sStr.replace(/>/g, "&gt;");
	sStr = sStr.replace(/</g, "&lt;");
	sStr = sStr.replace(/"/g, "&quot;");
	sStr = sStr.replace(/'/g, "&#39;");
	return sStr;
}

// const user = params.user;
user = htmlEncode(user);
// ...
$("p").html(user);
```

- 使用`.attr()`操作`a.href`、`ifame.src`、`form.action`、`embed.src`、`object.data`、`link.href`、`area.href`、`input.formaction`、`button.formaction`属性时，应参考*JavaScript页面类规范1.3.1*部分，限定重定向的资源目标地址。

- 使用`.attr(attributeName, value)`时，如第一个参数值`attributeName`外部可控，应用白名单限定允许操作的属性范围。

- 使用`$.getScript(url [, success ])`时，如第一个参数值`url`外部可控（如：从URL取值拼接，请求jsonp接口），应限定可控变量值的字符集范围为：`[a-zA-Z0-9_-]+`。

**1.2.2【必须】限定/过滤传入Vue.js不安全函数的变量值**

- 使用`v-html`时，不允许对用户提供的内容使用HTML插值。如业务需要，应先对不可信内容做富文本过滤。

```html
// bad：直接渲染外部传入的不可信内容
<div v-html="userProvidedHtml"></div>

// good：使用富文本过滤库处理不可信内容后渲染
<!-- 使用 -->
<div v-xss-html="{'mode': 'whitelist', dirty: html, options: options}" ></div>

<!-- 配置 -->
<script>
	new Vue({
	el: "#app",
	data: {
		options: {
			whiteList: {
				a: ["href", "title", "target", "class", "id"],
				div: ["class", "id"],
				span: ["class", "id"],
				img: ["src", "alt"],
			},
		},
	},
});
</script>
```


- 使用`v-bind`操作`a.href`、`ifame.src`、`form.action`、`embed.src`、`object.data`、`link.href`、`area.href`、`input.formaction`、`button.formaction`时，应确保后端已参考*JavaScript页面类规范1.3.1*部分，限定了供前端调用的重定向目标地址。

- 使用`v-bind`操作`style`属性时，应只允许外部控制特定、可控的CSS属性值

```html
// bad：v-bind允许外部可控值，自定义CSS属性及数值
<a v-bind:href="sanitizedUrl" v-bind:style="userProvidedStyles">
click me
</a>

// good：v-bind只允许外部提供特性、可控的CSS属性值
<a v-bind:href="sanitizedUrl" v-bind:style="{
color: userProvidedColor,
background: userProvidedBackground
}" >
click me
</a>
```

<a id="1.1.3"></a>
## 1.3 页面重定向

**1.3.1【必须】限定跳转目标地址**

- 使用白名单，限定重定向地址的协议前缀（默认只允许HTTP、HTTPS）、域名（默认只允许公司根域），或指定为固定值；

- 适用场景包括，使用函数方法：`location.href`、`window.open()`、`location.assign()`、`location.replace()`；赋值或更新HTML属性：`a.href`、`ifame.src`、`form.action`、`embed.src`、`object.data`、`link.href`、`area.href`、`input.formaction`、`button.formaction`；

```javascript
// bad: 跳转至外部可控的不可信地址
const sTargetUrl = getURLParam("target");
location.replace(sTargetUrl);

// good: 白名单限定重定向地址
function validURL(sUrl) {
	return !!((/^(https?:\/\/)?[\w\-.]+\.(qq|tencent)\.com($|\/|\\)/i).test(sUrl) || (/^[\w][\w/.\-_%]+$/i).test(sUrl) || (/^[/\\][^/\\]/i).test(sUrl));
}

const sTargetUrl = getURLParam("target");
if (validURL(sTargetUrl)) {
	location.replace(sTargetUrl);
}

// good: 制定重定向地址为固定值
const sTargetUrl = "http://www.qq.com";
location.replace(sTargetUrl);
```

<a id="1.1.4"></a>
## 1.4 JSON解析/动态执行

**1.4.1【必须】使用安全的JSON解析方式**

- 应使用`JSON.parse()`解析JSON字符串。低版本浏览器，应使用安全的[Polyfill封装](https://github.com/douglascrockford/JSON-js/blob/master/json2.js)

```javascript
// bad: 直接调用eval解析json
const sUserInput = getURLParam("json_val");
const jsonstr1 = `{"name":"a","company":"b","value":"${sUserInput}"}`;
const json1 = eval(`(${jsonstr1})`);

// good: 使用JSON.parse解析
const sUserInput = getURLParam("json_val");
JSON.parse(sUserInput, (k, v) => {
	if (k === "") return v;
	return v * 2;
});

// good: 低版本浏览器，使用安全的Polyfill封装（基于eval）
<script src="https://github.com/douglascrockford/JSON-js/blob/master/json2.js"></script>;
const sUserInput = getURLParam("json_val");
JSON.parse(sUserInput);
```

<a id="1.1.5"></a>
## 1.5 跨域通讯

**1.5.1【必须】使用安全的前端跨域通信方式**

- 具有隔离登录态（如：p_skey）、涉及用户高敏感信息的业务（如：微信网页版、QQ空间、QQ邮箱、公众平台），禁止通过`document.domain`降域，实现前端跨域通讯，应使用postMessage替代。

**1.5.2【必须】使用postMessage应限定Origin**

- 在message事件监听回调中，应先使用`event.origin`校验来源，再执行具体操作。

- 校验来源时，应使用`===`判断，禁止使用`indexOf()`

```javascript
// bad: 使用indexOf校验Origin值
window.addEventListener("message", (e) => {
	if (~e.origin.indexOf("https://a.qq.com")) {
	// ...
	} else {
	// ...
	}
});

// good: 使用postMessage时，限定Origin，且使用===判断
window.addEventListener("message", (e) => {
	if (e.origin === "https://a.qq.com") {
	// ...
	}
});
```

<a id="1.2"></a>
# II. 配置&环境

<a id="1.2.1"></a>
## 2.1 敏感/配置信息

**2.1.1【必须】禁止明文硬编码AK/SK**

- 禁止前端页面的JS明文硬编码AK/SK类密钥，应封装成后台接口，AK/SK保存在后端配置中心或密钥管理系统

<a id="1.2.2"></a>
## 2.2 第三方组件/资源

**2.2.1【必须】使用可信范围内的统计组件**

**2.2.2 【必须】禁止引入非可信来源的第三方JS**

<a id="1.2.3"></a>
## 2.3 纵深安全防护

**2.3.1【推荐】部署CSP，并启用严格模式**