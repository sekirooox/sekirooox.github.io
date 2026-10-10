<div align="center">

<img src="assets/img/avatar.svg?v=d3eb6bb2ca4f" width="112" height="112" alt="MayL 博客头像" />

# MayL 的博客

**记录技术、学习与生活。**

基于 Chirpy 的个人博客 · 中文界面 · 上海时区

[![Build and Deploy](https://github.com/sekirooox/sekirooox.github.io/actions/workflows/pages-deploy.yml/badge.svg)](https://github.com/sekirooox/sekirooox.github.io/actions/workflows/pages-deploy.yml)
[![Chirpy](https://img.shields.io/badge/Chirpy-7.6.0-7957d5)](https://github.com/cotes2020/jekyll-theme-chirpy)
[![GitHub Pages](https://img.shields.io/badge/Hosted_on-GitHub_Pages-222222?logo=github)](https://sekirooox.github.io/)

[访问博客](https://sekirooox.github.io/) · [维护手册](docs/MAINTENANCE.md) · [文章模板](templates/post.md) · [构建记录](https://github.com/sekirooox/sekirooox.github.io/actions)

</div>

---

## 关于这个项目

你好，我是 **MayL**。首页用于自我介绍并展示匿名汇总的访客足迹；技术实践、学习笔记和生活随笔可从归档、分类、标签或搜索进入。

项目从 GitHub Skills 的 GitHub Pages 练习起步，目前使用官方 **Chirpy 7.6.0** 主题，通过 GitHub Actions 构建和发布。主题提供响应式布局、明暗模式、站内搜索、分类与标签、文章目录、数学公式、Mermaid 流程图和 RSS。

## 快速开始

### 本地预览

选择适合自己的环境：

| 环境 | 启动方式 |
| --- | --- |
| Docker Desktop | 启动 Docker 后运行 `docker compose up --build` |
| Ruby 3.4.11 | 运行 `bundle install`，然后运行 `bundle exec jekyll serve --livereload` |
| Windows PowerShell | 已有 Ruby 或本机便携环境时运行 `./tools/preview.ps1` |
| VS Code / Codespaces | 使用仓库 Dev Container，初始化后运行 `bash tools/serve.sh` |

预览地址：**<http://localhost:4000/>**。

修改 `_config.yml` 后需要重启预览。完整的环境配置与排错步骤见[维护手册](docs/MAINTENANCE.md)。

### 发布到 GitHub Pages

1. 在仓库 **Settings → Pages → Build and deployment → Source** 中选择 **GitHub Actions**。
2. 检查变更范围，只暂存和提交需要发布的文件，然后推送到 `main`。
3. 在 Actions 中查看 **Build and Deploy**；构建和内部链接检查通过后自动部署。
4. 打开[线上博客](https://sekirooox.github.io/)检查结果。

> Pull Request 只执行构建检查。部署仅限 `main` 的推送或在 `main` 上手动运行。仅修改 README 不会触发部署。

## 写作与维护

| 想做什么 | 从哪里开始 |
| --- | --- |
| 新增文章 | 复制 [文章模板](templates/post.md) 到 `_posts/YYYY/MM/YYYY-MM-DD-english-slug.md` |
| 修改站点名称、简介、时区 | 编辑 [`_config.yml`](_config.yml) |
| 修改首页简短介绍 | 编辑 [`_includes/profile-intro.html`](_includes/profile-intro.html) |
| 修改完整个人介绍 | 编辑 [`_tabs/about.md`](_tabs/about.md) |
| 新增独立栏目 | 在 `_tabs/` 中创建页面，设置 `title`、`icon`、`order` 和 `permalink` |
| 增加分类或标签 | 修改文章 Front Matter 中的 `categories`、`tags`，页面自动生成 |
| 添加图片 | 放入 `assets/img/`，文章图片使用 `/assets/img/...` 路径 |
| 启用公式或流程图 | 在文章 Front Matter 中设置 `math: true` 或 `mermaid: true` |
| 配置评论、统计或定制样式 | 按[维护手册](docs/MAINTENANCE.md)中的功能扩展说明操作 |

文章日期请带上 `+0800`，避免未来日期被过滤。Chirpy 会自动为文章图片补上项目路径；普通页面链接使用 `relative_url`。

仓库保留了第一篇 `MyFirstBlog`，并提供三篇操作示例：

- [博客入门](./_posts/2026/09/2026-09-25-welcome-to-chirpy.md)：置顶、导航和文章互链。
- [Markdown 排版](./_posts/2026/09/2026-09-24-markdown-playground.md)：代码、表格、提示块和图片。
- [公式与流程图](./_posts/2026/09/2026-09-23-math-and-diagrams.md)：数学公式与 Mermaid。

示例可按需修改或删除；删除前请一并处理其他文章对它的引用。

## 项目结构

```text
.
├── _config.yml                 站点配置与功能开关
├── _posts/YYYY/MM/             按年月分组的博客文章
├── _tabs/                      分类、标签、归档、关于等栏目
├── _data/                      社交链接与访客统计回退数据
├── _includes/                  首页介绍、统计地图和主题扩展钩子
├── _layouts/home-profile.html  独立个人首页布局
├── _plugins/                   文章更新时间插件
├── assets/img/                 头像与文章图片
├── templates/post.md           文章模板
├── docs/                       维护手册、验证记录与归档资料
├── tools/                      本地预览、检查和统计抓取脚本
├── test/                       统计解析测试与 PR 布局数据
├── .github/workflows/          GitHub Pages 构建发布流程
├── .devcontainer/              VS Code / Codespaces 环境
├── Gemfile / Gemfile.lock      主题与锁定的 Ruby 依赖
├── .ruby-version               Ruby 版本
├── Dockerfile                  容器定义
├── docker-compose.yml          本地容器预览配置
└── index.html                  独立个人首页入口及旧地址跳转
```

主题布局和样式由 gem 提供。`_site/` 是构建产物，`.tools/`、`vendor/`、`.bundle/` 是本地环境目录，不应提交。独立笔记目录 `csdn-repo/` 已从站点构建范围排除。

GoatCounter 在生产环境跟踪全站，但文章页不公开阅读次数。首页的累计访问与国家分布只在发布时更新；API Token 配置、数据口径和排错见[统计维护说明](docs/ANALYTICS.md)。

原 GitHub Skills 教程工作流归档于 `docs/legacy-github-skills/`，不会再触发初始化或覆盖首页。

## 构建检查

在 Linux 或开发容器中运行：

```sh
bash tools/test.sh
```

脚本执行生产构建，并检查生成页面的内部链接、图片与脚本引用。浏览器中的搜索、主题切换和移动端布局仍需实际检查。

- [完整使用与维护手册](docs/MAINTENANCE.md)：环境、部署、项目结构、写作、栏目扩展、升级与排错。
- [迁移验证记录](docs/VERIFICATION.md)：本次迁移已完成的检查及验证边界。

## 致谢与许可

感谢 [Chirpy](https://github.com/cotes2020/jekyll-theme-chirpy)、[Chirpy Starter](https://github.com/cotes2020/chirpy-starter) 和 [GitHub Skills](https://skills.github.com)。

原项目许可保留于 [LICENSE](LICENSE)，主题与 starter 的许可说明见 [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)。
