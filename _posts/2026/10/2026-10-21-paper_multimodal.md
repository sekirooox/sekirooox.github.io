---
title: "论文阅读·多模态工作"
author: MayL
date: 2026-10-21
categories: ["论文阅读与科研", "论文阅读"]
tags: ["论文阅读", "科研笔记"]
render_with_liquid: false
math: true
description: "本文记录“论文阅读·多模态工作”的研究问题、主要方法与实验结论，便于理解论文并开展后续研究。"
---
# 端到端视觉-语言训练
## CLIP

## ALBEF：ALign BEfore Fusion

预训练的视觉特征和文本特征一开始间隔很远，**不利于在最后多模态的编码器进行学习(对齐)**。

模型本质上：就是CLIP的模型，但是为了保留一个多模态的编码器，因此**将BERT的模型拆分成文本和多模态编码器(使用交叉注意力对齐)**。

三种损失：图文对比损失，图文匹配损失，语言模型损失

图文匹配损失：**给定图像和文本，输出一个二分类值**，表示是否匹配。这一步通过利用对比损失构造最难样本进行加速。

语言模型损失：给定图像和掩码后的文本，**输出掩码处的文本**。
<figure><img src="https://i-blog.csdnimg.cn/direct/a5ea26a95e8447c4a59c207c83c877f2.png" alt="多模态学习" width="720"><figcaption><p>ALBEF 对齐结构</p></figcaption></figure>
## VLMO
动机：同一双塔模型(CLIP，视觉和文本编码器完全独立且分开)；单塔模型(有一个多模态编码器，推理速度)

模型：MOE的架构，**只不过MOE换成模态的专家FFN，有一个负责模态融合FFN(VL-FFN)**

采用共享注意力权重，**分阶段训练单一模态，多模态的训练方式**。

<figure><img src="https://i-blog.csdnimg.cn/direct/9f56518c0430407ca845dc938e1c4e7b.png" alt="多模态学习" width="720"><figcaption><p>VLMO 模态专家</p></figcaption></figure>
<figure><img src="https://i-blog.csdnimg.cn/direct/1a111426bc044338ae2eecea98805f80.png" alt="多模态学习" width="720"><figcaption><p>VLMO 共享注意力</p></figcaption></figure>



## BEIT-3

动机：**利用掩码语言损失来直接进行损失计算**。同一个多个模态间的计算。
<figure><img src="https://i-blog.csdnimg.cn/direct/d6a278bb5abc4376ac4bbd5bf242887a.png" alt="多模态学习" width="720"><figcaption><p>BEIT-3 多模态预训练</p></figcaption></figure>

## BLIP：实现视觉-语言理解 (VQR和IT-R)和生成 (VQA)的大一统

### Multimodal mixture of Encoder-Decoder (MED)

共享**自注意力 (SA)**，**交叉注意力层 (CA)**，**FFN层**，根据子任务分别采用不同的**特异化模块** (例如因果注意力层)，得到不同的编码/解码器 (视觉和文本编码器，视觉-文本-**接地编码**器，视觉-文本-**接地解码**器)`统一学习截然不同的视觉`任务。

<figure><img src="/assets/img/posts/paper-multimodal/duo-mo-tai-tu-05.png" alt="多模态学习" width="720"><figcaption><p>BLIP 多模态编码器</p></figcaption></figure>

>颜色相同`表示参数共享`。

Unimodal encoder：包括文本和视觉，视觉可以使用ViT或者Res，文本可以使用Bert。

Image-grounded text encoder：使用自注意力 (SA)，交叉注意力层 (CA)和FFN。主要对应的任务是**视觉-文本的语义理解**。

Image-grounded text decoder：使用因果自注意力 (CSA)，交叉注意力层 (CA)和FFN。主要对应的任务是**从视觉到文本生成**。

#### Image-Text Contrastive Loss (ITC)：对齐图像和文字，实现图文检索
和CLIP基本一致，List-wise，**给定图像和文本字幕**，让匹配的图像和文本在表示空间中更接近。



#### Image-Text Matching Loss (ITM)：对齐图像和字幕，实现图文理解

ITM是一种**二元分类任务**，模型利用**ENCODE token**和**ITM头**预测图像-文本对根据其多模态特征是正（匹配）还是负（未匹配）。

为了寻找更多信息的负面，我们采用了Li等人（2021a）的硬负挖掘策略，其中批次中对比相似度更高的负对更有可能被选中来计算损失。

```text
文本 token
    ↓
Cross-Attention 读取图像特征
    ↓
融合后的 [CLS] 或 [Encode] 表示
    ↓
二分类头
    ↓
匹配 / 不匹配
```

对应的二分类损失可以写成：
$$
\mathcal{L}_{ITM}=
-\left[
y\log p_{\text{match}}
+
(1-y)\log(1-p_{\text{match}})
\right]
$$

>ITC（Image-Text Contrastive，图文对比学习）：学习图像和文本的**全局表示**是否相近。
ITM（Image-Text Matching，图文匹配）：学习一对图像和文本是否真正匹配，通常是二分类判断。

#### Language Modeling Loss (LM)：实现图文问答

语言建模丢失（LM）激活了基于图像的文本解码器，旨在根据图像生成文本描述。它优化交叉熵损失，训练模型以自回归方式最大化文本的概然。计算损失时，我们会应用0.1的标签平滑。与广泛用于VLP的MLM损耗相比，LM使模型具备将视觉信息转换为连贯说明的泛化能力。

### CapFilt：自举训练
>字幕生成器通过LM**语言损失**进行微调，学习视觉-文本生成；过滤器通过**ITC和ITM损失**进行微调，学习视觉-文本理解 (**判别式任务**)。

<figure><img src="/assets/img/posts/paper-multimodal/duo-mo-tai-tu-06.png" alt="多模态学习" width="720"><figcaption><p>CapFilt 字幕过滤</p></figcaption></figure>

我们提出了字幕与过滤（CapFilt）新方法，旨在提升文本语料库的质量。图3展示了CapFilt的示意图。它引入了两个模块：一个用于生成给定网页图片的说明文字的字幕器，以及一个用于去除噪点图像-文本对的过滤器。字幕生成器和过滤器`均从同一预训练的MED模型初始化`，并在COCO数据集上**单独微调**。

<figure><img src="/assets/img/posts/paper-multimodal/duo-mo-tai-tu-07.png" alt="多模态学习" width="720"><figcaption><p>BLIP-2 Q-Former</p></figcaption></figure>

微调是一个轻量化的过程。具体来说，字幕器是一个基于图像的文本解码器。**它根据LM的目标进行微调**，用于解码给定的图像文本。给定网页图片Iw，说明员生成合成标题T，每张图片只有一个说明。

该滤波器是一个基于图像的文本编码器。它根据**ITC和ITM**的目标进行微调，以判断文本是否与图像匹配。该过滤器会在原始网页文本 Tw 和合成文本 Ts 中去除噪点文本，后者如果 ITM 头预测文本与图像不匹配，则该文本被视为噪声。最后，我们将筛选后的图像-文本对与人工注释对结合，形成一个新数据集，用于预训练新模型。



### 下游任务迁移：实现匹配 (检索)-理解 (二分类)-生成 (自回归)

+ 图文检索：topk搜索
+ 字幕生成：可以不经过图像-文本接地编码器。
+ VQA：全流程，视觉-语言理解+生成。
+ VQR：需要接地编码器，本质作为**二分类**任务。例如"图像中有狗吗"->输出"true/false"
+ Visual Dialog (VisDial)：视觉对话，需要**引入额外的对话编码器**进行适配。

<figure><img src="/assets/img/posts/paper-multimodal/duo-mo-tai-tu-08.png" alt="多模态学习" width="720"><figcaption><p>查询变换器结构</p></figcaption></figure>



# 模块化视觉-语言训练

## LiT（2022）	

高效图文对齐，**冻结视觉编码器**，训练文本侧。

保留图文对比学习范式，没有重点解决 LLM 的**视觉条件生成**。

## Frozen（2021）	
让冻结 LLM **接收视觉输入，训练视觉侧**，将视觉表示用作 LLM 的连续提示。

较**直接地适配**视觉输入，缺少 BLIP-2 的 Q-Former 两阶段训练。

## Flamingo（2022）
多模态少样本学习，冻结预训练模块 + **Perceiver Resampler** + LLM **内部 Cross-Attention**	修改 LLM 的**计算架构**以注入视觉信息。

**修改了LLM的内部结构**，引入的适配器和LLM内部架构**参数量较大**。

## BLIP-2：轻量级模块化视觉-语言训练

<figure><img src="/assets/img/posts/paper-multimodal/duo-mo-tai-tu-09.png" alt="多模态学习" width="720"><figcaption><p>查询变换器训练</p></figcaption></figure>

### Query-Former：高效提取多模态视觉和文本特征

<figure><img src="/assets/img/posts/paper-multimodal/duo-mo-tai-tu-10.png" alt="多模态学习" width="720"><figcaption><p>视觉提示投影</p></figcaption></figure>

基本思路：**漏斗型**的模型结构，**输入是文本和Query tokens**，多通道输出，分别计算ITC，ITM和ITG损失，**通过注意力掩码隔离不同的任务**。

我们提出Q-Forform作为可训练模块，用以弥合冻结图像编码器与冻结LLM之间的差距。它从图像编码器中提取固定数量的输出特征，独立于输入图像分辨率。

如图2所示，Q-Forformer 由两个`共享相同自注意力层`的变换器子模块组成：
（1） 与**冻结**图像编码器交互的图像变换器对于视觉特征提取，
（2）一个既可以作为文本编码器又能作为文本解码器的文本转换器。我们为图像变换器**创建了一定数量的可学习查询嵌入**。

查询通过自关注层相互交互，并通过交叉注意力层（每隔一隔插入一次）与冻结的图像特征交互。查询还可以**通过相同的自我注意力层与文本互动**。

根据预训练任务的不同，我们应用不同的自我注意力掩体来控制查询与文本的交互。我们用 BERTbase 的预训练权重初始化 QFormer（Devlin 等，2019），而交叉注意力层则是随机初始化的。总共，Q-Forform包含1.88亿参数。请注意，查询被视为模型参数。

### 第一阶段训练：根据三大目标预训练Query-Former
统一化的输入：query tokens + text embeddings

ITC：通过单模态掩码，避免query和text进行互动，然后通过两个通道获得编码后的query tokens和text [CLS] embeddings，计算ITC损失。

>注意：**query tokens有K个**，因此会**选择与[CLS]匹配最大**的一个，作为与该组query tokens的匹配结果。

ITM：query tokens直接**送入二分类头**，完成二分类任务。

ITG：text tokens用于NTP loss。

### 第二阶段训练：微调Query-Former和LLM适配器


在生成预训练阶段，我们将QFormer（带冻结图像编码器）连接到冻结的LLM上，以获取LLM的生成语言能力。如图3所示，我们使用**全连通（FC）层线性投影**输出查询嵌入Z到与LLM文本嵌入**相同的维度**。投影的查询嵌入随后会在输入`文本嵌入前加上`。它们作为**软视觉提示**，对 Q-former 提取的视觉表示进行条件条件。

由于Q-Former已预训练以提取语言信息视觉表示，它实际上作为信息瓶颈，将最有用的信息输入LLM，同时剔除无关的视觉信息。这减轻了LLM学习视觉-语言对齐的负担，从而减轻了灾难性的遗忘问题。

我们实验了两种类型的大型语言模型：基于译码器的LLM和基于编码器-解码器的LLM。对于基于解码器的LLM，我们**预训练语言建模丢失**，其中冻结的LLM被要求生成基于Q-Former视觉表示的文本。

对于基于编码器-解码器的大型语言模型，我们用前缀语言建模损失进行预训练，**将文本拆分为两部分**。前缀文本与视觉表示作为LLM编码器的输入串接。后缀文本作为LLM解码器的生成目标。

<figure><img src="/assets/img/posts/paper-multimodal/duo-mo-tai-tu-11.png" alt="多模态学习" width="720"><figcaption><p>多模态下游任务</p></figcaption></figure>

### 下游任务：冻结LLM，微调Query-Former和LLM适配器

我们对BLIP-2模型进行微调，用于**图像标题任务**，该任务要求模型生成图像视觉内容的文本描述。

给定带注释的VQA数据，我们会微调Q-Forform和图像编码器的参数，同时保持LLM冻结。我们对开放式答案生成损失进行微调，即**LLM接收Q-Former的输出和问题作为输入**，并被要求生成答案。为了提取与问题更相关的图像特征，我们对问题进行了条件化Q-Forformer。

由于图像-文本检索不涉及语言生成，我们直接微调**第一阶段预训练模型，无需LLM**。具体来说，我们与 Q-Former 一起在 COCO 上微调图像编码器，使用与预训练相同的目标（即 ITC、ITM 和 ITG）进行

