---
title: 撰写新文章
author: cotes
date: 2019-08-08 14:10:00 +0800
categories: [教程]
tags: [chirpy, jekyll, markdown, 写作, front-matter, 多媒体]
render_with_liquid: false
description: jekyll基于Kramdown, 有许多独特的语法. 本教程将介绍如何在 _Chirpy_ 模板中撰写文章。即使你以前使用过 Jekyll，也值得阅读，因为许多功能需要设置特定变量才能使用。
---


Kramdown
## 命名与路径

新建一个名为 `YYYY-MM-DD-TITLE.EXTENSION`{: .filepath} 的文件，并将其放在根目录下的 `_posts`{: .filepath} 目录中。请注意，`EXTENSION`{: .filepath} 必须为 `md`{: .filepath} 或 `markdown`{: .filepath}。如果希望节省创建文件的时间，可以考虑使用 [`Jekyll-Compose`](https://github.com/jekyll/jekyll-compose) 插件。

## 前置元数据（Front Matter）

通常，需要在文章顶部按如下方式填写 [Front Matter](https://jekyllrb.com/docs/front-matter/)（前置元数据）：

```yaml
---
title: TITLE
date: YYYY-MM-DD HH:MM:SS +/-TTTT
categories: [TOP_CATEGORY, SUB_CATEGORY]
tags: [TAG]     # TAG names should always be lowercase
---
```

> 文章的 _layout_ 默认已设置为 `post`，因此无需在 Front Matter 中添加 _layout_ 变量。
{: .prompt-tip }

### 日期时区

为了准确记录文章的发布日期，除了在 `_config.yml`{: .filepath} 中设置 `timezone`，还应在文章 Front Matter 的 `date` 变量中注明时区。格式为 `+/-TTTT`，例如 `+0800`。

### 分类与标签

每篇文章的 `categories` 设计为**最多包含两个元素**，而 `tags` 的元素数量可以为零，也**可以有任意多个**。例如：

```yaml
---
categories: [Animal, Insect]
tags: [bee]
---
```

### 作者信息

通常无需在 _Front Matter_ 中填写文章作者信息，默认会从配置文件的 `social.name` 变量和 `social.links` 的第一项读取。不过，你也可以按以下方式覆盖默认值：

在 `_data/authors.yml` 中添加作者信息（如果网站还没有这个文件，直接创建即可）。

```yaml
<author_id>:
  name: <full name>
  twitter: <twitter_of_author>
  url: <homepage_of_author>
```
{: file="_data/authors.yml" }

然后使用 `author` 指定单个作者，或使用 `authors` 指定多个作者：

```yaml
---
author: <author_id>                     # for single entry
# or
authors: [<author1_id>, <author2_id>]   # for multiple entries
---
```

不过，`author` 键同样可以指定多个作者。

> 从 `_data/authors.yml`{: .filepath } 文件读取作者信息的好处是，页面会包含 `twitter:creator` 元标签，从而丰富 [Twitter Cards](https://developer.twitter.com/en/docs/twitter-for-websites/cards/guides/getting-started#card-and-content-attribution) 的信息，并有利于 SEO。
{: .prompt-info }

### 文章摘要

默认情况下，文章开头的文字会作为摘要，显示在首页文章列表、_相关文章_区域以及 RSS 订阅的 XML 中。如果不想使用自动生成的摘要，可以通过 _Front Matter_ 中的 `description` 字段自定义，如下所示：

```yaml
---
description: Short summary of the post.
---
```

此外，`description` 文本也会显示在文章页面的标题下方。

## 文章目录

默认情况下，文章目录（**T**able **o**f **C**ontents，TOC）显示在文章右侧面板中。如果希望全局关闭，请在 `_config.yml`{: .filepath} 中将 `toc` 变量设为 `false`。如果只想关闭某篇文章的目录，在该文章的 [Front Matter](https://jekyllrb.com/docs/front-matter/) 中添加以下内容：

```yaml
---
toc: false
---
```

## 评论

评论的全局设置由 `_config.yml`{: .filepath} 文件中的 `comments.provider` 选项定义。一旦为该变量指定了评论系统，所有文章都会启用评论。

如果想关闭某篇文章的评论，在该文章的 **Front Matter** 中添加以下内容：

```yaml
---
comments: false
---
```

## 媒体资源

在 _Chirpy_ 中，图片、音频和视频统称为媒体资源。

### URL 前缀
{: #url-prefix }

有时需要为文章中的多个资源重复填写相同的 URL 前缀，这是一项繁琐的工作。通过设置两个参数，可以避免这种重复操作。

- 如果使用 CDN 托管媒体文件，可以在 `_config.yml`{: .filepath } 中指定 `cdn`。这样，站点头像和文章媒体资源的 URL 都会加上 CDN 域名前缀。

  ```yaml
  cdn: https://cdn.com
  ```
  {: file='_config.yml' .nolineno }

- 如果要为当前文章或页面指定资源路径前缀，在文章的 _Front Matter_ 中设置 `media_subpath`：

  ```yaml
  ---
  media_subpath: /path/to/media/
  ---
  ```
  {: .nolineno }

`site.cdn` 和 `page.media_subpath` 既可以单独使用，也可以组合使用，从而灵活构成最终的资源 URL：`[site.cdn/][page.media_subpath/]file.ext`

### 图片

#### 图片说明

在图片的**下一行添加斜体文字**，它就会作为图片说明显示在图片下方：

```markdown
![img-description](/path/to/image)
_Image Caption_
```
{: .nolineno}

#### 尺寸

为了防止图片加载时页面内容发生位移，应为每张图片设置宽度和高度。

```markdown
![Desktop View](/assets/img/sample/mockup.png){: width="700" height="400" }
```
{: .nolineno}

> 对于 SVG，至少需要指定_宽度_，否则无法渲染。
{: .prompt-info }

从 _Chirpy v5.0.0_ 开始，`height` 和 `width` 支持缩写（`height` → `h`，`width` → `w`）。下面的示例与上面的效果相同：

```markdown
![Desktop View](/assets/img/sample/mockup.png){: w="700" h="400" }
```
{: .nolineno}

#### 位置

默认情况下，图片居中显示，但可以通过 `normal`、`left` 或 `right` 类来指定位置。

> 一旦指定了位置，就不应再添加图片说明。
{: .prompt-warning }

- **普通位置**

  在下面的示例中，图片将左对齐：

  ```markdown
  ![Desktop View](/assets/img/sample/mockup.png){: .normal }
  ```
  {: .nolineno}

- **向左浮动**

  ```markdown
  ![Desktop View](/assets/img/sample/mockup.png){: .left }
  ```
  {: .nolineno}

- **向右浮动**

  ```markdown
  ![Desktop View](/assets/img/sample/mockup.png){: .right }
  ```
  {: .nolineno}

#### 深浅色模式

你可以让图片**随主题偏好切换深浅色模式**。为此，需要准备两张图片，一张用于深色模式，另一张用于浅色模式，然后分别指定对应的类（`dark` 或 `light`）：

```markdown
![Light mode only](/path/to/light-mode.png){: .light }
![Dark mode only](/path/to/dark-mode.png){: .dark }
```

#### 阴影

对于程序窗口截图，可以考虑添加阴影效果：

```markdown
![Desktop View](/assets/img/sample/mockup.png){: .shadow }
```
{: .nolineno}

#### 预览图

如果希望**在文章顶部添加图片**，请提供一张分辨率为 `1200 x 630` 的图片。请注意，如果图片宽高比不符合 `1.91 : 1`，图片将被缩放和裁剪。

了解这些前提后，就可以开始设置图片属性：

```yaml
---
image:
  path: /path/to/image
  alt: image alternative text
---
```

请注意，[`media_subpath`](#url-prefix) 同样适用于预览图。也就是说，设置该参数后，`path` 属性只需填写图片文件名。

为了简化写法，也可以直接用 `image` 定义路径。

```yml
---
image: /path/to/image
---
```

#### LQIP

对于预览图：

```yaml
---
image:
  lqip: /path/to/lqip-file # or base64 URI
---
```

> 可以在《[文本与排版](../text-and-typography/)》一文的预览图中观察 LQIP 效果。

对于普通图片：

```markdown
![Image description](/path/to/image){: lqip="/path/to/lqip-file" }
```
{: .nolineno }

### 社交媒体平台

可以使用以下语法嵌入社交媒体平台的视频或音频：

```liquid
{% include embed/{Platform}.html id='{ID}' %}
```

其中，`Platform` 是平台名称的小写形式，`ID` 是视频 ID。

下表展示了如何从给定的视频或音频 URL 中获取所需的两个参数，同时列出了当前支持的平台。

| 视频 URL                                                                                                                   | 平台       | ID                       |
| -------------------------------------------------------------------------------------------------------------------------- | ---------- | :----------------------- |
| [https://www.**youtube**.com/watch?v=**H-B46URT4mg**](https://www.youtube.com/watch?v=H-B46URT4mg)                         | `youtube`  | `H-B46URT4mg`            |
| [https://www.**twitch**.tv/videos/**1634779211**](https://www.twitch.tv/videos/1634779211)                                 | `twitch`   | `1634779211`             |
| [https://www.**bilibili**.com/video/**BV1Q44y1B7Wf**](https://www.bilibili.com/video/BV1Q44y1B7Wf)                         | `bilibili` | `BV1Q44y1B7Wf`           |
| [https://www.open.**spotify**.com/track/**3OuMIIFP5TxM8tLXMWYPGV**](https://open.spotify.com/track/3OuMIIFP5TxM8tLXMWYPGV) | `spotify`  | `3OuMIIFP5TxM8tLXMWYPGV` |

Spotify 还支持一些附加参数：

- `compact` — 显示紧凑型播放器（例如 `{% include embed/spotify.html id='3OuMIIFP5TxM8tLXMWYPGV' compact=1 %}`）；
- `dark` — 强制使用深色主题（例如 `{% include embed/spotify.html id='3OuMIIFP5TxM8tLXMWYPGV' dark=1 %}`）。

### 视频文件

如果想直接嵌入视频文件，使用以下语法：

```liquid
{% include embed/video.html src='{URL}' %}
```

其中，`URL` 是视频文件的地址，例如 `/path/to/sample/video.mp4`。

还可以为嵌入的视频文件指定附加属性。以下是支持的完整属性列表。

- `poster='/path/to/poster.png'` — 视频下载时显示的封面图片
- `title='Text'` — 显示在视频下方的标题，样式与图片说明相同
- `autoplay=true` — 视频具备播放条件后自动开始播放
- `loop=true` — 视频结束后自动回到开头循环播放
- `muted=true` — 初始状态为静音
- `types` — 指定其他视频格式的扩展名，用 `|` 分隔。请确保这些文件与主要视频文件位于同一目录。

下面的示例使用了上述所有属性：

```liquid
{%
  include embed/video.html
  src='/path/to/video.mp4'
  types='ogg|mov'
  poster='poster.png'
  title='Demo video'
  autoplay=true
  loop=true
  muted=true
%}
```

### 音频文件

如果想直接嵌入音频文件，使用以下语法：

```liquid
{% include embed/audio.html src='{URL}' %}
```

其中，`URL` 是音频文件的地址，例如 `/path/to/audio.mp3`。

还可以为嵌入的音频文件指定附加属性。以下是支持的完整属性列表。

- `title='Text'` — 显示在音频下方的标题，样式与图片说明相同
- `types` — 指定其他音频格式的扩展名，用 `|` 分隔。请确保这些文件与主要音频文件位于同一目录。

下面的示例使用了上述所有属性：

```liquid
{%
  include embed/audio.html
  src='/path/to/audio.mp3'
  types='ogg|wav|aac'
  title='Demo audio'
%}
```

## 置顶文章

可以将一篇或多篇文章置顶到首页，置顶文章按发布日期倒序排列。通过以下设置启用：

```yaml
---
pin: true
---
```

## 提示块

提示块有 `tip`、`info`、`warning` 和 `danger` 几种类型。向引用块添加 `prompt-{type}` 类即可生成相应提示。例如，以下方式定义了一个 `info` 类型的提示：

```md
> Example line for prompt.
{: .prompt-info }
```
{: .nolineno }

## 语法

### 行内代码

```md
`inline code part`
```
{: .nolineno }

### 文件路径高亮

```md
`/path/to/a/file.extend`{: .filepath}
```
{: .nolineno }

### 代码块

使用 Markdown 符号 ```` ``` ```` 可以轻松创建代码块，如下所示：

````md
```
This is a plaintext code snippet.
```
````

#### 指定语言

使用 ```` ```{language} ```` 即可获得带语法高亮的代码块：

````markdown
```yaml
key: value
```
````

> Jekyll 的 `{% highlight %}` 标签与本主题不兼容。
{: .prompt-danger }

#### 行号

默认情况下，除 `plaintext`、`console` 和 `terminal` 外，所有语言的代码块都会显示行号。如果想隐藏某个代码块的行号，为它添加 `nolineno` 类：

````markdown
```shell
echo 'No more line numbers!'
```
{: .nolineno }
````

#### 指定文件名

你可能已经注意到，代码块顶部会显示代码语言。如果想将其替换为文件名，可以添加 `file` 属性：

````markdown
```shell
# content
```
{: file="path/to/file" }
````

#### Liquid 代码

如果想展示 **Liquid** 代码片段，请使用 `{% raw %}` 和 `{% endraw %}` 包裹 Liquid 代码：

````markdown
{% raw %}
```liquid
{% if product.title contains 'Pack' %}
  This product's title contains the word Pack.
{% endif %}
```
{% endraw %}
````

也可以在文章的 YAML 区块中添加 `render_with_liquid: false`（需要 Jekyll 4.0 或更高版本）。

## 数学公式

我们使用 [**MathJax**][mathjax] 生成数学公式。出于网站性能考虑，默认不会加载数学功能，但可以通过以下设置启用：

[mathjax]: https://www.mathjax.org/

```yaml
---
math: true
---
```

启用数学功能后，可以使用以下语法添加数学公式：

- **块级公式**应使用 `$$ math $$`，并且在 `$$` 前后**必须**保留空行
  - **插入公式编号**应使用 `$$\begin{equation} math \end{equation}$$`
  - **引用公式编号**时，在公式块内使用 `\label{eq:label_name}`，并在正文中使用 `\eqref{eq:label_name}`（见下方示例）
- **行内公式**（正文中）应使用 `$$ math $$`，且 `$$` 前后不要留空行
- **行内公式**（列表中）应使用 `\$$ math $$`

```markdown
<!-- Block math, keep all blank lines -->

$$
LaTeX_math_expression
$$

<!-- Equation numbering, keep all blank lines  -->

$$
\begin{equation}
  LaTeX_math_expression
  \label{eq:label_name}
\end{equation}
$$

Can be referenced as \eqref{eq:label_name}.

<!-- Inline math in lines, NO blank lines -->

"Lorem ipsum dolor sit amet, $$ LaTeX_math_expression $$ consectetur adipiscing elit."

<!-- Inline math in lists, escape the first `$` -->

1. \$$ LaTeX_math_expression $$
2. \$$ LaTeX_math_expression $$
3. \$$ LaTeX_math_expression $$
```

> 从 `v7.0.0` 开始，**MathJax** 的配置选项已移至 `assets/js/data/mathjax.js`{: .filepath } 文件。可以根据需要修改这些选项，例如添加[扩展][mathjax-exts]。  
> 如果通过 `chirpy-starter` 构建站点，请将该文件从 gem 安装目录（可用 `bundle info --path jekyll-theme-chirpy` 命令查看）复制到仓库中的相同目录。
{: .prompt-tip }

[mathjax-exts]: https://docs.mathjax.org/en/latest/input/tex/extensions/index.html

## Mermaid

[**Mermaid**](https://github.com/mermaid-js/mermaid) 是一款出色的图表生成工具。若要在文章中启用，请在 YAML 区块中添加以下内容：

```yaml
---
mermaid: true
---
```

然后就可以像使用其他 Markdown 代码语言一样，使用 ```` ```mermaid ```` 和 ```` ``` ```` 包裹图表代码。

## 了解更多

如需了解更多 Jekyll 文章相关知识，请访问 [Jekyll 文档：文章](https://jekyllrb.com/docs/posts/)。
