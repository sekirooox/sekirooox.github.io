---
title: "计算机基础·cs336·损失函数,优化器,调度器,数据处理和模型加载保存"
author: MayL
date: 2026-02-07
categories: ["大语言模型与强化学习", "大语言模型"]
tags: ["人工智能", "学习笔记"]
render_with_liquid: false
math: true
description: "本文围绕“计算机基础·cs336·损失函数,优化器,调度器…”梳理核心概念、算法思路与实践要点，便于系统学习和后续查阅。"
---

@[toc]
# Entropy:
$$H(x)=x\cdot logx$$
## BCE:二分类损失
$$L=- y\cdot logy_{pred}+(1-y) \cdot log(1-y_{pred})$$
+ 一句话概括:**y为正,看预测正类的概率;y为负类,预测负类的概率**
+ 注意有一个负号
## Cross Entropy:

### 朴素实现
+ $y_{pred}$:(b,...,n)
+ $y$:(b,...)
+ 将y零一向量化至(b,...,n)维度，然后对于每一个维度运行BCE二分类损失算法

>缺点：无用计算，大部分维度都是0，**只有维度为1的情况才有运算**。


### Log-sum-exp实现
+ CE等价于对于标签所在维度进行熵的运算
+ 经过(2)的等价操作，我们只需要计算(3)中的**log-sum-exp项**，然后减去**标签维度的输出**(注意这里不是概率)即可。
$$
\begin{align}
  &\ell=-\log\left(\mathrm{Softmax}(o)_y\right)=-\log\left(\frac{\exp(o_y)}{\sum_j\exp(o_j)}\right)\\
 & \ell=-\left(\log(\exp(o_{y}))-\log\sum_{j}\exp(o_{j})\right) \\
 & \ell=\underbrace{\log\left(\sum_{j}\exp(o_{j})\right)}_{\text{LogSumExp 项}}-o_{y}
\end{align}$$
+ 但是直接计算log-sum-exp项的数值不稳定，例如某些输出可能很大>89，造成inf移除，有的情况下，输出都很小，导致分母接近于0。
+ 我们对每一个输出的结果减去最大值$m$得到稳定计算log-sum-exp项的公式：
$$
\begin{align}\begin{gathered}
&\mathrm{LogSumExp}(o)=\log\left(\sum\exp(o_{j}-M+M)\right) \\
&\mathrm{LogSumExp}(o)=\log\left(\exp(M)\cdot\sum\exp(o_{j}-M)\right) \\
&\mathrm{LogSumExp}(o)=M+\log\sum\exp(o_{j}-M)
\end{gathered}\end{align}
$$
```python
def cross_entropy_loss(logits,targets):
    """
    logits : b ... n
    targets : b ... 
    """
    m = torch.max(logits,dim=-1,keepdim=True).values# b ... 1
    log_sum_exp = torch.log(torch.sum(torch.exp(logits-m),dim=-1,keepdim=True))# b ... 1
    log_sum_exp = log_sum_exp + m # b ... 1
    target_logits = torch.gather(logits,dim=-1,index=targets.unsqueeze(-1))# b ... 1
    loss = log_sum_exp - target_logits # b ... 1
    return loss.mean()# 对batch和seq维度求平均
```

## Softmax实现
+ **减去最大值然后再进行指数与求和**
+ 结果等价，但是数值更加稳定。
$$
\begin{align}
Softmax&=\frac{e^z}{\sum_ie^i}\\
&=\frac{e^{z-m}}{\sum_ie^{i-m}}
&=\frac{e^m}{e^m}\frac{e^{z-m}}{\sum_ie^{i-m}}
\end{align}
$$

```python
def softmax(x,dim):
    # x: b...n 
    # 使用log-sum-exp的技巧,所有softmax函数-最大值m
    m = torch.max(x,dim=dim,keepdim=True).values
    sum_exp = torch.sum(torch.exp(x-m),dim=dim,keepdim=True)
    return torch.exp(x-m)/sum_exp
```
---
# Adam和AdamW优化器原理
+ $m_t$代表第t次优化的动量，就是历史梯度的加权**一阶矩估计**。
+ $v_t$代表第t次优化的缩放系数，就是历史梯度的加权**二阶矩估计**。
$$
\begin{align}
m_t&=\beta_1m_{t-1}+(1-\beta_1)g_t \\
v_{t}&=\beta_{2}v_{t-1}+(1-\beta_{2})g_{t}^{2}
\end{align}
$$
+ 冷启动：当优化次数t区域无穷时，没有影响；当t较小时，原来的动力和缩放系数会被适当增大
$$\hat{m}_t=\frac{m_t}{1-\beta_1^t},\quad\hat{v}_t=\frac{v_t}{1-\beta_2^t}$$

## AdamW优化器
+ 在原有基础上解决了权重衰减的一些问题，在更新时**单独减去权重衰减**$\eta\lambda\theta_t$系数。
+ 参数更新公式：**先更新Adam，再更新权重衰减**
$$\Delta\theta_t=\eta\frac{\hat{m}_t}{\sqrt{\hat{v}_t}+\epsilon}\\
\theta_{t+1}=\theta_t-\Delta\theta_t-\underbrace{\eta\lambda\theta_t}_{\text{解耦的衰减项}}
$$
## Optimizer的原理
+ self.param_groups：一般只有一个，就**对应你传入的parameters()和学习率参数**。
+ super().__init__(params,defaults)。

```python
from torch.optim import Optimizer
"""Adam的实现,无性能优化版本"""
class AdamW(Optimizer):
    def __init__(self,params,lr=1e-3,betas=(0.9,0.999),eps=1e-8,weight_decay=0.01):
        defaults = dict(lr=lr,betas=betas,eps=eps,weight_decay=weight_decay)
        super().__init__(params,defaults)# defaults 会被复制到每个 param_group
        # self.state(dict),self.param_groups(dict) 
    def step(self,closure=None):
        # 标准接口
        loss = None
        if closure is not None:
            with torch.enable_grad():
                loss = closure()
        for group in self.param_groups:
            params = group['params']
            lr = group['lr']
            beta1, beta2 = group['betas']
            eps = group['eps']
            weight_decay = group['weight_decay']
            for p in params:
                if p.grad is None:
                    continue
                
                # g_t
                grad = p.grad.data

                state = self.state[p] 
                if len(state)==0:
                    state['t'] = 0
                    # memory_format=torch.preserve_format用于内存优化
                    state['m'] = torch.zeros_like(p,memory_format=torch.preserve_format)
                    state['v'] = torch.zeros_like(p,memory_format=torch.preserve_format)
                
                # Adam 更新公式:分别更新一阶矩和二阶矩
                state['t'] += 1
                state['m'] = beta1*state['m'] + (1-beta1)*grad
                state['v'] = beta2*state['v'] + (1-beta2)*grad*grad

                # Cold Start:不能保存
                m_hat = state['m']/(1-beta1**state['t'])
                v_hat = state['v']/(1-beta2**state['t'])

                # 先使用Adam公式,再使用权重衰减
                adam_term = lr*m_hat/(torch.sqrt(v_hat)+eps)

                # 权重衰减
                if weight_decay is not None:
                    weight_decay_term = lr*weight_decay*p.data
                else: 
                    weight_decay_term = 0
                
                p.data -= adam_term + weight_decay_term
        return loss
```

# 可变学习率
>在训练函数中**使用下列函数获得新的学习率，然后替代优化器中的学习率即可**。
>
$$\alpha(t)=
\begin{cases}
\alpha_{\max}\cdot\frac{t}{T_w}, & 0\leq t<T_w \\
\alpha_{\min}+\frac{1}{2}\left(1+\cos\left(\pi\cdot\frac{t-T_w}{T_c-T_w}\right)\right)(\alpha_{\max}-\alpha_{\min}), & T_w\leq t\leq T_c \\
\alpha_{\min}, & t>T_c & 
\end{cases}$$
## Warmup
+ **一开始模型会进行热身，学习率会比较低**，缓慢提高，防止随机初始化的参数在遇到高学习率时表现非常不稳定的情况
## Cosine退火
+ 在稳定更新参数的时候，**学习率缓慢减小**
## 训练尾部
+ **保持较低学习率**

```python
import math
def get_lr_cosine_schedule_with_warmup(
    it,
    max_lr,
    min_lr,
    warmup_iters,
    cosine_schedule_iters,
):
    # 1. warmup 阶段
    if it < warmup_iters:
        return max_lr * it / warmup_iters

    # 2. 退火结束后
    if it > cosine_schedule_iters:
        return min_lr

    # 3. cosine decay 阶段
    decay_ratio = (it - warmup_iters) / (cosine_schedule_iters - warmup_iters)
    coeff = 0.5 * (1.0 + math.cos(math.pi * decay_ratio))
    lr = min_lr + coeff * (max_lr - min_lr)
    return lr
```
---
# 梯度裁剪
+ 为了避免模型的梯度爆炸，有时需要对模型参数的梯度进行一定裁剪，保持安全值范围内容
+ 对所有参数的梯度进行norm-2计算，然后进行裁剪
$$g_{new}=g_{old}\times\frac{M}{\|g\|_2+\epsilon}$$

```python
def clip_grad_norm(parameters,max_norm,eps=1e-5):
    parameters = [p for p in parameters if p.grad is not None ]
    if parameters is None:
        return 
    
    total_norm = 0
    for p in parameters:
        # 在step之前调用
        param_norm = torch.norm(p.grad.detach(),2)
        total_norm += param_norm.item() ** 2 # sum{p^2}

    total_norm = total_norm ** 0.5 
    if total_norm > max_norm:
        for p in parameters:
            p.grad.detach().mul_(max_norm/(total_norm+eps))
```

# 数据处理
+ 训练任务:**预测下一个词**
+ 训练集和标签定义: 训练集$[x_i,...x_n]$,标签:$[x_{i+1},...x_n]$
+ **不要直接使用list读取完整文本，使用`np.memmap`建立内存映射，需要时候读取！**
```python
import numpy as np
import numpy.typing as npt
import torch
def get_batch(dataset:npt.NDArray,batch_size,max_seq_length,device):
    # dataset:ndarray(list)
    n = len(dataset)
    # max_idx max_idx + max_seq_length-1 + 1 <= len(dataset)-1 
    max_idx = n - max_seq_length - 1
    start_indices = np.random.randint(0,max_idx+1,size=(batch_size,))

    # torch.stack:从某一个维度堆叠tensor
    x_batch = torch.stack(
        [torch.from_numpy(dataset[st_idx:st_idx+max_seq_length])
        for st_idx in start_indices]
    )
    y_batch = torch.stack(
        [torch.from_numpy(dataset[st_idx+1:st_idx+max_seq_length+1])
        for st_idx in start_indices]
    )

    return x_batch.to(device),y_batch.to(device)
```

# 模型保存和存储
+ 分别保存model，optimizer的state_dict()，还有**保存当前的iteration(主要用于更新学习率调度)**。

```python
def save_checkpoint(model,optimizer,iteration,save_path):
    checkpoint = {
        'model': model.state_dict(),
        'optimizer': optimizer.state_dict(),
        'iteration': iteration
    }
    torch.save(checkpoint,save_path)    
```

```python
def load_checkpoint(model,optimizer,filepath,device='cpu'):
    checkpoint = torch.load(filepath,map_location=device)
    model.load_state_dict(checkpoint['model'])
    optimizer.load_state_dict(checkpoint['optimizer'])
    iteration = checkpoint['iteration']
    return iteration
```

