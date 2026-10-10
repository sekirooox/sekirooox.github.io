---
title: "深度学习·Cascade-CLIP"
author: MayL
date: 2025-08-08
categories: ["深度学习与计算机视觉", "计算机视觉"]
tags: ["计算机视觉", "clip", "深度学习", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“深度学习·Cascade-CLIP”涉及的模型原理、关键方法与实践要点，便于理解和复习相关技术。"
---

# Cascade-CLIP
+ ZegClip的改进工作
+ 创新点：级联式的结构，NGA，证明中间特征对于分割也有效。
# 动机

+ ZegClip忽略了中间层的关键信息，导致对于**物体边缘的分割效果**不好。**中间层次有着多尺度的信息**，Zegclip忽略了这种信息。
>“while they neglect the crucial information in intermediate layers that contain rich object details” ([Li 等, 2024, p. 1](zotero://select/library/items/28K57B4G)) ([pdf](zotero://open-pdf/library/items/DI34FU5M?page=1&annotation=VU4RUYR8)) 🔤而忽略了包含丰富对象细节的中间层中的关键信息🔤
>“exhibit weaknesses in segmenting object details, especially the boundaries of the semantic objects.” ([Li 等, 2024, p. 2](zotero://select/library/items/28K57B4G)) ([pdf](zotero://open-pdf/library/items/DI34FU5M?page=2&annotation=QB5FFCPW)) 🔤在分割对象细节方面表现出弱点，尤其是语义对象的边界。🔤
+ 简单的融合中间层的特征效果不佳，破坏了**原有的视觉语言相关性**。
>“However, the fusion of multi-level features disrupts these original visual-language correlations due to the significant disparity between the middle-layer and last-layer features” ([Li 等, 2024, p. 2](zotero://select/library/items/28K57B4G)) ([pdf](zotero://open-pdf/library/items/DI34FU5M?page=2&annotation=TNHELARK)) 🔤然而，由于中间层和最后一层特征之间的显着差异，多层特征的融合破坏了这些原始的视觉语言相关性🔤
+ 这张图是层级间的相似性分数，可见即使是**相邻层相似度分数也不高**，但是作者的方法相邻层的相似度分数还是不错的。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/164ba0aab778400590b8b0d43e112a03.png){: referrerpolicy="no-referrer" }
# 方法
+ 分为多个阶段，每一个阶段有独立的text-image decoder
+ 在本文中，**作者划分了3个阶段**，每个阶段的设置见下。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/98a16bb7b0c448209a0318e194c363e7.png){: referrerpolicy="no-referrer" }
## 级联式的架构
+ 将阶段$s$(包含$l$ 个transformer layers)的特征综合处理得到$Z_s$，然后每一个文本编码$\hat{T}$(C,2D)投射到(C,D)，这个**投射层貌似是独立的**。按照Zegclip的做法得到掩码矩阵$M_s$。直接相加所有阶段的掩码矩阵，并使用**softmax归一化**，得到最后的掩码矩阵。
+ 注意：前几层包含的语义信息太少，所以不考虑。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/570a65fb5f0948f2be34a18c4d4a5114.png){: referrerpolicy="no-referrer" }
+ stage数量的设置和划分
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/50f369cae3274daa924ad308e92b765a.png){: referrerpolicy="no-referrer" }
## NGA
+ 怎么综合处理这些中间特征？作者通过实验证明**直接相加或者拼接效果不好**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d9ba21f192b049beb6406a3512289f24.png){: referrerpolicy="no-referrer" }

+ NGA**本质是一种加权**
+ 注意：权重的**初始化方式**作者已经给出，并且**在训练中可以学习**！
+ $\sigma=1$
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/fc6a0133e75043b2b2a27cac79c0cbee.png){: referrerpolicy="no-referrer" }

