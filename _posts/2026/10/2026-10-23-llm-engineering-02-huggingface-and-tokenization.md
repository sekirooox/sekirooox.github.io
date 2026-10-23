---
title: "LLM 工程实践：Hugging Face 与分词"
date: 2026-10-23
categories: ["大语言模型与强化学习", "大语言模型"]
tags: ["llm", "pytorch", "transformers", "huggingface", "cs336"]
description: "完整整理 Transformers、Datasets、Evaluate、Trainer、Unicode、UTF-8 与 BPE。"
published: true
math: true
---

本文整合 Hugging Face/Transformers 工作流与 CS336 分词作业总结，按照“流水线推理—数据处理—训练评估—编码基础—BPE”的顺序组织内容。以完整工作流为主线，早期笔记补充接口示例，便于查阅与对照。

## Hugging Face Transformers 完整工作流

> 来源：`_posts/2025/11/2025-11-18-llm_transformers.md`

> 本文档整合 Pipeline、Tokenizer、Model、Dataset、Evaluate、Training 六大模块，涵盖模型加载、数据处理、训练与评估。

### 1. Pipeline 流水线

`pipeline` 将**预处理、模型推理和后处理**封装为流水线。输入原始文本后，即可获得情感标签等结果，**无需手动处理 `logits`**。

#### 1.1 整体流程

```
原始输入 → tokenizer → token化结果 → model → 推理结果 → 后处理 → 预期结果
```

- `tokenizer`：将原始输入转为模型输入（token ID 和掩码等）
- `model`：将 token 结果转换为推理结果
- 推理结果一般需要**后处理**（如 `softmax` 和 `argmax`）
- `pipeline`：直接给出最终结果，封装以上全部步骤。

> **笔记**：重点理解接口职责，具体参数按需查阅官方文档。

#### 1.2 直接加载 Pipeline

```python
from transformers import pipeline

local_path = 'model/models--uer--roberta-base-finetuned-dianping-chinese'
pipe = pipeline("text-classification", model=local_path, device=0)

pipe("很好玩")
# [{'label': 'positive (stars 4 and 5)', 'score': 0.9271}]
```

> 注意：`local_path` 是权重文件的**目录路径**，`device=0` 表示使用 GPU。

#### 1.3 组装 Pipeline

分别加载模型和分词器，可更灵活地控制组件：

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline

model = AutoModelForSequenceClassification.from_pretrained(local_path)
tokenizer = AutoTokenizer.from_pretrained(local_path)
pipe = pipeline("text-classification", model=model, tokenizer=tokenizer)
```

#### 1.4 手动推理（不经过 Pipeline）

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

### 2. Tokenizer 分词器

Tokenizer 负责将原始文本转为模型可处理的 token id，并处理填充、截断等中间过程。

#### 2.1 分词与 ID 互转

```python
sen = "弱小的我也有大梦想!"
tokens = tokenizer.tokenize(sen)                        # 分词
str_sen = tokenizer.convert_tokens_to_string(tokens)    # 还原

ids = tokenizer.convert_tokens_to_ids(tokens)           # token → id
tokens_back = tokenizer.convert_ids_to_tokens(ids)       # id → token
```

#### 2.2 encode 与 decode

| 方法 | 作用 | 特殊 token |
|------|------|-----------|
| `encode()` | 分词 + 转 id | 默认添加（`add_special_tokens=True`） |
| `decode()` | id → 原始句子 | 默认保留（`skip_special_tokens=False`） |

> **笔记**：默认添加特殊 token；建议显式设置 `truncation=True` 和 `padding`，避免依赖版本兼容行为。详见 [Tokenizer 官方文档](https://huggingface.co/docs/transformers/main_classes/tokenizer)。

```python
# 编码（带截断和填充）
ids = tokenizer.encode(sen, max_length=20, truncation=True, padding="max_length")
# [101, 2483, 2207, 4638, 2769, 738, 3300, 1920, 3457, 2682, 106, 102, 0, 0, 0, 0, 0, 0, 0, 0]

# 解码
str_sen = tokenizer.decode(ids, skip_special_tokens=False)
# '[CLS] 弱 小 的 我 也 有 大 梦 想! [SEP]'
```

#### 2.3 encode_plus 与直接调用

`encode_plus` 返回字典式编码结果，通常包含 `attention_mask`；BERT 等模型还会返回用于区分句子的 `token_type_ids`。直接调用 `tokenizer` 也可获得这类结果：

```python
inputs = tokenizer.encode_plus(sen, padding="max_length", max_length=20)
# {'input_ids': [...],
#  'token_type_ids': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#  'attention_mask':  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0]}
```

#### 2.4 直接调用 Tokenizer（最常用）

`tokenizer(text)` 是常用入口；单句输入时与 `encode_plus` 用法相近，返回字典式的 `BatchEncoding`：

```python
inputs = tokenizer(sen, padding="max_length", max_length=15, return_tensors='pt')
# {'input_ids': tensor([[...]]), 'token_type_ids': tensor([[...]]), 'attention_mask': tensor([[...]])}
```

> 需要 PyTorch 张量时，指定 **`return_tensors='pt'`**；默认返回 Python 列表。

#### 2.5 填充与截断规则

- `padding="max_length"` 将不足长度的序列填充至 `max_length`。
- `truncation=True` 将超过长度上限的序列截断。
- 可同时指定 `padding` 和 `truncation`，分别处理短序列与长序列。
- 解码时可用 `skip_special_tokens=True` 忽略特殊 token

#### 2.6 批处理与输出结构

将多个句子作为列表传入 `tokenizer`，即可批量编码。填充和截断规则同样适用于批处理：

```python
pt_batch = tokenizer(
    ["We are very happy to show you the 🤗 Transformers library.", "We hope you don't hate it."],
    padding=True,
    truncation=True,
    max_length=512,
    return_tensors="pt",
)
```

批处理<span style="color:red">不会改变基本输出格式</span>：返回值仍为字典式的 `BatchEncoding`，包含 `input_ids`、`attention_mask` 等字段；是否包含 `token_type_ids` 取决于模型。

各字段按相同的样本索引对应。指定 `return_tensors="pt"` 后，下例每个张量的形状均为 `(2, 14)`，分别表示批次大小和填充后的序列长度。

```text
{'input_ids': tensor([[  101, 11312, 10320, 12495, 19308, 10114, 11391, 10855, 10103,   100,
         58263, 13299,   119,   102],
        [  101, 11312, 18763, 10855, 11530,   112,   162, 39487, 10197,   119,
           102,     0,     0,     0]]), 'token_type_ids': tensor([[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]), 'attention_mask': tensor([[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0]])}
```

### 3. Model 模型

#### 3.1 AutoConfig

`AutoConfig` 用于加载与模型架构匹配的配置对象；已加载模型的配置可通过 `model.config` 访问，例如隐藏维度和标签数：

```python
from transformers import AutoConfig

config = AutoConfig.from_pretrained(local_path)
print(config.hidden_size)      # 768
print(config.num_labels)       # 可修改：config.num_labels = 10
```

> 配置字段随架构变化；可修改 `config.num_labels` 等属性，但修改已实例化模型的配置不会自动重建网络。

#### 3.2 AutoModel（骨干网络）

`AutoModel` 仅包含**骨干网络**，输出隐藏状态，不带任务头：

> **笔记**：`AutoModel` 是骨干；`AutoModelForSequenceClassification` 包含分类头。`output.logits` 是原始分数，单标签分类时可用 `softmax` 转为概率。

```python
from transformers import AutoModel

model = AutoModel.from_pretrained(local_path)
output = model(**inputs)
print(output.last_hidden_state.size())  # torch.Size([1, 12, 768])
```

#### 3.3 AutoModelForSequenceClassification（带分类头）

包含骨干网络和分类头，`output.logits` 返回未归一化的分类分数：

```python
from transformers import AutoModelForSequenceClassification

clz_model = AutoModelForSequenceClassification.from_pretrained(local_path, num_labels=10)
output = clz_model(**inputs)
# SequenceClassifierOutput(loss=None, logits=tensor([[...]]), ...)
print(output.logits)
```

#### 3.4 Pipeline 与模型接口的区别

`pipeline` 接收原始输入，例如待分类的文本，返回最终标签和 `score`。它封装了分词、模型前向计算和后处理。

模型通常接收分词器输出的 `input_ids`、`attention_mask` 等张量。`AutoModel` 返回隐藏状态；带分类头的模型返回 `SequenceClassifierOutput`，其中 `logits` 是未归一化的分类分数，提供标签时通常还会返回 `loss`。

下面是两个样本、五个类别的分类输出，`logits` 的形状为 `(2, 5)`：

```text
SequenceClassifierOutput(loss=None, logits=tensor([[-2.6222, -2.7745, -0.8967,  2.0137,  3.3064],
        [ 0.0064, -0.1258, -0.0503, -0.1655,  0.1329]],
       grad_fn=<AddmmBackward0>), hidden_states=None, attentions=None)
```

#### 3.5 自定义模型配置

配置类描述模型结构，例如隐藏维度和注意力头数。`AutoConfig.from_pretrained()` 读取配置；`AutoModel.from_config()` 按配置创建模型，权重随机初始化，通常需要训练后才能用于任务。

##### 读取模型配置

加载 DistilBERT 的配置，并通过参数指定注意力头数：

```python
from transformers import AutoConfig

my_config = AutoConfig.from_pretrained("distilbert/distilbert-base-uncased", n_heads=12)
my_config
```

以下为原环境中的配置输出，具体字段随版本变化：

```text
DistilBertConfig {
  "activation": "gelu",
  "architectures": [
    "DistilBertForMaskedLM"
  ],
  "attention_dropout": 0.1,
  "bos_token_id": null,
  "dim": 768,
  "dropout": 0.1,
  "eos_token_id": null,
  "hidden_dim": 3072,
  "initializer_range": 0.02,
  "max_position_embeddings": 512,
  "model_type": "distilbert",
  "n_heads": 12,
  "n_layers": 6,
  "pad_token_id": 0,
  "qa_dropout": 0.1,
  "seq_classif_dropout": 0.2,
  "sinusoidal_pos_embds": false,
  "tie_weights_": true,
  "tie_word_embeddings": true,
  "transformers_version": "5.20.1",
  "vocab_size": 30522
}
```

##### 修改配置属性

可以直接修改配置对象。注意隐藏维度必须能被注意力头数整除：将 `dim` 改为 `512` 时，同时将 `n_heads` 改为 `8`。

```python
my_config.dim = 512
my_config.n_heads = 8
my_config
```

```text
DistilBertConfig {
  "activation": "gelu",
  "architectures": [
    "DistilBertForMaskedLM"
  ],
  "attention_dropout": 0.1,
  "bos_token_id": null,
  "dim": 512,
  "dropout": 0.1,
  "eos_token_id": null,
  "hidden_dim": 3072,
  "initializer_range": 0.02,
  "max_position_embeddings": 512,
  "model_type": "distilbert",
  "n_heads": 8,
  "n_layers": 6,
  "pad_token_id": 0,
  "qa_dropout": 0.1,
  "seq_classif_dropout": 0.2,
  "sinusoidal_pos_embds": false,
  "tie_weights_": true,
  "tie_word_embeddings": true,
  "transformers_version": "5.20.1",
  "vocab_size": 30522
}
```

##### 按新配置初始化模型

```python
from transformers import AutoModel

my_model = AutoModel.from_config(my_config)
```

此时只使用了预训练模型的配置作为结构参考，并未加载其预训练权重。接口区别见 [Auto classes 官方文档](https://huggingface.co/docs/transformers/model_doc/auto)。

---

### 4. Dataset 数据集

#### 4.1 加载数据集

```python
from datasets import load_dataset

local_path = '../dataset/datasets--madao33--new-title-chinese'
datasets = load_dataset(local_path)

# `load_dataset` 返回 `DatasetDict`，可按字典和列表的方式访问。

# DatasetDict({
#     train: Dataset({features: ['title', 'content'], num_rows: 5850})
#     validation: Dataset({features: ['title', 'content'], num_rows: 1679})
# })
```

**加载时直接划分：**

```python
dataset = load_dataset(local_path, split="train[20:100]")        # 切片
dataset = load_dataset(local_path, split=["train[:50%]", "train[50%:]"])  # 对半划分
```

**加载 CSV/JSON：**

```python
dataset = load_dataset("csv", data_files="./ChnSentiCorp_htl_all.csv", split="train")
dataset = load_dataset("json", data_files="./cmrc2018_trial.json", field="data")
```

#### 4.2 查看数据集

| 操作 | 代码 |
|------|------|
| 按 key 查列 | `datasets["train"]["title"][:2]` |
| 按索引切片 | `datasets["train"][:2]` |
| 列名列表 | `datasets["train"].column_names` |
| 特征类型 | `datasets["train"].features` |
| 数据类型 | `datasets["train"].features['title']` → `Value(dtype='string')` |

#### 4.3 数据划分

```python
dataset = datasets["train"].train_test_split(test_size=0.2)
```

#### 4.4 选择与过滤

```python
# 按索引选择（返回新 Dataset）
datasets["train"].select([0, 1, 25])

# 过滤（lambda 返回 bool）
filter_dataset = datasets["train"].filter(lambda example: "中国" in example["title"])

```

`filter` 的回调应返回布尔值，每个 `example` 都是完整字典；`map` 会遍历样本并允许修改字段。

#### 4.5 数据映射（Tokenizer 预处理）

定义映射函数，编码正文与标题。启用 `batched=True` 时，函数接收各列的列表；下面是序列到序列任务的预处理示例，输出仍需配合相应模型和数据规整器。

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

> `batched=True` 用于批量映射，不要求此时将所有序列填充为等长；组成训练批次时再统一填充。

#### 4.6 数据规整（动态填充 Batch）

`DataCollatorWithPadding` 自动将同 batch 内的不同长度序列填充至最长：

```python
from transformers import DataCollatorWithPadding
from torch.utils.data import DataLoader

collator = DataCollatorWithPadding(tokenizer=tokenizer)
dl = DataLoader(tokenized_dataset, batch_size=4, collate_fn=collator, shuffle=True)

for batch in dl:
    print(batch["input_ids"].size())  # torch.Size([4, 动态最长长度])
```

> 应先移除原始文本等非模型输入字段。`DataCollatorWithPadding` 适合填充输入序列；上文的变长标题标签属于序列到序列任务，应配合 `DataCollatorForSeq2Seq`，不能直接套用分类批次的规整方式。

---

### 5. Evaluate 评估指标

> `evaluate.load()` 可按指标名称或本地路径加载。若网络访问受限，可执行 `git clone https://github.com/huggingface/evaluate.git`，再指向仓库内相应的指标目录。

```python
import evaluate

accuracy = evaluate.load("../metrics/accuracy")
print(accuracy)  # 打印使用方法
```

#### 5.1 基础用法

```python
results = accuracy.compute(references=[0, 1, 2, 0, 1, 2], predictions=[0, 1, 1, 2, 1, 0])
# {'accuracy': 0.5}
```

#### 5.2 训练时批量计算

```python
accuracy = evaluate.load("../metrics/accuracy")
for refs, preds in zip([[0, 1], [0, 1]], [[1, 0], [0, 1]]):
    accuracy.add_batch(references=refs, predictions=preds)
accuracy.compute()
```

#### 5.3 组合多个指标

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

> 组合指标时需注意标签类型和多分类参数。上例注释中的准确率有误：四个样本预测正确三个，`accuracy` 应为 `0.75`；其余指标应为 `precision=1.0`、`recall=0.5`、`f1≈0.6667`。

---

### 6. Training 训练

Hugging Face 的 `Trainer` 封装了数据加载和训练循环。准备好模型、数据集与训练参数后，即可调用接口完成常规训练。

> 常规任务无需手写训练循环；特殊训练逻辑可通过回调或继承 `Trainer` 扩展。

#### 6.1 TrainingArguments 配置

以下保留原笔记中的版本写法；`evaluation_strategy` 在新版中对应 `eval_strategy`，运行时应核对所安装版本的接口。

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

#### 6.2 评估函数

先加载 `acc_metric` 和 `f1_metric`，再将此函数传给 `Trainer`；多分类任务还需为 F1 指定合适的平均方式。

```python
def eval_metric(eval_predict):
    predictions, labels = eval_predict
    predictions = predictions.argmax(axis=-1)
    acc = acc_metric.compute(predictions=predictions, references=labels)
    f1 = f1_metric.compute(predictions=predictions, references=labels)
    acc.update(f1)
    return acc
```

#### 6.3 Trainer 初始化与使用

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

> `Trainer` 直接接收处理好的 `Dataset`，**不需要额外封装 `DataLoader`**。输入样本和标签的格式仍须与任务匹配；预测时应传入数据集，例如 `trainer.predict(tokenized_datasets["test"])`。

#### 6.4 标准训练流程

Transformers 的 PyTorch 模型继承自 [`torch.nn.Module`](https://pytorch.org/docs/stable/nn.html#torch.nn.Module)，可用于自定义训练循环，也可交给 `Trainer`。后者还提供分布式训练、混合精度等功能。

根据任务准备以下组件，再传给 `Trainer` 或用于前置的数据处理：

1. [PreTrainedModel](https://huggingface.co/docs/transformers/main/zh/main_classes/model#transformers.PreTrainedModel) 或者 [`torch.nn.Module`](https://pytorch.org/docs/stable/nn.html#torch.nn.Module)：

   ```py
   >>> from transformers import AutoModelForSequenceClassification

   >>> model = AutoModelForSequenceClassification.from_pretrained("distilbert/distilbert-base-uncased")
   ```

2. `TrainingArguments` 含有你可以修改的模型超参数，比如学习率，批次大小和训练时的迭代次数。如果你没有指定训练参数，那么它会使用默认值：

   ```py
   >>> from transformers import TrainingArguments

   >>> training_args = TrainingArguments(
   ...     output_dir="path/to/save/folder/",
   ...     learning_rate=2e-5,
   ...     per_device_train_batch_size=8,
   ...     per_device_eval_batch_size=8,
   ...     num_train_epochs=2,
   ... )
   ```

3. 一个预处理类，比如分词器，特征提取器或者处理器：

   ```py
   >>> from transformers import AutoTokenizer

   >>> tokenizer = AutoTokenizer.from_pretrained("distilbert/distilbert-base-uncased")
   ```

4. 加载一个数据集：

   ```py
   >>> from datasets import load_dataset

   >>> dataset = load_dataset("rotten_tomatoes")  # doctest: +IGNORE_RESULT
   ```

5. 创建一个给数据集分词的函数，并且使用 `map` 应用到整个数据集：

   ```py
   >>> def tokenize_dataset(dataset):
   ...     return tokenizer(dataset["text"])

   >>> dataset = dataset.map(tokenize_dataset, batched=True)
   ```

6. 用来从数据集中创建批次的 [DataCollatorWithPadding](https://huggingface.co/docs/transformers/main/zh/main_classes/data_collator#transformers.DataCollatorWithPadding)：

   ```py
   >>> from transformers import DataCollatorWithPadding

   >>> data_collator = DataCollatorWithPadding(tokenizer=tokenizer)
   ```

组件准备完成后，按上节示例初始化 `Trainer` 并调用 `trainer.train()`。

---

### 7. 模型下载与本地加载

#### 7.1 下载脚本示例

使用 [LetheSec/HuggingFace-Download-Accelerator](https://github.com/LetheSec/HuggingFace-Download-Accelerator)：

```bash
python hf_download.py --model uer/roberta-base-finetuned-dianping-chinese --save_dir ./model
```

#### 7.2 直接下载（默认路径）

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline

model = AutoModelForSequenceClassification.from_pretrained('uer/roberta-base-finetuned-chinanews-chinese')
tokenizer = AutoTokenizer.from_pretrained('uer/roberta-base-finetuned-chinanews-chinese')
text_classification = pipeline('sentiment-analysis', model=model, tokenizer=tokenizer)
text_classification("北京上个月召开了两会")
```

默认缓存路径：`~/.cache/huggingface/hub`

---

### 附录：常见问题速查

| 问题 | 解决 |
|------|------|
| 分词结果为列表，需要 PyTorch 张量 | 设置 `return_tensors='pt'` |
| 输入包含填充 token | 正确传入 `attention_mask`；动态填充可减少填充量，仍需掩码 |
| 组批时序列长度不一致 | 按任务选择数据规整器，统一输入及标签的长度 |
| evaluate 无法加载 | 使用本地 git clone 后的路径加载 |
| `local_path` 报错找不到文件 | 确认传入的是**目录路径**而非单个文件 |
| 训练时 GPU 利用率低 | 检查批次大小、数据加载速度与设备配置 |

---

## Hugging Face 使用教程（早期笔记补充）

> 来源：`_posts/2025/11/2025-11-03-llm_huggingface.md`

### Pipeline

<figure><img src="/assets/img/posts/llm-huggingface-tokenization/mo-xing-fen-ci-tui-li-liu-shui-xian.png" alt="模型分词" width="362"><figcaption><p>推理流水线</p></figcaption></figure>

#### 模型的加载

理解模型类型与任务的对应关系，具体加载方法可查阅官方示例。

<figure><img src="/assets/img/posts/llm-huggingface-tokenization/mo-xing-fen-ci-fen-lei-mo-xing-jia-zai.png" alt="模型分词" width="362"><figcaption><p>分类模型加载示例</p></figcaption></figure>

##### 直接加载pipeline

+ `local_path` 指向包含配置与权重等文件的**本地目录**。
+ 按运行环境设置 `device`；`device=0` 指定第一块 GPU，默认设备行为应结合安装版本确认。

```python
local_path='model\models--uer--roberta-base-finetuned-dianping-chinese'
pipe = pipeline("text-classification", model=local_path,device=0)
```

##### 组装为pipeline

+ 分别加载模型与分词器，模型类应与任务匹配。

```python
model=AutoModelForSequenceClassification.from_pretrained(local_path)
tokenizer = AutoTokenizer.from_pretrained(local_path)
pipe=pipeline("text-classification", model=model, tokenizer=tokenizer)
```

##### 使用方法

+ 输入待分类文本，返回包含标签与分数的结构化结果。

```python
pipe("很好玩")
[{'label': 'positive (stars 4 and 5)', 'score': 0.9271045327186584}]

```

### Tokenizer

分词器负责**分词、编码，以及填充和截断**等预处理。

<figure><img src="/assets/img/posts/llm-huggingface-tokenization/mo-xing-fen-ci-fen-ci-yu-chu-li.png" alt="模型分词" width="362"><figcaption><p>分词预处理步骤</p></figcaption></figure>

#### 编码与解码接口

##### encode：编码为 token ID

+ `encode` 完成分词与 ID 转换，不单独返回掩码。
+ `add_special_tokens=True` 表示添加模型所需的特殊 token，默认开启。
+ 可以设置填充和截断
+ `max_length` 指定长度上限；建议显式开启 `truncation=True`，并按需设置 `padding`。

```python
# 截断
ids = tokenizer.encode(sen, max_length=20, truncation=True,padding="max_length")
ids
[101,2483,2207,4638,2769,738,3300,1920,3457,2682,106,102,0,0,0,0,0,0,0,0]
```

##### 解码函数：`decode`

将 token ID 解码为文本，**默认保留特殊 token**；解码结果不一定逐字还原原始输入。

```python
str_sen = tokenizer.decode(ids, skip_special_tokens=False)
str_sen
'[CLS] 弱 小 的 我 也 有 大 梦 想! [SEP]'
```

##### 编码入口：`__call__` 与 `encode_plus`

+ 相比 `encode`，还可返回 `attention_mask` 和 BERT 的句子类型标记 `token_type_ids`。

```python
inputs = tokenizer.encode_plus(sen, padding="max_length", truncation=True, max_length=20)
inputs
{'input_ids': [101, 2483, 2207, 4638, 2769, 738, 3300, 1920, 3457, 2682, 106, 102, 0, 0, 0, 0, 0, 0, 0, 0], 'token_type_ids': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 'attention_mask': [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0]}
```

##### 返回类型设置

+ 需要 PyTorch 张量时，指定 **`return_tensors='pt'`**；默认返回 Python 列表。

```python
inputs = tokenizer(sen, padding="max_length", truncation=True, max_length=15,return_tensors='pt')
inputs
```

##### 填充与截断

+ 解码时可用 `skip_special_tokens=True` 忽略特殊 token。
+ 填充和截断同时进行：`(sen, padding="max_length", truncation=True, max_length=20)`。
+ `padding="max_length"` 负责将短序列填充至指定长度。
+ `truncation=True` 负责截断超长序列，两者可同时使用。

### Model

+ 模型可分为**骨干网络和任务头**；`AutoModel` 加载骨干网络。
+ `AutoConfig` 描述模型结构与相关参数，不包含权重。
+ `AutoModelForSequenceClassification` 包含**骨干和分类头**，返回分类分数等任务输出。

#### AutoConfig

+ 配置模型结构和超参数，不包含模型权重。

```python
config = AutoConfig.from_pretrained(local_path)
config
BertConfig {
  "_name_or_path": "",
  "architectures": [
    "BertForMaskedLM"
  ],
  "attention_probs_dropout_prob": 0.1,
  "classifier_dropout": null,
...
}
```

#### AutoModel

+ 不带任务头，返回隐藏状态等特征，具体字段取决于模型。

```python
model = AutoModel.from_pretrained(local_path)
output = model(**inputs)
output
output.last_hidden_state.size()
torch.Size([1, 12, 768])
```

#### AutoModelForSequenceClassification

+ 带分类头的模型输出任务分数；概率转换等后处理仍需单独执行。
+ **取出模型的原始输出：`output.logits`**；若需要分类概率，再沿类别维执行 `softmax`。

```python
clz_model = AutoModelForSequenceClassification.from_pretrained(local_path, num_labels=10)
output=clz_model(**inputs)
SequenceClassifierOutput(loss=None, logits=tensor([[-0.1186, -0.0889,  0.5786,  0.5472, -0.1552, -0.0849,  0.2084,  0.1590,
         -0.1090,  0.3114]], grad_fn=<AddmmBackward0>), hidden_states=None, attentions=None)
```

### Dataset

+ 使用 Hugging Face `datasets` 库的 `load_dataset` 加载数据集。
+ 未指定 `split` 时通常返回 `DatasetDict`；指定单个划分时返回 `Dataset`。
+ 整理注：`load_dataset` 用于 Hub 数据集、数据文件或数据集脚本；若目录由 `Dataset.save_to_disk()` 生成，应改用 `load_from_disk()`。

#### load_dataset

##### split：选择划分与切片

+ 通过 `split` 选择数据划分，并使用切片语法限定样本范围。

```python
dataset = load_dataset(local_path, split="train[20:100]")
dataset
```

#### DatasetDict

+ 先用划分名取得 `Dataset`，再用列名读取对应列。
+ 支持切片，例如 `datasets["train"][:2]` 读取前两个样本。

```python
local_path='../dataset/datasets--madao33--new-title-chinese'
datasets = load_dataset(local_path)
datasets
DatasetDict({
    train: Dataset({
        features: ['title', 'content'],
        num_rows: 5850
    })
    validation: Dataset({
        features: ['title', 'content'],
        num_rows: 1679
    })
})
```

```python
datasets["train"]["title"]
['望海楼美国打“台湾牌”是危险的赌博',
 '大力推进高校治理能力建设']
```

##### 获得属性

+ 通过 `features` 属性查看各字段的数据类型。

```python
datasets["train"].features
{'title': Value(dtype='string', id=None),
 'content': Value(dtype='string', id=None)}
```

##### 筛选特定数据

+ `select` 按索引选取样本，返回新的数据集。

```python
datasets["train"].select([0, 1,25])
```

##### 过滤数据

+ `filter` 接收回调函数，以其返回的布尔值决定是否保留样本。
+ 默认逐样本调用，`example` 是包含各字段的字典。

```python
# 过滤
filter_dataset = datasets["train"].filter(lambda example: "中国化" in example["title"])
```

##### 数据映射：支持数据规整

+ `map` 将处理函数应用于样本或批次，返回修改后的字段。

```python
def add_prefix(example):
    example["title"] = 'Prefix: ' + example["title"]
    return example
 ['Prefix: 望海楼美国打“台湾牌”是危险的赌博',
 'Prefix: 大力推进高校治理能力建设',
 'Prefix: 坚持事业为上选贤任能',
 'Prefix: “大朋友”的话儿记心头',
 'Prefix: 用好可持续发展这把“金钥匙”',
 'Prefix: 跨越雄关，我们走在大路上',
 'Prefix: 脱贫奇迹彰显政治优势',
 'Prefix: 拱卫亿万人共同的绿色梦想',
 'Prefix: 为党育人、为国育才',
 'Prefix: 净化网络语言']
```

+ 设置 `batched=True` 可按**批次**处理，加快预处理速度。
+ 可以同时**移除特定的列。**

```python
from transformers import AutoTokenizer
tokenizer = AutoTokenizer.from_pretrained("bert-base-chinese")
def preprocess_function(example, tokenizer=tokenizer):
    model_inputs = tokenizer(example["content"], max_length=512, truncation=True)
    labels = tokenizer(example["title"], max_length=32, truncation=True)
    # label就是title编码的结果
    model_inputs["labels"] = labels["input_ids"]
    return model_inputs
processed_datasets = datasets.map(preprocess_function, batched=True, remove_columns=datasets["train"].column_names)
processed_datasets
```

---

## 编码、UTF-8 与 BPE（CS336 作业总结）

> 来源：`_posts/2026/02/2026-02-01-llm_cs336_tokenization.md`

### Python 基础

#### defaultdict 与 Counter

+ `collections.defaultdict` 继承自字典，可指定默认值工厂。`defaultdict(int)` 在访问缺失键时生成 `0`；`defaultdict(list)` 则生成空列表，便于直接调用 `append`。
+ `collections.Counter` 是字典子类，接收可迭代对象或计数映射，用于**统计元素出现次数**。例如 `Counter([1, 2, 3])` 对三个元素的计数均为 `1`。

常见操作包括 `update` 和 `subtract`，分别累加或扣减计数，可接收可迭代对象或计数映射。

#### `str.encode()` / `bytes.decode('utf-8')`

+ `str.encode("utf-8")` 将字符串编码为字节序列，`bytes.decode("utf-8")` 将其解码为字符串。

```python
string = 'hello'
for byte in string.encode('utf-8'):# b'hello'
    print(byte)
104 101 108 108 111
```

#### bytes()：整数转字节序列

`bytes()` 可将范围为 `0–255` 的整数序列转换为字节序列：

```python
bytes([104, 101, 108, 108, 111])
b'hello'
```

---

### 编码基础

#### 从字符到码点

##### ASCII

ASCII 使用 **7 位**编码，范围为 `0–127`，包含英文字母、数字、标点和控制字符，不支持中文。存入字节时，最高位为 `0`。

##### Unicode

Unicode 为字符分配统一的**码点**，例如 `A` 对应 `U+0041`。码点是字符编号；实际存储还需使用 UTF-8 等编码。

#### 从码点到字节

##### UTF-8、UTF-16 与 UTF-32

+ 字节表示方法：`b'\x00'`
+ UTF-8、UTF-16、UTF-32 中的数字表示**编码单元的位数**，并非每个字符固定占用的位数。
+ UTF-8 使用 **1–4 个字节**编码一个 Unicode 标量值，例如 `a` 占 1 字节，`好` 占 3 字节；UTF-16 使用 2 或 4 字节。
+ UTF-32 使用固定的 **4 字节**编码一个 Unicode 标量值；一个可见字符可能由多个码点组成。

<figure><img src="/assets/img/posts/llm-huggingface-tokenization/mo-xing-fen-ci-zi-fu-bian-ma-dui-bi.png" alt="模型分词" width="362"><figcaption><p>字符编码方式对比</p></figcaption></figure>

##### UTF-8 编码原理

<figure><img src="/assets/img/posts/llm-huggingface-tokenization/mo-xing-fen-ci-bian-chang-zi-jie-mo-ban.png" alt="模型分词" width="362"><figcaption><p>变长字节编码模板</p></figcaption></figure>

UTF-8 通过首字节前缀区分字节数，后续字节以 `10` 开头。图中的 `x` 表示码点的有效位；代理码点区间 `U+D800–U+DFFF` 不属于合法的 Unicode 标量值，不能直接编码为 UTF-8。

---

### BPE 算法

#### 预分词技术

+ 预分词先按空格、标点或正则规则划分文本片段，再在片段内部统计和合并相邻字节对，**限制 BPE 跨片段合并**。它约束合并边界，但不保证语义完整。

<figure><img src="/assets/img/posts/llm-huggingface-tokenization/mo-xing-fen-ci-yu-fen-ci-bian-jie.png" alt="模型分词" width="362"><figcaption><p>预分词边界示例</p></figcaption></figure>

---
