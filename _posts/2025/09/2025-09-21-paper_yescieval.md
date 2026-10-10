---
title: "论文精读·YESciEval: Robust LLM-as-a-Judge for Scientific Question Answering"
author: MayL
date: 2025-09-21
categories: ["论文阅读与科研", "大模型评测"]
tags: ["大模型评测", "llm", "llm-as-a-judge", "论文阅读"]
render_with_liquid: false
description: "本文记录“论文精读·YESciEval: Robust…”的研究问题、主要方法与实验结论，便于理解论文并开展后续研究。"
---

# YESciEval: Robust LLM-as-a-Judge for Scientific Question Answering
>ACL 2025
## 动机
+ 领域：**科学问答(QA)评估**的**鲁棒性**和**评估基准**。
+ **科学问答领域评估**的基准缺失，其对抗鲁棒性尚未被充分探索

## 创新点
### 制作一个全新的数据集，包括原有的**良性问答**，**作者合成的对抗性问答**。
+ 基于两个已有的数据集，按照任务的定义来合成新的数据集。
+ 不是数据集中的所有内容都拿来用，而是**1个问题对应N个参考文献**的形式筛选其中的合格样本。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/78e1f64efa9d4087b41fb74690b5d08b.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/061b904bf26c43439a854f195f367a11.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/28d302d9eab74f4a8f0570d49f9893e2.png){: referrerpolicy="no-referrer" }
+ 制作对抗性数据集，分别针对9个指标进行不同的对抗扰动。对抗攻击的程度从**轻微subtle到极端extreme**，以此获得低质量的文本，旨在探索LLM对于不同质量文本的敏感程度(**会不会过分乐观**，**能否判断好回答和坏回答**)。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/dae5cfc54a26493d977f40918bf93d48.png){: referrerpolicy="no-referrer" }



### 科学问答方面的基准测试：
+ 从3个方面，9个指标来评估问答的质量。具体流程是**4个LLM生成答案，4个LLM作为评审评估回答质量**。
+ **任务定义：**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/fa8196580b3d4b489ab6a3665f888455.png){: referrerpolicy="no-referrer" }
+ **3个方面，9个指标：**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8782ca21aacf4476b9e1776183ae1e29.png){: referrerpolicy="no-referrer" }
### 全新的对齐方法
+ 包括先进行有监督微调，然后使用CPO技术进行强化学习上的微调。
+ 有监督微调的数据只有良性，会导致LLM出现**乐观偏差**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/71c209a2f756486ebf606eee289ca96c.png){: referrerpolicy="no-referrer" }

+ CPO技术采用良性+对抗性数据，确保**不会过分乐观或者悲观。**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5820a655ef3e4abdb137741c88bedd67.png){: referrerpolicy="no-referrer" }



