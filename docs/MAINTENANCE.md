# MayL 博客使用与维护手册

## 1. 站点与技术选择

站点地址：<https://sekirooox.github.io/>。

使用官方 `jekyll-theme-chirpy` **7.6.0** gem，配合官方 starter 的配置、导航页面和更新日期插件。主题的布局、样式、脚本来自 gem，保留官方交互与响应式设计；中文界面、站点名称、头像和文章为本仓库内容。不是将演示站的作者资料和文章原样复制。

Ruby 版本固定在 `.ruby-version`；完整依赖由 `Gemfile.lock` 管理。GitHub Actions 安装环境、构建 Jekyll、检查内部链接并发布。普通写作不需要 Node.js。

## 2. 首次部署

1. 在 GitHub 仓库 **Settings → Pages → Build and deployment → Source** 选择 **GitHub Actions**。必须从原先的分支构建切换：Chirpy 使用 Jekyll 4 与自定义插件，不能继续依赖旧的内置构建。
2. 提交本次迁移的全部文件并推送到 `main`。先检查 `git status`，确保不包含 `.tools`、`vendor`、`_site`。
3. 在 Actions 查看 **Build and Deploy**。`build` 成功且链接检查通过后才会执行 `deploy`。
4. 打开站点，检查个人首页、访客地图、分类、标签、归档、关于和示例文章。PR 只构建检查，不发布。

```sh
git add .
git commit -m "Migrate blog to Chirpy"
git push origin main
```

如果远端比本地多了教程机器人的提交，先提交本地修改，再 `git pull --rebase origin main`，解决可能出现的 README 冲突后推送。不要强制推送覆盖远端。

上面的 `git add .` 只适用于工作区仅有本次博客变更的情况；如果还有其他工作，请逐项选择暂存文件。`csdn-repo/` 是迁移过程中出现的独立笔记目录，本次没有改动其内容，并已从 Jekyll 发布范围排除。要发布其中内容，请整理成 `_posts` 文章后再加入。

权限：工作流默认只有 `contents: read`；部署 job 单独拥有 `pages: write`、`id-token: write`。不需要个人访问令牌。若仓库有环境保护规则，按 `github-pages` 环境要求批准部署。

## 3. 本地预览与环境

### 方式 A：Docker（跨平台）

先安装并启动 Docker Desktop，然后在仓库根目录执行：

```sh
docker compose up --build
```

首次自动下载 Ruby 镜像并执行 `bundle install`。打开 <http://localhost:4000/>。依赖保存到 Docker volume，正文修改后自动刷新。结束时按 Ctrl+C，再执行 `docker compose down`。

### 方式 B：VS Code Dev Container / Codespaces

本仓库有 `.devcontainer/devcontainer.json`。在 VS Code 选择 **Dev Containers: Reopen in Container**，或者在 GitHub 创建 Codespace。容器初始化会执行 `bundle install`。终端运行 `bash tools/serve.sh`，打开转发的 4000 端口根地址。

### 方式 C：已有 Ruby 环境

安装 `.ruby-version` 指定的 Ruby；Windows 原生环境建议 RubyInstaller + Devkit。

```sh
bundle install
bundle exec jekyll serve --livereload
```

本次迁移若已在本机下载便携 Ruby，可用 `tools/preview.ps1` 启动；它也支持 PATH 中已有的 Ruby。便携运行时位于 Git 忽略的 `.tools/`，不属于仓库依赖，换电脑优先用容器。

修改 `_config.yml` 后需要重启预览。不要用 `--future` 进行发布验收，它会掩盖文章日期错误。

### 发布前检查

在 Linux 或容器中运行（Windows 原生 HTMLProofer 还需要配置 libcurl）：

```sh
bash tools/test.sh
```

该命令模拟生产环境构建，并检查生成 HTML 的内部链接和图片。外部网站可用性不作为构建阻断条件。它不代替浏览器检查：还应测试搜索、明暗切换、手机导航、公式、Mermaid 与图片。

## 4. 项目结构

```text
.
├── _config.yml                站点身份、时区、路径与功能开关
├── Gemfile / Gemfile.lock     主题及锁定的 Ruby 依赖
├── .ruby-version              Ruby 版本
├── index.html                 独立个人首页入口和旧项目地址跳转
├── _posts/YYYY/MM/            按年月分组的已发布文章
├── _drafts/                   草稿（需要时创建）
├── _tabs/                     侧栏栏目：分类、标签、归档、关于
├── _data/contact.yml          侧栏社交链接
├── _data/visitor_stats.yml    本地无统计数据时的回退内容
├── _layouts/home-profile.html 个人首页布局
├── _includes/                首页介绍、统计地图和主题扩展钩子
├── _plugins/                  按 Git 历史生成文章更新时间
├── assets/img/                头像和文章图片
├── templates/post.md          可复制的文章模板，不发布到站点
├── tools/                     预览、构建、检查和统计抓取脚本
├── test/                      统计解析测试和 PR 布局测试数据
├── docs/                      本维护手册及归档说明，不发布到站点
├── .github/workflows/         唯一有效的构建发布流程
├── .github/steps/             原 GitHub Skills 教程文字，仅作参考
├── .devcontainer/             VS Code / Codespaces 开发环境
├── Dockerfile                 Ruby 容器环境
└── docker-compose.yml         本地端口、源码挂载和依赖缓存
```

`_site/` 是生成结果；`vendor/`、`.bundle/`、`.tools/` 是本地依赖与环境，均不应提交。主题 `_layouts`、`_includes`、`_sass` 和 JavaScript 默认在 gem 内，看不到这些文件夹是正常的。运行 `bundle info jekyll-theme-chirpy --path` 可查看主题位置。

## 5. 首页与个人信息

在 `_config.yml` 修改 `title`、`tagline`、`description`、`social.name` 和 `github.username`。头像是 `assets/img/avatar.svg`，可换成自己的 PNG/JPG 并更新 `avatar` 路径。首页简短介绍位于 `_includes/profile-intro.html`，`_tabs/about.md` 是更完整的关于页。

首页大头像和全站侧栏共用 `_config.yml` 的 `avatar`，README 顶部单独引用同一张图片。同名替换 `assets/img/avatar.svg` 后，请同步更新配置和 README 中 `?v=` 后的版本标记（可使用日期或文件哈希前缀），让浏览器重新加载图片。这个参数不是文件名的一部分，无需创建带问号的文件。修改配置后需重启本地预览；线上需重新构建部署。网站 favicon 和分享预览图是独立配置，不会随头像自动替换。

当前用户主页必须保持：

```yaml
url: "https://sekirooox.github.io"
baseurl: ""
lang: zh-CN
timezone: Asia/Shanghai
```

`url` 末尾不加斜杠。用户主页的 `baseurl` 必须为空，工作流直接构建并上传 `_site`。如果以后改回项目站点，才需要将 `baseurl` 设置为仓库路径，并同步检查构建目录。

首页使用专用 `home-profile` 布局，只显示自我介绍和访客统计，不列出文章，也不生成 `/page2/`。文章仍可通过分类、标签、归档、搜索和直接链接访问。要改首页正文，编辑 `_includes/profile-intro.html`；要改布局或地图说明，分别编辑 `_layouts/home-profile.html` 和 `_includes/home-stats.html`。明暗模式默认跟随系统，可用 `theme_mode: light` 或 `dark` 指定初始偏好。

访客统计由部署工作流从 GoatCounter API 读取，Token 只保存在 `GOATCOUNTER_API_KEY` Secret 中。文章页不公开阅读次数；完整配置、统计口径、手动刷新与故障处理见 [`docs/ANALYTICS.md`](ANALYTICS.md)。

## 6. 新增、修改和删除文章

复制 `templates/post.md` 到 `_posts/YYYY/MM/YYYY-MM-DD-english-slug.md`。例如，
`2026-09-16-example.md` 应放在 `_posts/2026/09/`。Jekyll 会递归读取
`_posts`，年月目录只用于整理源文件，不会改变当前的 `/posts/:title/` 地址或文章分类。

```yaml
---
title: "一次 Python 学习记录"
date: 2026-09-26 00:00:00 +0800
description: 记录列表推导式的使用场景和一个练习。
categories: [技术, Python]
tags: [python, 学习笔记]
pin: false
math: false
mermaid: false
---
```

正文从 `##` 开始，页面会自动显示文章主标题。日期不要晚于当前时间，`+0800` 与站点时区保持一致。文件名日期与 Front Matter 日期应一致。

- 分类按数组顺序组成层级；标签可跨分类复用，建议拼写一致。
- 文章 URL 默认是 `/posts/english-slug/`；修改标题不会改变文件名对应的地址，改文件名则会。
- 改地址时用 `redirect_from: /posts/old-slug/` 保留入口。本仓库已为第一篇文章保留旧日期地址。
- 隐藏文章用 `published: false`，或移入 `_drafts/` 并去掉文件名日期；用 `--drafts` 本地查看草稿。
- 删除文章前搜索其他文章是否通过 `post_url` 引用了它，并同步移除引用，否则构建会失败。

示例文章：`welcome-to-chirpy` 测试置顶与内链；`markdown-playground` 测试排版；`math-and-diagrams` 测试公式和流程图。它们均可修改或删除；欢迎文章引用了另外两篇，删除时一起处理链接。

### 图片、内部链接与代码

图片放在 `assets/img/posts/文章名/`，引用时处理项目子路径：

```liquid
![描述](/assets/img/posts/example/screenshot.png)
[关于我]({{ '/about/' | relative_url }})
[另一篇文章]({% post_url 2026-09-25-welcome-to-chirpy %})
```

Chirpy 会对文章中的图片自动补上 `baseurl`，因此图片用 `/assets/...` 即可，不要再加 `relative_url`，否则路径会重复。普通页面链接仍使用 `relative_url`，文章互链使用 `post_url`。代码围栏注明 `python`、`bash`、`yaml` 等语言即可高亮。

## 7. 新增栏目与导航

### 只想增加一个内容主题

给文章加 `categories: [技术, 数据分析]` 或新标签即可。分类和标签页自动生成，无需创建页面。

### 增加一个独立侧栏页面

新建 `_tabs/projects.md`：

```markdown
---
title: 项目
icon: fas fa-code
order: 5
permalink: /projects/
---

## 我的项目

介绍项目背景、成果和链接。
```

`order` 决定排序；图标使用主题已加载的 Font Awesome 图标。自定义中文标题时明确写 `permalink`，避免地址随标题变化。现有 `categories`、`tags`、`archives` 有专用布局，保留各自 `layout`。

### 建立专题文章列表

可以在新栏目正文中使用 Liquid：

```liquid
{% for post in site.categories['技术'] %}
- [{{ post.title }}]({{ post.url | relative_url }})
{% endfor %}
```

若需要独立于博客的“作品集”集合，在 `_config.yml` 的 `collections` 下保留 `tabs`，新增 `projects: { output: true }`，并为该集合设置默认 `layout: page`、`permalink: /projects/:name/`。创建 `_projects/` 内容，再建 `_tabs/projects.md` 循环 `site.projects`。不要只创建集合却遗漏导航入口。

## 8. 功能开关与扩展

| 功能 | 修改位置 | 操作 |
| --- | --- | --- |
| 文章目录 | `toc` | 全局配置或文章单独设为 false |
| 数学公式 | 文章 `math: true` | 用 `$$` 包裹块级公式 |
| Mermaid | 文章 `mermaid: true` | 使用 mermaid 代码围栏 |
| RSS | `/feed.xml` | 自动生成，社交栏已启用 |
| 搜索 | 主题内置 | 新文章构建后自动进入索引 |
| 评论 | `comments` | 先配置服务，再启用 provider |
| 访问统计 | `analytics`、部署 Secret | 已启用全站 GoatCounter，首页公开构建时汇总 |
| PWA | `pwa` | 默认启用安装与离线缓存 |
| 社交入口 | `_data/contact.yml` | 新增 type、icon、url |
| 编辑文章按钮 | `actions.edit_post` | 启用后填写仓库 edit/main 地址 |

### Giscus 评论

在 GitHub 启用仓库 Discussions，通过 <https://giscus.app/zh-CN> 安装应用并选择讨论分类。把生成的 `repo`、`repo_id`、`category`、`category_id` 填入 `_config.yml` 的 `comments.giscus`，设置 `comments.provider: giscus`。ID 必须来自真实配置，不能猜。默认未开启评论，文章的 `comments: true` 本身不会启用服务。

### 样式与布局

优先改配置。确需改样式时，从当前安装的主题中复制 `assets/css/jekyll-theme-chirpy.scss` 到仓库同名位置，保留原始导入，再在文件末尾追加规则。不要直接修改 `vendor` 内文件，重装依赖会丢失。

布局、组件也可以从主题 gem 复制到本仓库同路径，例如 `_includes/`、`_layouts/`。覆盖越多，升级时需对照合并的地方越多。深度修改主题 JavaScript 时，应改用官方主题源码开发流程并构建前端资源；不要在 starter 随意添加未经编译的源码。

### 静态资源网络问题

当前采用官方默认 CDN 配置。图标、字体、公式和 Mermaid 等功能可能受网络影响。需要自托管时按 [官方静态资源仓库](https://github.com/cotes2020/chirpy-static-assets) 配置完整 `assets/lib`，再打开 `assets.self_host.enabled`；不要只打开开关而不下载资源。

## 9. 维护、升级与排错

升级主题时先建分支，调整 Gemfile 固定版本，运行 `bundle update jekyll-theme-chirpy`，对照新 starter 同步配置、插件和工作流。提交更新后的 lock 文件，在 PR 构建通过后再合并。Windows 更新 lock 时执行 `bundle lock --add-platform x86_64-linux`，确保 CI 可用。

常见情况：

- **首页 404**：确认仓库名精确为 `sekirooox.github.io`，核对 Pages Source、最新 deploy 及 `url/baseurl`。
- **文章不出现**：检查日期、时区、`published`、文件路径；时间到达后仍需触发新构建。
- **CSS 或图片 404**：确认 `baseurl` 为空，并检查资源链接没有残留旧仓库路径。
- **链接检查失败**：看 Test site 的具体文件和路径，修正链接，不要直接关闭检查。
- **Cancelled**：同分支新运行会取代旧任务，查看最新一次结果。
- **修改后显示旧内容**：等待部署成功，再硬刷新；仍有问题时在浏览器 Application → Service Workers 中注销旧服务工作线程并清理站点缓存。
- **原教程 workflow**：已移到 `docs/legacy-github-skills/*.disabled`，防止重新初始化并覆盖首页。

回滚使用 `git revert <变更提交>` 后推送，保留可追溯历史。上线前至少检查桌面与手机宽度下的导航、首页、文章目录和搜索。

## 10. 官方参考

- [Chirpy 主题源码](https://github.com/cotes2020/jekyll-theme-chirpy)
- [Chirpy Starter](https://github.com/cotes2020/chirpy-starter)
- [安装与部署](https://chirpy.cotes.page/posts/getting-started/)
- [写作说明](https://chirpy.cotes.page/posts/write-a-new-post/)
- [GitHub Pages 发布来源](https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site)
