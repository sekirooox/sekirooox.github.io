---
title: "计算机视觉·MaskFormer"
author: MayL
date: 2025-11-30
categories: ["深度学习与计算机视觉", "计算机视觉"]
tags: ["计算机视觉", "深度学习", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“计算机视觉·MaskFormer”涉及的模型原理、关键方法与实践要点，便于理解和复习相关技术。"
---

# MaskFormer
借助了**DETR**的核心思想，不过将原本的目标检测任务迁移到了语义分割和全景分割领域。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6036143e2f0146d68e90fb1ae69f914b.png){: referrerpolicy="no-referrer" }
# 方法
## 前向过程
+ 和DETR一样，使用骨干网络获取一个低分辨率特征图。再使用一个FPN获得分辨率与输入图像相同的特征图(缘于语义分割任务的特点)。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ef6026ec92cf4c79b8ead4f5a9733c8d.png){: referrerpolicy="no-referrer" }+ 设置N个查询向量，然后每个查询向量作为Q，特征图作为K和V，进行**交叉注意力计算**，得到对应N个段嵌入。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a3ef12b7cca04ab5a37b7b78b158aeb3.png){: referrerpolicy="no-referrer" }
+ 然后和DETR一致，这N个段嵌入首先通过一个简单的MLP得到维度为$N\times (K+1)$的类别概率分布，也是引入了一个No object类别，K是目标数。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/af9a9ef3b84a458987f0596476f00433.png){: referrerpolicy="no-referrer" }
+ 不同的是，需要生成掩码，不能直接通过段嵌入+线性层得到。于是段嵌入会被映射为**掩码嵌入**，掩码嵌入与特征图进行QK矩阵乘法操作，得到$N\times H\times W$个语义掩码。
+ 需要注意的是：**这些掩码不是二值的！这些掩码不是二值的！这些掩码不是二值的！**，只经过了sigmoid进行简单的激活。

## 训练损失
+ 损失与DETR的原理保持基本一致
+ 生产的N个软掩码与M个**真实掩码**进行匹配。
>如何定义真实掩码GT mask?
>图像中可能有x个类别的注释，这x个注释可以看作是一个真实掩码。对于示例分割，还要求这x个注释互相不连通(也就是**属于同一类别且连通的掩码才是真实掩码**)。
+ 匹配上**非no object类**的计算**掩码损失**：就是语义分割任务中常用的dice和focal损失
+ 所有查询对应的类别概率分布**都要计算交叉熵损失**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1dadf1fde3fa4847a5d34dc74938d5cf.png){: referrerpolicy="no-referrer" }

## 推理方式
+ 对于一般的语义分割任务：每一个查询向量的类别概率分布p_i$\times$生成的软掩码m_i，最后求和即可,得到H*W的类别概率分布，最后取最大值即可。
+ 注意：对于**属于no object的类别不进行任何计算**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f4781f936acd4e27b52b2863b7aac013.png){: referrerpolicy="no-referrer" }

