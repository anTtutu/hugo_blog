---
title: "claude code skill介绍"
date: 2026-04-30T00:29:47+08:00
tag : [ "claude code", "skill" ]
description: "claude code skill介绍"
categories: [ "claude code", "skill" ]
toc: true
---

## 前言

本文档介绍 `.claude/skills/` 目录下各个技能（skill）的功能和用途，以表格形式呈现，方便快速查阅。

## 文档生成类技能

| 技能名称 | 功能描述 | 用途场景 | 关键特性 |
|---------|---------|---------|---------|
| **swagger-doc-generator** | 为 Java Spring Boot 项目生成 OpenAPI/Swagger 文档 | 当需要生成 REST API 文档时触发 | 分析 Controller 代码、注解和 DTO，生成符合 OpenAPI 3.0 规范的 YAML/JSON 文件 |

## 图表绘制类技能

| 技能名称 | 功能描述 | 用途场景 | 关键特性 |
|---------|---------|---------|---------|
| **drawio** | 创建 draw.io 图表（.drawio 文件） | 流程图、架构图、ER 图、序列图、类图、网络图、线框图 | 支持导出 PNG/SVG/PDF，生成 mxGraphModel XML 格式 |
| **excalidraw-diagram** | 生成 Excalidraw 图表 | 手绘风格图表、流程图、思维导图 | 支持 Obsidian/Standard/Animated 三种输出模式 |
| **mermaid-visualizer** | 将文本转换为 Mermaid 图表 | 流程图、系统架构、对比图、思维导图 | 支持 Process Flow、Circular Flow、Comparison、Mindmap、Sequence、State 等类型 |
| **graphviz** | 使用 DOT 语言创建有向/无向图 | 依赖树、调用图、包层级结构 | 使用 `digraph` 或 `graph`，自动布局 |
| **canvas** | 创建 JSON 格式的自由定位画布 | 概念图、知识图、规划板 | 支持节点（text/file/link/group）和边连接，Obsidian Canvas 兼容 |

## 架构图类技能

| 技能名称 | 功能描述 | 用途场景 | 关键特性 |
|---------|---------|---------|---------|
| **architecture** | 创建分层系统架构图（HTML/CSS） | 技术栈、微服务拓扑、多层应用设计 | 12 种配色风格（Steel Blue、Ember Warm、Neon Dark 等）+ 12 种布局模式 |
| **uml** | 创建 UML 图表 | 类图、序列图、活动图、状态图、组件图等 | 使用 PlantUML 语法，支持 9500+ mxgraph  stencil 图标 |
| **cloud** | 创建云架构图（AWS/Azure/GCP/阿里云） | 多云拓扑、迁移蓝图 | 支持 AWS、Azure、GCP、阿里云、IBM、Kubernetes、OpenStack |
| **network** | 创建网络拓扑图 | LAN/WAN、数据中心互联、物理/逻辑网络设计 | 支持 Cisco、Citrix 等网络设备图标 |
| **security** | 创建安全架构图 | IAM 流程、零信任模型、加密管道、威胁检测 | 包含身份访问、加密、网络安全、合规审计等图标 |
| **data-analytics** | 创建数据分析和 ETL 架构图 | 数据湖、实时流处理、数据仓库、BI 仪表盘 | 支持 AWS 分析服务（Athena、Glue、Kinesis、Redshift 等） |
| **iot** | 创建物联网架构图 | 智能家居、工业物联网、边缘计算、传感器网络 | 支持设备管理、边缘网关、数字孪生等 |
| **archimate** | 创建 ArchiMate 企业架构图 | TOGAF 视图、分层 EA 建模、业务/应用/技术层 | 支持业务、应用、技术、动机、实现层 |

## 流程图类技能

| 技能名称 | 功能描述 | 用途场景 | 关键特性 |
|---------|---------|---------|---------|
| **bpmn** | 创建业务流程图（BPMN/EIP/精益映射） | 工作流自动化、审批链、消息集成模式、价值流映射 | 支持 BPMN 事件、网关、任务，EIP 消息模式 |
| **mindmap** | 创建层级思维导图 | 头脑风暴、主题分解、学习笔记、决策树 | 使用 PlantUML @startmindmap 语法，自动径向布局 |
| **infographic** | 创建基于模板的信息图 | KPI 仪表盘、时间线、路线图、SWOT 分析、漏斗图 | 使用简化的空格分隔语法，预置 40+ 模板 |

## 可视化卡片类技能

| 技能名称 | 功能描述 | 用途场景 | 关键特性 |
|---------|---------|---------|---------|
| **infocard** | 创建信息卡片（HTML/CSS 编辑风格） | 知识摘要、数据亮点、活动公告、杂志级排版 | 30+ 风格模板 + 30+ 布局骨架 |
| **ppt-master** | AI 驱动生成 PPT 演示文稿 | 从 PDF/DOCX/URL/Markdown 生成 PPTX | 多步骤串行流程：源处理 → 项目初始化 → 模板选择 → 策略设计 → SVG 生成 → 导出 |

## 数据可视化类技能

| 技能名称 | 功能描述 | 用途场景 | 关键特性 |
|---------|---------|---------|---------|
| **vega** | 创建 Vega/Vega-Lite 图表 | 统计可视化：柱状图、折线图、散点图、热力图、雷达图 | 使用声明式 JSON 语法，90% 场景用 Vega-Lite |

## 其他技能

| 技能名称 | 功能描述 | 用途场景 | 关键特性 |
|---------|---------|---------|---------|
| **find-skills** | 发现和安装代理技能 | 当用户询问"如何做 X"或寻找技能时使用 | 搜索 Skills CLI (npx skills) 和 Skillhub 生态系统的技能 |
| **api-conventions** | REST API 设计规范 | 定义 API 设计标准 | URL kebab-case、JSON camelCase、分页支持、API 版本化 |
| **obsidian-canvas-creator** | 创建 Obsidian Canvas 文件 | 交互式画布、心智图、空间化信息组织 | 支持 MindMap 和 Freeform 两种布局 |

---

## 技能使用快速指南

### 触发词汇总

| 技能 | 触发词 |
|------|--------|
| swagger-doc-generator | Swagger、OpenAPI、API文档、生成接口文档 |
| drawio | draw、diagram、flowchart、architecture、.drawio 文件 |
| excalidraw-diagram | Excalidraw、画图、流程图、思维导图、可视化 |
| ppt-master | create PPT、make presentation、生成PPT、做PPT |
| infographic | KPI、timeline、roadmap、SWOT、funnel、comparison |

### 语法标识符汇总

| 技能 | 代码 fence 标识符 |
|------|----------------|
| uml / cloud / network / security / bpmn / iot / data-analytics / archimate / mindmap | ` ```plantuml ` 或 ` ```puml ` |
| mermaid-visualizer | ` ```mermaid ` |
| graphviz | ` ```dot ` |
| vega | ` ```vega-lite ` 或 ` ```vega ` |
| canvas | ` ```canvas ` |
| infographic | ` ```infographic ` |

---

## 技能分类索引

### 📊 图表绘制类
- drawio、excalidraw-diagram、mermaid-visualizer、graphviz、canvas

### 🏗️ 架构设计类
- architecture、uml、cloud、network、security、data-analytics、iot、archimate

### 📈 流程与关系类
- bpmn、mindmap、infographic

### 📇 可视化内容类
- infocard、ppt-master、vega

### 🔧 工具与规范类
- swagger-doc-generator、find-skills、api-conventions、obsidian-canvas-creator

---

## 文档生成类技能

| 技能名称 | 功能描述 | 用途场景 | 关键特性 |
|---------|---------|---------|---------|
| swagger-doc-generator | 为 Java Spring Boot 项目生成 OpenAPI/Swagger 文档 | 当需要生成 REST API 文档时触发 | 分析 Controller 代码、注解和 DTO，生成符合 OpenAPI 3.0 规范的 YAML/JSON 文件 |

## 图表绘制类技能

| 技能名称 | 功能描述 | 用途场景 | 关键特性 |
|---------|---------|---------|---------|
| drawio | 创建 draw.io 图表（.drawio 文件） | 流程图、架构图、ER 图、序列图、类图、网络图、线框图 | 支持导出 PNG/SVG/PDF，生成 mxGraphModel XML 格式 |
| excalidraw-diagram | 生成 Excalidraw 图表 | 手绘风格图表、流程图、思维导图 | 支持 Obsidian/Standard/Animated 三种输出模式 |
| mermaid-visualizer | 将文本转换为 Mermaid 图表 | 流程图、系统架构、对比图、思维导图 | 支持 Process Flow、Circular Flow、Comparison、Mindmap、Sequence、State 等类型 |
| graphviz | 使用 DOT 语言创建有向/无向图 | 依赖树、调用图、包层级结构 | 使用 digraph 或 graph，自动布局 |
| canvas | 创建 JSON 格式的自由定位画布 | 概念图、知识图、规划板 | 支持节点（text/file/link/group）和边连接，Obsidian Canvas 兼容 |

## 架构图类技能

| 技能名称 | 功能描述 | 用途场景 | 关键特性 |
|---------|---------|---------|---------|
| architecture | 创建分层系统架构图（HTML/CSS） | 技术栈、微服务拓扑、多层应用设计 | 12 种配色风格 + 12 种布局模式 |
| uml | 创建 UML 图表 | 类图、序列图、活动图、状态图、组件图等 | 使用 PlantUML 语法，支持 9500+ mxgraph stencil 图标 |
| cloud | 创建云架构图（AWS/Azure/GCP/阿里云） | 多云拓扑、迁移蓝图 | 支持 AWS、Azure、GCP、阿里云、IBM、Kubernetes、OpenStack |
| network | 创建网络拓扑图 | LAN/WAN、数据中心互联、物理/逻辑网络设计 | 支持 Cisco、Citrix 等网络设备图标 |
| security | 创建安全架构图 | IAM 流程、零信任模型、加密管道、威胁检测 | 包含身份访问、加密、网络安全、合规审计等图标 |
| data-analytics | 创建数据分析和 ETL 架构图 | 数据湖、实时流处理、数据仓库、BI 仪表盘 | 支持 AWS 分析服务 |
| iot | 创建物联网架构图 | 智能家居、工业物联网、边缘计算、传感器网络 | 支持设备管理、边缘网关、数字孪生等 |
| archimate | 创建 ArchiMate 企业架构图 | TOGAF 视图、分层 EA 建模 | 支持业务、应用、技术、动机、实现层 |

## 流程图类技能

| 技能名称 | 功能描述 | 用途场景 | 关键特性 |
|---------|---------|---------|---------|
| bpmn | 创建业务流程图（BPMN/EIP/精益映射） | 工作流自动化、审批链、消息集成模式 | 支持 BPMN 事件、网关、任务，EIP 消息模式 |
| mindmap | 创建层级思维导图 | 头脑风暴、主题分解、学习笔记、决策树 | 使用 PlantUML @startmindmap 语法，自动径向布局 |
| infographic | 创建基于模板的信息图 | KPI 仪表盘、时间线、路线图、SWOT 分析、漏斗图 | 使用简化的空格分隔语法，预置 40+ 模板 |

## 可视化卡片类技能

| 技能名称 | 功能描述 | 用途场景 | 关键特性 |
|---------|---------|---------|---------|
| infocard | 创建信息卡片（HTML/CSS 编辑风格） | 知识摘要、数据亮点、活动公告、杂志级排版 | 30+ 风格模板 + 30+ 布局骨架 |
| ppt-master | AI 驱动生成 PPT 演示文稿 | 从 PDF/DOCX/URL/Markdown 生成 PPTX | 多步骤串行流程 |

## 数据可视化类技能

| 技能名称 | 功能描述 | 用途场景 | 关键特性 |
|---------|---------|---------|---------|
| vega | 创建 Vega/Vega-Lite 图表 | 统计可视化：柱状图、折线图、散点图、热力图、雷达图 | 使用声明式 JSON 语法 |

## 其他技能

| 技能名称 | 功能描述 | 用途场景 | 关键特性 |
|---------|---------|---------|---------|
| find-skills | 发现和安装代理技能 | 当用户询问"如何做 X"或寻找技能时使用 | 搜索 Skills CLI 和 Skillhub 生态系统的技能 |
| api-conventions | REST API 设计规范 | 定义 API 设计标准 | URL kebab-case、JSON camelCase、分页支持、API 版本化 |
| obsidian-canvas-creator | 创建 Obsidian Canvas 文件 | 交互式画布、心智图、空间化信息组织 | 支持 MindMap 和 Freeform 两种布局 |

---

> 更多详细使用说明请参考各技能目录下的 `skill.md` 文件。