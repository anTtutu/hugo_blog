# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 项目概览

个人 Hugo 静态博客（中文内容），部署到 GitHub Pages（anTtutu.github.io）。使用 maupassant 主题（2018-2019 年代主题），主题直接以源码形式 vendor 在 `themes/maupassant/` 并纳入 git 跟踪（**不是** submodule），已打补丁适配 Hugo 0.164 的新模板 API。修改主题模板直接改 `themes/maupassant/layouts/` 即可。

- Hugo 版本：v0.164.0+extended，通过 gvm 的 go1.26.2 `go install` 安装于 `~/.gvm/pkgsets/go1.26.2/global/bin/hugo`（非 Homebrew）
- 全站唯一配置文件：`config.toml`（菜单、utteranc 评论、busuanzi 统计、打赏、本地搜索均在其中配置）

## 常用命令

```bash
hugo server -D                          # 本地预览（-D 含草稿）
hugo                                    # 构建到 public/（已 gitignore）
hugo new post/2026-09-23-slug.md        # 新建文章，archetype 默认 draft: true
./deployGitPages.sh "提交说明"           # 部署（见下方说明）
```

### 构建挂死问题（重要）

Hugo 0.164 存在 renderPages 死锁 bug：站点渲染错误攒够 10 个触发 `h.Stop()` 时，walker 协程恰好阻塞在 `pages <- p`，错误被吞、构建永久挂起（表现为 "static: syncing static files" 之后无输出、0% CPU）。

- 诊断/绕过：`HUGO_NUMWORKERMULTIPLIER=1 hugo --destination /tmp/xxx` 单 worker 构建可暴露真实模板错误，逐个修复
- 若构建卡在加锁阶段：残留的 `.hugo_build.lock`（flock）会阻塞后续所有构建，杀掉 hugo 进程并删除该文件
- 模板适配已完成的修复（新文章无需处理，改模板时参考）：`.Site.LanguageCode`→`.Site.Language.Locale`、`.Site.Author.name`→`.Site.Params.Author`、GoogleAnalytics 改用 `.Site.Config.Services.GoogleAnalytics.ID`

### 部署

`deployGitPages.sh` 会：交互式确认（输入 y）→ 提交并推送本源码仓库 → 用 sed 切换 `config.toml` 顶部三行 baseURL 注释（github/coding/gitee 三选一）→ `hugo` 构建 → 复制 `public/*` 到**同级目录** `../anTtutu.github.io/` 仓库并推送。前提是 `../anTtutu.github.io/` 已 clone。注意脚本会实际改动 git 工作区并推送远端。

## 内容约定

- 文章位于 `content/post/`，文件名固定 `YYYY-MM-DD-slug.md`
- front matter 字段：`title`、`date`、`tag`、`categories`、`description`、`toc`（参考 `archetypes/default.md` 与最近文章）
- 文章图片存放在 `static/posts/<主题>/`，正文以绝对路径引用 `![xxx](/posts/<主题>/xxx.png)`；也有部分外链图
- `content/about/`、`content/archives/`、`content/search/` 是页面型 bundle（各含 index.md），不要往这些目录加普通文章
- `static/contact/`、`static/payimg/` 存放二维码与打赏图，正文引用 `/contact/xxx.JPG`

## 目录结构要点

- `public/`：构建产物，已 gitignore，勿手动编辑
- `server/`：**手工维护的静态页面目录**（如 `server/about/ai.html` 等独立 HTML 小工具页），混有早期 Hugo 0.64 渲染的旧快照；`hugo` 构建不写入此处，改动这里的文件需手动提交
- `themes/maupassant/exampleSite/`：主题自带示例，与本站无关
