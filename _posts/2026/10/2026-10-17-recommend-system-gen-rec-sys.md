---
title: "生成式推荐与判别式推荐"
date: 2026-10-17 00:00:00 +0800
description: 梳理生成式推荐的建模方式、模型架构、语义 ID 及残差量化方法。
categories: [推荐系统]
tags: [推荐系统, 生成式推荐, Transformer, LLM, 语义ID, 向量量化]
render_with_liquid: false
pin: false
math: true
mermaid: false
---

## 判别式推荐与生成式推荐

### 判别式推荐

判别式推荐以用户与物品的静态特征（如 ID、类目属性）及动态特征（如行为序列）为输入，预测点击率（CTR）、转化率（CVR）等业务指标。其核心是学习条件概率 $$p(y=1\mid u,i,c)$$，用于估计用户 $$u$$ 在上下文 $$c$$ 中对物品 $$i$$ 产生正向交互的概率；$$y$$ 表示交互标签。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-pan-bie-shi-jian-mo.png" alt="生成式推荐" width="702"><figcaption><p>判别式推荐建模</p></figcaption></figure>

### 生成式推荐

生成式推荐根据用户属性、上下文以及历史交互序列（包括物品 ID 与曝光后的反馈行为），直接生成下一步行为或物品。它将推荐建模为序列生成过程：

$$
\begin{align}
p_\theta(i_{1:T}\mid u,c) &= \prod_{t=1}^{T}p_\theta(i_t\mid i_{<t},u,c)
\end{align}
$$

其中，$$\theta$$ 表示模型参数，$$i_{1:T}$$ 表示长度为 $$T$$ 的物品序列，$$i_{<t}$$ 表示第 $$t$$ 步之前的历史序列，$$u$$ 和 $$c$$ 分别表示用户与上下文。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-sheng-cheng-shi-jian-mo.png" alt="生成式推荐" width="708"><figcaption><p>生成式推荐建模</p></figcaption></figure>

### 两类范式的差异

判别式推荐通常存在以下局限：

- 推荐链路与网络结构复杂，工程优化成本较高。
- 信息在多阶段链路中流动受限，较依赖特征工程，且各阶段的优化目标往往不一致。

生成式推荐尝试用统一的序列目标贯通表示、召回与生成，但也带来了离散物品表示、生成约束和在线推理效率等新问题。

## 生成式推荐模型

### Transformer

#### 注意力机制

标准缩放点积注意力先计算查询与键的相似度，再通过 softmax 得到注意力权重：

$$
\begin{align}
\mathbf A &= \operatorname{softmax}\!\left(\frac{\mathbf Q\mathbf K^{\mathsf T}}{\sqrt{d_k}}\right)
\end{align}
$$

其中，$$\mathbf Q,\mathbf K\in\mathbb R^{T\times d_k}$$ 分别表示查询矩阵和键矩阵，$$d_k$$ 表示键向量维度，$$T$$ 表示序列长度，$$\mathbf A\in\mathbb R^{T\times T}$$ 表示注意力权重矩阵。部分推荐模型会调整或替换 softmax 归一化，以强化兴趣相关信号，但图中展示的是标准形式。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-zhu-yi-li-quan-zhong.png" alt="生成式推荐" width="719"><figcaption><p>注意力权重计算</p></figcaption></figure>

#### 位置编码

Transformer 常用正弦位置编码（sinusoidal positional encoding）、相对位置编码和旋转位置编码（RoPE）。推荐系统除序列顺序外，还需显式建模物品—物品、物品—行为及行为—行为之间的<span style="color:red">绝对位置关系</span>与<span style="color:red">时间差</span>。

> 即使物品 1 和物品 2 在序列中相邻，如果两次行为间隔数年，它们也可能没有显著关联。

#### 编码器—解码器架构

LLM 通常采用仅解码器（decoder-only）架构；推荐输入不仅包含行为序列，还包括<span style="color:red">用户画像和推荐目标</span>。编码器可压缩这些条件信息，并通过交叉注意力与解码器交互，从而控制自回归生成方向。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-bian-ma-jie-ma-jia-gou.png" alt="生成式推荐" width="706"><figcaption><p>编码器解码器架构</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-shuang-jia-gou-dui-bi.png" alt="生成式推荐" width="684"><figcaption><p>双架构对比</p></figcaption></figure>

#### 定制化掩码

标准因果掩码会阻止当前位置关注未来信息：

$$
\begin{align}
\operatorname{Attention}(\mathbf Q,\mathbf K,\mathbf V) &= \operatorname{softmax}\!\left(\frac{\mathbf Q\mathbf K^{\mathsf T}}{\sqrt{d_k}}+\mathbf M\right)\mathbf V
\end{align}
$$

其中，$$\mathbf Q,\mathbf K\in\mathbb R^{T\times d_k}$$，$$\mathbf V\in\mathbb R^{T\times d_v}$$，掩码矩阵 $$\mathbf M\in\mathbb R^{T\times T}$$，输出矩阵属于 $$\mathbb R^{T\times d_v}$$。

$$
\begin{align}
M_{ij} &= \begin{cases}
0, & j\le i,\\
-\infty, & j>i.
\end{cases}
\end{align}
$$

其中，$$M_{ij}$$ 表示位置 $$i$$ 对位置 $$j$$ 的掩码值；当 $$j>i$$ 时，未来位置在 softmax 后获得零权重。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-yin-guo-yan-ma-ji-suan.png" alt="生成式推荐" width="712"><figcaption><p>因果掩码计算</p></figcaption></figure>

还可以将用户行为序列<span style="color:red">划分为多个会话</span>，通过会话级掩码增强会话内关联并减少跨会话噪声；多任务场景也可按点击、转化等目标设计不同的可见范围。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-ding-zhi-hua-yan-ma.png" alt="生成式推荐" width="717"><figcaption><p>定制化掩码</p></figcaption></figure>

### 扩散模型

扩散模型先在前向过程中逐步加入噪声，再在反向过程中学习去噪。用于推荐时，它既可增强用户或物品表示，也可并行生成推荐序列，并承担多模态融合或协同图建模任务。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-kuo-san-qu-zao-guo-cheng.png" alt="生成式推荐" width="665"><figcaption><p>扩散与去噪过程</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-kuo-san-tui-jian-ying-yong.png" alt="生成式推荐" width="710"><figcaption><p>扩散推荐应用</p></figcaption></figure>

扩散模型的生成质量与灵活性较强，但多步采样会增加推理延迟；工业部署通常需要在生成质量和实时性之间权衡。

### LLM 用于推荐

- 预训练：对齐语言建模与推荐建模的目标，并兼顾用户行为序列和多模态内容。
- 指令微调：将推荐任务表达为可学习的指令，同时处理高度 ID 化的物品。
- 偏好对齐：推荐系统难以定义统一奖励信号，通常需要综合多样性、个性化等多个目标。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-da-mo-xing-tui-jian-shi-pei.png" alt="生成式推荐" width="684"><figcaption><p>大模型推荐适配</p></figcaption></figure>

## 物品分词与语义 ID

### 稀疏 ID 范式（Sparse ID-Based）

思路是<span style="color:red">沿用传统推荐系统的编码方式</span>：每个物品对应一个 ID，再由嵌入层编码。

优点是实现简单、技术成熟，并可复用传统推荐链路中的嵌入层；缺点是物品数量巨大时词表容易膨胀，新物品也难以利用 LLM 的语义泛化能力，存在冷启动问题。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-xi-shu-biao-shi-fan-shi.png" alt="生成式推荐" width="723"><figcaption><p>稀疏标识范式</p></figcaption></figure>

### 文本 ID 范式（Text-Based）

思路是<span style="color:red">沿用 LLM 的分词方式</span>，使用多个自然语言令牌描述一个物品。

优点是能够发挥 LLM 的泛化能力，且语义表达比稀疏 ID 更丰富；缺点是自然语言具有模糊性和歧义性，同一物品可能对应多种表述，从而增加生成与匹配的不确定性。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-wen-ben-biao-shi-fan-shi.png" alt="生成式推荐" width="721"><figcaption><p>文本标识范式</p></figcaption></figure>

### 语义 ID 范式（Semantic ID-Based）

语义 ID 借鉴<span style="color:red">流式索引召回</span>等方法，根据物品的潜在表示进行<span style="color:red">多级量化或聚类</span>，得到离散令牌序列。

- 组合空间：通过多级聚类可组合出规模巨大的离散编码空间。词表大小为 $K=8000$、序列长度为 $L=4$ 时，理论容量为 $K^L=8000^4\approx4\times10^{15}$。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-yu-yi-zu-he-kong-jian.png" alt="生成式推荐" width="713"><figcaption><p>语义组合空间</p></figcaption></figure>

- 层次结构：层次化编码为模型提供较强的<span style="color:red">归纳偏置</span>。模型学习到用户偏好“篮球”（如 `token 5`）后，可将偏好迁移到具有相同前缀（如 `[10, 5, ...]`）的物品，实现基于前缀的泛化。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-yu-yi-biao-shi-ceng-ci.png" alt="生成式推荐" width="714"><figcaption><p>语义标识层次</p></figcaption></figure>

- 推理能力：令牌可从一级类目、二级类目逐步过渡到细粒度属性，使模型能够隐式学习<span style="color:red">概念层面的推理过程</span>。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-yu-yi-biao-shi-tui-li.png" alt="生成式推荐" width="731"><figcaption><p>语义标识推理</p></figcaption></figure>

#### VQ-VAE：反向传播优化聚类

VQ-VAE 先由编码器得到连续表示，再从可学习码本中选择最近码字，最后由解码器重建输入。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-vq-vae-jie-gou.png" alt="生成式推荐" width="700"><figcaption><p>VQ-VAE结构</p></figcaption></figure>

##### 分配码字

$$
\begin{align}
\mathbf E &= [\mathbf e_1,\mathbf e_2,\ldots,\mathbf e_K]\in\mathbb R^{d\times K},\\
k^{*} &= \underset{j\in\{1,\ldots,K\}}{\arg\min}\,\lVert\mathbf z_e-\mathbf e_j\rVert_2,\\
\mathbf z_q &= \mathbf e_{k^{*}}
\end{align}
$$

其中，$$\mathbf E$$ 表示码本矩阵，$$K$$ 表示码本大小，$$d$$ 表示向量维度，$$\mathbf z_e,\mathbf e_j,\mathbf z_q\in\mathbb R^d$$ 分别表示编码器输出、第 $$j$$ 个码字和量化结果，$$k^{*}$$ 表示最近码字的索引。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-ma-ben-ma-zi-fen-pei.png" alt="生成式推荐" width="718"><figcaption><p>码本与码字分配</p></figcaption></figure>

##### 损失优化

$$
\begin{align}
\mathcal L_{\mathrm{VQ}} &= \underbrace{\lVert\mathbf x-\hat{\mathbf x}\rVert_2^2}_{\mathcal L_{\mathrm{recon}}}+\underbrace{\lVert\operatorname{sg}[\mathbf z_e]-\mathbf z_q\rVert_2^2}_{\mathcal L_{\mathrm{codebook}}}+\underbrace{\beta\lVert\mathbf z_e-\operatorname{sg}[\mathbf z_q]\rVert_2^2}_{\mathcal L_{\mathrm{commit}}}
\end{align}
$$

其中，$$\mathbf x$$ 和 $$\hat{\mathbf x}$$ 分别表示输入与重建结果，$$\mathcal L_{\mathrm{recon}}$$、$$\mathcal L_{\mathrm{codebook}}$$ 和 $$\mathcal L_{\mathrm{commit}}$$ 分别表示重建损失、码本损失和承诺损失，$$\operatorname{sg}$$ 表示停止梯度操作，$$\beta$$ 表示承诺损失权重。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-vq-vae-sun-shi-han-shu.png" alt="生成式推荐" width="710"><figcaption><p>VQ-VAE损失函数</p></figcaption></figure>

##### 近似可导

量化的最近邻选择不可导，VQ-VAE 使用直通估计器，在前向传播中执行离散选择，在反向传播中近似复制梯度：

$$
\begin{align}
\frac{\partial\mathcal L}{\partial\mathbf z_e} &\approx \frac{\partial\mathcal L}{\partial\mathbf z_q}
\end{align}
$$

其中，$$\mathcal L$$ 表示训练损失，$$\mathbf z_e,\mathbf z_q\in\mathbb R^d$$ 分别表示量化前后的向量；该式采用分母布局表示梯度。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-zhi-tong-gu-ji-ti.png" alt="生成式推荐" width="713"><figcaption><p>直通估计梯度</p></figcaption></figure>

#### RQ-VAE：多层残差量化

单层量化的编码容量与表达精度有限。RQ-VAE 逐层量化残差，以码字序列形成组合编码空间。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-rq-vae-can-cha-liang-hua.png" alt="生成式推荐" width="656"><figcaption><p>RQ-VAE残差量化</p></figcaption></figure>

##### 残差量化

每一层都对全部物品在该层的残差进行量化，并设置 $$K$$ 个码字：

$$
\begin{align}
\mathbf r_0 &= \mathbf z_e,\\
k_\ell &= \underset{j\in\{1,\ldots,K\}}{\arg\min}\,\lVert\mathbf r_{\ell-1}-\mathbf e_j^{(\ell)}\rVert_2,\\
\mathbf r_\ell &= \mathbf r_{\ell-1}-\mathbf e_{k_\ell}^{(\ell)},\\
\mathbf z_q &= \sum_{\ell=1}^{L}\mathbf e_{k_\ell}^{(\ell)}
\end{align}
$$

其中，$$L$$ 表示量化层数，$$\mathbf z_e,\mathbf r_\ell,\mathbf e_j^{(\ell)},\mathbf z_q\in\mathbb R^d$$，$$k_\ell$$ 表示第 $$\ell$$ 层选中的码字索引；最终语义 ID 为 $$[k_1,k_2,\ldots,k_L]$$。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-can-cha-liang-hua-die-dai.png" alt="生成式推荐" width="757"><figcaption><p>残差量化迭代</p></figcaption></figure>

一维示例中，目标值 $$z=5.5$$；第一层选择 $$5$$ 后得到 $$r_1=0.5$$，第二层选择 $$0.4$$ 后得到 $$r_2=0.1$$，最终以 $$\hat z=5.4$$ 逼近原值。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-can-cha-bi-jin-shi-li.png" alt="生成式推荐" width="760"><figcaption><p>残差逼近示例</p></figcaption></figure>

##### 优化函数

$$
\begin{align}
\mathcal L_{\mathrm{RQ}} &= \lVert\mathbf x-\hat{\mathbf x}\rVert_2^2+\sum_{\ell=1}^{L}\left[\lVert\operatorname{sg}[\mathbf r_{\ell-1}]-\mathbf e_{k_\ell}^{(\ell)}\rVert_2^2+\beta\lVert\mathbf r_{\ell-1}-\operatorname{sg}[\mathbf e_{k_\ell}^{(\ell)}]\rVert_2^2\right],\\
\frac{\partial\mathcal L}{\partial\mathbf r_{\ell-1}} &\approx \frac{\partial\mathcal L}{\partial\mathbf e_{k_\ell}^{(\ell)}}
\end{align}
$$

其中，$$\mathcal L_{\mathrm{RQ}}$$ 表示 RQ-VAE 损失，$$\mathbf x,\hat{\mathbf x}$$ 表示输入与重建结果，$$\beta$$ 表示承诺损失权重；第二行表示每一层使用直通估计器近似传播梯度。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-rq-vae-sun-shi-han-shu.png" alt="生成式推荐" width="757"><figcaption><p>RQ-VAE损失函数</p></figcaption></figure>

#### RQ-K-Means：工业化量化

RQ-VAE 通过反向传播联合优化表示与码字分配。工业场景也可将表示学习与码本构建解耦，对预训练表示逐层执行 K-Means，以降低联合训练成本，并便于为新物品增量分配语义 ID。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-rq-kmeans-jie-gou.png" alt="生成式推荐" width="600"><figcaption><p>RQ-KMeans结构</p></figcaption></figure>

$$
\begin{align}
\mathcal C^{(\ell)} &= \operatorname{KMeans}(\mathcal R^{(\ell)},K),\\
s_i^{(\ell)} &= \underset{k\in\{1,\ldots,K\}}{\arg\min}\,\lVert\mathbf r_i^{(\ell)}-\mathbf c_k^{(\ell)}\rVert_2,\\
\mathbf r_i^{(\ell+1)} &= \mathbf r_i^{(\ell)}-\mathbf c_{s_i^{(\ell)}}^{(\ell)},\\
\tilde{\mathbf m}_i &= \sum_{\ell=1}^{L}\mathbf c_{s_i^{(\ell)}}^{(\ell)}
\end{align}
$$

其中，$$\mathcal R^{(\ell)}$$ 表示第 $$\ell$$ 层的残差集合，$$\mathcal C^{(\ell)}$$ 表示由 $$K$$ 个中心组成的码本，$$s_i^{(\ell)}$$ 表示物品 $$i$$ 的码字索引，$$\mathbf r_i^{(\ell)},\mathbf c_k^{(\ell)},\tilde{\mathbf m}_i\in\mathbb R^d$$，$$\tilde{\mathbf m}_i$$ 表示量化重建向量。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-rq-kmeans-liang-hua.png" alt="生成式推荐" width="755"><figcaption><p>RQ-KMeans量化</p></figcaption></figure>

#### RQ-OPQ：混合编码

部分 RQ 实现会丢弃最后一层量化后的残差，而该残差仍包含品牌型号、价格区间等难以被层次聚类捕获的细粒度特征。RQ-OPQ 使用 RQ 表示共性语义，再用优化乘积量化（OPQ）编码剩余的个性特征。

##### OPQ 优化

OPQ 先学习正交旋转矩阵，再将旋转后的残差划分为 $$M$$ 个子空间，并在各子空间的子码本中寻找最近邻：

$$
\begin{align}
\tilde{\mathbf r} &= \mathbf R\mathbf r_L, & \mathbf R^{\mathsf T}\mathbf R &= \mathbf I_d,\\
q_m &= \underset{\mathbf c\in\mathcal C_m}{\arg\min}\,\lVert\tilde{\mathbf r}_m-\mathbf c\rVert_2
\end{align}
$$

其中，$$\mathbf r_L\in\mathbb R^d$$ 表示 RQ 最后一层残差，$$\mathbf R\in\mathbb R^{d\times d}$$ 表示正交旋转矩阵，$$\tilde{\mathbf r}_m\in\mathbb R^{d/M}$$ 表示第 $$m$$ 个子向量，$$\mathcal C_m$$ 表示对应子码本，$$q_m$$ 表示最近码字索引。若每个子码本大小为 $$K_{\mathrm{sub}}$$，则组合容量为 $$K_{\mathrm{sub}}^M$$。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-opq-ma-ben-gui-mo.png" alt="生成式推荐" width="755"><figcaption><p>OPQ码本规模</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-opq-liang-hua-liu-cheng.png" alt="生成式推荐" width="760"><figcaption><p>OPQ量化流程</p></figcaption></figure>

##### 共性语义与个性特征

- RQ 部分负责共性语义：前三层 ID 如 `[102, 8, 1]` 可分别对应“电子产品”“手机通讯”“Apple/苹果”，用于确定商品的层级身份。
- OPQ 部分负责个性特征：剩余残差中的“粉色”“256 GB”等正交属性可编码为补充 ID `[56, 99]`，用于匹配具体偏好。

最终 ID `[102, 8, 1, 56, 99]` 同时保留层级语义和特定库存量单位（SKU）的属性，从而缓解长尾商品的区分与召回问题。

### 局限性

#### SID 冲突

量化存在信息损失，多个物品可能映射到相同的语义 ID（SID）序列。根本原因之一是码本利用不均衡：大量物品集中在少数聚类中心附近，而部分中心很少被使用，使实际容量低于理论容量。

缓解策略主要分为两类：训练阶段改进量化算法，例如采用均匀分配或限制聚类中心容量；推理阶段则接受冲突，并在 SID 序列中加入额外信息消除歧义，例如以前几层捕获共性语义、以后几层编码独特特征。

#### 目标不一致

语义 ID 生成通常由表示提取、SID 量化和生成模型训练三个阶段组成。阶段间独立优化会导致目标难以端到端对齐：表示模型未必针对推荐任务优化，量化过程也未必考虑下游生成模型的偏好。

可行方向包括联合优化，使梯度跨阶段传播；也可以设计循环一致性等自监督任务，确保 SID 保留物品核心语义，并通过迭代训练促进各组件相互适应。

#### 多模态融合

推荐物品通常包含内容语义、协同信号和场景属性等多模态信息。不同模态在语义空间中的分布并不一致，简单拼接或加权平均难以充分利用其互补性。

融合方法可分为表示层融合和量化层融合：前者通过门控机制或对比学习整合多模态表示；后者为不同模态维护独立量化通道，并在码本层面整合信息，例如使用模态专属码本或混合专家架构动态分配权重。
