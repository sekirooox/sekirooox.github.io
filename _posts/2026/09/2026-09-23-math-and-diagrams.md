---
title: "技术笔记示例：公式与 Mermaid 流程图"
date: 2026-09-23 20:00:00 +0800
description: 展示 Chirpy 的数学公式与流程图，并解释如何按文章启用。
categories: [教程]
tags: [数学, mermaid, 示例]
math: true
mermaid: true
---

这篇文章在 Front Matter 中启用了 `math: true` 和 `mermaid: true`。

## 数学公式

平方和展开：

$$
(a+b)^2 = a^2 + 2ab + b^2
$$

公式用于解释推导过程。没有数学内容的文章可以省略 `math`。

## 发布流程

```mermaid
flowchart LR
    A[编写 Markdown] --> B[本地预览]
    B --> C[提交到 main]
    C --> D[Jekyll 构建]
    D --> E[内部链接检查]
    E --> F[GitHub Pages 发布]
```

## 操作练习

把“本地预览”节点改成自己的步骤，再刷新页面。Mermaid 由浏览器渲染，需要加载相应脚本；如果图表没有出现，先检查网络和浏览器控制台。
