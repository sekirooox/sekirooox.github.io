---
title: "AlignZeg: Mitigating Objective Misalignment for Zero-shot Semantic Segmentation"
author: MayL
date: 2025-10-15
categories: ["深度学习与计算机视觉", "计算机视觉"]
tags: ["计算机视觉", "语义分割", "深度学习", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“AlignZeg: Mitigating Ob…”涉及的模型原理、关键方法与实践要点，便于理解和复习相关技术。"
---

# AlignZeg: Mitigating Objective Misalignment for Zero-shot Semantic Segmentation
>Abstract. A serious issue that harms the performance of zero-shot visual recognition is named objective misalignment, i.e., the learning  objective prioritizes improving the recognition accuracy of seen classes  rather than unseen classes, while the latter is the true target to pursue. This issue becomes more significant in zero-shot image segmentation because the stronger (i.e., pixel-level) supervision brings a larger gap  between seen and unseen classes. To mitigate it, we propose a novel architecture named AlignZeg, which embodies a comprehensive improvement of the segmentation pipeline, including proposal extraction, classification, and correction, to better fit the goal of zero-shot segmentation.  (1) Mutually-Refined Proposal Extraction. AlignZeg harnesses a  mutual interaction between mask queries and visual features, facilitating  detailed class-agnostic mask proposal extraction. (2) GeneralizationEnhanced Proposal Classification. AlignZeg introduces synthetic  data and incorporates multiple background prototypes to allocate a more  generalizable feature space. (3) Predictive Bias Correction. During  the inference stage, AlignZeg uses a class indicator to find potential unseen class proposals followed by a prediction postprocess to correct the  prediction bias. Experiments demonstrate that AlignZeg markedly enhances zero-shot semantic segmentation, as shown by an average 3.8%  increase in hIoU, primarily attributed to a 7.1% improvement in identifying unseen classes, and we further validate that the improvement comes  from alleviating the objective misalignment issue.

摘要。影响零射击视觉识别性能的一个严重问题被称为目标偏差，即学习目标优先于提高可见类的识别精度而不是未见类，而后者才是真正要追求的目标。这个问题在零镜头图像分割中变得更加重要，因为更强（即像素级）的监督会带来更大的可见类和未见类之间的差距。为了缓解这一问题，我们提出了一种名为AlignZeg的新架构，它体现了对分割管道的全面改进，包括提案提取、分类和校正，以更好地适应零采样分割的目标。(1)互精提案提取。AlignZeg利用掩码查询和视觉特征之间的相互作用，促进了详细的与类别无关的掩码建议提取。(2)泛化：增强提案分类。AlignZeg引入了合成数据，并结合了多个背景原型来分配更一般化的特征空间。(3)预测偏差校正。在推理阶段，AlignZeg使用类指示器来查找潜在的未见过的类建议，然后使用预测后处理来纠正预测偏差。实验表明，AlignZeg显著增强了零射击语义分割，hIoU平均提高了3.8%，这主要归因于识别未见类的效率提高了7.1%，我们进一步验证了这种提高来自于缓解客观错位问题。


### 设计思路：双阶段方法生成掩码的过程

# GEPC
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/fa73694928d7489a9cd5db1c9240f420.png){: referrerpolicy="no-referrer" }
这篇论文《**AlignZeg: Mitigating Objective Misalignment for Zero-shot Semantic Segmentation**》的主要内容可概括如下：

---

### 研究背景

语义分割（Semantic Segmentation）需要像素级标注数据，但真实世界中数据种类繁多，难以完全标注。**零样本语义分割（Zero-shot Semantic Segmentation, ZS3）** 旨在让模型在仅见过部分类别（seen classes）后，仍能识别训练中未出现的类别（unseen classes）。
随着 **CLIP** 等大规模视觉语言模型的发展，研究者将其迁移至像素级任务，实现“从文本到像素”的语义对齐。然而，现有方法主要优化**已见类的分类精度**，而非未见类的泛化性能，导致所谓的 **“Objective Misalignment（目标错位）”** 问题：训练目标与零样本任务目标不一致，从而对未见类预测产生偏差。

---

### 研究动机

作者发现当前的ZS3模型（如 ZegCLIP、DeOP、SAN 等）虽然高效，但普遍存在三个问题：

1. **目标错位（Objective Misalignment）**：模型训练时仅优化 seen 类性能，忽视 unseen 类泛化。
2. **特征空间不均衡**：seen 类占据特征空间主导地位，压制 unseen 类分布。
3. **预测偏置（Prediction Bias）**：推理阶段更容易预测为 seen 类。

因此，论文的核心动机是：

> **如何在训练和推理阶段同时缓解目标错位问题，使模型在保持 seen 类性能的同时显著提升 unseen 类识别能力。**

---

### 主要贡献点

论文提出一个完整框架 **AlignZeg**，从 **proposal 生成、分类与推理修正** 三个层面协同优化零样本分割任务，具体包括三大创新模块：

1. **Mutually-Refined Proposal Extraction (MRPE)**

   * 设计**双向交互机制**：mask queries 与视觉特征相互精炼（mutual refinement），得到高质量、类无关的 mask proposals。
   * 有助于减少对 seen 类特征的依赖，增强对 unseen 类的泛化。
   ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8edd4d2435c94a41b51bc6a074d56eeb.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3bfa0dcc554c4fd599cbd8091223aaeb.png){: referrerpolicy="no-referrer" }


2. **Generalization-Enhanced Proposal Classification (GEPC)**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d255301abec94565adde8f01f2acbfc2.png){: referrerpolicy="no-referrer" }

   * 引入两种策略：
每一个掩码对应的特征向量提取。

     * **Feature Expansion Strategy (FES)**：通过 Manifold Mixup 生成虚拟特征，扩大 seen 类特征分布边界；
每一个掩码提取的**特征向量**方式如下：
     ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/26cde46cc63f4608b906c4ff6bc2c633.png){: referrerpolicy="no-referrer" }

     ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f7b25957df6e4e43b3b2315894cb1ffe.png){: referrerpolicy="no-referrer" }

     * **Background Diversity Strategy (BDS)**：采用多背景原型（multi-background prototypes），增强背景多样性表示。
   * 从特征层面扩大 unseen 类的可占空间，避免 seen 类主导特征空间。

4. **Predictive Bias Correction (PBC)**
二分类指示器的标签设置：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5835b84823ad418f9381282233179b21.png){: referrerpolicy="no-referrer" }

概率校准：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0b7d270ee541475aa656c40897173990.png){: referrerpolicy="no-referrer" }

   * 在推理阶段引入一个二分类器 **ϕ_bc(·)**，用于检测哪些 proposals 可能属于 unseen 类；
   * 若检测为 unseen，则降低其 seen 类预测分数；
   * 实现对 seen/unseen 预测的显式偏差修正。

---

### 研究方法与整体框架

如论文第4页图2所示（*Overall Framework Diagram*）：

* 模型采用 CLIP 的视觉与文本编码器；
* 整个流程包括三个阶段：

  1. **提案生成（MRPE）**：融合 Image Encoder 与 CLIP Vision Encoder 特征，进行 query–feature 互精炼；
  2. **提案分类（GEPC）**：CLIP 文本编码器生成类别原型，结合虚拟样本与多背景特征进行特征空间扩展；
  3. **预测修正（PBC）**：在推理阶段判定并抑制偏向 seen 类的预测，输出最终分割图。

优化目标为：
$$
\mathcal{L} = \mathcal{L}_{bc} + \lambda_1\mathcal{L}_{ce} + \lambda_2\mathcal{L}_{mask} + \lambda_3\mathcal{L}_{vir} + \lambda_4\mathcal{L}_{reg}
$$
其中各项分别对应偏置校正、分类、掩码、虚拟样本与背景正则损失。

---

### 实验与结果

在 **PASCAL VOC 2012、COCO-Stuff 164K、PASCAL Context** 三个数据集上评估：

* 平均 hIoU 提升 **3.8%**，未见类 mIoU(U) 提升 **7.1%**；
* 在严格零样本设置（ZS3）下，性能超过 ZegCLIP、SAN 等 SOTA 方法。

可视化（图7–图8）显示：AlignZeg 有效减少 unseen 类被误分为 seen 类的现象，如“tree→bush”、“road→pavement”等典型错误显著减少。

---

### 总结

> **AlignZeg** 从根本上解决了零样本语义分割中的目标错位问题，
> 通过 **提案互精炼、特征泛化增强与预测偏置校正** 三个互补机制，
> 使模型在 seen 与 unseen 类上实现了更平衡、泛化性更强的表现。

