---
title: "论文精读·Generative Judge for Evaluating Alignment"
author: MayL
date: 2025-09-23
categories: ["论文阅读与科研", "大模型评测"]
tags: ["大模型评测", "llm-as-a-judge", "论文阅读", "科研笔记"]
render_with_liquid: false
description: "本文记录“论文精读·Generative Judge f…”的研究问题、主要方法与实验结论，便于理解论文并开展后续研究。"
---

# Generative Judge for Evaluating Alignment (AUTO-J)

# 数据集构建的流程
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b835735c93894386b2b489cba6bc8321.png){: referrerpolicy="no-referrer" }
## 手动定义58种场景
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a63387ce6e0142cca02f527a018df16a.png){: referrerpolicy="no-referrer" }
## 收集数据并按照场景分类
+ 从4个广泛的数据集种收集数据。这些数据包括**人类对于两个LLM模型生成的结果的偏好**
+ 处理为统一格式：**查询，输出1，输出2和人类的偏好**。
+ 然后训练一个模型，用于将这些案例**按照场景分类**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/56d7da41999242d39adb5828bb934f72.png){: referrerpolicy="no-referrer" }
## 生成评判
上述收集的数据还不足以满足LLM评审的要求，因此需要进一步进行处理。常见的方法是使用**闭源模型(GPT-4)仿照LLM进行评审**。
### 成对比较
+ 表8：首先给出评判标准，作为**系统和场景提示词**。
+ 表10：**处理原始数据的提示模板**，得到GPT-4生成的成对数据
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b07184a4e63444368d57e6c6261dd4bf.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d76ee6dd02dc404490067651ecc954aa.png){: referrerpolicy="no-referrer" }
+ 表18：按照以下格式**标准化GPT-4的输出结果**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/34566b7db564418081e92c57259fd798.png){: referrerpolicy="no-referrer" }
### 单一问答
+ **直接使用系统提示词会损害GPT-4的泛化能力**，所以作者采用了分而治之的技巧，**分为使用和不使用系统提示词**，然后最后综合二者结果，得到更加优质的回答。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/566c6924137b48ed9414f87e0a93ec5c.png){: referrerpolicy="no-referrer" }
+ 表11和12：提示词模板和融合二者回答的模板。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1a7477439ef044ebaf77b869303d9afd.png){: referrerpolicy="no-referrer" }
### 输入格式规定
+ 这个应该是训练时发现的问题：给定评价标准作为系统提示词时，**LLM只会表明的输出评价标准**。
+ 所以作者采用了上下文蒸馏的方法：不在输入时给定评价标准，让模型**从输出段隐式学习评价标准**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/aa7e479244124ded9091e672dbf43419.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/af0828f1d0ca4dec9bae5460c9352210.png){: referrerpolicy="no-referrer" }
# 训练细节
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b92d29ee73504541bfac0eadc2f2b1eb.png){: referrerpolicy="no-referrer" }
# 评估细节
## 成对比较
+ Eval-P
+ 为每个场景选取24个样本，每个样本包括2个回答和1个人工注释。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/738a587910054a24ab87253ff40e56d1.png){: referrerpolicy="no-referrer" }
## 评论生成
+ Eval-G：从Eval-P下采样
+ 从上一个24个样本中选4个，然后从两个回答中选择较差的回答，让**多个LLM为这些回答生成评语**，**用GPT-4和人工评审**来比较谁好
+ 用表示win-rate比较不同LLM的评语的优劣。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0bda73bca3da487fa2ed5ab523501f78.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6f509a12e16c452f95e0163e3cf0f7ba.png){: referrerpolicy="no-referrer" }

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/cc54a2fdaa6d4ea79b3ebf4ea5e4bad0.png){: referrerpolicy="no-referrer" }
## 打分
+ 为每个场景**采样两个query**，使用**两个LLM分别回答N次**，然后使用**多个LLM评审和GPT-4进行打分**，最后选择评分最高的版本。
+ 最后如何评估LLM评审的能力？1.LLM选择的评分**最高版本与GPT-4选的是否一致** 2.LLM评审**打分与GPT-4打分相关性**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/663984cbc23d46eb9719ce5928230b05.png){: referrerpolicy="no-referrer" }

