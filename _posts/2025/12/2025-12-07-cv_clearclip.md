---
title: "ClearCLIP"
author: MayL
date: 2025-12-07
categories: ["深度学习与计算机视觉", "计算机视觉"]
tags: ["计算机视觉", "clip", "深度学习", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“ClearCLIP”涉及的模型原理、关键方法与实践要点，便于理解和复习相关技术。"
---

# ClearCLIP: Decomposing CLIP Representations  for Dense Vision-Language Inference
Abstract. Despite the success of large-scale pretrained Vision-Language Models (VLMs) especially CLIP in various open-vocabulary tasks, their application to semantic segmentation remains challenging, producing noisy segmentation maps with mis-segmented regions. In this paper, we carefully re-investigate the architecture of CLIP, and identify residual connections as the primary source of noise that degrades segmentation quality. With a comparative analysis of statistical properties in the residual connection and the attention output across different pretrained models, we discover that CLIP’s image-text contrastive training paradigm emphasizes global features at the expense of local discriminability, leading to noisy segmentation results. In response, we propose ClearCLIP, a novel approach that decomposes CLIP’s representations to enhance open-vocabulary semantic segmentation. We introduce three simple modifications to the final layer: removing the residual connection, implementing the self-self attention, and discarding the feed-forward network. ClearCLIP consistently generates clearer and more accurate segmentation maps and outperforms existing approaches across multiple benchmarks, affirming the significance of our discoveries.
抽象的。尽管大规模预训练视觉语言模型（VLM）尤其是 CLIP 在各种开放词汇任务中取得了成功，但它们在语义分割中的应用仍然具有挑战性，会产生带有错误分割区域的噪声分割图。在本文中，我们仔细地重新研究了 CLIP 的架构，并将残余连接确定为降低分割质量的主要噪声源。通过对不同预训练模型的残差连接的统计特性和注意力输出的比较分析，我们发现CLIP的图文对比训练范式强调全局特征，而牺牲了局部可辨别性，导致分割结果存在噪声。作为回应，我们提出了 ClearCLIP，这是一种分解 CLIP 表示以增强开放词汇语义分割的新方法。我们对最后一层进行了三个简单的修改：删除剩余连接、实现自注意力、丢弃前馈网络。 ClearCLIP 始终如一地生成更清晰、更准确的分割图，并在多个基准测试中优于现有方法，证实了我们发现的重要性。

# 动机
The aforementioned baseline in Eq. (4) often fails to achieve satisfactory results [56]. This is probably because the CLIP is trained with image-level contrastive loss between vision and language, leading to poor alignment between local image regions and text representations [41]. Several studies [3,26,40,56] have attempted to address this challenge with minimal modifications to CLIP without retraining. At the core, they propose to revise the vanilla Attnqk in the last self-attention layer to an identical attention [56] or self-self attention [3, 26, 40], i.e., Attnqq, Attnkk or Attnvv, aiming at re-organizing the spatial information. As shown in Fig. 2, they successfully improve the baseline, with mIoU reaching up to nearly 20.0 from only 4.4 of CLIP with ViT-B/16 architecture (CLIPB/16) on the COCOStuff dataset. However, there are still several important challenges. Firstly, previous works still generate sub-optimal results with noises in segmentation maps. Secondly, these methods fail to obtain reasonable results when using a larger model, such as ViT-L/14. In Fig. 2, Attnqq and Attnkk are even worse than the vanilla Attnqk with more noises in segmentation maps. Such counter-intuitive phenomena indicates that existing works may have missed some important issues when adapting the CLIP model for dense prediction tasks. In this work, we are curious about where and how these noises in segmentation results originate and surface.
上述方程中的基线。 (4)常常达不到满意的效果[56]。这可能是因为 CLIP 是通过视觉和语言之间的图像级对比损失来训练的，导致局部图像区域和文本表示之间的对齐不良[41]。多项研究 [3,26,40,56] 试图通过对 CLIP 进行最小修改而无需重新训练来解决这一挑战。其核心是，他们建议将最后一个自注意力层中的普通 Attnqk 修改为相同的注意力[56]或自我注意力[3,26,40]，即 Attnqq、Attnkk 或 Attnvv，旨在重新组织空间信息。如图 2 所示，他们成功地改进了基线，在 COCOStuff 数据集上，使用 ViT-B/16 架构的 CLIP (CLIPB/16) 的 mIoU 从仅为 4.4 达到近 20.0。然而，仍然存在几个重要的挑战。首先，以前的工作仍然会产生次优结果，分割图中存在噪声。其次，当使用较大的模型（例如 ViT-L/14）时，这些方法无法获得合理的结果。在图 2 中，Attnqq 和 Attnkk 甚至比普通 Attnqk 更差，分割图中的噪声更多。这种反直觉的现象表明，现有的工作在将 CLIP 模型应用于密集的预测任务时可能遗漏了一些重要的问题。在这项工作中，我们很好奇分割结果中的这些噪声是如何产生和出现的。

+ 最近的研究着重于改进CLIP最后一层的注意力，但是作者发现，**这些方法的分割图像仍然有较大噪声**，尤其是**面对更大的CLIP模型时，这些噪声更加明显，并且会使得性能下降**。
+ 这个动机好像和resnet的动机差不多，**就是网络深度增加但是网络性能却下降，这个思想很深刻！**
+ 作者通过实验证明这些问题很大程度上源自于残差连接。





## 验证实验
+ 对于更大的CLIP模型，性能反而更低的情况，作者发现：注意力输出的范数和性能基本上呈现正相关
+ 之所以性能下降，作者推测**可能是因为残差层输出的特征范数较高**。CLIP-B时13~14的水平，CLIP-L确实24左右的水平。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/eafc6b2013ec4bd09dad60bf8c497e5c.png){: referrerpolicy="no-referrer" }
---
+ 作者可视化分割图之后发现，**残差的输出结果非常多噪声，性能几乎为0**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3d4fe67c53644aa7b093ab9c918e0506.png){: referrerpolicy="no-referrer" }
+ 局部可区分性差：残差层的归一化熵接近于0，**说明其提供不了任何有利信息**。同时，其在某些通道的的值非常大，**大部分在这些通道上十分相似**，这可能是因为为了**图像识别任务需要均匀的特征，但是这肯定不利于图像分割任务**。


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a11c51df174c40b782d05bd0314a04d1.png){: referrerpolicy="no-referrer" }
+ **FFN的作用可以忽略不计**。这个结论来自一篇验证clip的论文，作者发现当去掉残差和FFN时，效果更好。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/7a864ab856e14da9940359f49da6c789.png){: referrerpolicy="no-referrer" }
# 方法

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f24d436b41864e3ca7ea2811a1033f88.png){: referrerpolicy="no-referrer" }

# GPT总结
先给你一版“整篇论文的方法理解 + 复现指南”，尽量按你给的提纲来。

---

## 0. 摘要翻译（意译）

大规模视觉-语言预训练模型（VLM），尤其是 CLIP，在各种开放词汇任务上都很成功，但在语义分割等致密预测任务上表现一般，往往会产生噪声很大的分割图、区域错分。本文重新仔细审视了 CLIP 的结构，发现**残差连接**是导致噪声、降低分割质量的主要来源。

通过比较 CLIP 中残差分支和注意力分支在不同预训练模型里的统计特性，作者发现：CLIP 的图文对比学习会强调**全局特征方向**，牺牲了局部可区分性，导致分割结果很嘈杂。为此提出 ClearCLIP：把 CLIP 的表示“拆开”，增强其开放词汇语义分割能力。具体是对最后一层做三件小事：**去掉残差连接、改成 self-self attention、丢弃 FFN**。这样 ClearCLIP 能持续产生更清晰、准确的分割图，在多个 benchmark 上都优于已有方法，证明了上述分析的重要性。

---

## 1. 方法动机

### 1.a 为啥要提出 ClearCLIP？

核心现象：
直接用 CLIP 做开词汇语义分割（每个 patch 和文本类别 embedding 做余弦相似度）时，分割图**噪声极大**，局部区域分类错乱（Fig.1 左）。

之前很多工作（MaskCLIP、CLIPSurgery、SCLIP 等）都认为问题出在**自注意力**，于是改 attention：改成 identity，改成 value-value self-self attention 等，确实提升了 mIoU，但：

* 仍然有明显噪声；
* 换成更大的 ViT-L/14 反而变差或崩掉（Fig.2、Fig.5）。

这让作者怀疑：**真正的噪声源头可能不在 attention 本身，而在别的地方**。

于是他们把最后一层输出拆成两部分：

* 残差分支：$$X_{\text{res}} = X$$
* 注意力输出：$$X_{\text{attn}} = \text{Proj}(\text{Attn}_{qk}\cdot v)$$
* 原本输出：$$X_{\text{sum}} = X_{\text{res}} + X_{\text{attn}}$$  

然后分别拿 $$X_{\text{res}}$$ 与 $$X_{\text{attn}}$$ 做语义分割。结果：

* 用 $$X_{\text{res}}$$：mIoU 接近 0，图几乎全是噪声；
* 用 $$X_{\text{attn}}$$：分割明显更清晰，mIoU 远高于原始 $$X_{\text{sum}}$$（Fig.3）。

⇒ **噪声主要来自 residual 这一支，而不是注意力本身**。

### 1.b 现有方法的痛点 / 不足

1. **只动 attention，不动 residual：**

   * MaskCLIP：把 $$\text{Attn}_{qk}$$ 改成单位矩阵，只用 value embedding 做 dense 特征。
   * CLIPSurgery：强调 value-value attention。
   * SCLIP：组合 q-q 和 k-k self-self attention。

   这些方法都在“增强 attention 分支”，**但 residual 分支仍然保留并参与相加**，带来的高范数、低熵全局噪声依然叠加在最后特征里。

2. **大模型反而坏掉：**

   * 在 ViT-B/16 上，自注意力改造带来显著提升；
   * 在 ViT-L/14 上，q-q、k-k 甚至比原始 q-k 还差（Fig.2、Fig.5 下排），说明 residual 在大模型里影响更大。

3. **局部可区分性差：**

   * 统计发现：在 CLIP 中，残差分支 $$X_{\text{res}}$$ 在各层的 normalized entropy 接近 0，而注意力分支 $$X_{\text{attn}}$$ 保持接近 1（Fig.4）。
   * 说明 $$X_{\text{res}}$$ 中只有少数几个 channel 的值特别大（“高能通道”），大部分 patch 在这些通道方向上都很相似。

   这对于图像分类（需要全局方向）还可以，但对“区分不同空间位置的 patch”非常糟糕——用余弦相似度时，不同位置 patch 的方向太像，很难区分，从而产生噪声分割。

### 1.c 论文的直觉 / 核心假设（白话版）

用一句话概括作者的直觉：

> **CLIP 的训练让残差支变成“强全局、弱局部”的特征，而 attention 支保留了局部可分性；只要把 residual 砍掉、放大 attention，就能得到更干净的 dense 特征。**

更形式一点：

1. 残差 $$X_{\text{res}}$$ 在 latent 空间里被训练成对比学习的“全局方向”，层数越深，高能通道越集中、熵越低；
2. attention $$X_{\text{attn}}$$ 通过自注意力在空间上区分不同位置，保留局部差异；
3. 最终输出 $$X_{\text{sum}} = X_{\text{res}} + X_{\text{attn}}$$ 被残差里的高范数全局方向主导 ⇒ 破坏局部区分能力 ⇒ noisy segmentation；
4. 因此：**去 residual、强化 self-self attention 输出** 是提升 dense vision-language 的关键。

---

## 2. 方法设计（ClearCLIP）

### 2.a 整体流程（pipeline）

先回顾标准 CLIP ViT block 的形式：输入 token 序列
$$
X = [x_{\text{cls}}, x_1, \dots, x_{hw}]^\top \in \mathbb{R}^{(1+hw)\times d},
$$
其中 $$x_{\text{cls}}$$ 是全局 token，$$x_i$$ 是每个 patch 的视觉 token。最后一个 transformer block 计算：

1. 投影得到 $$q,k,v$$：
   $$
   q=\text{Proj}_q(\text{LN}(X)),\quad
   k=\text{Proj}_k(\text{LN}(X)),\quad
   v=\text{Proj}_v(\text{LN}(X))
   $$
2. 计算 q-k attention：
   $$
   \text{Attn}_{qk} = \text{softmax}\Big(\frac{qk^\top}{\sqrt{d_k}}\Big)
   $$
3. 注意力输出并加残差：
   $$
   X_{\text{attn}} = \text{Proj}(\text{Attn}_{qk}\cdot v),\quad
   X_{\text{sum}} = X_{\text{res}} + X_{\text{attn}} = X + X_{\text{attn}}
   $$
4. 再过一层 FFN：
   $$
   X_{\text{out}} = X_{\text{sum}} + \text{FFN}(\text{LN}(X_{\text{sum}}))
   $$

**Dense 分割 baseline：**

* 丢掉 CLS，只保留 patch token：
  $$
  X^{\text{visual}}_{\text{dense}} \in \mathbb{R}^{hw\times d}
  $$
* 文本侧：对每个类别 $$c$$，构造 prompt “a photo of a {label}”，用 CLIP 文本编码器得到
  $$
  X^{\text{text}} \in \mathbb{R}^{C\times d}
  $$
* 分割时，对每个位置 patch 向量与所有类别向量做余弦相似度并取 argmax：
  $$
  \mathcal{M}(i) = \arg\max_c\ \text{cos}\big(X^{\text{visual}}_{\text{dense}}(i,:),\ X^{\text{text}}(c,:)\big)
  $$
  最后 reshape 成 $$H\times W$$ 的语义 mask。

**ClearCLIP 改动点（都在最后一个 block）**：

1. **去掉残差连接：**

   不再做 $$X_{\text{sum}} = X + X_{\text{attn}}$$，而是直接用 $$X_{\text{attn}}$$ 做输出。

2. **使用 self-self attention（默认 q-q）：**

   把原来的 $$\text{Attn}_{qk}$$ 换成
   $$
   \text{Attn}_{qq} = \text{softmax}\Big(\frac{qq^\top}{\sqrt{d_q}}\Big)
   $$
   或其他 self-self 组合（q-q, k-k, v-v, I），实际发现 q-q 效果最好，因此默认采用：
   $$
   X^{\text{visual}} = X_{\text{attn}} = \text{Proj}(\text{Attn}_{qq}\cdot v)
   $$

3. **丢弃 FFN：**

   最后一层不再用 FFN：
   $$X_{\text{out}} = X_{\text{attn}} \quad (\text{不做 }+\text{FFN}(\cdot))$$

4. **后续 dense 推理不变：**

   * 仍然把 $$X^{\text{visual}}$$ 去掉 CLS，得到 $$hw\times d$$ 的 patch 特征；
   * 与文本特征做余弦、argmax 得分割图，公式同上。

所以 ClearCLIP 本质上就是：

> **把最后一层“残差 + FFN”砍掉，只保留 self-self attention 的空间重组输出，然后用它做 patch–文本的相似度分割。**

### 2.b 各模块作用与协同

1. **残差连接（RC）：**

   * 保持了前一层的表示 $$X_{\text{res}} = X$$；
   * 在 CLIP 对比训练下，它被塑造成“高范数、低熵、少数通道主导”的表示——即强全局方向，弱局部区分。
   * 对 classification 很好，对 dense segmentation 却是噪声来源。

2. **Self-self attention：**

   * 通过 $$\text{Attn}_{qq}, \text{Attn}_{kk}, \text{Attn}_{vv}$$ 等形式，让 token 之间根据自己的相似性进行空间上的重组；
   * 更关注局部语义关系（patch 与 patch 之间）；
   * 当 residual 被去掉时，这种空间重组直接决定最终特征的结构 ⇒ 得到更清晰、连贯的分割图。

3. **FFN：**

   * 理论上是做位置无关的非线性变换；
   * 但论文和 CLIPSurgery 的发现：最后一层 FFN 对“最终分类特征方向”影响很大，但对 dense 任务帮助有限甚至有害；
   * 在去 residual 之后，原本为“带 residual 的表示”设计的 FFN 变成不匹配的变换，于是直接丢掉反而更稳定。

4. **缩放因子 $$\alpha$$ 的分析（动机的一部分）：**

   作者设置
   $$
   X_{\text{sum}} = X_{\text{res}} + \alpha X_{\text{attn}}
   $$
   发现随着 $$\alpha$$ 增大，mIoU 持续上升；当 $$\alpha$$ 很小（0.5）时性能急剧下降（Fig.6）。

   ⇒ **放大 attention 输出、相对压制 residual** 能显著提升性能；极端情况就是完全去掉 residual（ClearCLIP 的做法）。

### 2.c 关键公式的通俗解释

1. **Entropy 公式（分析噪声来源）：**

   对于第 $$L$$ 层的特征图 $$X^L \in \mathbb{R}^{(1+hw)\times d}$$，把里面所有元素 flatten 成一维，然后做 softmax：
   $$
   p(X^L_{i,j}) = \frac{e^{X^L_{i,j}}}{\sum_{m,n} e^{X^L_{m,n}}}
   $$
   再计算归一化熵：
   $$
   H(X^L) = -\frac{1}{\log(hw\times d)}\sum_{i,j} p(X^L_{i,j}) \log p(X^L_{i,j})
   $$

   * 如果只在少数元素上非常大，其余都很小 ⇒ 分布很“尖” ⇒ 熵接近 0；
   * 如果比较均匀 ⇒ 熵接近 1。

   结果：CLIP 的 $$X_{\text{res}}, X_{\text{sum}}$$ 熵很低，而 DINO 的三个特征都比较稳定 ⇒ 佐证 CLIP 残差里“少数高能通道支配”的现象。

2. **Scaling 因子 $$\alpha$$：**

   $$X_{\text{sum}} = X_{\text{res}} + \alpha X_{\text{attn}}$$

   * 当 $$\alpha \uparrow$$：attention 的范数变大，开始在相加中主导方向 ⇒ 分割质量变好；
   * 当 $$\alpha \downarrow$$：residual 主导 ⇒ 回到 noisy segmentation。
     ClearCLIP 做的是“极限情况”：相当于 $$\alpha \to \infty$$ 且不再加 residual。

---

## 3. 与其他方法对比

### 3.a 与主流方法的本质区别

* 以往 training-free 方法（MaskCLIP、CLIPSurgery、SCLIP、GEM）：

  * **主要改 attention 形式**：从 q-k 改到 self-self（q-q, k-k, v-v, I 等），以期更好地“重组空间信息”；
  * 残差 + FFN 结构保留不动。
* ClearCLIP：

  * 从“特征分解 + 统计分析”的角度指出：**残差才是噪声主源**；
  * 直接 **去掉最后层残差和 FFN**，只用注意力输出做 dense 特征；
  * attention 选择只是“锦上添花”（q-q 最好），真正关键是结构层面的“拆残差”。

本质上，前人是在“加强干净信号（attention）”，ClearCLIP 是“直接砍掉噪声通道（residual + FFN）”。

### 3.b 创新点与贡献

1. **诊断性贡献：**

   * 通过范数、熵、通道均值等统计，系统证明残差分支在 CLIP 中产生高范数、低熵、少通道主导的特征，这是 dense segmentation 噪声的主要来源。

2. **结构性改造：**

   * 提出 ClearCLIP：仅在**最后一层**做“三连拆”：去残差、self-self attention、去 FFN，结构极其简单（2–3 行代码改动）。

3. **广泛适配：**

   * 在 CLIP、OpenCLIP、MetaCLIP、BLIP、MaskCLIP、SCLIP、GEM 等多种模型上，都可以直接套 ClearCLIP 作为“free lunch”，平均提升可达 20+ mIoU（Tab.5）。

4. **大模型友好：**

   * 以往方法在 ViT-L/14 上常常崩掉，ClearCLIP 在 L/14 上依然显著提升（CLIP-L/14 从 5.4 → 34.5 mIoU）。

### 3.c 适用场景

* **开放词汇 / 零样本语义分割**，尤其是：

  * 没有像素标签或只想 training-free；
  * 想直接利用预训练 CLIP / OpenCLIP 等模型；
  * 想在多数据集上统一评估而不愿为每个数据集 fine-tune。
* 类似的 **dense vision-language 任务**：

  * open-vocabulary stuff/thing segmentation；
  * weakly-supervised分割、mask proposal 生成等。

### 3.d 对比表（简化）

| 方法类别                               | 是否训练 | 关键操作                                        | 优点                                                              | 缺点 / 改进点                           |
| ---------------------------------- | ---- | ------------------------------------------- | --------------------------------------------------------------- | ---------------------------------- |
| CLIP baseline                      | ✗    | 直接用最后层 $$X_{\text{sum}}$$ + 文本余弦            | 实现极简单                                                           | 分割极度 noisy，mIoU 很低                 |
| MaskCLIP / CLIPSurgery / SCLIP 等   | ✗    | 改 attention 形式（I / v-v / q-q+k-k），仍保留残差+FFN | 明显提升 mIoU；注意力更聚焦                                                | 残差噪声仍在；大模型（L/14）表现不稳定              |
| Weakly-supervised（GroupViT, TCL 等） | ✓    | 设计 grouping / mask 生成模块，训练额外网络              | 性能较好，可学到更细致 mask                                                | 需要训练和额外数据；实现复杂                     |
| **ClearCLIP**                      | ✗    | 最后一层去残差 & FFN，只用 self-self attention 输出     | 结构极简，可直接加在多种模型上；大幅提升 mIoU，尤其是 CLIP / OpenCLIP / MetaCLIP；大模型也稳定 | 仍受 CLIP 本身分辨率、预训练数据分布限制；不是端到端可训练结构 |

---

## 4. 实验表现与优势

### 4.a 实验设计与设置

* **数据集（共 8 个）**：

  * 有背景类：VOC21, PASCAL Context60, COCO Object；
  * 无背景类：VOC20, Context59, COCOStuff, Cityscapes, ADE20K。
* **度量**：mIoU。
* **实现**：

  * 基于 MMSegmentation，采用 sliding window；
  * 输入图像短边 resize 到 448；
  * 文本侧使用标准 ImageNet prompt（不做花式 prompt engineering）；
  * 不做任何后处理（如 CRF、条件随机场等）；
  * **完全 training-free**：不对 CLIP / OpenCLIP 等做任何微调。

### 4.b 关键结果（指标）

1. **无背景类（Tab.2）——CLIP ViT-B/16：**

   * CLIP baseline：平均 mIoU $$12.6$$；
   * MaskCLIP：$$28.0$$；SCLIP（复现版）：$$35.2$$；
   * **ClearCLIP：$$37.5$$（5 个数据集平均），在 VOC20/Context59/Stuff/Cityscapes/ADE20K 上 4/5 个数据集最佳。**

2. **无背景类——CLIP ViT-L/14：**

   * CLIP：仅 $$5.4$$；
   * MaskCLIP：$$13.7$$；SCLIP：$$23.6$$；
   * **ClearCLIP：$$34.5$$，比 SCLIP 高约 11 mIoU，比 baseline 高 29 mIoU。**

3. **有背景类（Tab.3）——CLIP ViT-B/16：**

   * TCL（弱监督 SOTA）：平均 $$35.3$$；
   * SCLIP*（无重命名技巧复现）：$$37.3$$；
   * **ClearCLIP：$$39.1$$，在 Context60 和 COCO Object 上分别高出 SCLIP* 2.1 和 3.0 mIoU。**

4. **“Free lunch” 适配到其他模型（Tab.5）：**

   * 例如在 BLIP ViT-B 上：baseline 平均 $$11.4$$，+ClearCLIP 变 $$32.7$$，提升 21.3 mIoU；
   * 在 MetaCLIP ViT-B 上：11.0 → 36.4，+25.4；
   * 对 MaskCLIP / SCLIP / GEM 再叠加 ClearCLIP 也有小幅提升。

总体来看，**在完全不训练的前提下，ClearCLIP 把“纯 CLIP 分割”从几乎不可用拉到接近弱监督方法的水平**。

### 4.c 哪些场景 / 数据集优势最明显？

* **大 backbone（ViT-L/14）**：

  * 之前方法在 L/14 上往往崩掉，而 ClearCLIP 在 L/14 上的平均 mIoU 甚至接近 B/16 版本（34.5 vs 37.5），稳定又高效。
* **原始 CLIP / OpenCLIP / MetaCLIP / BLIP baseline 非常弱的场景**：

  * ClearCLIP 的提升往往是 +20 ~ +25 mIoU 级别（Tab.5）。
* **复杂多类场景（COCOStuff, ADE20K, Context59/60）**：

  * 从可视化（Fig.7,10,11）可以看出 ClearCLIP 的 mask 更干净、边界更连贯、碎块明显减少。

### 4.d 局限性

论文中显式或隐含的局限包括：

1. **仍然是 training-free**：

   * 相较完全监督 / 强弱监督方法（如一些 diffusion-based 或专门训练的 open-vocab seg 网络），性能仍有差距；
2. **受 CLIP 分辨率和 patch 大小限制**：

   * 最终 dense 特征的空间分辨率由 ViT patch size 决定（如 16×16），再通过插值上采样到原图；
   * 对极精细边界、细小物体的分割仍然有限；
3. **依赖 CLIP 预训练数据分布**：

   * 若目标类别在 CLIP 预训练中本身就表示较差，ClearCLIP 也难以弥补；
4. **只修改最后一层**：

   * 更深层次的结构问题可能仍然存在，但这一层已经带来足够大的收益。

---

## 5. 学习与应用（复现/迁移建议）

### 5.a 是否开源？复现关键步骤

* 论文给出 GitHub 地址：`https://github.com/mc-lan/ClearCLIP`（在首页和文中多处提到）。 

**如果你自己实现，关键步骤：**

1. **拿到预训练 CLIP / OpenCLIP / etc. 的 ViT 模型**；
2. **找到最后一个 transformer block**，把它拆成：

   * LN → q/k/v projection；
   * attention 计算；
   * 输出 projection；
   * 残差和 FFN；
3. **改造最后一层 block：**

   * 把 $$\text{Attn}_{qk}$$ 换成 $$\text{Attn}_{qq}$$（或其他 self-self）；
   * 直接输出 $$X_{\text{attn}} = \text{Proj}(\text{Attn}_{qq}\cdot v)$$；
   * 不再做 $$X + X_{\text{attn}}$$，也不再过 FFN。
4. **dense 推理：**

   * 去掉 CLS，只保留 patch tokens；
   * 文本侧用原始 CLIP 文本编码器算出类别 embedding；
   * 对每个 patch 与每个类别做余弦相似度，取 argmax；
   * 按照 ViT patch 网格 reshape 成低分辨率 mask，然后双线性插值到原图分辨率；
   * 按数据集类别集合、是否有 background 类去映射标签。

如果你用 MMSeg，ClearCLIP 相当于“改一个 backbone 的 forward + 简单 decode head”。

### 5.b 超参数、预处理、训练细节建议

虽是 training-free，但有几处“工程性的细节”值得注意：

1. **Attention 形式选择：**

   * 论文中 q-q 是默认；你可以尝试 k-k / v-v / I 作 ablation，但整体趋势是 q-q 最稳、平均 mIoU 最好。

2. **只改最后一层：**

   * 前面所有层保持原样（包括 residual & FFN），只在 last block 改，既省事也稳定；
   * 若想进一步探索，可尝试多层去 residual，但论文没这么做。

3. **输入尺度：**

   * 短边 448，长边按比例缩放，对软硬件很友好；过小分辨率会损失细节，过大显存吃不消。

4. **文本 prompt：**

   * 使用 ImageNet 标准 prompt，不做复杂 prompt 工程；
   * 若你在特定任务上，可以尝试 prompt ensemble 或 synonyms，通常能小幅增益。

5. **滑窗预测：**

   * 大图可以采用 sliding window，窗口和 stride 要与 ViT patch grid 对齐，防止边缘 artifacts。

### 5.c 向其他任务迁移的可能性

ClearCLIP 本质是：**让 CLIP 产生更干净、更局部可分的 dense 特征**，所以可以考虑迁移到：

1. **开放词汇检测 / instance segmentation：**

   * 把 ClearCLIP 的 patch 特征作为 backbone 特征，接入 proposal / segmentation head；
   * 利用文本 embedding 做 open-vocab 分类。

2. **弱监督 / 无监督分割：**

   * ClearCLIP 提供更好的“语义种子”，可以与 grouping / clustering 方法（如 GroupViT、PGSeg）组合。

3. **可视化解释 / 语义显著性：**

   * 相比原始 CLIP 的激活图，ClearCLIP 的激活更干净，可用于可视化解释、cross-modal grounding 等。

4. **Referring segmentation / phrase grounding：**

   * 把文本从“类别名”换成自然语言描述（短句），用同样的 dense 相似度机制即可。

---

## 6. 总结与速记

### 6.a 一句话核心思想（≤20 字）

> **砍掉残差与 FFN，让自注意力单独负责局部对齐。**

（或者：**移除残差放大注意力，提纯 CLIP 密集特征。**）

### 6.b 速记版 pipeline（不用论文术语）

1. 把图像切成很多小块并提取它们的向量。
2. 在最后一层只用“小块之间互相注意”的结果，不再加回原始向量，也不再过额外网络。
3. 把每个类别的文字变成向量。
4. 比较每个小块向量和各类别文字向量的相似度。
5. 把相似度最大的类别标签，贴回到对应图像位置，得到整张分割图。

如果你后面想，我也可以帮你对照你自己的方法（比如基于一阶段 ZegCLIP 改进）看，哪些思想可以直接拿来：比如“去残差的 last-block 改造”能不能迁到你的一阶段结构里。
