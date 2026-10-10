---
title: 自定义网站图标
author: cotes
date: 2019-08-11 00:34:00 +0800
categories: [教程]
tags: [chirpy, favicon, 网站图标, 主题定制]
---

[**Chirpy**](https://github.com/cotes2020/jekyll-theme-chirpy/) 的[网站图标（favicon）](https://www.favicon-generator.org/about/)位于 `assets/img/favicons/`{: .filepath} 目录中。你可能希望将它们替换为自己的图标。下面将介绍如何创建图标并替换默认图标。

## 生成网站图标

准备一张尺寸为 512x512 或更大的正方形图片（PNG、JPG 或 SVG），然后打开在线工具 [**Real Favicon Generator**](https://realfavicongenerator.net/)，点击 <kbd>Pick your favicon image</kbd>（选择网站图标图片）按钮上传图片文件。

下一步，网页会展示所有使用场景。你可以保留默认选项，滚动到页面底部，点击 <kbd>Next →</kbd>（下一步）按钮生成网站图标。

## 下载与替换

下载生成的压缩包并解压，然后从解压后的文件中删除以下文件：

- `site.webmanifest`{: .filepath}

接着，将剩余的图片文件（`.PNG`{: .filepath}、`.ICO`{: .filepath} 和 `.SVG`{: .filepath}）复制到 Jekyll 站点的 `assets/img/favicons/`{: .filepath} 目录，覆盖原有文件。如果站点还没有这个目录，创建它即可。

下表说明了如何处理网站图标文件：

| 文件 | 来自在线工具 | 来自 Chirpy |
| ------- | :--------------: | :---------: |
| `*.PNG` |        ✓         |      ✗      |
| `*.ICO` |        ✓         |      ✗      |
| `*.SVG` |        ✓         |      ✗      |


<!-- markdownlint-disable-next-line -->
>  ✓ 表示保留，✗ 表示删除。
{: .prompt-info }

下次构建站点时，网站图标就会替换为自定义版本。
