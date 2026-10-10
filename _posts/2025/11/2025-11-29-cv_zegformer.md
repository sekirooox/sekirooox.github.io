---
title: "计算机视觉·ZegFormer"
author: MayL
date: 2025-11-29
categories: ["深度学习与计算机视觉", "计算机视觉"]
tags: ["计算机视觉", "深度学习", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“计算机视觉·ZegFormer”涉及的模型原理、关键方法与实践要点，便于理解和复习相关技术。"
---

# ZegFormer
# 创新点
>核心思想是：对于像素进行分类的操作不符合人类的思维方式，我们擅长对于一个区域(Segment)进行分类。

因此，论文提出将 ZS3 解耦为**两个独立子任务**：
+ 类无关的图像分组
+ 把像素分成不同区域（segments），不依赖类别信息 ，因此具有天然的泛化性。
区域级别 zero-shot 分类（Segment-level Zero-Shot Classification）

对**每个 segment** 做类别预测。由于这是区域级别而非像素级别，因此可以自然使用像 CLIP 这样的大规模视觉-语言模型。
这一解耦使得模型更贴近人类的分割过程（先分块再识别）。


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9aa6fc1b9f5544ec8c171ba887f4beca.png){: referrerpolicy="no-referrer" }

# *新定义
作者对于ZS3和GZS3的新定义方式，还是比较有意思
简单来说就是**把语义分割看成两个部分**：
+ **先对图像进行分块**，例如$\mathcal{R}$表示多个区域，这些区域**不重叠**
+ 然后找到一种**标签映射关系**$\mathcal{L}$，用于将这些区域**映射到标签集合**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/845796a87b1e4621b888cbc02b92c792.png){: referrerpolicy="no-referrer" }
# 方法
## 块嵌入
+ 作者借助了**MaskFormer**的经典思想，引入N个可以学习的块嵌入，用于**编码图像中的嵌入**，$G\in R^{ N \times D}$
+ 借助一个视觉模型如ResNet+像素级解码器得到特征图$F (I) ∈ R^{D×H×W}$，**这个特征图大小与原始图像一致**。

+ 将块嵌入和特征图送入一个解码器得到**学习后的块嵌入**$G\in R^{ N \times D}$，这个块嵌入可以直接用于CLIP的分类。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/51fc402ac80e4bdbb0d3a7d861d3bec6.png){: referrerpolicy="no-referrer" }
+ 利用该块嵌入与文本嵌入进行相似度计算，得到每一个块嵌入的分布$p\in R^{N \times C}$
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/be8b537a0f324b9091418e27c27addcf.png){: referrerpolicy="no-referrer" }
+ 与MaskFormer不同的是，由于是零样本语义分割，**没有基于MLP的线性层**，而是**通过将CLIP文本编码器的嵌入与块嵌入进行相似度计算**来实现学习类别的概率分布。
+ 与MaskFormer一致，引入了no object**用于学习分类概率**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/25ae614b45f64c3ca16f031937c66416.png){: referrerpolicy="no-referrer" }
## 掩码嵌入
+ 与MaskFormer一致，作者引入了一个块掩码嵌入$B \in R^{ N \times D}$，用于学习特征图中的掩码$m\in R^{ H \times W}$。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b48dcd6a34054ff9bf49845b1db34f17.png){: referrerpolicy="no-referrer" }
+ 作者对**原始图像和掩码图像**进行融合操作，然后送给CLIP的**视觉编码器**提取**图像嵌入**$A\in R^{N\times D}$
+ 这一部是不需要训练的。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b388676e67154df9a1077161ee81b04c.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/05449e4aabb44c99bbe8c8a0027ad56a.png){: referrerpolicy="no-referrer" }
+ 类似块嵌入，**计算相似度**，得到如下概率分布：$p' \in R^{N \times C}$

## 训练
 + 使用二分图匹配得到最接近的类别
+ 对于每一个块嵌入，计算交叉熵损失。
+ 对于生成的掩码损失，与真实掩码计算DICE和FOCAL损失。
## 推理
+ 未完待续
推理阶段就是结合两个概率分布，乘以得到掩码，进行求和。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/70dbbb800de84f2784ae65b5224ce662.png){: referrerpolicy="no-referrer" }



