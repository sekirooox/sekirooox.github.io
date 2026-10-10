---
title: "论文精读·An Empirical Study of LLM-as-a-Judge for LLM Evaluation: Fine-tuned Judge Model is not a Gener"
author: MayL
date: 2025-09-22
categories: ["论文阅读与科研", "大模型评测"]
tags: ["大模型评测", "llm", "llm-as-a-judge", "模型微调"]
render_with_liquid: false
description: "本文记录“论文精读·An Empirical Study…”的研究问题、主要方法与实验结论，便于理解论文并开展后续研究。"
---

# An Empirical Study of LLM-as-a-Judge for LLM Evaluation: Fine-tuned  Judge Model is not a General Substitute for GPT-4
+ 这篇文章提出了一个命题：**微调后的LLM表现不如一个没有微调过的GPT-4模型**，实验结构表明**微调会导致LLM的泛化能力显著下降**。

+ 偏向于实证研究，对微调LLM提出了质疑。

## 微调后的模型和基准选择
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0c87d5cec4354d1b9ec4da3be49c651a.png){: referrerpolicy="no-referrer" }
# 主要贡献
研究了微调后的LLM存在的一些问题：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8c9bb25acc194ed2afbc727013d5402e.png){: referrerpolicy="no-referrer" }

## 微调模型受限于训练计划
+ 微调后的LLM只在对应的训练计划上表现良好，其余表现不尽人意。
+ **在其他训练计划上的表现还不如闭源的GPT-4**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c91f1add1fba4abda6f7f927ba1863fc.png){: referrerpolicy="no-referrer" }

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/268df97c796b46ff87ff7cb82b2e3422.png){: referrerpolicy="no-referrer" }

## 对质量表现好的偏好 Biased Towards Superficial Quality
+ 这部分也可以理解为对抗鲁棒性不行，用一些对抗样本：例如一个表现好的样本和一个看上去表现得好的差样本，让LLM进行评估。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f56a91c30b1b4e8b93848c7fe3017ebf.png){: referrerpolicy="no-referrer" }

+ 微调后的LLM的准确率较低，说明**它们可能被看起来表现良好的差样本误导**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f09a3ff888284d29ab563e4a66cbd49c.png){: referrerpolicy="no-referrer" }

## 无法实现对特定方面的有效评估 Incapable of Aspect-specific Evaluation
作者使用了三个数据集用于评估这些微调后的LLM，**旨在评估三者对于细粒度**(分别为事实性、危害性和安全性)方面的评估准确率。
发现它们的表现都非常差，说明**微调后的LLM可能丧失了泛化能力**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a493a1e59aa54433abdb937db5e53ef0.png){: referrerpolicy="no-referrer" }

## 无法受益于提示词工程策略 Can not Benefit from CoT and ICL

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5876b3a5cd7d4586ad906eff4e5f8019.png){: referrerpolicy="no-referrer" }
+ 微调后的LLM仍然固执己见，输出既定格式，说明它们很大程度上已经丧失了**指令跟随的能力**，也就是**泛化能力显著降低**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1dd8399037e640ff9f53fa8a3f97c0c2.png){: referrerpolicy="no-referrer" }

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/06166072ca294d31ba9023f58f627d71.png){: referrerpolicy="no-referrer" }
## 微调后的LLM的本质：一个特定领域的分类器
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/7c5b89ef25e542a2961fe76fb942f7c4.png){: referrerpolicy="no-referrer" }


作者使用Table1的数据微调以下三个LLM模型，分为负责**生成任务和分类任务**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/84a9e7add790425a9c51ca2341ae269c.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c1e62b7d46224a9da45e88a3ed6346f9.png){: referrerpolicy="no-referrer" }

+ 发现它们的**输出结果相似度很高**。与之对比,GPT-4的结果则于他们有较大差异。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ad64bd0de8104cf48f43529d6a683ecb.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1cd0eb410cd04c2ebeab0ba92df3ccfb.png){: referrerpolicy="no-referrer" }
+ 这简洁说明，经过微调，这些LLM已经完全沦落为一个特定领域的分类器，对于特定数据过拟合。
