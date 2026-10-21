---
title: "LLM 工程实践：Hugging Face 与分词"
date: 2026-10-21
categories: ["大语言模型与强化学习", "大语言模型"]
tags: ["llm", "pytorch", "transformers", "huggingface", "cs336"]
description: "完整整理 Transformers、Datasets、Evaluate、Trainer、Unicode、UTF-8 与 BPE。"
published: false
math: true
---

# LLM 工程实践：Hugging Face 与分词

本文整合 Hugging Face/Transformers 工作流与 CS336 分词作业总结，按照“流水线推理—数据处理—训练评估—编码基础—BPE”的顺序组织内容。新版工作流作为主线，早期教程仅保留独有示例，便于按需回顾。

## Hugging Face Transformers 完整工作流

> 来源：`_posts/2025/11/2025-11-18-llm_transformers.md`

### HuggingFace Transformers

> 本文档整合 Pipeline、Tokenizer、Model、Dataset、Evaluate、Training 六大模块，涵盖从模型加载到训练上线的完整流程。



#### 1. Pipeline 流水线

Pipeline 是集**前处理、模型推理、后处理**于一体的流水线。给定原始输入，自动输出最终结果（如情感标签），**无需手动处理 logits**。

##### 1.1 整体流程

```
原始输入 → tokenizer → token化结果 → model → 推理结果 → 后处理 → 预期结果
```

- `tokenizer`：将原始输入转为 token 形式（id + mask）
- `model`：将 token 结果转换为推理结果
- 推理结果一般需要**后处理**（如 softmax + argmax）
- `pipeline`：直接给出最终结果，封装以上全部步骤。

> **笔记**：不需要记忆官网用法，只需要会查就行。

##### 1.2 直接加载 Pipeline

```python
from transformers import pipeline

local_path = 'model/models--uer--roberta-base-finetuned-dianping-chinese'
pipe = pipeline("text-classification", model=local_path, device=0)

pipe("很好玩")
# [{'label': 'positive (stars 4 and 5)', 'score': 0.9271}]
```

> 注意：`local_path` 是权重文件的**目录路径**，`device=0` 表示使用 GPU。

##### 1.3 组装 Pipeline

分别加载模型和分词器，可更灵活地控制组件：

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline

model = AutoModelForSequenceClassification.from_pretrained(local_path)
tokenizer = AutoTokenizer.from_pretrained(local_path)
pipe = pipeline("text-classification", model=model, tokenizer=tokenizer)
```

##### 1.4 手动推理（不经过 Pipeline）

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

#### 2. Tokenizer 分词器

Tokenizer 负责将原始文本转为模型可处理的 token id，并处理填充、截断等中间过程。

##### 2.1 分词与 ID 互转

```python
sen = "弱小的我也有大梦想!"
tokens = tokenizer.tokenize(sen)                        # 分词
str_sen = tokenizer.convert_tokens_to_string(tokens)    # 还原

ids = tokenizer.convert_tokens_to_ids(tokens)           # token → id
tokens_back = tokenizer.convert_ids_to_tokens(ids)       # id → token
```

##### 2.2 encode 与 decode

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

##### 2.3 encode_plus（含掩码）

在 `encode` 基础上额外返回 `token_type_ids`（用于区分 BERT 中的两个句子）和 `attention_mask`（标识填充位置）：

```python
inputs = tokenizer.encode_plus(sen, padding="max_length", max_length=20)
# {'input_ids': [...],
#  'token_type_ids': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
#  'attention_mask':  [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0]}
```

##### 2.4 直接调用 Tokenizer（最常用）

`tokenizer(text)` 是最常用的快捷方式，效果等价于 `encode_plus`，返回 dict：

```python
inputs = tokenizer(sen, padding="max_length", max_length=15, return_tensors='pt')
# {'input_ids': tensor([[...]]), 'token_type_ids': tensor([[...]]), 'attention_mask': tensor([[...]])}
```

> **`return_tensors='pt'` 必须指定**，否则返回 Python 列表而非 tensor。

##### 2.5 填充与截断规则

- 优先填充至 `max_length`
- 如果文本本身就超过 `max_length`，**优先截断**
- 允许同时指定 `padding` 和 `truncation`
- 解码时可用 `skip_special_tokens=True` 忽略特殊 token

---

#### 3. Model 模型

##### 3.1 AutoConfig

`AutoConfig` 定义了模型的基本结构参数（如隐藏层大小、注意力头数等），等价于 `model.config`：

```python
from transformers import AutoConfig

config = AutoConfig.from_pretrained(local_path)
print(config.hidden_size)      # 768
print(config.num_labels)       # 可修改：config.num_labels = 10
```

> 里面涉及的参数不一定全，可通过 `config.num_labels` 等方式动态修改。

##### 3.2 AutoModel（骨干网络）

`AutoModel` 仅包含**骨干网络**，输出隐藏状态，不带任务头：

> **笔记**：`AutoModel` 只是骨干，`AutoModelForSequenceClassification` = 骨干 + 输出头，输出概率用 `output.logits`。

```python
from transformers import AutoModel

model = AutoModel.from_pretrained(local_path)
output = model(**inputs)
print(output.last_hidden_state.size())  # torch.Size([1, 12, 768])
```

##### 3.3 AutoModelForSequenceClassification（带分类头）

包含骨干 + 分类头，输出已经过分类层的结果。取概率用 `output.logits`：

```python
from transformers import AutoModelForSequenceClassification

clz_model = AutoModelForSequenceClassification.from_pretrained(local_path, num_labels=10)
output = clz_model(**inputs)
# SequenceClassifierOutput(loss=None, logits=tensor([[...]]), ...)
print(output.logits)
```

---

#### 4. Dataset 数据集

##### 4.1 加载数据集

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

##### 4.2 查看数据集

| 操作 | 代码 |
|------|------|
| 按 key 查列 | `datasets["train"]["title"][:2]` |
| 按索引切片 | `datasets["train"][:2]` |
| 列名列表 | `datasets["train"].column_names` |
| 特征类型 | `datasets["train"].features` |
| 数据类型 | `datasets["train"].features['title']` → `Value(dtype='string')` |

##### 4.3 数据划分

```python
dataset = datasets["train"].train_test_split(test_size=0.2)
```

##### 4.4 选择与过滤

```python
# 按索引选择（返回新 Dataset）
datasets["train"].select([0, 1, 25])

# 过滤（lambda 返回 bool）
filter_dataset = datasets["train"].filter(lambda example: "中国" in example["title"])

```

`filter` 的回调应返回布尔值，每个 `example` 都是完整字典；`map` 会遍历样本并允许修改字段。

##### 4.5 数据映射（Tokenizer 预处理）

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

##### 4.6 数据规整（动态填充 Batch）

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

#### 5. Evaluate 评估指标

> **笔记**：evaluate 默认从官网加载，记得本地 clone 后改用本地路径。
> 解决方法：`git clone https://github.com/huggingface/evaluate.git` 到本地目录，改用本地路径加载。

```python
import evaluate

accuracy = evaluate.load("../metrics/accuracy")
print(accuracy)  # 打印使用方法
```

##### 5.1 基础用法

```python
results = accuracy.compute(references=[0, 1, 2, 0, 1, 2], predictions=[0, 1, 1, 2, 1, 0])
# {'accuracy': 0.5}
```

##### 5.2 训练时批量计算

```python
accuracy = evaluate.load("../metrics/accuracy")
for refs, preds in zip([[0, 1], [0, 1]], [[1, 0], [0, 1]]):
    accuracy.add_batch(references=refs, predictions=preds)
accuracy.compute()
```

##### 5.3 组合多个指标

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

#### 6. Training 训练

HuggingFace 的 `Trainer` 封装了 DataLoader + 训练循环，不需要再加载 `DataLoader`，不需要再写训练代码，直接调用接口即可。

> **笔记**：Trainer 包含了 DataLoader 和训练的一整套训练框架，不需要再加载 DataLoader，也不需要再写训练代码，直接调用接口！

##### 6.1 TrainingArguments 配置

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

##### 6.2 评估函数

```python
def eval_metric(eval_predict):
    predictions, labels = eval_predict
    predictions = predictions.argmax(axis=-1)
    acc = acc_metric.compute(predictions=predictions, references=labels)
    f1 = f1_metric.compute(predictions=predictions, references=labels)
    acc.update(f1)
    return acc
```

##### 6.3 Trainer 初始化与使用

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

#### 7. 模型下载与本地加载

##### 7.1 加速下载（推荐）

使用 [LetheSec/HuggingFace-Download-Accelerator](https://github.com/LetheSec/HuggingFace-Download-Accelerator)：

```bash
python hf_download.py --model uer/roberta-base-finetuned-dianping-chinese --save_dir ./model
```

##### 7.2 直接下载（默认路径）

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline

model = AutoModelForSequenceClassification.from_pretrained('uer/roberta-base-finetuned-chinanews-chinese')
tokenizer = AutoTokenizer.from_pretrained('uer/roberta-base-finetuned-chinanews-chinese')
text_classification = pipeline('sentiment-analysis', model=model, tokenizer=tokenizer)
text_classification("北京上个月召开了两会")
```

默认缓存路径：`~/.cache/huggingface/hub`

---

#### 附录：常见问题速查

| 问题 | 解决 |
|------|------|
| `return_tensors='pt'` 返回列表而非 tensor | 加上这个参数 |
| tokenizer 输出有 padding id 参与计算 | 使用 `attention_mask` 屏蔽，或改用 Collator 动态填充 |
| 数据集分词后报错 shape 不一致 | 使用 `DataCollatorWithPadding` 替代固定长度 padding |
| evaluate 无法加载 | 使用本地 git clone 后的路径加载 |
| `local_path` 报错找不到文件 | 确认传入的是**目录路径**而非单个文件 |
| 训练时 GPU 利用率低 | 检查 batch_size 是否过小、学习率是否合适 |

---

## Hugging Face 使用教程（早期笔记，保留独有示例）

> 来源：`_posts/2025/11/2025-11-03-llm_huggingface.md`

### Pipeline
<figure><img src="/assets/img/posts/llm-huggingface-tokenization/022d335f5d3147208393f4af1ebd0248.png" alt="Hugging Face 分词与模型" width="362"><figcaption><p>Pipeline 处理流程</p></figcaption></figure>

#### 模型的加载
**不需要记忆，只需要在官网找就行。**

<figure><img src="/assets/img/posts/llm-huggingface-tokenization/082aa3937b404289ad75151ede8561c1.png" alt="Hugging Face 分词与模型" width="362"><figcaption><p>本地模型加载示例</p></figcaption></figure>

##### 直接加载pipeline
+ 注意`local_path`指的是权重相关文件的**目录路径.**
+ 注意`device`参数需配置，默认部署于CPU上.
```python
local_path='model\models--uer--roberta-base-finetuned-dianping-chinese'
pipe = pipeline("text-classification", model=local_path,device=0)
```
##### 组装为pipeline
+ 分别加载模型和分词器，但是注意这个类不要用错了。
```python
model=AutoModelForSequenceClassification.from_pretrained(local_path)
tokenizer = AutoTokenizer.from_pretrained(local_path)
pipe=pipeline("text-classification", model=model, tokenizer=tokenizer)
```
##### 使用方法
+ 接受输入，返回结构化输出
```python
pipe("很好玩")
[{'label': 'positive (stars 4 and 5)', 'score': 0.9271045327186584}]

```


### Tokenizer
**分词+编码+中间过程(填充、阶段等)**
<figure><img src="/assets/img/posts/llm-huggingface-tokenization/a8395bf047764b6a91adeb21a1c7e422.png" alt="Hugging Face 分词与模型" width="362"><figcaption><p>Tokenizer 处理步骤</p></figcaption></figure>
#### 解码和编码函数
##### 分词函数：`encode`(不带有掩码)
+ 分词+编码
+ 注意：**add_special_tokens=True这一个参数，默认是添加的**。
+ 可以设置填充和截断
+ 开启`max_length`参数后，**默认是截断，默认不开启填充**。
```python
# 截断
ids = tokenizer.encode(sen, max_length=20, truncation=True,padding="max_length")
ids
[101,2483,2207,4638,2769,738,3300,1920,3457,2682,106,102,0,0,0,0,0,0,0,0]
```


##### 解码函数：`decode`
只针对编码后的结果进行解码，返回完整的句子，**默认是保留特殊token的**

```python
str_sen = tokenizer.decode(ids, skip_special_tokens=False)
str_sen
'[CLS] 弱 小 的 我 也 有 大 梦 想! [SEP]'
```


##### 编码函数：`call`和`encode_plus`(带有掩码)
+ 在encode基础上增加了掩码(对应填充)和其他信息(例如区分Bert的SEQ的掩码)
```python
inputs = tokenizer.encode_plus(sen, padding="max_length", truncation=True, max_length=20)
inputs
{'input_ids': [101, 2483, 2207, 4638, 2769, 738, 3300, 1920, 3457, 2682, 106, 102, 0, 0, 0, 0, 0, 0, 0, 0], 'token_type_ids': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 'attention_mask': [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0]}
```

##### 返回类型设置
+ **注意`return_tensors='pt'`参数，不然返回的是一个py类型的列表**！
```python
inputs = tokenizer(sen, padding="max_length", truncation=True, max_length=15,return_tensors='pt')
inputs
```

##### 填充与截断
+ 解码时可用 `skip_special_tokens=True` 忽略特殊 token。
+ 填充和截断同时进行：`(sen, padding="max_length", truncation=True, max_length=20)`。
+ **优先填充至最大长度。**
+ **如果本来就超过最大长度，优先截断。**

### Model
+ 有点类似**骨干和输出头**的关系，`AutoModel`只是**骨干**
+ `AutoConfig`定义了**骨干接受的一些参数**
+ `AutoModelForSequenceClassification`作为**具体的模型**，包括**骨干+输出头**，输出的是预期结果，而不是中间特征。
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
+ 不带model head，输出结果有多个，可以定制多个
```python
model = AutoModel.from_pretrained(local_path)
output = model(**inputs)
output
output.last_hidden_state.size()
torch.Size([1, 12, 768])
```

##### AutoModelForSequenceClassification
+ 具体的模型，可以看到已经是**后处理**的结果了(**包括输出头**)。
+ **取出模型的原始输出：`output.logits`**；若需要分类概率，再沿类别维执行 `softmax`。

```python
clz_model = AutoModelForSequenceClassification.from_pretrained(local_path, num_labels=10)
output=clz_model(**inputs)
SequenceClassifierOutput(loss=None, logits=tensor([[-0.1186, -0.0889,  0.5786,  0.5472, -0.1552, -0.0849,  0.2084,  0.1590,
         -0.1090,  0.3114]], grad_fn=<AddmmBackward0>), hidden_states=None, attentions=None)
```

### Dataset
+ 使用huggingface官方的datasets库中的`load_dataset`函数来加载数据集
+ **加载的类型为`DatasetDict`，当成一个字典+列表来使用！**
+ 整理注：`load_dataset` 用于 Hub 数据集、数据文件或数据集脚本；若目录由 `Dataset.save_to_disk()` 生成，应改用 `load_from_disk()`。

#### load_dataset
##### 加载时划分数据集：`split`
+ 支持数据集划分和切片，`split`参数

```python
dataset = load_dataset(local_path, split="train[20:100]")
dataset
```
#### DatasetDict
+ 类似dict，**用键值的方式得到对应列**
+ 支持切片：`datasets["train"][:2]`
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

+ 按照属性的用法会得到数据类型说明

```python
datasets["train"].features
{'title': Value(dtype='string', id=None),
 'content': Value(dtype='string', id=None)}
```

##### 筛选特定数据
+ 选择特定索引的数据
```python
datasets["train"].select([0, 1,25])
```
##### 过滤数据
+ filter后面**填写bool表达式**，表示过滤的条件。
+ 每一个example作为完整的元素，是一个**字典类型**。
```python
# 过滤
filter_dataset = datasets["train"].filter(lambda example: "中国化" in example["title"])
```
##### 数据映射：支持数据规整
+ 数据映射：可以理解为`iter_row()`的实现方式，遍历每一个数据，对数据的字段进行一定的修改
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
+ 支持按照**批次**`bacthed=True`的形式加快处理速度。
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

### python基础
#### defaultdict 和 Counter
+ DefaultDict：继承自python字典，主要区别是可以用`DefaultDict(int)`**指定默认值**(当为int时，返回0)，例如`DefaultDict(list)`可以**直接往键里面append元素**
+ Counter：继承自python字典，接受可以迭代的对象(list,dict)作为输入，输出返回一个字典，**得到当前元素的出现次数统计**。`Counter([1,2,3])={1:1,2:1,3:1}`
常见操作：`update`和`substract`增加或者减少元素的统计次数(接受list/dict作为参数)
#### `str.encode()` / `bytes.decode('utf-8')`
+ 将字符串转为对应**utf-8编码**(字节的形式)

```python
string = 'hello'
for byte in string.encode('utf-8'):# b'hello'
    print(byte)
104 101 108 108 111
```
#### bytes()函数：整数转字节序列

```python
bytes([104, 101, 108, 108, 111])
b'hello'
```
---
<br><br><br><br><br><br>
### 编码基础
#### 字符转数字
##### ASCII
用一个字节**0~255**来表示一个英文字符，不支持中文。
##### Unicode
标识大多数字符，被标识的字符成为**码点**


#### 数字转存储(字节)
##### UTF-8,UTF-16,UTF-32
+ 字节表示方法：`b'\x00'`
+ 8，16，32指的是**位数(bit)**。
+ UTF-8指的是使用**最少一字节来存储字符**(实际是**动态存储**，例如英文字母‘a'对应一个字节，中文字符“好”对应3个字节)
+ UTF-32指的是使用4字节来存储任意字符，如果**字符不需要4个字节，则填充至4个字节**。
<figure><img src="/assets/img/posts/llm-huggingface-tokenization/85347824a1c74ad1b77d4304bda51975.png" alt="Hugging Face 分词与模型" width="362"><figcaption><p>UTF 编码方式对比</p></figcaption></figure>
##### UTF-8编码原理(了解即可)
<figure><img src="/assets/img/posts/llm-huggingface-tokenization/2b3ca08f5fdb4369ba199c7aec10b703.png" alt="Hugging Face 分词与模型" width="362"><figcaption><p>UTF-8 编码模板</p></figcaption></figure>
##### 实现
---
<br><br><br><br><br><br>

### BPE算法
#### 预分词技术
+ 简单来说就是隔离每一个词，确保每一个词的语义完整，**避免BPE算法统计跨语义的次数**。


<figure><img src="/assets/img/posts/llm-huggingface-tokenization/1512c1ffc20a4684bc916684dba091ea.png" alt="Hugging Face 分词与模型" width="362"><figcaption><p>BPE 预分词示例</p></figcaption></figure>
  ---
<br><br><br><br><br><br>

---

