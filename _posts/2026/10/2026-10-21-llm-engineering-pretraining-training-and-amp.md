---
title: "LLM 预训练、训练栈与 AMP"
date: 2026-10-21
categories: ["大语言模型与强化学习", "大语言模型"]
tags: ["llm", "pytorch", "transformers", "huggingface", "cs336"]
description: "从 MiniMind 预训练数据管线到 CS336 训练、推理、实验和自动混合精度。"
published: true
math: true
---

# LLM 预训练、训练栈与 AMP

本文整合 MiniMind 预训练、CS336 训练栈、语言模型训练与推理、模型实验，以及 AMP 自动混合精度笔记。正文尽量保留原始代码、公式、图片、命令与实验记录，仅调整章节顺序、统一标题层级，并修正明确的技术错误。

> **内容来源**
>
> - `_posts/2026/03/2026-03-24-llm_minimind_pretrain.md`
> - `_posts/2026/02/2026-02-07-llm_cs336_training_stack.md`
> - `_posts/2026/02/2026-02-12-llm_cs336_train_infer.md`
> - `_posts/2026/02/2026-02-13-llm_cs336_exp_infer.md`
> - `_posts/2026/03/2026-03-24-llm_amp.md`

## MiniMind 预训练：模型、数据与 Trainer

> 原始文件：`_posts/2026/03/2026-03-24-llm_minimind_pretrain.md`

> **整合修订说明**
>
> - Transformers 通常从 `config.json` 读取模型配置，而不是 `model.info`。
> - `AutoModelForCausalLM.from_config(config)` 会按配置随机初始化模型；只有加载自定义远端代码时才涉及 `trust_remote_code`。
> - 同一 batch 最终需要规则张量，但原始样本不必等长；可以动态 padding 或定长 packing。
> - `default_data_collator` 负责组 batch，不会执行 MLM 随机掩码。下方保留原实现，同时以这些修订为准。

>**所有的代码都基于`transformers`库。**
### 预训练
#### 初始化模型和分词器
##### 初始化配置文件 AutoConfig
+ 类似transformers中的AutoModel一样，都需要先下载配置文件`model.info`，然后读取该文件夹获得配置信息
```cpp
from transformers import AutoConfig, AutoModelForCausalLM
model_path = "../model/Qwen2.5-1.5B"
config = AutoConfig.from_pretrained(model_path)
config
```
+ 配置信息包含模型的架构：

```cpp
Qwen2Config {
  "architectures": [
    "Qwen2ForCausalLM"
  ],
  "attention_dropout": 0.0,
```

##### 从配置文件初始化 AutoModel
+ `AutoModelForCausalLM.from_config`：这一步构造初始化需要很长的时间
+ **可能涉及与远程仓库中的定义进行对齐，甚至下载远程仓库的代码，没有科学上网会卡死！**
```cpp
model = AutoModelForCausalLM.from_config(config,trust_remote_code=False)
model.to("cuda")
```

+ model的具体架构：

```cpp
model
Qwen2ForCausalLM(
  (model): Qwen2Model(
    (embed_tokens): Embedding(151936, 1536)
    (layers): ModuleList(
      (0-27): 28 x Qwen2DecoderLayer(
        (self_attn): Qwen2SdpaAttention(
          (q_proj): Linear(in_features=1536, out_features=1536, bias=True)
          (k_proj): Linear(in_features=1536, out_features=256, bias=True)
          (v_proj): Linear(in_features=1536, out_features=256, bias=True)
          (o_proj): Linear(in_features=1536, out_features=1536, bias=False)
          (rotary_emb): Qwen2RotaryEmbedding()
```

##### 加载 AutoTokenizer
```cpp
from transformers import AutoTokenizer
tokenizer = AutoTokenizer.from_pretrained(model_path)
tokenizer
```


#### 预训练数据集
+ 数据集格式：**必须是token化的序列**
+ **最大长度必须一致**。
+ 构造出labels，**该labels与input_ids一致，模型会处理移位**。

##### 加载数据集
[参考文献](https://blog.csdn.net/orangerfun/article/details/131927248)
+ `path`：表示**数据集的名称**`monkey-gen`，如果只有当前参数则会自动下载到缓存；**数据集的格式**，例如`json，csv`等
+ `data_dir`：数据集所在的本地目录
+ `data_file`：数据集本身，例如`xxx.jsonl`.

```cpp
dataset = load_dataset("csv", data_files="./ChnSentiCorp_htl_all.csv", split="train")
dataset = load_dataset("json", data_files="./cmrc2018_trial.json", field="data")
```

##### DataDict
+ **类型为`Dict[str,Dataset]`**
+ 把他当成一个字典来理解，用于获得train或者test字段的Dataset。
+ **不支持直接索引**
```cpp
DatasetDict({
    train: Dataset({
        features: ['input_ids', 'attention_mask'],
        num_rows: 100001
    })
})
```
##### Dataset
+ **数组和字典的混合体**。
+ **可以理解为 `List[Dict]` <span style="color:red">或者</span> `Dict[List]` 的形式**，支持下标索引和键值对索引。


```cpp
Dataset({
    features: ['input_ids', 'attention_mask', 'labels'],
    num_rows: 1370
})
```


##### 数据预处理
+ 我们期望的预训练格式如下：首先是将原始文本 `str` <span style="color:red">转换为</span> `input_ids:List[int]`

###### 数据预先处理函数
+ 输入参数：`batched=True`时为examples：类型为`Dict[str,List[Any]]`

```cpp
examples = {
    "text": [
        "今天天气不错。",
        "我在学预训练语言模型。",
        "DeepSpeed 加速训练。"
    ]
}
```
+ 返回参数：`batched=True` <span style="color:red">时返回类型为</span> `Dict[str,List[Any]]`
+ 注意**tokenizer处理batch时会返回字典**`Dict[str,List[Any]]`。
```cpp
{
    "input_ids":      [[..., ...], [..., ...], [..., ...]],
    "attention_mask": [[..., ...], [..., ...], [..., ...]],
    # 其他字段（如 token_type_ids 等）
}
```

###### 1.数据集编码为tokens


```cpp
def tokenize_function(
examples:Dict[str,List[Any]]  # 列名 对应一个列表/值 
):
    return tokenizer(
        [text for text in examples['text']]
    )
    
```
examples的**数据类型**
+ examples的类型为：`Dict[str,List]`
+ 例如：`‘text’:[1,2,3]`

```cpp
tokenized_ds = ds.map(
    tokenize_function,
    batched=True,# 打包为列名：值/列表 'text': ['文本1', '文本2', ...]
    num_proc=10,
    remove_columns=column_names,
    load_from_cache_file=True
)
```
+ 输出结果，将删除当前列，并且返回`input_ids`，`attention_mask`组成的字典。
```cpp
DatasetDict({
    train: Dataset({
        features: ['input_ids', 'attention_mask'],
        num_rows: 5001
    })
})
```

###### 2.数据集分块，获得特定长度的`input_ids`和`labels`

```cpp
def group_texts(
    examples:Dict[str,List[str]]
):
    # 拼接所有可迭代对象
    concat_examples:Dict[str:List] ={
        k:list(chain(*examples[k])) # iter->list
        for k in examples.keys()# List[tensor]
    }

    # 计算总长度 seq=mask
    total_length = len(concat_examples[list(examples.keys())[0]])

    num_block = total_length // block_size 
    result = {
        # list -> list[tensor]
        k: [
            concat_examples[k][i*block_size:(i+1)*block_size] for i in range(num_block)
        ] 
        for k in concat_examples.keys()
    }
    result['labels'] = result['input_ids'].copy()
    return result
```

```cpp
lm_ds = tokenized_ds.map(
    group_texts,
    batched=True,
    num_proc=10,
    load_from_cache_file=True,
    batch_size = 1000,
)
```

chain：合并迭代器
+ 拼接两个迭代器，返回一个更长的迭代器
+ 可以通过list转换为数组。

```cpp
from itertools import chain
block_size = 2048
# 首位拼接 可迭代对象 -> 返回长迭代器
list(chain([1, 2], [3, 4]))      # [1, 2, 3, 4]
list(chain(*[[1, 2], [3, 4]]))   # [1, 2, 3, 4]
```


#### 训练器
+ 训练器包括**优化器**，**模型本身**，分词器等等，数据集**加粗样式**。
##### TrainingArguments
+ 规定了一些重要的超参数
+ 包括训练参数：epoch数，**梯度累积更新数**，评估参数等等
```cpp
from transformers import TrainingArguments
training_args = TrainingArguments(
    output_dir="output/",
    per_device_train_batch_size=1,
    gradient_accumulation_steps=4,
    logging_steps=4,
    num_train_epochs=1,
    save_steps=500, 
    learning_rate=1e-4,
    save_on_each_node=True,
    gradient_checkpointing=True,
)
```

##### Trainer
+ 数据集使用`default_data_collator`：**进行封装为batch**
+ `IterableWrapper(train_dataset)`：支持将训练集包裹为可迭代对象，**可以直接传入`Dataset`类型**。

```cpp
from transformers import Trainer, default_data_collator
from torchdata.datapipes.iter import IterableWrapper
# 训练器
trainer = Trainer(
    model=model,
    args=training_args,
    # Dataset传入也可以, 本身就是mmap, 不会节省太多内存
    train_dataset= IterableWrapper(train_dataset),# 将Dataset类型包裹为迭代器
    eval_dataset= None,
    # tokenizer=tokenizer,
    # 默认为 MLM 的 collator，使用 CLM 的 collater
    # CLM：因果语言建模, 输入和输出标签一致, 不会随机掩码
    data_collator=default_data_collator, # MLM：掩码语言建模,完型填空, 不会随机掩码;
)
```

---

---

## CS336：损失函数、优化器、调度器、数据与检查点

> 原始文件：_posts/2026/02/2026-02-07-llm_cs336_training_stack.md

### Entropy:

$$
\begin{align}
H(x)=x\cdot logx
\end{align}
$$

#### BCE:二分类损失

$$
\begin{align}
L=- y\cdot logy_{pred}+(1-y) \cdot log(1-y_{pred})
\end{align}
$$

+ 一句话概括:**y为正,看预测正类的概率;y为负类,预测负类的概率**
+ 注意有一个负号
#### Cross Entropy:

##### 朴素实现
+ $y_{pred}$:(b,...,n)
+ $y$:(b,...)
+ 将y零一向量化至(b,...,n)维度，然后对于每一个维度运行BCE二分类损失算法

>缺点：无用计算，大部分维度都是0，**只有维度为1的情况才有运算**。


##### Log-sum-exp实现
+ CE等价于对于标签所在维度进行熵的运算
+ 经过(2)的等价操作，我们只需要计算(3)中的**log-sum-exp项**，然后减去**标签维度的输出**(注意这里不是概率)即可。

$$
\begin{align}
  &\ell=-\log\left(\mathrm{Softmax}(o)_y\right)=-\log\left(\frac{\exp(o_y)}{\sum_j\exp(o_j)}\right)\\
 & \ell=-\left(\log(\exp(o_{y}))-\log\sum_{j}\exp(o_{j})\right) \\
 & \ell=\underbrace{\log\left(\sum_{j}\exp(o_{j})\right)}_{\text{LogSumExp 项}}-o_{y}
\end{align}
$$

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

#### Softmax实现
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
### Adam和AdamW优化器原理
+ $m_t$代表第t次优化的动量，就是历史梯度的加权**一阶矩估计**。
+ $v_t$代表第t次优化的缩放系数，就是历史梯度的加权**二阶矩估计**。

$$
\begin{align}
m_t&=\beta_1m_{t-1}+(1-\beta_1)g_t \\
v_{t}&=\beta_{2}v_{t-1}+(1-\beta_{2})g_{t}^{2}
\end{align}
$$

+ 冷启动：当优化次数t区域无穷时，没有影响；当t较小时，原来的动力和缩放系数会被适当增大

$$
\begin{align}
\hat{m}_t=\frac{m_t}{1-\beta_1^t},\quad\hat{v}_t=\frac{v_t}{1-\beta_2^t}
\end{align}
$$


#### AdamW优化器
+ 在原有基础上解决了权重衰减的一些问题，在更新时**单独减去权重衰减**$\eta\lambda\theta_t$系数。
+ 参数更新公式：**先更新Adam，再更新权重衰减**

$$
\begin{align}
\Delta\theta_t=\eta\frac{\hat{m}_t}{\sqrt{\hat{v}_t}+\epsilon}\\
\theta_{t+1}=\theta_t-\Delta\theta_t-\underbrace{\eta\lambda\theta_t}_{\text{解耦的衰减项}}
\end{align}
$$

#### Optimizer的原理
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

### 可变学习率
>在训练函数中**使用下列函数获得新的学习率，然后替代优化器中的学习率即可**。
>

$$
\begin{align}
\alpha(t)=
\begin{cases}
\alpha_{\max}\cdot\frac{t}{T_w}, & 0\leq t<T_w \\
\alpha_{\min}+\frac{1}{2}\left(1+\cos\left(\pi\cdot\frac{t-T_w}{T_c-T_w}\right)\right)(\alpha_{\max}-\alpha_{\min}), & T_w\leq t\leq T_c \\
\alpha_{\min}, & t>T_c & 
\end{cases}
\end{align}
$$

#### Warmup
+ **一开始模型会进行热身，学习率会比较低**，缓慢提高，防止随机初始化的参数在遇到高学习率时表现非常不稳定的情况
#### Cosine退火
+ 在稳定更新参数的时候，**学习率缓慢减小**
#### 训练尾部
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
### 梯度裁剪
+ 为了避免模型的梯度爆炸，有时需要对模型参数的梯度进行一定裁剪，保持安全值范围内容
+ 对所有参数的梯度进行norm-2计算，然后进行裁剪

$$
\begin{align}
g_{new}=g_{old}\times\frac{M}{\|g\|_2+\epsilon}
\end{align}
$$


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

### 数据处理
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

### 模型保存和存储
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



---

## CS336：语言模型训练与推理

> 原始文件：_posts/2026/02/2026-02-12-llm_cs336_train_infer.md

### torch前置知识
#### max，sort和topk操作：返回一个元组`(values，indices)`
+ 对于数组特定维度进行求和或排序
+ **返回一个元组`(values，indices)`**
```python
sorted_probs, sorted_indices = torch.sort(probs,descending=True,dim=-1)
```
+ TOPK函数
```python
logits_topk,indices_topk = torch.topk(logits,top_k,dim=-1) 
```
---
##### mean和median：只返回数值
---
#### 前缀和函数`torch.cumsum`

```python
`cum_probs = torch.cumsum(sorted_probs,dim=-1)`
```

#### *指定下标填充指定元素`torch.scatter()`
+ 指定下标：`sorted_indices`
+ 指定元素：`indices_to_remove`
+ 维度必须一一匹配
```python
indices_to_remove_origin.scatter_(dim=-1,index=sorted_indices,src=indices_to_remove)
```
---
#### 获得指定下标的元素`torch.gather`
+ `index=targets.unsqueeze(-1)`：维度必须与目标变量`logits`匹配
```python
target_logits = torch.gather(logits,dim=-1,index=targets.unsqueeze(-1))
```
---
#### `model.train() vs model.eval()`
+ 控制模型中特定层的行为
+ 主要控制 BatchNorm、Dropout 等层的行为；LayerNorm/RMSNorm 通常不随训练/评估模式改变。
+ `model.train()` 在进入训练阶段时调用一次即可，不要求放在每轮循环内；评估和推理前调用 `model.eval()`。
---
<br><br>
<br><br>

### LM的推理流程
#### 基本流程：滑动窗口(max_win_size=max_seq_len)
+ LM的输入：$[x_1,x_2\cdots,x_n]$
+ LM的输出：$[x_2,x_3\cdots,x_{n+1}]$
+ 给定$[x_1,x_2\cdots,x_n]$，我们希望得到的是$x_{n+1}$。
+ 为此，我们调用LM模型推理，得到$[x_2,x_3\cdots,x_{n+1}]$
+ **将$x_{n+1}$拼接到$[x_1,x_2\cdots,x_n]$中去**，得到序列$[x_1,x_2\cdots,x_n,x_{n+1}]$，我们通过滑动窗口的形式再下一次输入时，截取$[x_2\cdots,x_n,x_{n+1}]$这一部分作为输入。

```python
for _ in range(max_new_tokens):
	x = generated_sequence[...,-self.max_seq_len:]
	logits = self.forward(x)
	logits = logits[:,-1,:]# [b,vocab_size]
	# 从logits中采样得到next_token
	next_token = sample_token(logits)
	generated_sequence = torch.cat([generated_sequence,next_token],dim=-1)
```

#### 从logits中采样得到`next_token`的方法
<figure><img src="/assets/img/posts/llm-pretraining-training-amp/352d8af8673e452892b983e24083f44d.png" alt="预训练与混合精度" width="700"><figcaption><p>训练损失曲线</p></figcaption></figure>

+ 常见策略
+ 贪心 vs topk vs topp
+ 温度策略兼容
##### 实现时的注意事项
+ 不需要梯度加速计算：` @torch.no_grad()`
+ 排序等操作会破坏数组下标，因此需要使用`scatter_`等操作**对原数组填充**。
---
##### 温度系数Temperature $$T$$
+ 为softmax的结果除以一个常数$T$
+ **如果$T$趋于+无穷，那么模型就会趋于均匀采样；如果$T$趋于0，模型会趋于贪心策略**
+  **温度系数兼容所有采样策略**，**$T=0$会使模型随机性降低**！

$$
\begin{align}
\mathrm{softmax}_i(\mathbf{z};T)=\frac{\exp\left(\frac{z_i}{T}\right)}{\sum_j\exp\left(\frac{z_j}{T}\right)}
\end{align}
$$


##### 贪心
+ 直接取最大概率的token
+ 但它可能会导致生成的**文本缺乏多样性和创造性**，因为它总是选择最可能的选项，容易陷入局部最优

```python
	x = generated_sequence[...,-self.max_seq_len:]
	logits = self.forward(x)
	logits = logits[:,-1,:]# [b,vocab_size]
	next_token = torch.argmax(logits,dim=-1,keepdim=True) # b 1
```
##### topk采样
>模型会选择概率最高的 K 个 token，然后从这 K 个 token 中根据它们的概率分布进行采样。这样可以增加生成文本的多样性，同时仍然保持一定的质量
+ 从所有logits中挑选前k个，然后进行采样
+ 使用topk可以得到下标和对应值，然后**使用该下标进行散播对应值就行了**。
```python
    # top-k
    @torch.no_grad()
    def _generate_topk(
        self,
        inputs_id:torch.LongTensor,
        max_new_tokens:int,# max_new_tokens!=max_seq_len
        eos_token_id:int,
        top_k :int,
        temperature:float = 1.0,
        )->str:

        self.eval()
        generated_sequence = inputs_id.clone()# [b,l]
        for _ in range(max_new_tokens):
            x = generated_sequence[...,-self.max_seq_len:]
            logits = self.forward(x)
            logits = logits[:,-1,:]# [b,vocab_size]

            # temperature sampling
            logits = logits / temperature

            # top-k
            logits_topk,indices_topk = torch.topk(logits,top_k,dim=-1) 

            # 根据下标和元素填充新logits
            filtered_logits = torch.full_like(logits, float("-inf"))# b v
            filtered_logits.scatter_(dim=-1, index=indices_topk, src=logits_topk)# b v
            filtered_probs = softmax(filtered_logits,dim=-1)
            next_token = torch.multinomial(filtered_probs,num_samples=1)

            # 自回归
            generated_sequence = torch.cat([generated_sequence,next_token],dim=-1)
            if (next_token == eos_token_id).all():
                break
        if self.tokenizer is not None:
            return self.tokenizer.decode(generated_sequence.squeeze(0).tolist())
        return generated_sequence
```

##### topp
>Top-P Sampling（也称为 Nucleus Sampling）是一种更灵活的采样方法。在每一步生成时，模型会选择累计概率达到 P 的最小 token 集合，然后从这个集合中根据它们的概率分布进行采样。这样可以动态调整候选 token 的数量，既保证了多样性，又避免了选择过于罕见的 token。
+ 和topk采样类似，不过基本思路不是选前k个。
+ 先计算概率，对**概率进行排序**，**只采样累积概率小于等于p的token**。
+ 实现细节：自己定义掩膜
```python
    @torch.no_grad()
    def _generate_topp(
        self,
        inputs_id:torch.LongTensor,
        max_new_tokens:int,# max_new_tokens!=max_seq_len
        eos_token_id:int,
        top_p :float,
        temperature:float = 1.0,
    ):
        # topp: 排序-累积概率-mask-过滤-采样
        self.eval()
        generated_sequence = inputs_id.clone()# [b,l]
        for _ in range(max_new_tokens):
            x = generated_sequence[...,-self.max_seq_len:]
            logits = self.forward(x)
            logits = logits[:,-1,:]# [b,vocab_size]
            # temperature sampling
            logits = logits / temperature
            probs = softmax(logits,dim=-1)
            # sort
            sorted_probs, sorted_indices = torch.sort(probs,descending=True,dim=-1)
            # cdf
            cum_probs = torch.cumsum(sorted_probs,dim=-1)
            
            # mask-value
            indices_to_remove = cum_probs > top_p
            indices_to_remove[...,1:] = indices_to_remove[...,:-1].clone()
            indices_to_remove[...,0] = False

            # filter 
            indices_to_remove_origin = torch.zeros_like(logits,dtype=torch.bool)
            indices_to_remove_origin.scatter_(dim=-1,index=sorted_indices,src=indices_to_remove)
            filtered_logits = logits.masked_fill(indices_to_remove_origin,float("-inf"))
            filtered_probs = softmax(filtered_logits,dim=-1)
            next_token = torch.multinomial(filtered_probs,num_samples=1)

            # 自回归
            generated_sequence = torch.cat([generated_sequence,next_token],dim=-1)
            if (next_token == eos_token_id).all():# next_token:b 1
                break

        if self.tokenizer is not None:
            return self.tokenizer.decode(generated_sequence.squeeze(0).tolist())
        return generated_sequence
```

### 训练函数
`确定动态学习率->optimizer.zero_grad(set_to_none=True)->output = model(x)->train_loss = cross_entropy_loss(output,y)->train_loss.backward()->梯度裁剪->optimizer.step()`

```python
def train(args):
    # load data, model and optimizer
    train_data = np.memmap(args.train_data_path,dtype=np.uint16,mode='r')
    valid_data = np.memmap(args.val_data_path,dtype=np.uint16,mode='r')
    model = TransformerLM(
        vocab_size = args.vocab_size,
        n_layers = args.num_layers,
        d_model = args.d_model,
        num_heads = args.num_heads,
        d_ff = args.d_ff,
        bigo = args.bigo,
        max_seq_len=args.max_seq_len,
        is_norm = args.is_norm,# ablation parameters
        norm_type = args.norm_type,
        pre_norm = args.pre_norm,
        is_gate = args.is_gate,
        eps = args.eps,
        device = args.device,
        dtype = torch.float32,
        tokenizer = tokenizer,
    ).to(args.device)
    optimizer = AdamW(model.parameters(),lr=args.max_lr)
    for it in range(start_iter,args.max_iters):
        model.train()
        # dynamic learning rate 
        lr = get_lr_cosine_schedule_with_warmup(it,args.max_lr,args.min_lr,args.warmup_iters,args.cosine_schedule_iters)
        for group in optimizer.param_groups:
            group['lr'] = lr
        x, y = get_batch(train_data,args.batch_size,args.max_seq_len,args.device)
        optimizer.zero_grad(set_to_none=True)
        output = model(x)
        train_loss = cross_entropy_loss(output,y)
        train_loss.backward()
        with torch.no_grad():# 不需要梯度,加速处理
            train_ppl = ppl(output,y)
        # gradient clipping
        clip_grad_norm(model.parameters(),args.max_norm,args.eps)
        optimizer.step()
        if it % args.eval_interval == 0 or it == args.max_iters - 1:
            model.eval()
            with torch.no_grad():
                x_val, y_val = get_batch(valid_data,args.batch_size,args.max_seq_len,args.device)
                output_val = model(x_val)
                # 评估指标
                val_loss = cross_entropy_loss(output_val,y_val)
                val_ppl = ppl(output_val,y_val)
```


### 参考文献
[参考1](https://yyzhang2025.github.io/posts/LearningNotes/CS336/Assignments/Ass01/ass01.html#temperature)


---

## CS336：模型实验与推理实验

> 原始文件：_posts/2026/02/2026-02-13-llm_cs336_exp_infer.md

### 模型架构实验
+ 包括现代LM的一些设计细节
+ 是否norm，是否pre-norm，是否使用RMSNorm，是否使用门控FFN
#### 脚本

```python
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=========================================="
echo "Starting all ablation and baseline experiments"
echo "Scripts directory: ${SCRIPT_DIR}"
echo "=========================================="

EXPERIMENT_SCRIPTS=(
    "baseline.sh"
    "norm.sh"
    "layer_norm.sh"
    "post_norm.sh"
    "gated_ffn.sh"
    "rope.sh"
)

for SCRIPT in "${EXPERIMENT_SCRIPTS[@]}"; do
    SCRIPT_PATH="${SCRIPT_DIR}/${SCRIPT}"

    if [ ! -f "${SCRIPT_PATH}" ]; then
        echo "ERROR: Script not found: ${SCRIPT_PATH}"
        exit 1
    fi

    echo ""
    echo "------------------------------------------"
    echo "Running experiment: ${SCRIPT}"
    echo "------------------------------------------"

    bash "${SCRIPT_PATH}"

    echo "Finished experiment: ${SCRIPT}"
done

echo ""
echo "=========================================="
echo "All experiments completed successfully 🎉"
echo "=========================================="

```
#### 实验结果
+ 代码有一些bug，仅供娱乐

<figure><img src="/assets/img/posts/llm-pretraining-training-amp/05fdf1bd128b417486e5351e1abf222a.png" alt="预训练与混合精度" width="700"><figcaption><p>生成结果对比</p></figcaption></figure>

### 学习率实验
#### 脚本
```python
#!/bin/bash
set -e

# ===================== tokenizer =====================
VOCAB_PATH="data/TinyStoriesV2-GPT4-train/vocab.json"
MERGES_PATH="data/TinyStoriesV2-GPT4-train/merges.txt"
SPECIAL_TOKENS="<|endoftext|>"
EOS_TOKEN="<|endoftext|>"

# ===================== data =====================
TRAIN_DATA_PATH="data/TinyStoriesV2-GPT4-train.bin"
VAL_DATA_PATH="data/TinyStoriesV2-GPT4-valid.bin"

# ===================== model =====================
VOCAB_SIZE=10000
MAX_SEQ_LEN=256
D_MODEL=512
D_FF=1344
BIGO=10000
NUM_LAYERS=4
NUM_HEADS=16
EPS=1e-5

# ===================== training =====================
BATCH_SIZE=64
MIN_LR=6e-5
WARMUP_ITERS=1000
COSINE_SCHEDULE_ITERS=9500
MAX_ITERS=10000
MAX_NORM=1.0

# ===================== eval / checkpoint =====================
EVAL_INTERVAL=100
SAVE_INTERVAL=1000
OUT_DIR="checkpoints"
CHECKPOINT_PATH=""

# ===================== system =====================
DEVICE="cuda"

# ===================== logging =====================
RUN_NAME_PREFIX="lr"

MAX_LRS=(1e-4 3e-4 6e-4 1e-3)

# ===================== run =====================
for LR in "${MAX_LRS[@]}"; do
    echo "Running training with max_lr=${LR}"

    uv run cs336_basics/train.py \
        --vocab_path "${VOCAB_PATH}" \
        --merges_path "${MERGES_PATH}" \
        --special_tokens "${SPECIAL_TOKENS}" \
        --eos_token "${EOS_TOKEN}" \
        \
        --train_data_path "${TRAIN_DATA_PATH}" \
        --val_data_path "${VAL_DATA_PATH}" \
        \
        --vocab_size "${VOCAB_SIZE}" \
        --max_seq_len "${MAX_SEQ_LEN}" \
        --d_model "${D_MODEL}" \
        --d_ff "${D_FF}" \
        --bigo "${BIGO}" \
        --num_layers "${NUM_LAYERS}" \
        --num_heads "${NUM_HEADS}" \
        --eps "${EPS}" \
        \
        --batch_size "${BATCH_SIZE}" \
        --max_lr "${LR}" \
        --min_lr "${MIN_LR}" \
        --warmup_iters "${WARMUP_ITERS}" \
        --cosine_schedule_iters "${COSINE_SCHEDULE_ITERS}" \
        --max_iters "${MAX_ITERS}" \
        --max_norm "${MAX_NORM}" \
        \
        --eval_interval "${EVAL_INTERVAL}" \
        --save_interval "${SAVE_INTERVAL}" \
        --out_dir "${OUT_DIR}" \
        --checkpoint_path "${CHECKPOINT_PATH}" \
        \
        --device "${DEVICE}" \
        --run_name "${RUN_NAME_PREFIX}_${LR}"

    echo "Finished run with max_lr=${LR}"
    echo "-----------------------------------"
done

```
#### 结果
+ 6e-3是当前实验条件下最优的最大学习率。
<figure><img src="/assets/img/posts/llm-pretraining-training-amp/99d79e946110406682137ebe82f50a08.png" alt="预训练与混合精度" width="700"><figcaption><p>学习率实验结果</p></figcaption></figure>
---
<br><br><br><br>
### 推理
#### 不同方式的推理结果
+ 提示词：`Once upon a time`
+ ### 贪心解码
>Once upon a time, there was a little girl named Lily. She loved to play with her toys and eat yummy food. One day, she found a big, red apple in her kitchen. She was very happy and wanted to eat it all. Lily's mom saw her and said, "Lily, you can have the apple if you promise to share it with your brother, Tim." Lily thought about it and said, "I promise, Mom." She took the apple and went to Tim's house. When Lily got to Tim's house, she said, "Tim, I have a surprise for you!" Tim was excited and said, "What is it, Lily?" Lily showed him the apple and said, "I promise to share it with you." Tim was very happy and they both ate the apple together. <|endoftext|>
>从前有一个小女孩叫莉莉。她喜欢玩玩具，也喜欢吃美味的食物。一天，她在厨房里发现了一个又大又红的苹果。她非常开心，想把它全部吃掉。莉莉的妈妈看见了她，说：“莉莉，如果你答应和你的弟弟蒂姆分享这个苹果，你就可以吃它。”莉莉想了想，说：“我答应，妈妈。”她拿着苹果去了蒂姆的家。到了那里，她说：“蒂姆，我给你带来了一个惊喜！”蒂姆兴奋地问：“是什么，莉莉？”莉莉把苹果给他看，说：“我答应和你一起分享。”蒂姆非常高兴，他们一起把苹果吃掉了。<|endoftext|>
+ ### TOPK(K=50,T=1)解码
>Once upon a time, there was a boy named Tim and his dog. They loved to play in the yard. One day, while they were playing, Tim got a letter down. The letter said, "Be careful and do not go near the big drain." Tim and his dog did not listen. They wanted to see what was in the big drain. They jumped over it and ran away. Suddenly, they had to hide behind a tree. Just as Tim was about to catch the big drain, a little bird came out of the tree. The bird said, "Hello, I saw you and wanted to play too!" Tim was surprised, but he was happy to have a new friend to play with. They all played together and had lots of fun. The moral of the story is to always listen to your friends and be kind to everyone. <|endoftext|> 
>从前有一个男孩叫蒂姆，他有一只小狗。他们喜欢在院子里玩耍。一天，当他们在玩的时候，蒂姆收到了一封信。信上写着：“要小心，不要靠近那个大排水沟。”蒂姆和他的小狗没有听从劝告。他们想看看大排水沟里有什么。他们跳了过去，又跑开了。突然，他们不得不躲在一棵树后面。就在蒂姆快要靠近大排水沟的时候，一只小鸟从树上飞了出来。小鸟说：“你好，我看到你们，也想一起玩！”蒂姆很惊讶，但他很高兴能有一个新朋友一起玩。他们一起玩得很开心。这个故事的寓意是：要听从朋友的劝告，并善待每一个人。<|endoftext|>
+ ### TOPP(P=0.8,T=1)解码
>Once upon a time, there was a small house with a chimney. The chimney was very old and old. It was very old and sad because it was always dirty. The house was sad because it could not be clean and pretty like the chimney. One day, a little girl named Mia came to the house. She saw the sad house and wanted to help. Mia had an idea to make the house look new and pretty. She picked up the house and put it in a vase. She was very happy with her work. The next day, Mia saw that the house was very clean and pretty. She decided to wash it. She scrubbed and scrubbed until the house was clean and shiny. The house looked very pretty, and Mia was happy too. Now, the house was clean and shiny. The house was happy too, because it could finally be clean and shiny. <|endoftext|>
> 从前有一座带烟囱的小房子。烟囱非常非常旧，也很破旧。它总是脏兮兮的，因此显得很伤心。小房子也很难过，因为它不能像烟囱那样干净漂亮。一天，一个叫米娅的小女孩来到这座房子前。她看到这座伤心的房子，想要帮助它。米娅想出了一个让房子变得焕然一新的主意。她把房子拿起来，放进一个花瓶里。她对自己的成果感到很开心。第二天，米娅看到房子变得非常干净漂亮。她决定再给它清洗一遍。她不停地刷啊刷，直到房子变得干净又闪亮。房子看起来非常漂亮，米娅也很开心。现在，房子终于干净又闪亮了。房子也很开心，因为它终于可以变得干净又闪亮。<|endoftext|>
#### 推理代码

```python
import torch
import torch.nn as nn
from cs336_basics.transformer_block import TransformerBlock,TransformerLM
from cs336_basics.optimizer import AdamW
from cs336_basics.checkpoint import load_checkpoint
from cs336_basics.tokenizer import BPETokenizer
from cs336_basics.preprocess import bytes_to_unicode,load_trained_tokenizer

# load tokenizer
vocab_path = 'data/TinyStoriesV2-GPT4-train/vocab.json'
merges_path = 'data/TinyStoriesV2-GPT4-train/merges.txt'
special_tokens = ['<|endoftext|>']
tokenizer = load_trained_tokenizer(
    vocab_path = vocab_path,
    merges_path= merges_path,
    special_tokens = special_tokens
)

eos_token_id = tokenizer.encode(special_tokens[0])[0]


# load_model
device = 'cuda' if torch.cuda.is_available() else 'cpu'
checkpoint_path = 'cs336_basics/checkpoints/checkpoint_9999.pt'
model = TransformerLM(
    vocab_size=10000,
    n_layers=4,
    d_model=512,
    d_ff=1344,
    num_heads=16,
    bigo=10000,
    max_seq_len=256,
    is_norm=True,
    norm_type='RMSNorm',
    pre_norm=True,
    is_gate=True,
    eps=1e-5,
    device = device,
    dtype = torch.float32,
    tokenizer=tokenizer
)
optimizer = AdamW(model.parameters(), lr=1e-4, weight_decay=0.01)
iteration = load_checkpoint(model,optimizer,checkpoint_path,device)
print('load model successfully from checkpoint: {}, iteration: {}, device: {}'.format(checkpoint_path, iteration,device))

prompt = "Once upon a time"
input_ids = tokenizer.encode(prompt)
# print('input_ids: ', input_ids)

def greedy_text():
    generate_text = model.generate(
        inputs_id=input_ids,
        max_new_tokens=256,
        eos_token_id=eos_token_id,
        temperature=1.0,
        greedy=True,
    )
    return generate_text
def topk_text():
    generate_text = model.generate(
        inputs_id=input_ids,
        max_new_tokens=256,
        eos_token_id=eos_token_id,
        temperature=1.0,
        greedy=False,
        top_k=50
    )
    return generate_text
def topp_text():
    generate_text = model.generate(
        inputs_id=input_ids,
        max_new_tokens=256,
        eos_token_id=eos_token_id,
        temperature=1.0,
        greedy=False,
        top_p=0.8
    )
    return generate_text
greed_generated_text = greedy_text()
topk_generated_text = topk_text()
topp_generated_text = topp_text()

print(f'Greedy Generated Text:\n ', greed_generated_text)
print(f'Top-k Generated Text:\n ', topk_generated_text)
print(f'Top-p Generated Text:\n ', topp_generated_text)

```



---

## AMP 自动混合精度训练

> 原始文件：`_posts/2026/03/2026-03-24-llm_amp.md`

> **整合修订说明**
>
> 原笔记完整保留了数值范围、显存与 loss scaling 的推导。需要补充的是：PyTorch 原生 AMP 通常保留 FP32 参数，由 `autocast` 按算子选择执行精度，并不要求用户显式维护一份 FP16 runtime weights。FP32 参数的梯度通常也是 FP32。FP16 的最小正规数约为 `6.10e-5`，最小次正规数约为 `5.96e-8`。使用梯度裁剪时必须先 `scaler.unscale_(optimizer)`；BF16 通常不需要 GradScaler。

### 完整AMP训练流程

```cpp
======================
[初始化阶段]
======================

Model Weights:
    FP32 master weights（优化器维护，真实参数）

Runtime Weights:
    FP16 weights（由FP32 cast得到，用于forward/backward）


======================
[Forward（autocast开启）]
======================

Input: FP32
↓（进入 autocast）

[算子1：matmul / conv]
→ cast 为 FP16（利用Tensor Core加速）
→ 输出：FP16

[算子2：exp / softmax / layernorm 等数值敏感操作]
→ 自动提升为 FP32（防止数值不稳定，如overflow/精度损失）
→ 输出：FP32

[算子3：继续 matmul]
→ cast 回 FP16
→ 输出：FP16

...

最终 loss：
→ 通常为 FP32（loss / reduction类操作一般在FP32）


======================
[Loss Scaling]
======================

loss (FP32)
↓ × scale（如1024）
scaled loss (FP32)

# 目的：放大梯度，避免FP16下溢（变0）


======================
[Backward]
======================

scaled loss (FP32)
↓ backward（自动根据forward路径传播）

梯度传播过程：

- 来自 FP16 forward 分支：
    → 梯度通常以 FP16 表示（易受下溢影响）

- 来自 FP32 forward 分支：
    → 梯度计算中涉及 FP32（更稳定）

最终得到：
gradients（大多数存储为 FP16，部分计算路径为 FP32）


======================
[Unscale + 类型转换]
======================

FP16 gradients
↓ cast
FP32 gradients

↓ ÷ scale（unscale，恢复真实梯度）

得到：
真实梯度（FP32）


======================
[参数更新（Optimizer Step）]
======================

FP32 gradients
↓
更新 FP32 master weights（高精度累积更新）

# 关键原因：
# FP16无法表示微小更新，会导致训练停滞


======================
[同步回计算图]
======================

更新后的 FP32 master weights
↓ cast
FP16 weights（供下一轮 forward 使用）


======================
[整体数据流总结]
======================

FP32 master weights
↓ cast
FP16 weights
↓
forward（FP16为主 + FP32关键算子）
↓
loss（FP32）
↓ scale
scaled loss（FP32）
↓ backward
grad（FP16为主）
↓ cast + unscale
grad（FP32）
↓
update master weights（FP32）
↓
再 cast → FP16（进入下一轮）


======================
[核心要点]
======================

1. FP16用于“计算加速”（forward/backward主路径）
2. FP32用于“数值稳定”（loss / softmax / norm等）
3. FP32用于“参数更新”（避免精度丢失）
4. loss scaling 仅用于解决 FP16 梯度下溢问题
```

### 混合精度训练的优势
#### 节省显存占用：激活值是大头
+ **激活值是关键大头，而且与batch_size和序列长度有关**，因此应该考虑节省这些中间值的梯度占用！

FP32：
```cpp
参数:      1 GB
activation: 6 GB
gradient:   3 GB
----------------
总计:     10 GB
```
AMP：
```cpp
参数:
  FP32 master: 1 GB
  FP16 copy:   0.5 GB

activation:   3 GB（减半）
gradient:     1.5 GB（减半）
----------------
总计:        6 GB
```

#### 加快推理速度：低精度加速
+ NVIDIA的显卡**对于低精度BF16/FP16有专门加速**

| 精度   | 吞吐量   |
| ---- | ----- |
| FP32 | 1×    |
| FP16 | 2×～8× |


### 低精度(bf16,fp16)的问题
#### 溢出问题
混合精度训练（Mixed Precision Training）的核心是：
用 **FP16（或BF16）进行大部分计算**，用 **FP32保留关键数值稳定性**。
但由于 FP16 的表示范围和精度有限，会引入一系列典型问题。下面用**具体例子**说明这些问题。


##### FP16 的数值限制

FP16（IEEE half precision）：

* 指数位：5 bit → **范围小**
* 尾数：10 bit → **精度低**

大致范围：

* 最大值：≈ (6.5 \times 10^4)
* 最小正数（正规）：≈ (6 \times 10^{-8})


##### 梯度下溢（underflow）


假设某层梯度为：

$$
\begin{align}
g = 1 \times 10^{-8}
\end{align}
$$

* FP32：可以表示 ✔️
* FP16：**直接变成 0 ❌**


##### 梯度上溢（overflow）

$$
\begin{align}
g = 1 \times 10^5
\end{align}
$$

* FP16最大值 ≈ 65504
* 超出范围 → **变成 inf**


---

#### 大数吃小数问题
+ 浮点数加减法需要**先对齐指数**，再比对小数部分，但是小数部分往往有限
+ **数值差距悬殊时，容易出现小数部分溢出**。

$$
\begin{align}
2048 = 1.0 \times 2^{11}
\end{align}
$$

$$
\begin{align}
0.5 = 1.0 \times 2^{-1}
\end{align}
$$


对齐指数：

$$
\begin{align}
0.5 = 1.0 \times 2^{-1} = 0.000000000001 \times 2^{11}
\end{align}
$$

**但BF16 只有 7 位尾数：**

```text
2048: 1.0000000 × 2^11
0.5 : 0.000000000001 × 2^11  （被截断）
```
结果

$$
\begin{align}
2048 + 0.5 \approx 2048
\end{align}
$$

 **0.5 被完全忽略**


---
### 混合精度训练的流程
+ 在涉及前向过程中，可以使用**低精度**。
+ 在涉及梯度更新过程中，优化器会保存**较高精度的模型参数**和并使用**较高精度的梯度值**。

<figure><img src="/assets/img/posts/llm-pretraining-training-amp/2026-03-24-llm_amp-01.png" alt="预训练与混合精度" width="700"><figcaption><p>AMP 数据流</p></figcaption></figure>
+ 对于高精度的数学计算操作：**例如矩阵加法，softmax操作，强制使用高精度。**


#### Loss scaling
+ 动机：**低精度的高数值部分使用较少**，可以考虑**将梯度更新缩放N倍，确保不会溢出，然后转换位低精度来进行更新**。

<figure><img src="/assets/img/posts/llm-pretraining-training-amp/2026-03-24-llm_amp-02.png" alt="预训练与混合精度" width="620"><figcaption><p>Loss Scaling 原理</p></figcaption></figure>
Loss scaling 的本质是在反向传播前对 **loss 进行数值放大**，使得在 **FP16 精度下计算的梯度不会发生下溢**；在得到梯度后再进行反缩放（unscale），恢复真实梯度，并在 FP32 master weight 上进行更新，从而保证数值稳定性和更新精度。

<figure><img src="/assets/img/posts/llm-pretraining-training-amp/2026-03-24-llm_amp-03.png" alt="预训练与混合精度" width="700"><figcaption><p>梯度反缩放流程</p></figcaption></figure>
### 实现
+ `with torch.cuda.amp.autocast(device_type="cuda", dtype=torch.float16)`：模型会**在这个上下文下，优先选择FP16精度**，**对于需要高精度的操作例如softmax，计算过程仍然使用FP32，不受影响**。
+ `scaler.scale(loss).backward() `：缩放损失，确保FP16的梯度不会溢出。
```cpp
# PyTorch AMP（FP16）训练片段

scaler = torch.cuda.amp.GradScaler()

for x, y in dataloader:
    optimizer.zero_grad()

    with torch.cuda.amp.autocast(device_type="cuda", dtype=torch.float16):
        out = model(x)
        loss = criterion(out, y)

    scaler.scale(loss).backward()   # scaled loss 反传
    scaler.step(optimizer)          # 内部完成 unscale + update（FP32 master）
    scaler.update()                 # 动态调整 scale
```

---

