---
title: "论文精读·Is LLM an Overconfident Judge? Unveiling the Capabilities of LLMs in Detecting Offensive Langu"
author: MayL
date: 2025-09-22
categories: ["论文阅读与科研", "大模型评测"]
tags: ["大模型评测", "llm", "llm-as-a-judge", "论文阅读"]
render_with_liquid: false
description: "本文记录“论文精读·Is LLM an Overconf…”的研究问题、主要方法与实验结论，便于理解论文并开展后续研究。"
---

# Is LLM an Overconfident Judge? Unveiling the Capabilities of LLMs in  Detecting Offensive Language with Annotation Disagreement

+ 这篇论文主要探究了LLM检测冒犯语言，**注释不一致样本如何影响LLM决策的问题**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f82556bbad00482ebe0d37c3317b1911.png){: referrerpolicy="no-referrer" }

+ 注释不一致，如下图所示。就是对于冒犯语言，**有5个评审人对齐进行打分(是/不是)**，有些情况下5个评审人的**打分不一致**，作者将其**平均化**为下图的软标签[0,1]。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/29b9cf5e3a3e465484da1d9a84869c37.png){: referrerpolicy="no-referrer" }

# 主要贡献
+ **研究了一个新问题(最主要)**：冒犯语言检测中存在的**注释不一致**现象，给出了**评估方法**。
+ 研究了不同的不一致程度样本对于LLM的影响
+ 研究了**如何解决不一致的样本**，如何评估LLM是否过度自信，与人类的评估是否一致。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0446248d6f4f4b148c3cf9ddc9c60d5b.png){: referrerpolicy="no-referrer" }

## 实验
### RQ1：研究在**注释不一致情况下LLM对于冒犯语言检测的表现**。
+ **视为二分类任务**，指标有准确率和F1分数。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/45729e3128e444c29d4d1a9a8c3fe9a6.png){: referrerpolicy="no-referrer" }
### RQ1：研究LLM的自信和样本的一致程度是否对齐。
+ 换句话说，就是**LLM应该对于低一致程度的样本自信心较低，对高一致程度的样本自信度较高**。这点与人类评估得到的一致性分数一致。
+ 作者采用了self-consistency方法，设置不同的温度系数，最后**取不同温度系数下结果的平均值**得到，用于**表示LLM的自信心**，并与人类评估给出的一致性分数计算**MSE分数**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3dae9798e74040f189aad91facf7d96a.png){: referrerpolicy="no-referrer" }

### RQ2：研究不一致的样本对于LLM学习的影响。
+ 分别采用**few-shot learning**和**指令微调**的方法。分贝设置不同的不一致程度和混合程度改进LLM，分析结果。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/dc2aa0cd2aad40d8969f6b797ca65ad0.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/143d1a4bee6542239ea59bd3e413c53f.png){: referrerpolicy="no-referrer" }

