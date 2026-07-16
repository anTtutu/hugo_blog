---
title: "Draw.io MCP + Claude Code 集成教程"
date: 2026-04-09T00:29:47+08:00
tag : [ "claude code", "drawio", "mcp" ]
description: "Draw.io MCP + Claude Code 集成教程"
categories: [ "claude code", "drawio", "mcp" ]
toc: true
---

## 前言

> 分享如何在 Claude Code CLI 中使用 draw.io MCP 服务器创建、编辑和导出流程图

---

## 目录

1. [架构概述](#架构概述)
2. [环境准备](#环境准备)
3. [配置步骤](#配置步骤)
4. [基础使用](#基础使用)
5. [进阶技巧](#进阶技巧)
6. [常见问题](#常见问题)

---

## 架构概述

### 两种集成方式对比

| 方式 | 命令 | 适用场景 | 复杂度 |
|------|------|----------|--------|
| **Skill 方式** | `/skill install drawio` | 快速开始，一键安装 | ⭐ 简单 |
| **MCP 方式** | 编辑 `settings.json` | 自定义配置，多环境部署 | ⭐⭐ 中等 |

### 系统架构图

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────────┐
│   Claude Code   │────▶│  drawio-mcp  │────▶│  Draw.io Server │
│    CLI 工具     │     │   MCP服务     │     │  (本地:6002)     │
└─────────────────┘     └──────────────┘     └─────────────────┘
        │                                                │
        │  方式1: Skill 命令                              │
        │  /skill install drawio                         ▼
        │                                       ┌─────────────────┐
        │                                       │    浏览器窗口    │
        │                                       │  (实时预览编辑)   │
        │                                       └─────────────────┘
        │
        │  方式2: MCP 配置
        │  settings.json 配置
        │
        ▼
┌─────────────────┐
│   MCP Server    │
│  (npx 启动)     │
└─────────────────┘
```

**工作流程**：
1. **Skill 方式**：Claude 内置识别 → 自动调用 drawio 工具
2. **MCP 方式**：Claude 调用 drawio-mcp 工具 → 生成 XML → 启动本地服务 → 浏览器展示
3. 用户在浏览器中实时预览和编辑图表

---

## 环境准备

### 前置要求

| 组件 | 版本要求 | 说明 |
|------|----------|------|
| Node.js | 18+ | MCP 服务器运行依赖 |
| Claude Code | 最新版 | CLI 工具 |
| 浏览器 | Chrome/Firefox/Safari | 预览和编辑图表 |

### 检查环境

```bash
# 检查 Node.js 版本
node --version  # 应 >= 18.0.0

# 检查 npm/npx
npm --version
npx --version

# 检查 Claude Code
claude --version
```

---

## 配置步骤

### Step 0: 安装 Draw.io Skill（推荐方式）

Claude Code 官方提供了便捷的 Skill 安装命令：

```bash
# 在 Claude Code CLI 中执行
/skill install drawio

# 或者使用 skill 命令直接调用
skill: drawio
```

**验证安装**：
```bash
/skills
```

应看到输出：
```
Installed Skills:
  ✓ drawio - Create and edit diagrams using draw.io
```

> **注意**：如果使用 Skill 命令安装成功，可跳过 Step 1-2 的手动配置，直接进入 [Step 3 验证配置](#step-3-验证配置)。

---

### 备用方案：手动 MCP 配置

如果 Skill 命令不可用，请使用以下手动配置方式：

### Step 1: 打开 Claude Code 配置

```bash
# 在 Claude Code 中执行
/mcp
```

或者在 shell 中直接编辑配置文件：

```bash
# macOS/Linux
~/.claude/settings.json

# Windows
%USERPROFILE%\.claude\settings.json
```

### Step 2: 添加 MCP 服务器配置

在 `settings.json` 的 `mcpServers` 中添加 drawio 配置：

```json
{
    "mcpServers": {
        "drawio": {
            "command": "npx",
            "args": [
                "-y",
                "@next-ai-drawio/mcp-server@latest"
            ]
        }
    }
}
```

### Step 3: 完整配置示例

```json
{
    "env": {
        "ANTHROPIC_AUTH_TOKEN": "your-api-key",
        "ANTHROPIC_BASE_URL": "https://api.anthropic.com"
    },
    "mcpServers": {
        "drawio": {
            "command": "npx",
            "args": ["-y", "@next-ai-drawio/mcp-server@latest"]
        },
        "context7": {
            "url": "https://mcp.context7.com/mcp"
        }
    },
    "permissions": {
        "allow": ["Bash(git:*)", "Read", "Write"],
        "deny": ["Bash(rm: -rf /*)"],
        "ask": ["WebFetch"]
    }
}
```

### Step 4: 重启 Claude Code

```bash
# 完全退出后重新启动
claude
```

### Step 5: 验证配置

在 Claude Code 中输入：

```
/mcp
```

你应该能看到 `drawio` 出现在已启用的 MCP 服务器列表中：

```
MCP Servers:
  ✓ drawio (prompts: 0, tools: 3)
    Tools: create_new_diagram, edit_diagram, export_diagram
```

---

## 基础使用

### Skill 方式快速开始

安装 Skill 后，可以直接使用自然语言命令：

```
# 创建新图表
生成一个用户登录流程图

# 创建架构图
帮我画一个微服务架构图，包含网关、用户服务、订单服务和数据库

# 创建时序图
生成一个下单流程的时序图
```

**Claude 会自动**：
1. 识别 drawio Skill 可用
2. 构建 mxGraphModel XML
3. 调用 `create_new_diagram` 工具
4. 启动本地服务器并打开浏览器

### MCP 方式使用流程

如果通过 MCP 配置，使用方法相同，Claude 会自动处理工具调用。

---

### 场景一：创建新图表

**用户输入**：
```
生成一个用户登录流程图
```

**Claude 会自动**：
1. 构建 mxGraphModel XML
2. 调用 `create_new_diagram` 工具
3. 启动本地服务器并打开浏览器

**浏览器地址**：
```
http://localhost:6002?mcp=mcp-xxxxx
```

### 场景二：编辑现有图表

**重要：编辑前必须先获取当前图表！**

```
在现有流程图中添加一个"短信验证"步骤
```

**Claude 执行步骤**：
1. 调用 `get_diagram` 获取当前 XML
2. 解析现有元素 ID
3. 调用 `edit_diagram` 添加新元素

### 场景三：导出图表

```
将这个流程图导出为 PNG 保存到 ./docs/login-flow.png
```

**支持的格式**：
- `.drawio` - XML 源文件（可再次编辑）
- `.png` - 图片格式
- `.svg` - 矢量图形

---

## XML 格式规范

### 基础结构

```xml
<mxGraphModel dx="1434" dy="794" grid="1" gridSize="10">
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />
    
    <!-- 你的元素在这里 -->
    
  </root>
</mxGraphModel>
```

### 常用元素类型

#### 1. 矩形组件

```xml
<mxCell id="2" value="矩形文本" 
        style="rounded=1;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" 
        vertex="1" parent="1">
  <mxGeometry x="100" y="100" width="120" height="60" as="geometry" />
</mxCell>
```

#### 2. 菱形判断

```xml
<mxCell id="3" value="条件判断" 
        style="rhombus;whiteSpace=wrap;html=1;fillColor=#fff2cc;strokeColor=#d6b656;" 
        vertex="1" parent="1">
  <mxGeometry x="100" y="200" width="100" height="100" as="geometry" />
</mxCell>
```

#### 3. 圆柱（数据库）

```xml
<mxCell id="4" value="" 
        style="shape=cylinder3;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;" 
        vertex="1" parent="1">
  <mxGeometry x="100" y="350" width="100" height="120" as="geometry" />
</mxCell>
```

#### 4. 连接线（箭头）

```xml
<mxCell id="5" value="" style="endArrow=classic;html=1;strokeColor=#666666;" 
        edge="1" parent="1" source="2" target="3">
  <mxGeometry width="50" height="50" relative="1" as="geometry" />
</mxCell>
```

### ID 规范

- `id="0"` - 保留，根节点
- `id="1"` - 保留，父容器
- `id="2+"` - 用户元素，必须唯一

### 颜色参考

| 用途 | 填充色 | 边框色 |
|------|--------|--------|
| 客户端/前端 | `#dae8fc` | `#6c8ebf` |
| 网关/代理 | `#ffe6cc` | `#d79b00` |
| 微服务 | `#d5e8d4` | `#82b366` |
| 数据存储 | `#f8cecc` | `#b85450` |
| 缓存 | `#fff2cc` | `#d6b656` |
| 通用容器 | `#f5f5f5` | `#666666` |

---

## 进阶技巧

### 技巧一：分层架构图

使用容器包裹相关组件：

```xml
<!-- 外层容器 -->
<mxCell id="container" value="" 
        style="rounded=1;whiteSpace=wrap;html=1;fillColor=#e1d5e7;strokeColor=#9673a6;" 
        vertex="1" parent="1">
  <mxGeometry x="40" y="300" width="600" height="200" as="geometry" />
</mxCell>

<!-- 内部元素 parent 指向容器 -->
<mxCell id="service1" value="服务A" 
        style="rounded=1;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;" 
        vertex="1" parent="container">
  <mxGeometry x="20" y="30" width="100" height="60" as="geometry" />
</mxCell>
```

### 技巧二：泳道图

使用 `swimlane` 样式创建泳道：

```xml
<mxCell id="lane1" value="泳道1" 
        style="swimlane;horizontal=0;startSize=30;fillColor=#dae8fc;" 
        vertex="1" parent="1">
  <mxGeometry x="40" y="40" width="500" height="100" as="geometry" />
</mxCell>
```

### 技巧三：自动布局

虽然 mcp-drawio 不支持自动布局，但可以按坐标网格排列：

```
X 轴: 40, 200, 360, 520, 680... (间隔 160)
Y 轴: 80, 200, 320, 440... (间隔 120)
```

### 技巧四：复用模板

创建一个基础模板文件：

```bash
# 保存常用图表结构
touch ~/templates/drawio/
```

---

## 完整示例：微服务架构图

```xml
<mxGraphModel dx="1434" dy="794" grid="1" gridSize="10" guides="1" 
              tooltips="1" connect="1" arrows="1" fold="1" 
              page="1" pageScale="1" pageWidth="1200" pageHeight="900">
  <root>
    <mxCell id="0" />
    <mxCell id="1" parent="0" />
    
    <!-- 标题 -->
    <mxCell id="title" value="&lt;b&gt;系统架构图&lt;/b&gt;" 
            style="text;html=1;strokeColor=none;fillColor=none;align=center;fontSize=18;" 
            vertex="1" parent="1">
      <mxGeometry x="400" y="20" width="400" height="40" as="geometry" />
    </mxCell>
    
    <!-- 网关层 -->
    <mxCell id="gateway" value="&lt;b&gt;API Gateway&lt;/b&gt;" 
            style="rounded=1;whiteSpace=wrap;html=1;fillColor=#ffe6cc;strokeColor=#d79b00;" 
            vertex="1" parent="1">
      <mxGeometry x="340" y="100" width="200" height="60" as="geometry" />
    </mxCell>
    
    <!-- 服务A -->
    <mxCell id="svc1" value="&lt;b&gt;Service A&lt;/b&gt;" 
            style="rounded=1;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;" 
            vertex="1" parent="1">
      <mxGeometry x="100" y="220" width="140" height="70" as="geometry" />
    </mxCell>
    
    <!-- 服务B -->
    <mxCell id="svc2" value="&lt;b&gt;Service B&lt;/b&gt;" 
            style="rounded=1;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;" 
            vertex="1" parent="1">
      <mxGeometry x="370" y="220" width="140" height="70" as="geometry" />
    </mxCell>
    
    <!-- 服务C -->
    <mxCell id="svc3" value="&lt;b&gt;Service C&lt;/b&gt;" 
            style="rounded=1;whiteSpace=wrap;html=1;fillColor=#d5e8d4;strokeColor=#82b366;" 
            vertex="1" parent="1">
      <mxGeometry x="640" y="220" width="140" height="70" as="geometry" />
    </mxCell>
    
    <!-- 数据库 -->
    <mxCell id="db" value="" 
            style="shape=cylinder3;whiteSpace=wrap;html=1;fillColor=#dae8fc;strokeColor=#6c8ebf;" 
            vertex="1" parent="1">
      <mxGeometry x="390" y="360" width="100" height="100" as="geometry" />
    </mxCell>
    
    <!-- 连线：网关到服务 -->
    <mxCell id="edge1" value="" style="endArrow=classic;html=1;strokeColor=#666666;" 
            edge="1" parent="1" source="gateway" target="svc1">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="edge2" value="" style="endArrow=classic;html=1;strokeColor=#666666;" 
            edge="1" parent="1" source="gateway" target="svc2">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="edge3" value="" style="endArrow=classic;html=1;strokeColor=#666666;" 
            edge="1" parent="1" source="gateway" target="svc3">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    
    <!-- 连线：服务到数据库 -->
    <mxCell id="edge4" value="" style="endArrow=classic;html=1;strokeColor=#b85450;" 
            edge="1" parent="1" source="svc1" target="db">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="edge5" value="" style="endArrow=classic;html=1;strokeColor=#b85450;" 
            edge="1" parent="1" source="svc2" target="db">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    <mxCell id="edge6" value="" style="endArrow=classic;html=1;strokeColor=#b85450;" 
            edge="1" parent="1" source="svc3" target="db">
      <mxGeometry relative="1" as="geometry" />
    </mxCell>
    
  </root>
</mxGraphModel>
```

---

## 常见问题

### Q1: 浏览器打开后空白

**解决方案**：
1. 等待 2-3 秒让服务器完全启动
2. 按 `Ctrl+F5` 强制刷新
3. 检查浏览器控制台是否有 CORS 错误

### Q2: MCP 服务器未启动

**排查步骤**：
```bash
# 检查 6002 端口是否被占用
lsof -i :6002

# 如果被占用，终止进程
kill -9 <PID>
```

### Q3: 编辑图表时丢失原有内容

**根本原因**：未先调用 `get_diagram` 就直接编辑

**正确流程**：
```
用户: 修改流程图
Claude: [自动调用 get_diagram] → [解析现有内容] → [调用 edit_diagram]
```

### Q4: 如何保存编辑后的图表

**当前限制**：浏览器中的手动编辑不会自动同步回 Claude

**建议做法**：
1. 在 Claude 中完成所有修改
2. 导出为 `.drawio` 文件保存
3. 如需再次编辑，从文件重新导入

---

## 快捷键参考

在浏览器编辑器中：

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+S` | 保存 (导出) |
| `Ctrl+Z` | 撤销 |
| `Ctrl+Y` | 重做 |
| `Delete` | 删除选中元素 |
| `Ctrl+Drag` | 复制元素 |
| `Alt+Shift+Arrow` | 调整大小 |

---

## 学习资源

- [Draw.io 官方文档](https://www.drawio.com/doc/)
- [mxGraph 模型参考](https://jgraph.github.io/mxgraph/)
- [Claude Code MCP 文档](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/mcp)

---

## 总结

drawio-mcp 让 Claude Code 具备了强大的图表生成能力，适合：

- ✅ 系统架构设计
- ✅ 业务流程梳理
- ✅ 数据流程可视化
- ✅ 技术方案讲解

**最佳实践**：先让 Claude 生成初版 → 浏览器微调 → 导出保存

---