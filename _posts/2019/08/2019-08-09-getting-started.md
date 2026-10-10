---
title: 入门指南
description: >-
  本指南全面介绍 Chirpy 的基础知识。
  你将学习如何安装、配置和使用第一个基于 Chirpy 的网站，以及如何将它部署到 Web 服务器。
author: cotes
date: 2019-08-09 20:55:00 +0800
categories: [教程]
tags: [chirpy, jekyll, 入门, 环境配置, github-pages, 部署]
pin: false
media_subpath: 'https://chirpy-img.netlify.app/posts/20180809'
---

## 创建站点仓库

创建站点仓库时，你可以根据需要选择以下两种方式：

### 方式一：使用 Starter（推荐）

这种方式简化了升级流程，隔离了不必要的文件，非常适合希望通过最少配置专注于写作的用户。

1. 登录 GitHub，打开 [**starter**][starter]。
2. 点击 <kbd>Use this template</kbd>（使用此模板）按钮，然后选择 <kbd>Create a new repository</kbd>（创建新仓库）。
3. 将新仓库命名为 `<username>.github.io`，其中 `username` 替换为你的 GitHub 用户名，使用小写字母。

### 方式二：Fork 主题

这种方式便于修改功能或界面设计，但升级时会遇到一些困难。因此，除非你熟悉 Jekyll，并计划对主题进行较大改动，否则不建议尝试。

1. 登录 GitHub。
2. [Fork 主题仓库](https://github.com/cotes2020/jekyll-theme-chirpy/fork)。
3. 将新仓库命名为 `<username>.github.io`，其中 `username` 替换为你的 GitHub 用户名，使用小写字母。

## 配置环境

创建仓库后，就可以配置开发环境了。主要有以下两种方式：

### 使用开发容器（Windows 推荐）

开发容器通过 Docker 提供隔离环境，避免与系统发生冲突，并确保所有依赖都在容器内管理。

**步骤**：

1. 安装 Docker：
   - Windows/macOS：安装 [Docker Desktop][docker-desktop]。
   - Linux：安装 [Docker Engine][docker-engine]。
2. 安装 [VS Code][vscode] 和 [Dev Containers 扩展][dev-containers]。
3. 克隆仓库：
   - 使用 Docker Desktop：启动 VS Code，[将仓库克隆到容器卷中][dc-clone-in-vol]。
   - 使用 Docker Engine：将仓库克隆到本地，然后通过 VS Code [在容器中打开][dc-open-in-container]。
4. 等待开发容器配置完成。

### 配置原生环境（类 Unix 系统推荐）

在类 Unix 系统上，可以配置原生环境以获得最佳性能，也可以选择使用开发容器。

**步骤**：

1. 按照 [Jekyll 安装指南](https://jekyllrb.com/docs/installation/)安装 Jekyll，并确保已安装 [Git](https://git-scm.com/)。
2. 将仓库克隆到本机。
3. 如果你 Fork 了主题，请安装 [Node.js][nodejs]，并在根目录运行 `bash tools/init.sh` 初始化仓库。
4. 在仓库根目录运行 `bundle install` 安装依赖。

## 使用

### 启动 Jekyll 服务器

使用以下命令在本地运行站点：

```terminal
$ bundle exec jekyll serve
```

> 如果使用开发容器，必须在 **VS Code** 的终端中运行该命令。
{: .prompt-info }

几秒钟后，即可通过 <http://127.0.0.1:4000> 访问本地服务器。

### 配置

根据需要修改 `_config.yml`{: .filepath} 中的变量。常用选项包括：

- `url`
- `avatar`
- `timezone`
- `lang`

### 社交联系方式

社交联系方式显示在侧栏底部。你可以在 `_data/contact.yml`{: .filepath} 文件中启用或禁用特定联系方式。

### 自定义样式表

若要自定义样式表，将主题中的 `assets/css/jekyll-theme-chirpy.scss`{: .filepath} 文件复制到 Jekyll 站点的相同路径，并在文件末尾添加自定义样式。

### 自定义静态资源

静态资源配置自 `5.1.0` 版本引入。静态资源的 CDN 定义在 `_data/origin/cors.yml`{: .filepath } 中。你可以根据网站发布地区的网络状况替换其中的部分资源。

如果希望自行托管静态资源，请参考 [_chirpy-static-assets_](https://github.com/cotes2020/chirpy-static-assets#readme) 仓库。

## 部署

部署前，请检查 `_config.yml`{: .filepath} 文件，确保 `url` 配置正确。如果使用[**项目站点**](https://help.github.com/en/github/working-with-github-pages/about-github-pages#types-of-github-pages-sites)且不使用自定义域名，或者希望在 **GitHub Pages** 以外的 Web 服务器上通过基础路径访问网站，请记得将 `baseurl` 设置为以斜杠开头的项目名称，例如 `/project-name`。

现在，你可以从以下方式中选择_一种_来部署 Jekyll 站点。

### 使用 GitHub Actions 部署

请做好以下准备：

- 如果使用 GitHub Free 计划，请将站点仓库保持为公开状态。
- 如果已将 `Gemfile.lock`{: .filepath} 提交到仓库，且本机运行的不是 Linux，请更新锁定文件中的平台列表：

  ```console
  $ bundle lock --add-platform x86_64-linux
  ```

接下来，配置 _Pages_ 服务：

1. 打开 GitHub 上的仓库，选择 _Settings_（设置）选项卡，然后点击左侧导航栏中的 _Pages_。在 _Build and deployment_（构建和部署）下的 **Source**（来源）部分，从下拉菜单中选择 [**GitHub Actions**][pages-workflow-src]。  
   ![构建来源](pages-source-light.png){: .light .border .normal w='375' h='140' }
   ![构建来源](pages-source-dark.png){: .dark .normal w='375' h='140' }

2. 向 GitHub 推送提交以触发 _Actions_ 工作流。在仓库的 _Actions_ 选项卡中，应能看到 _Build and Deploy_ 工作流正在运行。构建成功完成后，站点会自动部署。

现在，你可以通过 GitHub 提供的 URL 访问站点。

### 手动构建与部署

如果使用自托管服务器，需要先在本机构建站点，再将站点文件上传到服务器。

进入源项目的根目录，使用以下命令构建站点：

```console
$ JEKYLL_ENV=production bundle exec jekyll b
```

除非指定了输出路径，否则生成的站点文件会放在项目根目录的 `_site`{: .filepath} 文件夹中。将这些文件上传到目标服务器即可。

[nodejs]: https://nodejs.org/
[starter]: https://github.com/cotes2020/chirpy-starter
[pages-workflow-src]: https://docs.github.com/en/pages/getting-started-with-github-pages/configuring-a-publishing-source-for-your-github-pages-site#publishing-with-a-custom-github-actions-workflow
[docker-desktop]: https://www.docker.com/products/docker-desktop/
[docker-engine]: https://docs.docker.com/engine/install/
[vscode]: https://code.visualstudio.com/
[dev-containers]: https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers
[dc-clone-in-vol]: https://code.visualstudio.com/docs/devcontainers/containers#_quick-start-open-a-git-repository-or-github-pr-in-an-isolated-container-volume
[dc-open-in-container]: https://code.visualstudio.com/docs/devcontainers/containers#_quick-start-open-an-existing-folder-in-a-container
