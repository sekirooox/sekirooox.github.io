---
title: "LLM·transformers库"
author: MayL
date: 2025-11-18
categories: ["大语言模型与强化学习", "大语言模型"]
tags: ["transformer", "llm", "人工智能", "学习笔记"]
render_with_liquid: false
description: "本文围绕“LLM·transformers库”梳理核心概念、算法思路与实践要点，便于系统学习和后续查阅。"
---

@[toc]
# HuggingFace Transformers

> 本文档整合 Pipeline、Tokenizer、Model、Dataset、Evaluate、Training 六大模块，涵盖从模型加载到训练上线的完整流程。



## 1. Pipeline 流水线

Pipeline 是集**前处理、模型推理、后处理**于一体的流水线。给定原始输入，自动输出最终结果（如情感标签），**无需手动处理 logits**。

### 1.1 整体流程

```
原始输入 → tokenizer → token化结果 → model → 推理结果 → 后处理 → 预期结果
```

- `tokenizer`：将原始输入转为 token 形式（id + mask）
- `model`：将 token 结果转换为推理结果
- 推理结果一般需要**后处理**（如 softmax + argmax）
- `pipeline`：直接给出最终结果，封装以上全部步骤。

> **笔记**：不需要记忆官网用法，只需要会查就行。

### 1.2 直接加载 Pipeline

```python
from transformers import pipeline

local_path = 'model/models--uer--roberta-base-finetuned-dianping-chinese'
pipe = pipeline("text-classification", model=local_path, device=0)

pipe("很好玩")
# [{'label': 'positive (stars 4 and 5)', 'score': 0.9271}]
```

> 注意：`local_path` 是权重文件的**目录路径**，`device=0` 表示使用 GPU。

### 1.3 组装 Pipeline

分别加载模型和分词器，可更灵活地控制组件：

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline

model = AutoModelForSequenceClassification.from_pretrained(local_path)
tokenizer = AutoTokenizer.from_pretrained(local_path)
pipe = pipeline("text-classification", model=model, tokenizer=tokenizer)
```

### 1.4 手动推理（不经过 Pipeline）

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer
import torch

tokenizer = AutoTokenizer.from_pretrained(local_path)
model = AutoModelForSequenceClassification.from_pretrained(local_path)
model.eval()

input_text = "我觉得不太行！"
inputs = tokenizer(input_text, return_tensors="pt")

with torch.no_grad():
    res = model(**inputs)

logits = torch.softmax(res.logits, dim=-1)
pred = torch.argmax(logits).item()
print(pred)
```

---

## 2. Tokenizer 分词器

Tokenizer 负责将原始文本转为模型可处理的 token id，并处理填充、截断等中间过程。

### 2.1 分词与 ID 互转

```python
sen = "弱小的我也有大梦想!"
tokens = tokenizer.tokenize(sen)                        # 分词
str_sen = tokenizer.convert_tokens_to_string(tokens)    # 还原

ids = tokenizer.convert_tokens_to_ids(tokens)           # token → id
tokens_back = tokenizer.convert_ids_to_tokens(ids)       # id → token
```

### 2.2 encode 与 decode

| 方法 | 作用 | 特殊 token |
|------|------|-----------|
| `encode()` | 分词 + 转 id | 默认添加（`add_special_tokens=True`） |
| `decode()` | id → 原始句子 | 默认保留（`skip_special_tokens=False`） |

> **笔记**：`add_special_tokens=True` 默认开启；开启 `max_length` 后**默认截断**，默认不填充。

```python
# 编码（带截断和填充）
ids = tokenizer.encode(sen, max_length=20, truncation=True, padding="max_length")
# [101, 2483, 2207, 4638, 2769, 738, 3300, 1920, 3457, 2682, 106, 102, 0, 0, 0, 0, 0, 0, 0, 0]

# 解码
str_sen = tokenizer.decode(ids, skip_special_tokens=False)
# '[CLS] 弱 小 的 我 也 有 大 梦 想! [SEP]'
```

### 2.3 encode_plus（含掩码）

在 `encode` 基础上额外返回 `token_type_ids`（用于区分 BERT 中的两个句子）和 `attention_mask`（标识填充位置）：

```python
inputs = tokenizer.encode_plus(sen, padding="max_length", max_length=20)
# {'input_ids': [...],
#  'token_type_ids': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#  'attention_mask':  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0]}
```

### 2.4 直接调用 Tokenizer（最常用）

`tokenizer(text)` 是最常用的快捷方式，效果等价于 `encode_plus`，返回 dict：

```python
inputs = tokenizer(sen, padding="max_length", max_length=15, return_tensors='pt')
# {'input_ids': tensor([[...]]), 'token_type_ids': tensor([[...]]), 'attention_mask': tensor([[...]])}
```

> **`return_tensors='pt'` 必须指定**，否则返回 Python 列表而非 tensor。

### 2.5 填充与截断规则

- 优先填充至 `max_length`
- 如果文本本身就超过 `max_length`，**优先截断**
- 允许同时指定 `padding` 和 `truncation`
- 解码时可用 `skip_special_tokens=True` 忽略特殊 token

---

## 3. Model 模型

### 3.1 AutoConfig

`AutoConfig` 定义了模型的基本结构参数（如隐藏层大小、注意力头数等），等价于 `model.config`：

```python
from transformers import AutoConfig

config = AutoConfig.from_pretrained(local_path)
print(config.hidden_size)      # 768
print(config.num_labels)       # 可修改：config.num_labels = 10
```

> 里面涉及的参数不一定全，可通过 `config.num_labels` 等方式动态修改。

### 3.2 AutoModel（骨干网络）

`AutoModel` 仅包含**骨干网络**，输出隐藏状态，不带任务头：

> **笔记**：`AutoModel` 只是骨干，`AutoModelForSequenceClassification` = 骨干 + 输出头，输出概率用 `output.logits`。

```python
from transformers import AutoModel

model = AutoModel.from_pretrained(local_path)
output = model(**inputs)
print(output.last_hidden_state.size())  # torch.Size([1, 12, 768])
```

### 3.3 AutoModelForSequenceClassification（带分类头）

包含骨干 + 分类头，输出已经过分类层的结果。取概率用 `output.logits`：

```python
from transformers import AutoModelForSequenceClassification

clz_model = AutoModelForSequenceClassification.from_pretrained(local_path, num_labels=10)
output = clz_model(**inputs)
# SequenceClassifierOutput(loss=None, logits=tensor([[...]]), ...)
print(output.logits)
```

---

## 4. Dataset 数据集

### 4.1 加载数据集

```python
from datasets import load_dataset

local_path = '../dataset/datasets--madao33--new-title-chinese'
datasets = load_dataset(local_path)

> **笔记**：`load_dataset` 返回类型为 `DatasetDict`，当成字典 + 列表来用。

# DatasetDict({
#     train: Dataset({features: ['title', 'content'], num_rows: 5850})
#     validation: Dataset({features: ['title', 'content'], num_rows: 1679})
# })
```

**加载时直接划分：**

```python
dataset = load_dataset(local_path, split="train[20:100]")        # 切片
dataset = load_dataset(local_path, split=["train[:50%]", "train[50%:]"]])  # 对半划分
```

**加载 CSV/JSON：**

```python
dataset = load_dataset("csv", data_files="./ChnSentiCorp_htl_all.csv", split="train")
dataset = load_dataset("json", data_files="./cmrc2018_trial.json", field="data")
```

### 4.2 查看数据集

| 操作 | 代码 |
|------|------|
| 按 key 查列 | `datasets["train"]["title"][:2]` |
| 按索引切片 | `datasets["train"][:2]` |
| 列名列表 | `datasets["train"].column_names` |
| 特征类型 | `datasets["train"].features` |
| 数据类型 | `datasets["train"].features['title']` → `Value(dtype='string')` |

### 4.3 数据划分

```python
dataset = datasets["train"].train_test_split(test_size=0.2)
```

### 4.4 选择与过滤

```python
# 按索引选择（返回新 Dataset）
datasets["train"].select([0, 1, 25])

# 过滤（lambda 返回 bool）
filter_dataset = datasets["train"].filter(lambda example: "中国" in example["title"])

> **笔记**：`filter` 填 bool 表达式，每个 example 作为完整字典传入；`map` 即 `iter_row()` 的实现方式，遍历每一行并可修改字段。
```

### 4.5 数据映射（Tokenizer 预处理）

定义处理函数，对每一行（字典）进行分词，生成可直接用于训练的 tensor：

```python
from transformers import AutoTokenizer

tokenizer = AutoTokenizer.from_pretrained("bert-base-chinese")

def preprocess_function(example):
    model_inputs = tokenizer(example["content"], max_length=512, truncation=True)
    labels = tokenizer(example["title"], max_length=32, truncation=True)
    model_inputs["labels"] = labels["input_ids"]
    return model_inputs

processed_datasets = datasets.map(preprocess_function, batched=True, remove_columns=datasets["train"].column_names)
# DatasetDict({
#     train: Dataset({features: ['input_ids','token_type_ids','attention_mask','labels'], num_rows: 5850})
# })
```

> 使用 `batched=True` 可批量处理加速，但需确保 batch 内序列长度一致（或配合下文的 Collator 使用）。

### 4.6 数据规整（动态填充 Batch）

`DataCollatorWithPadding` 自动将同 batch 内的不同长度序列填充至最长：

```python
from transformers import DataCollatorWithPadding
from torch.utils.data import DataLoader

collator = DataCollatorWithPadding(tokenizer=tokenizer)
dl = DataLoader(tokenized_dataset, batch_size=4, collate_fn=collator, shuffle=True)

for batch in dl:
    print(batch["input_ids"].size())  # torch.Size([4, 动态最长长度])
```

> Collator **只能对 tokenizer 输出字段**（`input_ids`、`token_type_ids`、`attention_mask`、`labels`）进行填充，遇到其他字段会报错。

---

## 5. Evaluate 评估指标

> **笔记**：evaluate 默认从官网加载，记得本地 clone 后改用本地路径。
> 解决方法：`git clone https://github.com/huggingface/evaluate.git` 到本地目录，改用本地路径加载。

```python
import evaluate

accuracy = evaluate.load("../metrics/accuracy")
print(accuracy)  # 打印使用方法
```

### 5.1 基础用法

```python
results = accuracy.compute(references=[0, 1, 2, 0, 1, 2], predictions=[0, 1, 1, 2, 1, 0])
# {'accuracy': 0.5}
```

### 5.2 训练时批量计算

```python
accuracy = evaluate.load("../metrics/accuracy")
for refs, preds in zip([[0, 1], [0, 1]], [[1, 0], [0, 1]]):
    accuracy.add_batch(references=refs, predictions=preds)
accuracy.compute()
```

### 5.3 组合多个指标

```python
clf_metrics = evaluate.combine([
    "../metrics/accuracy",
    "../metrics/f1",
    "../metrics/recall",
    "../metrics/precision"
])
clf_metrics.compute(references=[0,1,1,0], predictions=[0,1,0,0])
# {'accuracy': 0.5, 'f1': 0.5, 'recall': 0.5, 'precision': 0.5}
```

> 组合指标时需注意各指标间的兼容性。

---

## 6. Training 训练

HuggingFace 的 `Trainer` 封装了 DataLoader + 训练循环，不需要再加载 `DataLoader`，不需要再写训练代码，直接调用接口即可。

> **笔记**：Trainer 包含了 DataLoader 和训练的一整套训练框架，不需要再加载 DataLoader，也不需要再写训练代码，直接调用接口！

### 6.1 TrainingArguments 配置

```python
from transformers import TrainingArguments

train_args = TrainingArguments(
    output_dir="./checkpoints",              # 输出文件夹
    per_device_train_batch_size=64,         # 训练 batch size
    per_device_eval_batch_size=128,          # 验证 batch size
    logging_steps=10,                        # 日志打印频率
    evaluation_strategy="epoch",             # 评估策略（epoch/step）
    save_strategy="epoch",                   # 保存策略
    save_total_limit=2,                      # 最多保存几个 checkpoint
    learning_rate=2e-5,                      # 学习率
    weight_decay=0.01,                       # 权重衰减
    metric_for_best_model="f1",             # 最优模型评估指标
    load_best_model_at_end=True,             # 训练结束后加载最优模型
)
```

### 6.2 评估函数

```python
def eval_metric(eval_predict):
    predictions, labels = eval_predict
    predictions = predictions.argmax(axis=-1)
    acc = acc_metric.compute(predictions=predictions, references=labels)
    f1 = f1_metric.compute(predictions=predictions, references=labels)
    acc.update(f1)
    return acc
```

### 6.3 Trainer 初始化与使用

```python
from transformers import Trainer, DataCollatorWithPadding

trainer = Trainer(
    model=model,
    args=train_args,
    train_dataset=tokenized_datasets["train"],
    eval_dataset=tokenized_datasets["test"],
    data_collator=DataCollatorWithPadding(tokenizer=tokenizer),
    compute_metrics=eval_metric,
)

trainer.train()       # 训练
trainer.evaluate()    # 评估
trainer.predict()     # 预测
```

> `Trainer` 直接接收处理好的 Dataset，**不需要额外封装 DataLoader**。

---

## 7. 模型下载与本地加载

### 7.1 加速下载（推荐）

使用 [LetheSec/HuggingFace-Download-Accelerator](https://github.com/LetheSec/HuggingFace-Download-Accelerator)：

```bash
python hf_download.py --model uer/roberta-base-finetuned-dianping-chinese --save_dir ./model
```

### 7.2 直接下载（默认路径）

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline

model = AutoModelForSequenceClassification.from_pretrained('uer/roberta-base-finetuned-chinanews-chinese')
tokenizer = AutoTokenizer.from_pretrained('uer/roberta-base-finetuned-chinanews-chinese')
text_classification = pipeline('sentiment-analysis', model=model, tokenizer=tokenizer)
text_classification("北京上个月召开了两会")
```

默认缓存路径：`~/.cache/huggingface/hub`

---

## 附录：常见问题速查

| 问题 | 解决 |
|------|------|
| `return_tensors='pt'` 返回列表而非 tensor | 加上这个参数 |
| tokenizer 输出有 padding id 参与计算 | 使用 `attention_mask` 屏蔽，或改用 Collator 动态填充 |
| 数据集分词后报错 shape 不一致 | 使用 `DataCollatorWithPadding` 替代固定长度 padding |
| evaluate 无法加载 | 使用本地 git clone 后的路径加载 |
| `local_path` 报错找不到文件 | 确认传入的是**目录路径**而非单个文件 |
| 训练时 GPU 利用率低 | 检查 batch_size 是否过小、学习率是否合适 |





