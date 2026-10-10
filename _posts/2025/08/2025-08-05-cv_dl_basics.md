---
title: "深度学习·基础知识"
author: MayL
date: 2025-08-05
categories: ["深度学习与计算机视觉", "深度学习"]
tags: ["深度学习", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“深度学习·基础知识”涉及的模型原理、关键方法与实践要点，便于理解和复习相关技术。"
---

# 交叉熵损失CE
>只关心正确类别的预测概率
+ 先进行softmax得到logits
+ 真实标签的**概率分布：**$y$，预测标签的**概率分布**：$\hat{y}$,$N$表示**类别数**，且$y_i\in\{0,1\}$
+ 衡量**两个概率分布的距离或者差别**，类似**KL散度**
$$
\mathcal{L}(y,\hat{y})=-\frac{1}{N}\sum_{i=1}^Ny_i log(\hat{y}_i)
$$

# 二元交叉熵BCE
>只需要**记忆BCE**就可，**CE是其的一种推广**
>BCE确实**强制每个类别的输出趋近0或1**
+ 先对每一个类别预测结果应用softmax得到logits
+ 每一个类别的$y_i$允许为1，意味着可以存在**多个分类结果**。
+ 真实标签的**概率分布：**$y$，预测标签的**概率分布**：$\hat{y}$,$N$表示**样本数**，且$y_i\in\{0,1\}$
$$
\mathcal{L}(y,\hat{y})=-\frac{1}{N}\sum_{i=1}^Ny_i log(\hat{y}_i)+(1-y_i)log(1-\hat{y}_i)
$$

# Focal loss
+ 用于**解决数据集不平衡的问题**
+ 建立在**BCE**的基础之上
+ $p_t$表明预测的置信度，**与类别无关**。(例如**p=1表示对于类别1的预测概率为1**，但是$p_t$表明了**对正确标签的预测概率**)
+ $\alpha_t$定义与$p_t$类同，主要用平衡**正负样本权衡**。
+ $(1-p_t)^{\gamma}$用于平衡**难易的样本权衡**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/467b61937e464f308a0f7af3992de837.png){: referrerpolicy="no-referrer" }

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c3290dcc267446f6bc96dc6dd4aabcce.png){: referrerpolicy="no-referrer" }

+ 以下两种公式完全等价。就是**展开来写**的区别。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e4cac6fd88be44a1a01b0025e91de637.png){: referrerpolicy="no-referrer" }

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d993148c9c7349ba90fbd87fefdf7d90.png){: referrerpolicy="no-referrer" }
这里的$y_i$是**预测结果**,$\hat{y}\in\{0,1\}$是**ground truth**，$\alpha_t$**一般不加**，不考虑正负样本；$\gamma=2$时效果最好。

# Dice loss
+ 解决**数据集不平衡**的问题
标准公式：
$$
\mathcal{L}_{dice}=1-\frac{2|X\cap Y|}{|X|+|Y|}
$$

很明显如果完全重合损失为0，所以这个loss适用于**直接优化IOU指标**
+ 实际计算：
+ 针对每一个类别计算loss损失
+ **遍历每一个类别i**，`(ground_truth==i)*pred*2`得到上面的项，然后分别对掩码矩阵和预测矩阵求平方得到下面的项(技巧：转bool值)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/34be589a3d87494f9dcd6d7b162e6f62.png){: referrerpolicy="no-referrer" }


# GZLSS/ZLSS和FLSS/FLSS
Zero-label=zero shot
few label=few shot

## 训练过程
+ **预先设定某些类别为seen和unseen类**
+ 训练过程中对于unseen或者不涉及的类别，**不计算损失**
+ **数据集的样本的划分细节等都不变**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c96cda05d2a545b6bf835f57d2dfcf09.png){: referrerpolicy="no-referrer" }
## 测试过程
+ IOU指标取平均得到mIOU
+ seen和unseen的类被分别计算
+ 最终得到`harmonic mean (H)`
![](https://i-blog.csdnimg.cn/direct/00a8b0ffb7634985bb100dd62eb36874.png){: referrerpolicy="no-referrer" }

# “inductive” zero-shot 和“transductive” zero-shot
>Besides “inductive” zero-shot segmentation, there is a “transductive” zero-shot learning setting, which assumes that the names of unseen classes are known before the testing stage. They [17, 56] suppose that the training images include the unseen objects, and only ground truth masks for these regions are not available. Our method can easily be extended to both settings and achieve excellent performance.

`“transductive” zero-shot`在训练过程中，unseen类已知，图片中也包括unseen类，但是**它们的注释**信息是不知道的，所以需要CLIP**生成伪标签**，通过**BCE来生成损失**。
