---
title: "论文精读·The Alternative Annotator Test for LLM-as-a-Judge: How to Statistically Justify Replacing Huma"
author: MayL
date: 2025-09-26
categories: ["论文阅读与科研", "大模型评测"]
tags: ["大模型评测", "llm", "llm-as-a-judge", "论文阅读"]
render_with_liquid: false
description: "本文记录“论文精读·The Alternative An…”的研究问题、主要方法与实验结论，便于理解论文并开展后续研究。"
---

# The Alternative Annotator Test for LLM-as-a-Judge:  How to Statistically Justify Replacing Human Annotators with LLMs
>先前的研究用各种指标评估LLM评审和人类评审的区别，却**没有回答一个本质的问题**：**LLM评审能否取代人类评审员？什么时候可以认为取代？**这篇论文使用**简单统计学**的方法给出了答案。
+ 基准测试：提出了`alt-test`，用于确定什么时候LLM可以取代人类评审。
+ 实证分析：证明了LLM在一定情况下可以取代人类评审。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b985917b19d045d0a6b5733c50506ffe.png){: referrerpolicy="no-referrer" }
## 贡献点
+ 主要就是`alt-test`这个关键基准测试。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/91831520f9d947d096b8edc9c49ce022.png){: referrerpolicy="no-referrer" }

# 方法
+ 作者的主要思路如下：**最好的标准不可以获得**，因此认为一种常见的方法是**将LLM的评估结果与已有评估结果进行比较**，分布近似相等的就是好的评审。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b93cd9181f164bf7a1f7659cfa4ec18c.png){: referrerpolicy="no-referrer" }

+ 首先是有n个样本，m个人类评估者，一个LLM评审。依次排除每一个人类评估者，计算**一致分数S**，分别针对三种任务：**分类，回归，生成**任务进行了准确的定义。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3e79be0ed37c4ddf8982f920523d0979.png){: referrerpolicy="no-referrer" }
+ 优势分数：其实就是对于每一个样本，分别计算**LLM**和**被排除的人类评估者** 与**剩下评估者**的一致性分数，最后取平均/期望即可！
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/775c81c403a1422aa7c515bd22e8c33a.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/800ba262f56f4589a91d4c7775977a75.png){: referrerpolicy="no-referrer" }
+ 使用**假设检验和FDR**(用于减少假阳性激活)，统计针对每一个样本，LLM和被排除的人类评估者的**零假设拒绝次数**，取平均得到胜率(win)。
+ **如果胜率大于0.5，则认为LLM可以取代被排除的人类评估者**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/964bfab3a3d24624b125cd60a2477d36.png){: referrerpolicy="no-referrer" }
## 比较LLM评审
+ 胜率体现的东西有限，采用对于m个人类评估者分别排除后的**平均优势概率**，作为对比LLM评审的指标。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9cb98fba24674134b2e5f332d30831cb.png){: referrerpolicy="no-referrer" }

