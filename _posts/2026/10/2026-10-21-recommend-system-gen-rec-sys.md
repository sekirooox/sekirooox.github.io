---
title: "生成式推荐与判别式推荐"
date: 2026-10-21 00:00:00 +0800
description: 梳理生成式推荐的建模方式、模型架构、语义 ID 及残差量化方法。
categories: [推荐系统]
tags: [推荐系统, 生成式推荐, Transformer, LLM, 语义ID, 向量量化]
render_with_liquid: false
pin: false
math: true
mermaid: false
---

# 生成式推荐系统
## 判别式推荐与生成式推荐

### 判别式推荐

判别式推荐以用户与物品的静态特征（如 ID、类目属性）及动态特征（如行为序列）为输入，预测点击率（CTR）、转化率（CVR）等业务指标。其核心是学习条件概率 $$p(y=1\mid u,i,c)$$，用于估计用户 $$u$$ 在上下文 $$c$$ 中对物品 $$i$$ 产生正向交互的概率；$$y$$ 表示交互标签。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-pan-bie-shi-jian-mo.png" alt="生成式推荐" width="720"><figcaption><p>判别式推荐建模</p></figcaption></figure>

### 生成式推荐

生成式推荐根据用户属性、上下文以及历史交互序列（包括物品 ID 与曝光后的反馈行为），直接生成下一步行为或物品。它将推荐建模为序列生成过程：

$$
\begin{align}
p_\theta(i_{1:T}\mid u,c) &= \prod_{t=1}^{T}p_\theta(i_t\mid i_{<t},u,c)
\end{align}
$$

其中，$$\theta$$ 表示模型参数，$$i_{1:T}$$ 表示长度为 $$T$$ 的物品序列，$$i_{<t}$$ 表示第 $$t$$ 步之前的历史序列，$$u$$ 和 $$c$$ 分别表示用户与上下文。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-sheng-cheng-shi-jian-mo.png" alt="生成式推荐" width="720"><figcaption><p>生成式推荐建模</p></figcaption></figure>

### 两类范式的差异

判别式推荐通常存在以下局限：

- 推荐链路与**网络结构复杂**，工程优化成本较高。
- 信息在多阶段链路中流动受限，**较依赖特征工程**，且各阶段的优化目标往往不一致。

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

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-zhu-yi-li-quan-zhong.png" alt="生成式推荐" width="720"><figcaption><p>注意力权重计算</p></figcaption></figure>

#### 位置编码

Transformer 常用正弦位置编码（sinusoidal positional encoding）、相对位置编码和旋转位置编码（RoPE）。推荐系统除序列顺序外，还需显式建模物品—物品、物品—行为及行为—行为之间的<span style="color:red">绝对位置关系</span>与<span style="color:red">时间差</span>。

> 即使物品 1 和物品 2 在序列中相邻，如果两次行为间隔数年，它们也可能没有显著关联。

#### 编码器—解码器架构

LLM 通常采用仅解码器（decoder-only）架构；推荐输入不仅包含行为序列，还包括<span style="color:red">用户画像和推荐目标</span>。编码器可压缩这些条件信息，并通过交叉注意力与解码器交互，从而控制自回归生成方向。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-bian-ma-jie-ma-jia-gou.png" alt="生成式推荐" width="720"><figcaption><p>编码器解码器架构</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-shuang-jia-gou-dui-bi.png" alt="生成式推荐" width="720"><figcaption><p>双架构对比</p></figcaption></figure>

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

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-yin-guo-yan-ma-ji-suan.png" alt="生成式推荐" width="720"><figcaption><p>因果掩码计算</p></figcaption></figure>

还可以将用户行为序列<span style="color:red">划分为多个会话</span>，通过会话级掩码增强会话内关联并减少跨会话噪声；多任务场景也可按点击、转化等目标设计不同的可见范围。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-ding-zhi-hua-yan-ma.png" alt="生成式推荐" width="720"><figcaption><p>定制化掩码</p></figcaption></figure>

### 扩散模型

扩散模型先在前向过程中逐步加入噪声，再在反向过程中学习去噪。用于推荐时，它既可增强用户或物品表示，也可并行生成推荐序列，并承担多模态融合或协同图建模任务。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-kuo-san-qu-zao-guo-cheng.png" alt="生成式推荐" width="720"><figcaption><p>扩散与去噪过程</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-kuo-san-tui-jian-ying-yong.png" alt="生成式推荐" width="720"><figcaption><p>扩散推荐应用</p></figcaption></figure>

扩散模型的生成质量与灵活性较强，但多步采样会增加推理延迟；工业部署通常需要在生成质量和实时性之间权衡。

### LLM 用于推荐

- 预训练：对齐语言建模与推荐建模的目标，并兼顾用户行为序列和多模态内容。
- 指令微调：将推荐任务表达为可学习的指令，同时处理高度 ID 化的物品。
- 偏好对齐：推荐系统难以定义统一奖励信号，通常需要综合多样性、个性化等多个目标。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-da-mo-xing-tui-jian-shi-pei.png" alt="生成式推荐" width="720"><figcaption><p>大模型推荐适配</p></figcaption></figure>

## 物品分词与语义 ID

### 稀疏 ID 范式（Sparse ID-Based）

思路是<span style="color:red">沿用传统推荐系统的编码方式</span>：每个物品对应一个 ID，再由嵌入层编码。

优点是实现简单、技术成熟，并可复用传统推荐链路中的嵌入层；缺点是物品数量巨大时词表容易膨胀，新物品也难以利用 LLM 的语义泛化能力，存在冷启动问题。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-xi-shu-biao-shi-fan-shi.png" alt="生成式推荐" width="720"><figcaption><p>稀疏标识范式</p></figcaption></figure>

### 文本 ID 范式（Text-Based）

思路是<span style="color:red">沿用 LLM 的分词方式</span>，使用多个自然语言令牌描述一个物品。

优点是能够发挥 LLM 的泛化能力，且语义表达比稀疏 ID 更丰富；缺点是自然语言具有模糊性和歧义性，同一物品可能对应多种表述，从而增加生成与匹配的不确定性。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-wen-ben-biao-shi-fan-shi.png" alt="生成式推荐" width="720"><figcaption><p>文本标识范式</p></figcaption></figure>

### 语义 ID 范式（Semantic ID-Based）

语义 ID 借鉴<span style="color:red">流式索引召回</span>等方法，根据物品的潜在表示进行<span style="color:red">多级量化或聚类</span>，得到离散令牌序列。

- 组合空间：通过多级聚类可组合出规模巨大的离散编码空间。词表大小为 $K=8000$、序列长度为 $L=4$ 时，理论容量为 $K^L=8000^4\approx4\times10^{15}$。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-yu-yi-zu-he-kong-jian.png" alt="生成式推荐" width="720"><figcaption><p>语义组合空间</p></figcaption></figure>

- 层次结构：层次化编码为模型提供较强的<span style="color:red">归纳偏置</span>。模型学习到用户偏好“篮球”（如 `token 5`）后，可将偏好迁移到具有相同前缀（如 `[10, 5, ...]`）的物品，实现基于前缀的泛化。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-yu-yi-biao-shi-ceng-ci.png" alt="生成式推荐" width="720"><figcaption><p>语义标识层次</p></figcaption></figure>

- 推理能力：令牌可从一级类目、二级类目逐步过渡到细粒度属性，使模型能够隐式学习<span style="color:red">概念层面的推理过程</span>。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-yu-yi-biao-shi-tui-li.png" alt="生成式推荐" width="720"><figcaption><p>语义标识推理</p></figcaption></figure>

#### VQ-VAE：反向传播优化聚类

VQ-VAE 先由编码器得到连续表示，再从可学习码本中选择最近码字，最后由解码器重建输入。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-vq-vae-jie-gou.png" alt="生成式推荐" width="720"><figcaption><p>VQ-VAE结构</p></figcaption></figure>

##### 分配码字

$$
\begin{align}
\mathbf E &= [\mathbf e_1,\mathbf e_2,\ldots,\mathbf e_K]\in\mathbb R^{d\times K},\\
k^{*} &= \underset{j\in\{1,\ldots,K\}}{\arg\min}\,\lVert\mathbf z_e-\mathbf e_j\rVert_2,\\
\mathbf z_q &= \mathbf e_{k^{*}}
\end{align}
$$

其中，$$\mathbf E$$ 表示码本矩阵，$$K$$ 表示码本大小，$$d$$ 表示向量维度，$$\mathbf z_e,\mathbf e_j,\mathbf z_q\in\mathbb R^d$$ 分别表示编码器输出、第 $$j$$ 个码字和量化结果，$$k^{*}$$ 表示最近码字的索引。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-ma-ben-ma-zi-fen-pei.png" alt="生成式推荐" width="720"><figcaption><p>码本与码字分配</p></figcaption></figure>

##### 损失优化

$$
\begin{align}
\mathcal L_{\mathrm{VQ}} &= \underbrace{\lVert\mathbf x-\hat{\mathbf x}\rVert_2^2}_{\mathcal L_{\mathrm{recon}}}+\underbrace{\lVert\operatorname{sg}[\mathbf z_e]-\mathbf z_q\rVert_2^2}_{\mathcal L_{\mathrm{codebook}}}+\underbrace{\beta\lVert\mathbf z_e-\operatorname{sg}[\mathbf z_q]\rVert_2^2}_{\mathcal L_{\mathrm{commit}}}
\end{align}
$$

其中，$$\mathbf x$$ 和 $$\hat{\mathbf x}$$ 分别表示输入与重建结果，$$\mathcal L_{\mathrm{recon}}$$、$$\mathcal L_{\mathrm{codebook}}$$ 和 $$\mathcal L_{\mathrm{commit}}$$ 分别表示重建损失、码本损失和承诺损失，$$\operatorname{sg}$$ 表示停止梯度操作，$$\beta$$ 表示承诺损失权重。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-vq-vae-sun-shi-han-shu.png" alt="生成式推荐" width="720"><figcaption><p>VQ-VAE损失函数</p></figcaption></figure>

##### 近似可导

量化的最近邻选择不可导，VQ-VAE 使用直通估计器，在前向传播中执行离散选择，在反向传播中近似复制梯度：

$$
\begin{align}
\frac{\partial\mathcal L}{\partial\mathbf z_e} &\approx \frac{\partial\mathcal L}{\partial\mathbf z_q}
\end{align}
$$

其中，$$\mathcal L$$ 表示训练损失，$$\mathbf z_e,\mathbf z_q\in\mathbb R^d$$ 分别表示量化前后的向量；该式采用分母布局表示梯度。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-zhi-tong-gu-ji-ti.png" alt="生成式推荐" width="720"><figcaption><p>直通估计梯度</p></figcaption></figure>

#### RQ-VAE：多层残差量化

单层量化的编码容量与表达精度有限。RQ-VAE **逐层量化**残差，以码字序列形成组合编码空间。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-rq-vae-can-cha-liang-hua.png" alt="生成式推荐" width="720"><figcaption><p>RQ-VAE残差量化</p></figcaption></figure>

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

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-can-cha-liang-hua-die-dai.png" alt="生成式推荐" width="720"><figcaption><p>残差量化迭代</p></figcaption></figure>

一维示例中，目标值 $$z=5.5$$；第一层选择 $$5$$ 后得到 $$r_1=0.5$$，第二层选择 $$0.4$$ 后得到 $$r_2=0.1$$，最终以 $$\hat z=5.4$$ 逼近原值。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-can-cha-bi-jin-shi-li.png" alt="生成式推荐" width="720"><figcaption><p>残差逼近示例</p></figcaption></figure>

##### 优化函数

$$
\begin{align}
\mathcal L_{\mathrm{RQ}} &= \lVert\mathbf x-\hat{\mathbf x}\rVert_2^2+\sum_{\ell=1}^{L}\left[\lVert\operatorname{sg}[\mathbf r_{\ell-1}]-\mathbf e_{k_\ell}^{(\ell)}\rVert_2^2+\beta\lVert\mathbf r_{\ell-1}-\operatorname{sg}[\mathbf e_{k_\ell}^{(\ell)}]\rVert_2^2\right],\\
\frac{\partial\mathcal L}{\partial\mathbf r_{\ell-1}} &\approx \frac{\partial\mathcal L}{\partial\mathbf e_{k_\ell}^{(\ell)}}
\end{align}
$$

其中，$$\mathcal L_{\mathrm{RQ}}$$ 表示 RQ-VAE 损失，$$\mathbf x,\hat{\mathbf x}$$ 表示输入与重建结果，$$\beta$$ 表示承诺损失权重；第二行表示每一层使用直通估计器近似传播梯度。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-rq-vae-sun-shi-han-shu.png" alt="生成式推荐" width="720"><figcaption><p>RQ-VAE损失函数</p></figcaption></figure>

#### RQ-K-Means：工业化量化

RQ-VAE 通过**反向传播**联合优化表示与码字分配。工业场景也可将表示学习与码本构建解耦，对预训练表示逐层执行 K-Means，以降低联合训练成本，并便于为新物品增量分配语义 ID。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-rq-kmeans-jie-gou.png" alt="生成式推荐" width="720"><figcaption><p>RQ-KMeans结构</p></figcaption></figure>

$$
\begin{align}
\mathcal C^{(\ell)} &= \operatorname{KMeans}(\mathcal R^{(\ell)},K),\\
s_i^{(\ell)} &= \underset{k\in\{1,\ldots,K\}}{\arg\min}\,\lVert\mathbf r_i^{(\ell)}-\mathbf c_k^{(\ell)}\rVert_2,\\
\mathbf r_i^{(\ell+1)} &= \mathbf r_i^{(\ell)}-\mathbf c_{s_i^{(\ell)}}^{(\ell)},\\
\tilde{\mathbf m}_i &= \sum_{\ell=1}^{L}\mathbf c_{s_i^{(\ell)}}^{(\ell)}
\end{align}
$$

其中，$$\mathcal R^{(\ell)}$$ 表示第 $$\ell$$ 层的残差集合，$$\mathcal C^{(\ell)}$$ 表示由 $$K$$ 个中心组成的码本，$$s_i^{(\ell)}$$ 表示物品 $$i$$ 的码字索引，$$\mathbf r_i^{(\ell)},\mathbf c_k^{(\ell)},\tilde{\mathbf m}_i\in\mathbb R^d$$，$$\tilde{\mathbf m}_i$$ 表示量化重建向量。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-rq-kmeans-liang-hua.png" alt="生成式推荐" width="720"><figcaption><p>RQ-KMeans量化</p></figcaption></figure>

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

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-opq-ma-ben-gui-mo.png" alt="生成式推荐" width="720"><figcaption><p>OPQ码本规模</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-opq-liang-hua-liu-cheng.png" alt="生成式推荐" width="720"><figcaption><p>OPQ量化流程</p></figcaption></figure>

##### 共性语义与个性特征

- RQ 部分负责共性语义：前三层 ID 如 `[102, 8, 1]` 可分别对应“电子产品”“手机通讯”“Apple/苹果”，用于确定商品的层级身份。
- OPQ 部分负责个性特征：剩余残差中的“粉色”“256 GB”等正交属性可编码为补充 ID `[56, 99]`，用于匹配具体偏好。

最终 ID `[102, 8, 1, 56, 99]` 同时保留层级语义和特定库存量单位（SKU）的属性，从而缓解长尾商品的区分与召回问题。

### 局限性

#### SID 冲突

量化存在信息损失，`多个物品可能映射到相同的语义` ID（SID）序列。根本原因之一是**码本利用不均衡**：大量物品集中在**少数聚类**中心附近，而部分中心很少被使用，使实际容量低于理论容量。

缓解策略主要分为两类：训练阶段**改进量化**算法，例如采用均匀分配或限制聚类中心容量；推理阶段则接受冲突，并在 SID 序列中加入额外信息消除歧义，例如以前几层捕获共性语义、以后几层编码独特特征。

#### 目标不一致

语义 ID 生成通常由表示提取、SID 量化和生成模型训练三个阶段组成。阶段间独立优化会导致目标难以端到端对齐：表示模型未必针对推荐任务优化，量化过程也未必考虑下游生成模型的偏好。

可行方向包括联合优化，使梯度跨阶段传播；也可以设计循环一致性等自监督任务，确保 SID 保留物品核心语义，并通过迭代训练促进各组件相互适应。

#### 多模态融合

推荐物品通常包含内容语义、协同信号和场景属性等**多模态信息**。不同模态在语义空间中的分布并不一致，简单拼接或加权平均**难以充分利用其互补性**。

融合方法可分为表示层融合和量化层融合：前者通过门控机制或对比学习整合多模态表示；后者为不同模态维护独立量化通道，并在码本层面整合信息，例如使用模态专属码本或混合专家架构动态分配权重。


# 推荐系统的scaling

## DLRM系统的scaling困难

首先是特征瓶颈。DLRM依赖手工设计的数值型特征（如点击率、平均观看时长等统计特征）来压缩历史信息。当增加模型容量时，这些预聚合的特征成为信息瓶颈：模型能力提升了，但输入信息的丰富度没有提升。

其次是架构碎片化。DLRM由异构的模块组成（FM、DCN、DIN、MMoE等），每个模块针对特定类型的特征交互优化。增加某个模块的容量往往只能带来局部改善，难以产生系统性的提升。

最后是训练范式的限制。传统DLRM采用的是item-level建模：对每个候选项独立计算评分，每个训练样本只对应一个
三元组。这意味着模型每次只能从单个交互中学习一个监督信号，增加模型容量不会增加每个样本提供的信息量。而且，这种范式的计算成本随候选集规模线性增长，独立评分机制也无法捕捉候选之间的关联。

这三个限制共同作用，让传统DLRM难以实现持续的规模化收益。突破这个困境，需要的不仅是工程优化，而是范式的转变。

## 用户的行为序列建模：物品+行动
传统方法只建模物品序列，预测下一个物品，却没有考虑用户对每个物品的响应。

现有方法将用户行为序列建模为**物品和行动**的序列，模型在学习这样一个序列时，`隐式学习`到了传统方法中**召回和排序**的概念


<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-01.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示28</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-02.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示29</p></figcaption></figure>

## 统一的特征空间

传统DLRM的一个显著特点是特征的异构性和碎片化。一个典型的工业级推荐模型可能使用上千个特征，包括类别型（Sparse）特征和数值型（Dense）特征。

对于离散型特征，例如用户id和类目属性，应该当**保留和去重**。

对于连续型特征，例如用户的CTR，可以通过对**类别型**特征，也就是用户行为序列，进行**隐式的推断和理解**，让更强的LLM自动学习这些特征。   

>也就是忽略数值型特征，但是这`不一定有效`。数值型特征可以起到**很强的偏置作用**！

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-03.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示30</p></figcaption></figure>

## 训练效率的提升
一次前向传播，可以从序列中**学习多个物品的动作**，比传统方法的**用户-物品-动作**三元组预测需要的前向传播次数更少。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-04.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示31</p></figcaption></figure>


## HSTU

### point-wise聚合替代softmax注意力机制
不进行softmax操作，突出用户对物品的`绝对兴趣`的强度。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-05.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示32</p></figcaption></figure>

### 绝对位置编码和时序编码

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-06.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示33</p></figcaption></figure>

### 训练和推理

#### 训练：Stochastic Length（随机长度）
思路：随机**截取序列片段**和完整序列用于训练，确保大多数时候序列长度较短。

直觉上可以`学习用户长期和短期`的兴趣用于训练。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-07.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示34</p></figcaption></figure>

#### 推理：M-FALCON-全局成本分摊的推理算法

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-08.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示35</p></figcaption></figure>

## HSTU的优化

### 自回归

#### 不必保持生成式损失，不必在每个历史位置都计算 BE Loss

如果自回归只是一个可选技巧，**更多监督信号应该提升性能**。

但实验结果显示AUC显著下降。这可以用“one-epoch问题” (Huang et al., 2025) 解释：推荐数据中，用户ID、物品ID等稀疏特征占据绝大部分参数。由于长尾分布，大量ID只出现一两次。在历史位置计算loss时，模型倾向于`“记住”每个交互细节，但这难以泛化`。

举个例子，假设用户小明的历史序列是“看了科技博主A的视频→点赞→看了美食博主B的视频→收藏”。如果在历史位置计算loss，模型会学习预测：“看了科技博主A后会点赞”。但这个模式难以泛化，测试集中小明可能看科技博主C的视频，模型却没见过这个组合。

此外，**如果只训练一个epoch（推荐系统的常见做法），模型没有机会纠正这种过拟合**。

#### 必须重点保留自回归的时间约束

第二组实验在历史位置使用全可见mask，允许双向attention。从**特征交互角度看这应该增强表达能力**，但性能仍然下降，且随模型规模增大下降幅度扩大。全可见`mask破坏了关键的归纳偏置`，即用户兴趣演化的因果性。Causal mask`强制模型学习因果结构`，而非任意统计相关性。

继续上面的例子，如果允许双向attention，模型在处理“看了科技博主A”这个行为时，能看到后面的“点赞”和“看了美食博主B”。这可能让模型学到虚假关联，比如“因为后面看了美食视频，所以给科技视频点赞”。但在现实中，用户在时刻的行为不可能被未来的行为影响。

Causal mask通过禁止“看到未来”，强制模型学习真实的因果关系`。

### 训练方式

#### user-level和point-wise

相比之下，样本组织方式的影响较小。传统DLRM采用**point-wise**训练，`每个样本对应一次交互`。

HSTU采用user-level训练，意思是**将同一用户的多次交互组织成序列**。这看似能带来梯度估计的稳定性和防止信息泄露的好处。

但实验显示，保持序列化组织但只在最后位置计算loss（模拟point-wise），性能几乎没有下降。

>在保留完整历史序列和自回归架构的情况下，**只监督最后一个候选**，与监督**多个位置相比**，模型效果差异很小。


### 特征工程
团队进一步测试了工业常用模块的兼容性。SIM、PPNet、PLE等模块在生成式架构下仍然有效。

特征工程方面的实验也有新发现：**大部分历史聚合特征的价值大幅降低**，因为模型的序列建模能力可以自动学会这些统计规律。

`但实时特征依然重要`，它们捕捉训练窗口外的新信息。此外，特征工程的简化释放了系统资源，为处理更大规模候选集创造了可能。

### 优化1：Action-Oriented，动作-序列编码到一个隐向量中
物品和动作融入到同一个token中，一个表示物品本身的编码，一个表示**动作含义** (例如点击/未点击)的编码。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-09.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示36</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-10.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示37</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-11.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示38</p></figcaption></figure>

对于候选物品，还需要特殊mask action，主要用于表示当前模型的**预测目标**是什么？例如CTR还是CVR？


<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-12.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示39</p></figcaption></figure>

候选物品`单独看待，之间不进行任何交互`，其余情况采用**因果掩码**的方式。


<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-13.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示40</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-14.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示41</p></figcaption></figure>

### 优化2：位置与时间的编码
有索引相关的位置编码 (例如sinual encoding)，请求索引的编码：用于编码**同一时间段的用户行为**，请求间时间编码：编码距离上一段请求的**时间间隔**，区分长期和短期兴趣。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-15.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示42</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-16.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示43</p></figcaption></figure>

## MTGR：生成式，重新引入特征工程

### HSTU/GenRank的根本假设：严格自回归
生成式/自回归的方式，限制了特征的交叉融合。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-17.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示44</p></figcaption></figure>

美团团队的消融实验给出了明确答案：**去除交叉特征后**，即使是最大规模的生成式模型，性能也会退化到甚至不如中等规模的传统DLRM。这不是一个可以通过scaling弥补的gap，而是信息本身的缺失。

### 核心贡献：混合特征工程和自回归

**MTGR的核心洞察**是：用户粒度建模带来的效率提升，本质上来自于样本聚合和计算复用，而`不一定要求完整的生成式建模`。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-18.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示45</p></figcaption></figure>

这个设计的哲学是：**区分手段和目的**。生成式架构（Transformer + 序列建模）是一种强大的表征学习手段，但不一定要服务于生成式的建模目标。用户粒度聚合是一种高效的计算组织方式，**但不一定要求完整的因果序列**。MTGR通过这种混合范式，在保持效率的同时，`恢复了判别式建模的灵活性`。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-19.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示46</p></figcaption></figure>


#### 特征建模

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-20.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示47</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-21.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示48</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-22.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示49</p></figcaption></figure>


### 分层次归一化

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-23.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示50</p></figcaption></figure>

### Dynamic Masking：静态特征忽略因果性，动态特征建模因果性

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-24.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示51</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-25.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示52</p></figcaption></figure>

## Rankmixer：偏判别式，硬件效率优化

RankMixer (Zhu et al., 2025) 通过hardware-aware的架构设计，从根本上解决了这一问题。其核心原则是从硬件特性反推架构设计，将推荐模型重构为统一的、GPU友好的计算图：用Token Mixing替代Self-Attention以降低复杂度，用Per-Token FFN捕捉特征异质性，用Sparse MoE实现参数高效的模型扩展。

模型核心是逐层堆叠的RankMixer Block，每个block包含Multi-head Token Mixing（替代Self-Attention）和Per-Token FFN（捕捉特征异质性）两个模块。输入特征经tokenization转换为`T个统一维度的token`，经L层block处理后通过mean pooling产生最终输出

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-26.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示53</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-27.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示54</p></figcaption></figure>


### Token Mixing：替换注意力层，只进行组合
每一个特点的**子维度相互交叉和排列**组合，用于后续进行**特征融合**。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-28.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示55</p></figcaption></figure>

### Per-Token FFN：特异参数

因为输入和输出的序列维度是**固定的**，因此可以为固定序列长度中的每个token，**分配特异化参数**。

推理时速度不变，存储时模型参数增多，但总体参数没有膨胀 (因为**Token Mixing本质是无参数化的**)。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-29.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示56</p></figcaption></figure>

###  Sparse MoE：扩展表达能力

但**如何扩展到十亿甚至百亿参数**？直接增加模型深度和宽度会线性增加计算量，推理延迟也会同比增加，这在工业场景中不可接受。

Sparse Mixture-of-Experts（MoE）提供了解决方案：不是让所有参数都参与每个样本的计算，而是根据样本特性动态选择一部分expert。这样模型参数量可以很大，但每个样本的计算量是固定的（只激活少数expert）。

MoE的理想工作模式是每个expert专门化到某种特定样本模式。但在推荐场景中，**实现有效的expert specialization面临三大挑战**。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-30.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示57</p></figcaption></figure>

通过使用RELU**替代TOP-K**，确保每个专家都有机会被选择，同时抑制贡献非正的专家，强制实现专家的**训练平衡**。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-31.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示58</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-32.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示59</p></figcaption></figure>

### OneTrans：生成式，序列和特征建模

OneTrans (Zhang et al., 2025) 提出根本性架构革新：用**单一 Transformer backbone 同时完成序列建模和特征交互**。如图 图6.5.1 (b) 所示，OneTrans 通过统一 tokenizer **将序列特征（S-tokens）和非序列特征（NS-tokens）**转为统一 token 序列，在堆叠 Transformer 层中联合建模，打破序列与特征的信息壁垒，为应用 LLM 系统优化奠定基础。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-33.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示60</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-34.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示61</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-35.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示62</p></figcaption></figure>

#### Mixed Parameterization 

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-36.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示63</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-37.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示64</p></figcaption></figure>

#### 渐进式蒸馏

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-38.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示65</p></figcaption></figure>


# 端到端生成式建模

## OneRec-v1


### Aligned Collaborative-Aware Multimodal Representation
协同感知的多模态表示学习。每个视频包含丰富的多模态信息，包括标题、标签、语音转文字（ASR）、图像转文字（OCR）、封面图和采样帧。这些信息通过视觉语言模型（如 miniCPM-V-8B）处理后，生成 1280 个 Token 向量。为了实现高效处理，采用 **QFormer 模块将这些向量压缩为 4 个可学习的查询向量**。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-39.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示66</p></figcaption></figure>

然而，仅依赖内容特征生成的语义 ID 无法捕捉协同过滤信号。为此，OneRec-V1 引入了**物品对对比学习**：从用户行为中提取高协同相似度的物品对（如同一用户正向点击的物品），通过对比损失拉近这些物品对的表示，使语义 ID 能够同时编码内容语义和行为模式。

**还加入了标题生成的辅助任务**，确保表示保留内容理解能力。


<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-40.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示67</p></figcaption></figure>

>采用batch-wise的对比损失学习。正样本定义为：U2I，用户**点击过的物品**和用户**历史中与其相似度最高**的物品；I2I，与**展示高相似度** (Swing相似度)的物品对。

### RQ-Kmeans：残差量化

使用经过对比学习和字幕预测后的多模态特征 (不只单个向量，从Query-Former提取)，进行Kmeans层次聚类，注意**码本的数量是平衡的**。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-41.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示68</p></figcaption></figure>


### 特征工程

#### User Static Pathway

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-42.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示69</p></figcaption></figure>

#### Short-term Pathway

只取20个用户交互的视频序列，**构造一系列特征拼接**然后映射到统一维度。

>视频相关的特征**与之前提取的多模态特征基本无关**，vid表示视频id，后续被替换为sid。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-43.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示70</p></figcaption></figure>

#### Positive-feedback Pathway
取用户高度交互过的视频序列。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-44.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示71</p></figcaption></figure>

#### Lifelong Pathway
通过使用之前的**多模态特征**进行聚类，选取不超过M个物品，基准是**选择离聚类中心最近的物品**。

后面构造特征是没有使用多模态特征，只是索引到对应视频，然后根据视频构造特征，例如vid，aid等内容。部分内容例如playtime和dur等，**替换为该聚类中心的平均特征**，而非个体特征。

最终保留2000个具有用户代表性的终身特征，**使用Q-former进一步压缩至128个特征**。

>只用了多模态特征进行聚类，`构造特征时基本没用到过它`。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-45.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示72</p></figcaption></figure>

### 编码和解码器
就是正常的自注意力和交叉注意力层堆叠，使用稀疏MoE提高表达能力。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-46.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示73</p></figcaption></figure>

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-47.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示74</p></figcaption></figure>

### 强化学习：ECPO

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-48.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示75</p></figcaption></figure>

#### P-SCORE
>主要思想：定义多个塔模型，**对物品多个维度进行打分**，然后根据业务目标，**手动加权**这些分数。

为解决这些限制，我们建议使用神经网络学习个性化融合评分，称为P评分（偏好评分）（Cao等，2025）。该模型的整体框架如图5（中间）所示。该模型的**底层架构基于基于搜索兴趣模型（SIM）**（Pi 等，2020）。它包含多个塔楼，每个塔楼专门用于学习特定目标。在训练过程中，这些塔利用相应的目标标签作为辅助任务计算二元交叉熵（BCE）损失。

每个塔的隐藏状态，以及用户以及项目表示，则被输入到最后一层的多层感知器（MLP）。该MLP之后是单个塔输出P分数，利用所有目标的标签计算二元交叉熵损失。损失可以正式表示如下

>训练时，这些塔模型采用BCE损失。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-49.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示76</p></figcaption></figure>

#### EC-GRPO

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-50.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示77</p></figcaption></figure>

通过改进**负优势**下的clip函数，确保不会出现较大的梯度波动。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-51.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示78</p></figcaption></figure>

#### Generation Format Regularization

在生成式推荐中，合法性比率指的是生成语义ID序列中，能够映射到实际项目ID的比例。这一指标对于评估发电稳定性至关重要。实际上，语义ID序列的基数远大于视频序列。这确保所有项目都涵盖，词汇量增加更多参数，从而提升性能。

然而，这也可能导致在推理过程中**生成语义ID序列但没有对应的条目ID**，即非法生成。 引入强化学习与ECPO一起显著增加了非法输出的生成。最新研究（任 Sutherland，2024）认为这是·所致。如图7所示，预训练模型已经学会生成大部分合法代币。纳入强化学习后，A>0的项目仅略微调整分布。当应用A < 0的项目时，模型的概率分布将大部分概率质量压缩为当前认为的最优输出o∗。这导致某些**合法代币被挤压到与非法代币相当的概率，使模型难以区分合法代币**。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-52.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示79</p></figcaption></figure>

>后续从GRPO采样的样本中**只选取1%**用于赋予格式奖励。

### Rejection Sampling Fine-Tuning

先让模型生成多个候选答案，再用奖励模型或规则筛选出质量较高的答案，最后把这些高质量答案作为监督数据，对原模型进行 SFT 微调。

它本质上是一种“生成 → 筛选 → 模仿”的训练方式。

因为模型生成的候选不是全部用于训练，而是经过筛选：
- 高奖励样本：Accept（接受）
- 低奖励样本：Reject（拒绝）

### 实验

#### 使用SID替换VID
SID：语义id，长度为K，**依赖于码本**。
VID：离散型id，**表征某一特定视频**，数量巨大 (十几亿)。
优势：**参数更加高效**，而且语义表征能力更强。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-53.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示80</p></figcaption></figure>

#### 搜索策略：如何生成多个候选？

搜索策略强化学习在大型语言模型中通常采用top-k和top-p抽样来生成样本。在OneRec中，我们还探讨了`束流搜索`作为一种替代策略。

表8比较了这两种方法的结果，显示在OneRec强化学习框架中，束搜索显著优于top-k和top-p抽样。这一改进源于语义ID结构的固有规律性，遵循前缀树编码方案，因此与束搜索的系统探索高度契合。

#### On-policy vs Off-policy

参考模型本节比较了ECPO中策略生成的两个参考模型：（1）预训练模型（非政策模式）和（2）当前政策模型（政策外）。实验结果总结于表9。从表格中可以明显看出，**使用当前政策模型能带来更好的结果**，尤其是在离线奖励评估方面。这表明策略上方法允许模型持续自我学习，突破参考模型的局限，达到更高的上限。

**然而，就在线表现而言，政策内方法带来的改善并不显著**。这是因为奖励定义不够优，导致了轻微的奖励黑客行为。我们将将这一方面作为未来工作的关键方向。


<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-54.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示81</p></figcaption></figure>
#### 格式奖励验证

在本节中，我们进行实验以验证格式奖励的有效性。如第2.4.2节所述，在将强化学习纳入预训练模型后，由于挤压效应，**模型输出的合法性显著降至50%以下**。这意味着超过一半生成的语义ID与实际视频ID不对应，这对推荐的稳定性和推理的可扩展性造成了不利影响。

我们通过比较两种计算格式丢失的样本选择方法来评估格式奖励的影响：（1）从128个生成的候选样本中**选择概率最高的5个样本**，（2）随机选择5个样本。 图12展示了它们对产出合法性的影响。左图显示了所有128个生成样本的合法性率，右图则聚焦于所选样本。没有格式奖励，基线合法性仍低于50%。

Top-k 选择方法产生了一个有趣的模式：虽然整体合法性最初上升后下降，但被选中的样本迅速达到100%合法性，表明模型只学会在排名最高的子集中产生合法输出。相比之下，随机选择提供了更具挑战性的学习目标，但推动了稳步改进——最终合法性达到95%，且无下降迹象

>128指的是模型生产的候选物品，只选择其中5个**用于强化学习格式内容**。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-55.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示82</p></figcaption></figure>



#### Industrial Scenario Alignment

本节将展示一个利用强化学习解决工业挑战的实际案例。在快手平台上，病毒式内容农场占了内容创作者的很大一部分，主要制作质量不稳定的再利用和剪辑视频。虽然OneRec在多个业务指标上优于传统推荐系统，但我们观察到，如果没有适当的后期过滤策略，病毒内容的曝光比例会显著增加，这可能对平台生态系统产生负面影响。 病毒内容视频的最佳比例可以设置为f。当比例超过f时，我们会下重他们的P分数奖励以抑制这些内容的质量，同时保持系统对这些内容质量的感知。

<figure><img src="/assets/img/posts/recommend-system-gen-rec-sys/tui-jian-xi-tong-tu-56.png" alt="生成式推荐" width="720"><figcaption><p>推荐系统图示83</p></figcaption></figure>
