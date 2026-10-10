---
title: "论文精读·大模型评审(LLM-as-a-Judge)"
author: MayL
date: 2025-09-21
categories: ["论文阅读与科研", "大模型评测"]
tags: ["大模型评测", "llm", "llm-as-a-judge", "论文阅读"]
render_with_liquid: false
description: "本文记录“论文精读·大模型评审(LLM-as-a-Jud…”的研究问题、主要方法与实验结论，便于理解论文并开展后续研究。"
---

# 大模型评审 LLM-as-a-Judge

大模型评审简单理解就是让大模型模仿人类对一些东西进行打分和评价。
如何评价大模型评审，主要看其回答是否与人类的回答对齐/一致。
## 形式定义

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a8bdfdeecdb6491fb91ddaf4d5be6849.png){: referrerpolicy="no-referrer" }
# 基本流程
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f0263827b5144f118029d7c48c85a8d7.png){: referrerpolicy="no-referrer" }

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a7693d18bc9e471c810f78063ebad545.png){: referrerpolicy="no-referrer" }

## in-context learning
+ 核心过程就是**输入设计**和**prompt设计**。
+ 个人理解：**定义问题**，通过合适的prompt**让LLM理解和学习问题**案例。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/28939cd05d11472a90b2637d4fb1f0a1.png){: referrerpolicy="no-referrer" }

## model selection
+ 简单理解为：选择闭源但是强大的模型，或者选择开源的模型进行微调。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b544b114eba248b3a0b20649d306a1c6.png){: referrerpolicy="no-referrer" }
## post-processing
+ 动机：**大模型的输出存在随机化，格式也很混乱**，需要提取特定token或者得到标准化的输出。
+ Extracting specific tokens.
+ Constrained decoding：这是**强制要求LLM输出指定格式**，例如JSON格式。
+ Normalizing the output logits：没看懂，未完待续
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2a907a555eef465fa356c450e050cad0.png){: referrerpolicy="no-referrer" }

+ Selecting sentences
## evaulation pipeline
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/4e6d33c479014c5f9788d21a3c8ea750.png){: referrerpolicy="no-referrer" }
### Models

### Data
+ 这个第一次看还以为是给数据打标签呢，不是这样的！是对于特定数据(可能是LLM生成的内容)进行评估，举三个例子即可完全理解：
+  场景 1（**成对偏好**） → 对应 RLHF 偏好评估。
+ 场景 2（**文字评语**） → 对应 数据标注/批注生成。
+ 场景 3（**数值打分**） → 对应 单一回答打分/排序。

+ 用LLM评估以下东西。
# 提升策略
+ **优化提示，对应in-context learning**：旨在帮助LLM理解问题本身。将任务进行分解为多个子任务和子流程，将评价指标解耦为多个子指标。或者直接提供部分案例供LLM学习。
+ **微调模型，对应model selection**：提高LLM本身的能力，减小歧视(bias)。使用元数据微调，使用表现不好的案例微调。
+ **优化结果，对应post-processing**：旨在优化LLM的输出，包括使用多个LLM，多轮输出综合和其他策略。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/915ef4f1f59d47eb87df7221bf4a434a.png){: referrerpolicy="no-referrer" }

## 评估LLM-as-a-Judge的指标
+ **核心思想：让LLM的输出结果与人类提供的输出结果(人为注释)尽可能一致。**
+ **分类指标：**准确率，召回率那些。
+ **Agreement**(本质也是一种准确率指标)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/da3147ddc9dd4dbea3c784aa53fec42d.png){: referrerpolicy="no-referrer" }

+ **Bias(歧视、偏差)**：各种各样的歧视，所用的指标各不相同。
+  模型的**对抗鲁棒性**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/af90ccbabcea44d791dc39f9fd502f15.png){: referrerpolicy="no-referrer" }

# meta-evaluation experiment
+ 动机：作者提出了一个元评估框架，旨在评估**以上提升策略对LLM哪些能力有效，对于哪些歧视现象无效**？
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d0c2156138424116b1086ea92b93d657.png){: referrerpolicy="no-referrer" }
实验部分未完待续。

<br><br>
<br><br>
<br><br>

---


# 参考文献
```bash
@misc{guSurveyLLMasaJudge2025,
  title = {A {{Survey}} on {{LLM-as-a-Judge}}},
  author = {Gu, Jiawei and Jiang, Xuhui and Shi, Zhichao and Tan, Hexiang and Zhai, Xuehao and Xu, Chengjin and Li, Wei and Shen, Yinghan and Ma, Shengjie and Liu, Honghao and Wang, Saizhuo and Zhang, Kun and Wang, Yuanzhuo and Gao, Wen and Ni, Lionel and Guo, Jian},
  year = {2025},
  number = {arXiv:2411.15594},
  eprint = {2411.15594},
  primaryclass = {cs},
  publisher = {arXiv},
  doi = {10.48550/arXiv.2411.15594},
  archiveprefix = {arXiv}
}

```


