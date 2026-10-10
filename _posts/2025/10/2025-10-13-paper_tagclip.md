---
title: "论文精读·TagCLIP: Improving Discrimination Ability of Zero-Shot Semantic Segmentation"
author: MayL
date: 2025-10-13
categories: ["论文阅读与科研", "论文阅读"]
tags: ["clip", "语义分割", "论文阅读", "科研笔记"]
render_with_liquid: false
description: "本文记录“论文精读·TagCLIP: Improving…”的研究问题、主要方法与实验结论，便于理解论文并开展后续研究。"
---

# TagCLIP: Improving Discrimination Ability of  Zero-Shot Semantic Segmentation
> 2024年 SCI一区 TOP

Abstract—Contrastive Language-Image Pre-training (CLIP) has recently shown great promise in pixel-level zero-shot learning tasks. However, existing approaches utilizing CLIP’s text and patch embeddings to generate semantic masks often misidentify input pixels from unseen classes, leading to confusion between novel classes and semantically similar ones. In this work, we propose a novel approach, TagCLIP (Trusty-aware guided CLIP), to address this issue. We disentangle the ill-posed optimization problem into two parallel processes: semantic matching performed individually and reliability judgment for improving discrimination ability. Building on the idea of special tokens in language modeling representing sentence-level embeddings, we introduce a trusty token that enables distinguishing novel classes from known ones in prediction. To evaluate our approach, we conduct experiments on two benchmark datasets, PASCAL VOC 2012 and COCO-Stuff 164 K. Our results show that TagCLIP improves the Intersection over Union (IoU) of unseen classes by 7.4% and 1.7%, respectively, with negligible overheads. The code is available at here.

对比语言图像预训练（CLIP）最近在像素级零射击学习任务中显示出巨大的前景。然而，利用CLIP的文本和补丁嵌入来生成语义掩码的现有方法**经常会从未见过的类中错误地识别输入像素**，从而导致**新类和语义相似类之间的混淆**。在这项工作中，我们提出了一种新颖的方法，TagCLIP（信任感知引导CLIP），来解决这个问题。为了提高识别能力，我们将病态优化问题分解为两个并行的过程：分别进行语义匹配和可靠性判断。基于语言建模中表示句子级嵌入的特殊标记的思想，我们引入了一个可信的标记，可以在预测中区分新类和已知类。为了评估我们的方法，我们在两个基准数据集PASCAL VOC 2012和COCO-Stuff 164 K上进行了实验。我们的结果表明，TagCLIP在开销可以忽略不计的情况下，将未见类的联合交集（IoU）分别提高了7.4%和1.7%。代码可以在这里找到。
# 动机
+ 一直存在的问题：对看见类的过拟合现象。模型会将未见类错误识别为看见类(**新类和语义相似类之间的混淆**)。
+ 作者认为解决方案有两部分：一个正常进行语义匹配，**另一个是减少错误识别**。

# 研究方法
+ 作者在文本嵌入里面引入了一个置信token。
+ **放弃关系描述符**，通过transformer block得到增强后的文本嵌入。维度是((C+1),D)
+ 最后多出来那个维度，也用于生成语义掩码，不过是**用于调节**维度为(C,N)的正常语义匹配得到的掩码。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/445f8009d99b4fc897ec94469a95cf21.png){: referrerpolicy="no-referrer" }

以下是训练和测试过程
+ 这个图能体现作者的部分想法：置信token**主要是为了帮助模型区分哪些是看见类，哪些是未见类**。
+ 其中多出来的一层置信掩码使用**二进制标注**：**原有标注中看见类统一设置为1，其余为0，这样不影响训练逻辑**。

+ ![](https://i-blog.csdnimg.cn/direct/e3b8d67b0e694f77b7511bcc6d8f9ea2.png){: referrerpolicy="no-referrer" }
+ 推理思路非常简单：就是二者的加权，**调节正常匹配得到的掩码概率**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ba0c47c4303e4b3093fdc60e69646405.png){: referrerpolicy="no-referrer" }
+ 损失函数：NEL损失+置信掩码的DICE损失(这个不需要考虑ZegCLIP中提到的概率抑制等问题，主要目的是保证正确就行)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/96aaff26856f46d3992b70efe17644cb.png){: referrerpolicy="no-referrer" }


# 实验
## 本文的实验非常详尽，表格和图片数据也做得比较好，至少体现了作者工作量很足够，非常值得学习(用于水论文)😀
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/74f5f88a93d84705b7258813efca06b5.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/4a77fa3722d04b598d1ebe67599366a5.png){: referrerpolicy="no-referrer" }


