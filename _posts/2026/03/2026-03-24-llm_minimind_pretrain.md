---
title: "LLM·minimind-预训练"
author: MayL
date: 2026-03-24
categories: ["大语言模型与强化学习", "大语言模型"]
tags: ["llm", "人工智能", "学习笔记"]
render_with_liquid: false
description: "本文围绕“LLM·minimind-预训练”梳理核心概念、算法思路与实践要点，便于系统学习和后续查阅。"
---

@[toc]
>**所有的代码都基于`transformers`库。**
# 预训练
## 初始化模型和分词器
### 初始化配置文件 AutoConfig
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

### 从配置文件初始化 AutoModel
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

### 加载 AutoTokenizer
```cpp
from transformers import AutoTokenizer
tokenizer = AutoTokenizer.from_pretrained(model_path)
tokenizer
```


## 预训练数据集
+ 数据集格式：**必须是token化的序列**
+ **最大长度必须一致**。
+ 构造出labels，**该labels与input_ids一致，模型会处理移位**。

### 加载数据集
[参考文献](https://blog.csdn.net/orangerfun/article/details/131927248)
+ `path`：表示**数据集的名称**`monkey-gen`，如果只有当前参数则会自动下载到缓存；**数据集的格式**，例如`json，csv`等
+ `data_dir`：数据集所在的本地目录
+ `data_file`：数据集本身，例如`xxx.jsonl`.

```cpp
dataset = load_dataset("csv", data_files="./ChnSentiCorp_htl_all.csv", split="train")
dataset = load_dataset("json", data_files="./cmrc2018_trial.json", field="data")
```

### DataDict
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
### Dataset
+ **数组和字典的混合体**。
+ **可以理解为`List[Dict]`或者`Dict[List]`的形式**，支持下标索引和键值对索引。


```cpp
Dataset({
    features: ['input_ids', 'attention_mask', 'labels'],
    num_rows: 1370
})
```


### 数据预处理
+ 我们期望的预训练格式如下：首先是将原始文本`str`转换为`input_ids:List[int]`

#### 数据预先处理函数
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
+ 返回参数：`batched=True`时返回类型为`Dict[str,List[Any]]`
+ 注意**tokenizer处理batch时会返回字典**`Dict[str,List[Any]]`。
```cpp
{
    "input_ids":      [[..., ...], [..., ...], [..., ...]],
    "attention_mask": [[..., ...], [..., ...], [..., ...]],
    # 其他字段（如 token_type_ids 等）
}
```

#### 1.数据集编码为tokens


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

#### 2.数据集分块，获得特定长度的`input_ids`和`labels`

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


## 训练器
+ 训练器包括**优化器**，**模型本身**，分词器等等，数据集**加粗样式**。
### TrainingArguments
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

### Trainer
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


