---
title: "写作练习：Markdown、代码与图片"
date: 2026-09-24 20:00:00 +0800
description: 测试标题目录、代码高亮、表格、提示块、图片和任务列表。
categories: [教程]
tags: [markdown, 示例]
---

这是一篇排版测试文章，可以用作日常笔记的起点。

## 代码高亮

```python
def greet(name: str) -> str:
    return f"你好，{name}！"

print(greet("MayL"))
```

## 表格与任务

| 元素 | 用途                     |
| :--- | :----------------------- |
| 分类 | 建立有层级的主题目录     |
| 标签 | 跨主题检索关键词         |
| 摘要 | 首页卡片和搜索结果的介绍 |

- [x] 创建文章
- [x] 添加分类和标签
- [ ] 将示例改成自己的内容

## 图片

![博客头像](/assets/img/avatar.svg){: width="160" height="160" }
_图片保存在仓库中，Chirpy 会自动补上项目路径。_

## 提示与引用

> 重要步骤可以写成提示块，让读者更容易找到。
{: .prompt-info }

> 草稿预览可以使用 `bundle exec jekyll serve --drafts`；草稿不会默认发布。
{: .prompt-warning }

普通引用适合记录一句想法：

> 持续记录，让经验可以复用。
