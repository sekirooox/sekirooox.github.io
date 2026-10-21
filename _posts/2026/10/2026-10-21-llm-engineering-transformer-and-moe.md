---
title: "LLM 工程实践：Transformer 与 MoE 实现"
date: 2026-10-21
categories: ["大语言模型与强化学习", "大语言模型"]
tags: ["llm", "pytorch", "transformers", "huggingface", "cs336"]
description: "从零实现现代 Decoder-only Transformer，并整理 MoE 路由与负载均衡。"
published: true
math: true
---

# LLM 工程实践：Transformer 与 MoE 实现

本文整合两篇 CS336 作业总结：先从零实现现代 Decoder-only Transformer，再讨论 MoE 的 Top-k 路由、专家计算和负载均衡。原始公式、代码和插图均予以保留，对会影响理解或运行的明确错误直接作小幅修正。

## 现代 Transformer 架构与实现（CS336 作业总结）

> 来源：`_posts/2026/02/2026-02-01-llm_cs336_transformer.md`

### 现代Transformer架构
#### PreNorm vs PostNorm
+ **在计算残差前就进行归一化 vs 在残差后进行归一化**
+ 大部分LLM都采用计算前归一化
+ 个人理解：计算残差前归一化可以确保残差部分的数值稳定，进而与原始值相加时数值也能保持稳定。
<figure><img src="/assets/img/posts/llm-transformer-moe/e89b823307d6454aabe93ca83c141282.png" alt="Transformer架构" width="700"><figcaption><p>PreNorm 与 PostNorm</p></figcaption></figure>
##### doubleNorm
+ 残差前后都进行归一化处理
<figure><img src="/assets/img/posts/llm-transformer-moe/36ecccd1d7fd4b958bb69852cf2b134f.png" alt="Transformer架构" width="700"><figcaption><p>DoubleNorm 结构</p></figcaption></figure>

#### LayerNorm vs RMSNorm
+ LayerNorm和RMSNorm本质上对于性能的影响都不大。
+ **但是RMSNorm的计算操作更少，效率有一定提升，便于并行化**。

<figure><img src="/assets/img/posts/llm-transformer-moe/f732b56168f849cb89a50fd62f1eb73d.png" alt="Transformer架构" width="700"><figcaption><p>LayerNorm 计算</p></figcaption></figure>
<figure><img src="/assets/img/posts/llm-transformer-moe/a0fb30ad8f4243748b20be295a36518d.png" alt="Transformer架构" width="700"><figcaption><p>RMSNorm 计算</p></figcaption></figure>
#### FFN vs SwiGLU
+ Swish/SiLU 函数可写为 `torch.nn.functional.silu(x)`，等价于 `sigmoid(x) * x`；它不是 SELU。
+ GLU：表示门控，使用学习单独的门控映射矩阵V，与激活值进行逐元素乘法。
+ ### 8/3 原则：引入门控矩阵带来额外的参数，为了确保参数量仍然保持一致，FFN中的线性层维度从4倍d_model缩小为8/3倍d_model(同时保持64的倍数)。
<figure><img src="/assets/img/posts/llm-transformer-moe/96fed546f15042f3b5e0396d8a803c91.png" alt="Transformer架构" width="700"><figcaption><p>SwiGLU 门控结构</p></figcaption></figure>
#### 绝对位置编码 vs 相对位置编码
+ 绝对位置编码：在**获得语义嵌入后**就计算位置编码与嵌入值相加
+ 相对位置编码（RoPE）：在计算注意力前，按位置对 Q 和 K 的二维子空间执行旋转，使内积携带相对位置信息。
<figure><img src="/assets/img/posts/llm-transformer-moe/13499ca8253a40f59d67a9b08d7aea33.png" alt="Transformer架构" width="700"><figcaption><p>绝对与相对位置编码</p></figcaption></figure>


### torch实现
#### 前置操作
##### nn.Parameter vs nn.Register_buffer:
+ nn.Parameter：可训练参数，参与反向传播，优化器会更新；属于模块参数列表，会出现在 state_dict（作为参数）。
+ register_buffer：非训练状态（缓冲区），**不参与梯度计算与优化器更新**；不在 parameters() 中，但默认也出现在 state_dict（作为缓冲区），**随 to()/cuda() 迁移设备**。

##### `nn.init.trunc_normal_(self.w,std=1,mean=0,a=-3,b=3)`
+ 使用均值为0，方差为1进行归一化，然后**截断不在[a,b]范围内的初始值**。

##### `torch.tril(A,diagonal=0)`：保留下三角矩阵。
##### `scores.masked_fill(mask==False,float('-inf'))`：将矩阵值为1/True的地方填充为指定值
+ 我们得到的掩膜False值是要省略的，因此需要手动转换`mask==False`。
#### 线性层
+ 计算机为行存储优先，因此将W定义为(out,in)矩阵存储在前向过程中效率更高($xW^T$而不是$xW$。)。
```python
class Linear(nn.Module):
    def __init__(self,input_dim,output_dim,device=None,dtype=None):
        super().__init__()
        self.input_dim=input_dim
        self.output_dim=output_dim

        # initialize it in GPUs and define type
        factory_kwargs = {'device': device, 'dtype': dtype}

        # row-major storage
        self.w=nn.Parameter(torch.empty((output_dim,input_dim),**factory_kwargs))
        # no bias for modern LLM
        
        # truncated normal initialization
        std=math.sqrt(2.0/(input_dim+output_dim))# [a,b] truncate value
        nn.init.trunc_normal_(self.w,std=std,mean=0,a=-3*std,b=3*std)

    def forward(self,x):
        # x.shape:b,input_dim
        y=torch.einsum('b i,o i->b o',x,self.w)# einsum product
        return y
```

#### EmbeddingLayer
+ 嵌入层就是将token(此时为0~255的数字)映射为一个d_model长度的向量
+ 可以简单用一个W来表示这种映射(vocab_size,d_model)


```python
class Embedding_Layer(nn.Module):
    def __init__(self,vocab_size,embedding_dim,device=None,dtype=None):
        super().__init__()
        self.vocab_size=vocab_size
        self.w=nn.Parameter(torch.empty(vocab_size,embedding_dim,device=device,dtype=dtype))
        nn.init.trunc_normal_(self.w,std=1,mean=0,a=-3,b=3)

    def forward(self,x):
        # x:b,l
        return self.w[x]
```

#### ROPE旋转位置编码
##### 核心思想
<figure><img src="/assets/img/posts/llm-transformer-moe/85519c088aec4446bbdb7a432fa80f61.png" alt="Transformer架构" width="700"><figcaption><p>RoPE 旋转示意</p></figcaption></figure>

+ 我们需要让$Q_m$和$K_n$进行**注意力操作的结果与它们的相对位置有关(m-n)**，我们可以使用旋转矩阵的性质来满足这一点
+ 首先我们只考虑二维度的情况，假设$Q_m'$=$R(m\theta)Q_m$，$K_n'=R(n\theta)K_n$，R是旋转矩阵，**旋转角度与它们的位置有关**。
+ 此时$Q'^TK'=Q_mR(m\theta)R(n\theta)K_n$,然后我们利用一些旋转矩阵的性质，得到$Q'^TK'=Q_mR((m-n)\theta)K_n$

##### 计算公式
+ 旋转矩阵R是一个2x2的矩阵(我们现在只对2维的情况考虑)，假设有n个维度，**我们可以构造n/2个旋转矩阵R组成的对角矩阵**(**将n个维度拆分为n/2个组，每个组单独考虑**)。
+ 每一个**2D旋转矩阵的公式该token的相对位置i和处于第k个组共同决定**。
<figure><img src="/assets/img/posts/llm-transformer-moe/913a4614c842430eb69c2f61c07b71f6.png" alt="Transformer架构" width="374"><figcaption><p>二维旋转矩阵</p></figcaption></figure>
<figure><img src="/assets/img/posts/llm-transformer-moe/5af0a2af88c5400eab3f95e2743e1df0.png" alt="Transformer架构" width="637"><figcaption><p>旋转角度计算</p></figcaption></figure>
+ 特点：**第一组的旋转弧度最大，后面的组得到的旋转弧度迅速递减**
<figure><img src="/assets/img/posts/llm-transformer-moe/5b3c7482691a41b8baf7fd193d42b7b3.png" alt="Transformer架构" width="700"><figcaption><p>RoPE 频率分布</p></figcaption></figure>
##### 实现
+ 只考虑第 $$d$$ 个 token，可以发现 RoPE 作用于特征维度后具有如下形式。
+ 下标从0开始，对于偶数位：`output[...,0::2]=self.cos*x_even-self.sin*x_odd`
+ 下标从0开始，对于奇数位：`output[...,1::2]=self.cos*x_odd+self.sin*x_even`
+ 旋转角度 $$\theta$$ 由 token 位置和二维子空间索引共同决定，因此可以提前计算：`theta_matrix=torch.outer(seqs,thetas)# [l,d_k/2]`。

$$
\begin{align}
\boldsymbol{R}_{\Theta,m}^d\boldsymbol{x}=
\begin{pmatrix}
x_0 \\
x_1 \\
x_2 \\
x_3 \\
\vdots \\
\end{pmatrix}\otimes
\begin{pmatrix}
\cos m\theta_1 \\
\cos m\theta_1 \\
\cos m\theta_2 \\
\cos m\theta_2 \\
\end{pmatrix}+
\begin{pmatrix}
-x_1 \\
x_0 \\
-x_3\\
x_2 \\
\vdots \\
\end{pmatrix}\otimes
\begin{pmatrix}
\sin m\theta_1 \\
\sin m\theta_1 \\
\sin m\theta_2 \\
\sin m\theta_2 \\
\vdots \\
\end{pmatrix}
\end{align}
$$


```python
class RotaryPositionEmbedding(nn.Module):
    def __init__(self,d_k,bigo,max_seq_len,device=None):
        super().__init__()
        self.d_k=d_k # n h l d

        # For dimension
        thetas=1/(bigo**(torch.arange(0,d_k,2,device=device)/d_k))
        
        # For sequence length
        seqs=torch.arange(0,max_seq_len,device=device)
        theta_matrix=torch.outer(seqs,thetas)# [l,d_k/2]

        self.register_buffer('cos',theta_matrix.cos(),persistent=False)
        self.register_buffer('sin',theta_matrix.sin(),persistent=False)

    def forward(self,x):
        # x: b h l d
        x_even=x[...,0::2]
        x_odd=x[...,1::2]
        output=torch.empty_like(x)
        output[...,0::2]=self.cos*x_even-self.sin*x_odd
        output[...,1::2]=self.cos*x_odd+self.sin*x_even
        return output
```

#### Attention机制
##### 缩放点积
+ 除以`d_k`的原因：如果不除以，注意力分数的均值和方差会比较大，**导致softmax结果趋向于0-1编码(所有的值都趋于1或者趋于0)，在这种情况下，softmax的梯度会几乎消失！**
+ 建议使用爱因斯坦乘机，**兼容多头注意力**`('... n d,...m d->...n m',q,k)`
```python
def scaled_dot_product(q,k,v,mask=None):
    d=q.size(-1)
    # 最好省略b维度,兼容多头注意力
    scores=torch.einsum('... n d,...m d->...n m',q,k)
    scores=scores/math.sqrt(d)
    if mask is not None:
        # masked_fill填充mask为True的位置!
        scores=scores.masked_fill(mask==False,float('-inf'))
    
    # torch.softmax() == nn.functional.softmax()
    attn_weights=torch.softmax(scores,dim=-1)
    output=torch.einsum('...n m,... m d->... n d',attn_weights,v)
    
    return output,attn_weights
```
##### 注意力机制
+ 兼容交叉注意力
+ **建议使用 `einops` <span style="color:red">中的</span> `rearrange` 操作避免转置等改变矩阵维度的操作。**

```python
from einops import rearrange# 建议使用
class Attention(nn.Module):
    def __init__(self,d_model,num_heads,bigo=10000,max_seq_len=None,device=None,dtype=None):
        super().__init__()

        self.d_model=d_model
        self.d_k=d_model//num_heads
        self.num_heads=num_heads
        factory_kwargs = {'device': device, 'dtype': dtype}
        self.q_proj=nn.Linear(d_model,d_model,**factory_kwargs)
        self.k_proj=nn.Linear(d_model,d_model,**factory_kwargs)
        self.v_proj=nn.Linear(d_model,d_model,**factory_kwargs)

        
        # 注意力块还有一个输出投影层
        self.o_proj=nn.Linear(d_model,d_model,**factory_kwargs)

        # rope
        if max_seq_len is not None:
            self.rope = RotaryPositionEmbedding(self.d_k,bigo,max_seq_len,device=device)
        else:
            self.rope = None
        
    def forward(self,q,k,v,mask=None):
        # x:b,l,d_model
        b,l,d=q.size()
        q= self.q_proj(q)
        k= self.k_proj(k)
        v= self.v_proj(v)
        
        # 多头
        q= rearrange(q,' ... l (h d)-> ... h l d',h=self.num_heads,d=self.d_k)
        k= rearrange(k,' ... l (h d)-> ... h l d',h=self.num_heads,d=self.d_k)
        v= rearrange(v,' ... l (h d)-> ... h l d',h=self.num_heads,d=self.d_k)

        if self.rope is not None:
            q = self.rope(q)
            k = self.rope(k)
        
        output,attn_weights=scaled_dot_product(q,k,v,mask=mask)
        output = rearrange(output,'... h l d -> ... l (h d)',h=self.num_heads,d=self.d_k)
        output=self.o_proj(output)
        return output,attn_weights
```

##### 注意力掩码
+ 因果掩膜：为了避免当前token偷看后面的token，所以是下三角矩阵
```python
A= torch.arange(1,10).view(3,3)
L= torch.tril(A,diagonal=0)
L
```
#### SwiGLU
SwiGLU的计算公式如下：

$$
\begin{align}
SwiGLU=(\sigma(xW_1^T)\cdot xW_2^T)\cdot W_3^T
\end{align}
$$

```python
from torch.nn import functional as F
# torch.sigmoid==F.sigmoid
def silu(x):
    return x * torch.sigmoid(x)  # 等价于 F.silu(x)
class ModernFFN(nn.Module):
    def __init__(self,d_model,d_ff,device=None,dtype=None):
        super().__init__()
        factory_kwargs = {'device': device, 'dtype': dtype}
        self.fc1=nn.Linear(d_model,d_ff,**factory_kwargs)
        self.gate=nn.Linear(d_model,d_ff,**factory_kwargs)
        self.fc2=nn.Linear(d_ff,d_model,**factory_kwargs)
    def forward(self,x):
        o1=silu(self.fc1(x))
        o_gate=self.gate(x)
        o=self.fc2(o1*o_gate)
        return o
```

#### LayerNorm
+ LayerNorm=**高斯标准化进行缩放+偏差**

$$
\begin{align}
LayerNorm(x)=\frac{x-E(x)}{\sqrt{VAR(x)}}\cdot \gamma+ \beta
\end{align}
$$

+ $\gamma$和$\beta$都是**可学习的参数**,维度为(d_model,)
```python
class LayerNorm(nn.Module):
    def __init__(self,d_model,device=None,dtype=None,eps=1e-5):
        super().__init__()
        self.d_model=d_model
        self.eps=eps
        factory_kwargs = {'device': device, 'dtype': dtype}
        self.gamma=nn.Parameter(torch.ones(d_model,**factory_kwargs))# d_model,
        self.beta=nn.Parameter(torch.zeros(d_model,**factory_kwargs))# d_model,
    def forward(self,x):
        # x:b l d
        x_mean=x.mean(dim=-1,keepdim=True)# b l 1
        x_var=x.var(dim=-1,keepdim=True,unbiased=False)# b l 1

        # boardcast [b l 1]->[b l d]
        x_norm=(x-x_mean)/(torch.sqrt(x_var+self.eps))*self.gamma+self.beta
        return x_norm
```
+ 细节：`keepdim=True`:**保留一个维度，方便广播**
#### RMSNorm
RMSNorm的公式：

$$
\begin{align}
\frac{x}{RMS(x)+\epsilon}\cdot\gamma
\end{align}
$$

+ 其中，$$RMS(x)=\sqrt{\frac{1}{d}\sum_{i=1}^{d}x_i^2}$$ 表示向量 $$x$$ 的均方根，$$\gamma$$ 是维度为 $$d_{model}$$ 的可学习缩放参数。
+ $\gamma$代表**RMSNorm的参数**,维度为(d_model,)。
```python
class RMSNorm(nn.Module):
    def __init__(self,d_model,device=None,dtype=None,eps=1e-8):
        super().__init__()
        self.d_model=d_model
        self.eps=eps
        factory_kwargs = {'device': device, 'dtype': dtype}
        self.gamma=nn.Parameter(torch.ones(d_model,**factory_kwargs))# d_model,
    def forward(self,x):
        # x:b l d
        x_rms=torch.sqrt(torch.mean(x**2,dim=-1,keepdim=True)+self.eps)# b l 1
        x_norm=x/(x_rms)*self.gamma
        return x_norm
```


#### TransformerBlock
+ 采取PreNorm范式：**在进行ffn和attention操作前就进行归一化操作**
+ 输入和输出维度为(b,l,d_model)
```python
class TransformerBlock(nn.Module):
    def __init__(self,d_model,num_heads,d_ff,bigo,max_seq_len,device=None,dtype=None):
        super().__init__()
        factory_kwargs = {'device': device, 'dtype': dtype}
        self.ln1 = RMSNorm(d_model,**factory_kwargs)
        self.ln2 = RMSNorm(d_model,**factory_kwargs)
        self.ffn = ModernFFN(d_model,d_ff,**factory_kwargs)
        self.attention = Attention(d_model,num_heads,bigo,max_seq_len,**factory_kwargs)
    def forward(self,x,mask=None):
        # pre-norm
        # x:b l d
        x_norm_1 = self.ln1(x)
        x_attn, attn_weights = self.attention(x_norm_1,x_norm_1,x_norm_1,mask=mask) # output,score
        x_1 = x + x_attn # output,score
        x_norm_2 = self.ln2(x_1)
        x_ffn = self.ffn(x_norm_2)
        x_2 = x_1 + x_ffn
        return x_2
```
### 完整的语言模型
+ 输入:(b,l)，编码后的结果
+ 输出 `(b, l, vocab_size)` 的 logits；需要概率时再执行 softmax。
```python
class TransformerLM(nn.Module):
    def __init__(self,vocab_size,n_layers,d_model,d_ff,num_heads,bigo,max_seq_len,device=None,dtype=None):
        # 默认为prenorm
        # transformer block的最后一层输入前还有一层RMSnorm
        super().__init__()
        factory_kwargs = {'device': device, 'dtype': dtype}
        self.embedding = Embedding_Layer(vocab_size,d_model,**factory_kwargs)
        self.transformer_blocks= nn.ModuleList(
            TransformerBlock(d_model,num_heads,d_ff,bigo,max_seq_len,**factory_kwargs)
            for _ in range(n_layers)
        )
        
        self.ln_f = RMSNorm(d_model,**factory_kwargs)
        self.output_head = Linear(d_model,vocab_size,**factory_kwargs)
    def forward(self,x,token_positions=None,mask=None):
            # x:b l 
            # attn_weights = []
            x = self.embedding(x)
            for block in self.transformer_blocks:
                x = block(x, mask=mask)
            x = self.ln_f(x)
            x = self.output_head(x)
            return x
```

---

## 合并校订说明

本次整合已直接修正 SiLU、RoPE、Attention 输入形状、TransformerBlock 参数传递和 logits/概率等明确问题。实现仍是课程作业笔记版本；用于生产前还需补充形状断言、RoPE 缓存切片、KV cache 和高效注意力算子。


## 本部分资源完整性

- 两篇原文的 17 张图片均已保存到 `/assets/img/posts/llm-transformer-moe/`。
- 本部分图片引用均已改为站点内的本地路径，不再依赖 CSDN 外链。
- 原文没有其他需要复制的本地附件。

---

## CS336：MoE 混合专家

> 原始文件：_posts/2026/02/2026-02-01-llm_cs336_moe.md

### torch前置知识

#### `torch.expand(a,b,c)`
+ **扩展至(a,b,c)的维度**
+ **只能扩充1的维度**
+ 不创建新内存，类似view
```python
x = torch.tensor([[1], [2], [3]])
x.size()
torch.Size([3, 1])
x.expand(3, 4)
tensor([[ 1,  1,  1,  1],
        [ 2,  2,  2,  2],
        [ 3,  3,  3,  3]])
x.expand(-1, 4)   # -1 means not changing the size of that dimension
tensor([[ 1,  1,  1,  1],
        [ 2,  2,  2,  2],
        [ 3,  3,  3,  3]])
```


#### `torch.repeat(a,b,c)`
+ 每个维度分别复制a，b，c次
+ 可以扩展不为1的维度
+ 创建新内存

```python
x = torch.tensor([1, 2, 3])
x.repeat(4, 2)
tensor([[ 1,  2,  3,  1,  2,  3],
        [ 1,  2,  3,  1,  2,  3],
        [ 1,  2,  3,  1,  2,  3],
        [ 1,  2,  3,  1,  2,  3]])
x.repeat(4, 2, 1).size()
torch.Size([4, 2, 3])
```

#### `torch.nonzero(as_tuple=False)`:
+ 返回向量维度为(z,n_dim)，z表示有多少个匹配的非0元素，n_dim表示对应坐标。

```python
torch.nonzero(torch.tensor([1, 1, 1, 0, 1]))
tensor([[ 0],
        [ 1],
        [ 2],
        [ 4]])
torch.nonzero(torch.tensor([[0.6, 0.0, 0.0, 0.0],
                            [0.0, 0.4, 0.0, 0.0],
                            [0.0, 0.0, 1.2, 0.0],
                            [0.0, 0.0, 0.0,-0.4]]))
tensor([[ 0,  0],
        [ 1,  1],
        [ 2,  2],
        [ 3,  3]])
torch.nonzero(torch.tensor([1, 1, 1, 0, 1]), as_tuple=True)
(tensor([0, 1, 2, 4]),)
torch.nonzero(torch.tensor([[0.6, 0.0, 0.0, 0.0],
                            [0.0, 0.4, 0.0, 0.0],
                            [0.0, 0.0, 1.2, 0.0],
                            [0.0, 0.0, 0.0,-0.4]]), as_tuple=True)
(tensor([0, 1, 2, 3]), tensor([0, 1, 2, 3]))
torch.nonzero(torch.tensor(5), as_tuple=True)
(tensor([0]),)
```

#### `torch.index_select`
+ `torch.index_select(input, dim, index, *, out=None) → Tensor`
+ 指定维度选择指定坐标的元素
```python
# dim=0
tensor([[[20, 21, 22, 23, 24],
         [25, 26, 27, 28, 29],
         [30, 31, 32, 33, 34],
         [35, 36, 37, 38, 39]]])
# dim=1
tensor([[[ 5,  6,  7,  8,  9]],

        [[25, 26, 27, 28, 29]]])
# dim=2
tensor([[[ 1],
         [ 6],
         [11],
         [16]],

        [[21],
         [26],
         [31],
         [36]]])
# 索引后的数组尺寸，除了dim部分，其他和原来大小一样
# 原始
torch.Size([2, 4, 5])
# dim=0
torch.Size([1, 4, 5])
# dim=1
torch.Size([2, 1, 5])
# dim=2
torch.Size([2, 4, 1])

```


### MoE 混合专家
#### 核心思想
>混合专家模型（Mixture of Experts，MoE）是一种先进的神经网络架构，旨在通过整合多个模型或“专家”的预测来提升整体模型性能。MoE模型的核心思想是将**输入数据分配给不同的专家子模型，然后将所有子模型的输出进行合并**，以生成最终结果。这种分配可以根据输入数据的特征进行动态调整，确保每个专家处理其最擅长的数据类型或任务方面，从而实现更高效、准确的预测。

<figure><img src="/assets/img/posts/llm-transformer-moe/0411ae8b196d424e965065c9ea9b6e63.png" alt="Transformer架构" width="700"><figcaption><p>MoE 架构示意</p></figcaption></figure>

#### 优势
+ 模型索然很大，但是推理速度快。例如同样的FLOPs，**由于只激活少数专家，实际激活参数量比较低，推理速度比同样参数的密集模型快，而且可以得到更好的结果**。
+ 训练起来不像密集架构那样全部参数都要训练，**只有少数专家激活并参与训练**
+ 分布式架构：**专家可以分配到不同设备上去。**

#### 劣势
+ 理论上分布式，**在缺乏分布式节点和计算设备时比较鸡肋**。
+ 训练不稳定：**路由算法往往不可微分**，路由算法的学习不稳定。


### MoE的基本原理
#### MoE的架构
+ **多个不同的MLP** vs 多个不同的 Transformer头
+ 注意：为了确保参数量不会爆炸，**MLP的d_ff通常会大幅度减小，甚至比d_model还小**
<figure><img src="/assets/img/posts/llm-transformer-moe/7ec0b6ebc5194c6b85790620039fbdd2.png" alt="Transformer架构" width="700"><figcaption><p>专家路由过程</p></figcaption></figure>
#### 路由算法
+ 基本分类：**为每一个token选专家** vs 为每一个专家选token
<figure><img src="/assets/img/posts/llm-transformer-moe/85eaeb3744404f2fa05bf5ca79e4cf16.png" alt="Transformer架构" width="700"><figcaption><p>Top-k 路由</p></figcaption></figure>
+ **通常是为每一个token选专家：具体策略可以分类为 随机选择，RL算法，TOPK，哈希法。**
##### TOPK算法
+ 基本思想：**将路由器认为是一个简单的MLP**，给定token x，**映射为专家选择的概率s**，选择前K个专家。
+ 将专家计算的结果和选择概率**加权求和**与原输入残差链接。

<figure><img src="/assets/img/posts/llm-transformer-moe/7abc47ca49c5472982c5900958c7fcc5.png" alt="Transformer架构" width="700"><figcaption><p>专家容量分配</p></figcaption></figure>

#### 路由选择函数的训练目标(损失函数)
+ 核心思想：**避免只选择特定专家和设备**
<figure><img src="/assets/img/posts/llm-transformer-moe/90f6f2cb784e4852afab2fca166974f7.png" alt="Transformer架构" width="700"><figcaption><p>负载均衡损失</p></figcaption></figure>
+ $f_i$：统计所有batch/设备中**实际选择专家i的比例**
+ $P_i$ ：统计所有batch/设备中路由器选择专家i的概率(**想选择专家i的比例**)
+ 惩罚**路由器想选择专家i且实际选择专家i的情况**。

<figure><img src="/assets/img/posts/llm-transformer-moe/815ca11ac25c476195e4a3df90941c87.png" alt="Transformer架构" width="700"><figcaption><p>专家并行示意</p></figcaption></figure>
+ 直接对于softmax分数进行显示调整的方法：
<figure><img src="/assets/img/posts/llm-transformer-moe/870c19396bca4eb2b5202a5ea8068c23.png" alt="Transformer架构" width="700"><figcaption><p>MoE 输出合并</p></figcaption></figure>



---

