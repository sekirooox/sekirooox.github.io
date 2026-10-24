---
title: "LLM 工程实践：Hugging Face 与分词"
date: 2026-10-24
categories: ["大语言模型与强化学习", "大语言模型"]
tags: ["llm", "pytorch", "transformers", "huggingface", "cs336"]
description: "围绕接口用法与输入输出，整理 Transformers 推理、Dataset 预处理、组批、训练评估及 UTF-8 与 BPE。"
published: true
math: true
---

本文按“推理接口—样本处理—批次整理—训练评估—编码与分词”组织内容。重点对照各组件的用法、输入输出，以及不同训练任务的数据格式。

## 组件与数据流

Hugging Face 没有统一的训练数据格式。<span style="color:red">最终批次必须匹配模型的输入接口和损失计算要求</span>；`Trainer` 组织训练，不决定模型学习什么。

| 组件 | 输入 | 输出与职责 |
| --- | --- | --- |
| Dataset | 原始数据或已处理的数据 | 按索引提供单条样本 |
| Tokenizer / Processor | 文本、图像或音频 | 模型所需的数值表示 |
| `dataset.map()` | 单条样本或按列组织的一批样本 | 添加、修改字段，返回新数据集 |
| DataCollator | 多条样本组成的列表 | 整理为模型可接收的 Batch |
| Model + Loss | Batch 及目标信号 | 预测结果，以及训练所需的损失 |
| Trainer | 模型、数据、整理器和训练参数 | 执行训练、评估与模型保存 |

数据流为：原始 Dataset → `map()` 预处理 → DataLoader 取样 → DataCollator 组批 → `model(**batch)` → Loss → 反向传播与参数更新。数据已经符合接口时，可以省略 `map()`；非文本任务也不一定需要 Tokenizer。

## Pipeline：直接推理

`pipeline` 封装预处理、模型推理和后处理：输入原始文本，输出标签与分数，无需手动处理 `logits`。

<figure><img src="/assets/img/posts/llm-huggingface-tokenization/mo-xing-fen-ci-tui-li-liu-shui-xian.png" alt="模型分词" width="362"><figcaption><p>推理流水线</p></figcaption></figure>

### 直接加载与组件组装

`local_path` 指向包含配置和权重的本地目录；`device=0` 指定第一块 GPU。也可以分别加载模型和分词器，再组装流水线。

```python
from transformers import pipeline

local_path = 'model/models--uer--roberta-base-finetuned-dianping-chinese'
pipe = pipeline("text-classification", model=local_path, device=0)

pipe("很好玩")
# [{'label': 'positive (stars 4 and 5)', 'score': 0.9271}]
```

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline

model = AutoModelForSequenceClassification.from_pretrained(local_path)
tokenizer = AutoTokenizer.from_pretrained(local_path)
pipe = pipeline("text-classification", model=model, tokenizer=tokenizer)
```

### 手动推理

分词器返回字典式输入，`model(**inputs)` 展开为前向参数。分类模型输出原始分数；单标签分类可沿类别维执行 `softmax` 和 `argmax`。下例变量 `logits` 实际保存的是归一化后的概率。

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

## Tokenizer：文本与 Token ID

Tokenizer 负责分词、编码、填充和截断。预训练分词器通常直接加载已有词表，不需要根据当前数据重新建词表。

<figure><img src="/assets/img/posts/llm-huggingface-tokenization/mo-xing-fen-ci-fen-ci-yu-chu-li.png" alt="模型分词" width="362"><figcaption><p>分词预处理步骤</p></figcaption></figure>

### 接口与返回类型

| 接口 | 输入 | 输出 |
| --- | --- | --- |
| `tokenize()` | 字符串 | Token 字符串列表 |
| `convert_tokens_to_ids()` | Token 列表 | ID 列表 |
| `convert_ids_to_tokens()` | ID 列表 | Token 列表 |
| `convert_tokens_to_string()` | Token 列表 | 文本 |
| `encode()` | 文本 | ID 列表，通常默认添加特殊 Token |
| `decode()` | ID 序列 | 文本，默认保留特殊 Token |
| `tokenizer()` / `encode_plus()` | 文本；直接调用也支持文本列表 | 字典式 `BatchEncoding`，包含 ID 和掩码等字段 |

```python
sen = "弱小的我也有大梦想!"
tokens = tokenizer.tokenize(sen)                        # 分词
str_sen = tokenizer.convert_tokens_to_string(tokens)    # 还原

ids = tokenizer.convert_tokens_to_ids(tokens)           # token → id
tokens_back = tokenizer.convert_ids_to_tokens(ids)       # id → token
```

```python
# 编码（带截断和填充）
ids = tokenizer.encode(sen, max_length=20, truncation=True, padding="max_length")
# [101, 2483, 2207, 4638, 2769, 738, 3300, 1920, 3457, 2682, 106, 102, 0, 0, 0, 0, 0, 0, 0, 0]

# 解码
str_sen = tokenizer.decode(ids, skip_special_tokens=False)
# '[CLS] 弱 小 的 我 也 有 大 梦 想! [SEP]'
```

上例解码注释省略了尾部填充符；`skip_special_tokens=False` 时仍可能出现 `[PAD]`。解码也不保证逐字还原原始空格。

### 直接调用与批处理

默认返回 Python 列表；设置 `return_tensors="pt"` 返回 PyTorch 张量。`token_type_ids` 是否存在取决于模型，不能假设每种模型都有该字段。

```python
inputs = tokenizer(sen, padding="max_length", max_length=15, return_tensors='pt')
# {'input_ids': tensor([[...]]), 'token_type_ids': tensor([[...]]), 'attention_mask': tensor([[...]])}
```

```python
pt_batch = tokenizer(
    ["We are very happy to show you the 🤗 Transformers library.", "We hope you don't hate it."],
    padding=True,
    truncation=True,
    max_length=512,
    return_tensors="pt",
)
```

```text
{'input_ids': tensor([[  101, 11312, 10320, 12495, 19308, 10114, 11391, 10855, 10103,   100,
         58263, 13299,   119,   102],
        [  101, 11312, 18763, 10855, 11530,   112,   162, 39487, 10197,   119,
           102,     0,     0,     0]]), 'token_type_ids': tensor([[0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]]), 'attention_mask': tensor([[1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0]])}
```

批处理仍返回 `BatchEncoding`。上例各张量形状均为 `(2, 14)`，表示两个样本、填充后长度为 14；各字段按样本索引对应，`attention_mask` 的 `1` 表示有效位置，`0` 表示填充位置。

### 填充与截断

- `padding=True`：填充至当前批次最长长度。
- `padding="max_length"`：填充至指定长度。
- `truncation=True`：截断超过长度上限的输入，不能以 `max_length` 或填充选项替代。
- `skip_special_tokens=True`：解码时忽略特殊 Token。

上面的单句张量示例未显式设置截断，处理长文本时须开启 `truncation=True`。`encode_plus()` 的完整字段示例如下：

```python
inputs = tokenizer.encode_plus(sen, padding="max_length", truncation=True, max_length=20)
inputs
{'input_ids': [101, 2483, 2207, 4638, 2769, 738, 3300, 1920, 3457, 2682, 106, 102, 0, 0, 0, 0, 0, 0, 0, 0], 'token_type_ids': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], 'attention_mask': [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0]}
```

## Model：隐藏状态、任务头与配置

| 接口 | 输入 | 输出 |
| --- | --- | --- |
| `AutoConfig.from_pretrained()` | 模型名或配置目录 | 配置对象，不含权重 |
| `AutoModel.from_pretrained()` | 模型名或权重目录 | 预训练骨干模型 |
| `AutoModelForSequenceClassification.from_pretrained()` | 模型名或权重目录 | 带分类头的模型 |
| `AutoModel.from_config()` | 配置对象 | 随机初始化的模型，不加载预训练权重 |

`pipeline` 接收原始文本并返回最终预测；模型通常接收 `input_ids`、`attention_mask` 等张量，输出还需按任务解释。

### 骨干与分类输出

```python
from transformers import AutoModel

model = AutoModel.from_pretrained(local_path)
output = model(**inputs)
print(output.last_hidden_state.size())  # torch.Size([1, 12, 768])
```

```python
from transformers import AutoModelForSequenceClassification

clz_model = AutoModelForSequenceClassification.from_pretrained(local_path, num_labels=10)
output = clz_model(**inputs)
# SequenceClassifierOutput(loss=None, logits=tensor([[...]]), ...)
print(output.logits)
```

骨干示例中的 `last_hidden_state` 形状为 `(1, 12, 768)`，依次为批次、序列长度和隐藏维度。分类模型的 `logits` 为 `(B, C)`，其中 `B` 为批次大小、`C` 为类别数；提供标签时通常还返回标量 `loss`。实际尺寸随输入和配置变化。

两个样本、五个类别的输出如下：

```text
SequenceClassifierOutput(loss=None, logits=tensor([[-2.6222, -2.7745, -0.8967,  2.0137,  3.3064],
        [ 0.0064, -0.1258, -0.0503, -0.1655,  0.1329]],
       grad_fn=<AddmmBackward0>), hidden_states=None, attentions=None)
```

`num_labels=10` 必须与分类头及任务匹配；已有权重的分类头维度不兼容时，不能直接假设加载成功。

### 读取、修改和使用配置

```python
from transformers import AutoConfig

config = AutoConfig.from_pretrained(local_path)
print(config.hidden_size)      # 768
print(config.num_labels)       # 可修改：config.num_labels = 10
```

```python
from transformers import AutoConfig

my_config = AutoConfig.from_pretrained("distilbert/distilbert-base-uncased", n_heads=12)
my_config
```

```python
my_config.dim = 512
my_config.n_heads = 8
my_config
```

```python
from transformers import AutoModel

my_model = AutoModel.from_config(my_config)
```

DistilBERT 原配置的 `dim=768`、`n_heads=12`、`n_layers=6`；修改后 `dim=512`、`n_heads=8`。隐藏维度必须能被注意力头数整除。修改配置对象不会自动重建已实例化的模型，`from_config()` 才会按新配置创建模型。

## Dataset：加载、访问与预处理

`load_dataset()` 用于 Hub 数据集或 CSV、JSON 等数据文件；由 `save_to_disk()` 保存的目录应使用 `load_from_disk()`。未指定 `split` 时通常返回 `DatasetDict`，指定单个划分时返回 `Dataset`。

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

```python
dataset = load_dataset(local_path, split="train[20:100]")        # 切片
dataset = load_dataset(local_path, split=["train[:50%]", "train[50%:]"])  # 对半划分
```

```python
dataset = load_dataset("csv", data_files="./ChnSentiCorp_htl_all.csv", split="train")
dataset = load_dataset("json", data_files="./cmrc2018_trial.json", field="data")
```

### 访问、划分和过滤

| 操作 | 用法 | 结果 |
| --- | --- | --- |
| 取划分 | `datasets["train"]` | `Dataset` |
| 取一条样本 | `datasets["train"][0]` | 字段到值的字典 |
| 取多条样本 | `datasets["train"][:2]` | 字段到列表的字典 |
| 取列 | `datasets["train"]["title"]` | 该列数据 |
| 查结构 | `.column_names`、`.features` | 列名、字段类型 |
| 按索引选择 | `.select([0, 1, 25])` | 新 Dataset |
| 条件过滤 | `.filter(function)` | 保留回调返回真值的样本 |

```python
dataset = datasets["train"].train_test_split(test_size=0.2)
```

```python
# 按索引选择（返回新 Dataset）
datasets["train"].select([0, 1, 25])

# 过滤（lambda 返回 bool）
filter_dataset = datasets["train"].filter(lambda example: "中国" in example["title"])

```

### `map()` 的输入与输出

`map()` 执行数据转换，不规定统一目标格式。默认逐样本调用；`batched=True` 时，回调接收“字段 → 列表”的批次字典。以下 ID 仅说明结构，实际结果取决于分词器。

输入批次：

```text
{    "text": [        "I love this movie.",        "This movie is bad."    ],    "label": [1, 0]}
```

Tokenizer 返回各样本的 ID 和掩码：

```text
{    "input_ids": [        [101, 1045, 2293, 2023, 3185, 1012, 102],        [101, 2023, 3185, 2003, 2919, 1012, 102]    ],    "attention_mask": [        [1, 1, 1, 1, 1, 1, 1],        [1, 1, 1, 1, 1, 1, 1]    ]}
```

`map()` 把返回字段写回数据集，按索引读取时仍是一条样本：

```text
{    "text": "I love this movie.",    "label": 1,    "input_ids": [        101, 1045, 2293, 2023, 3185, 1012, 102    ],    "attention_mask": [        1, 1, 1, 1, 1, 1, 1    ]}
```

默认保留原列；可用 `remove_columns=["text"]` 移除文本列。标准整理器通常会将单数 `label` 转为模型参数 `labels`，也可显式重命名：

```python
tokenized_dataset = tokenized_dataset.rename_column(    "label",    "labels")
```

`map(batch_size=1000)` 是预处理函数一次接收的样本数；`per_device_train_batch_size=8` 是每个设备参与一次训练计算的样本数，两者不必相同。详见 [Datasets 数据处理文档](https://huggingface.co/docs/datasets/process)。

### 不同用途的映射

标题生成任务可分别编码正文和标题，将标题 ID 作为序列标签。下例只是预处理，不代表 BERT 骨干可以直接完成生成；后续需匹配序列到序列模型及整理器。

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

为标题添加前缀是另一种字段修改示例；原片段将函数和输出混排，未展示 `datasets.map(add_prefix)` 调用：

<details markdown="1">
<summary>标题前缀映射（原始片段）</summary>

原文存在代码粘连、截断或混排输出，以下仅用于对照；按规格保留围栏内原文，不作为可直接运行的脚本。

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

</details>

## DataCollator：多条样本组成一个 Batch

<span style="color:red">`map()` 决定单条样本怎样表示，DataCollator 决定多条样本怎样一起输入模型。</span>前者通常提前执行，后者在 DataLoader 每次组批时执行；二者均不更新参数。

### 动态填充的输入输出

长度为 4、6、3 的三条样本不能直接堆叠成普通二维张量。假设填充值为 `0`，先补齐至该批最长长度 6：

```text
sample1: [101, 200, 300, 102,   0,   0]
sample2: [101, 400, 500, 600, 700, 102]
sample3: [101, 800, 102,   0,   0,   0]
```

```text
sample1: [1, 1, 1, 1, 0, 0]
sample2: [1, 1, 1, 1, 1, 1]
sample3: [1, 1, 1, 0, 0, 0]
```

填充后的批次包含两个 `(3, 6)` 输入张量和一个 `(3,)` 分类标签张量：

```text
{    "input_ids": tensor([        [101, 200, 300, 102,   0,   0],        [101, 400, 500, 600, 700, 102],        [101, 800, 102,   0,   0,   0]    ]),    "attention_mask": tensor([        [1, 1, 1, 1, 0, 0],        [1, 1, 1, 1, 1, 1],        [1, 1, 1, 0, 0, 0]    ]),    "labels": tensor([1, 0, 1])}
```

```text
torch.Size([3, 6])
torch.Size([3, 6])
torch.Size([3])
```

`attention_mask` 约束注意力对填充位置的使用；它与控制哪些目标参与损失计算的 Loss Mask 不等价。一个 Token 不计入损失，仍可能作为上下文被关注。

### DataLoader 中使用

先准备已分词的 `tokenized_dataset`，移除原始文本等非模型输入字段，再交给整理器：

```python
from transformers import DataCollatorWithPadding
from torch.utils.data import DataLoader

collator = DataCollatorWithPadding(tokenizer=tokenizer)
dl = DataLoader(tokenized_dataset, batch_size=4, collate_fn=collator, shuffle=True)

for batch in dl:
    print(batch["input_ids"].size())  # torch.Size([4, 动态最长长度])
```

`model(**batch)` 将字典键展开为 `forward()` 参数，因此字段名、张量类型及形状必须匹配模型。`Trainer` 会按配置处理无用列；手动调用 Collator 时需自行保证输入合适。

### 固定填充与动态填充

固定填充到 128 时，长度为 5 和 10 的文本都会补至 128。动态填充则按实际训练批次决定长度：

```text
Batch 1:
长度 5、10、8
    ↓
统一 Padding 到 10

Batch 2:
长度 20、15、12
    ↓
统一 Padding 到 20
```

动态填充通常减少无效计算；固定形状编译、特定硬件或序列打包也可能更适合固定长度。预处理批次不等于训练批次，因此常在 `map()` 中只截断，训练组批时再填充。

### 按任务选择整理器

| 整理器 | 主要用途 |
| --- | --- |
| `DataCollatorWithPadding` | 填充文本输入，适用于标量分类标签 |
| `DataCollatorForSeq2Seq` | 整理源序列和变长目标序列 |
| `DataCollatorForLanguageModeling` | 构建语言模型目标，支持 MLM 或自回归模式 |
| `default_data_collator` | 堆叠固定形状或标量数据，不负责动态填充 |
| 自定义可调用对象 | `collator(samples) -> batch`，实现任务所需逻辑 |

更多用法见 [Data Collator 官方文档](https://huggingface.co/docs/transformers/main_classes/data_collator)。

## Trainer：训练与评估

`Trainer` 接收模型、数据集、整理器及训练参数，内部组织 DataLoader、前向传播、反向传播和参数更新，无需额外封装 DataLoader。

### 文本分类：从样本到模型输出

原始单条样本和分词后的数据格式分别为：

```text
{    "text": "This movie is great.",    "label": 1}
```

```text
{    "input_ids": [101, 2023, 3185, 2003, 2307, 102],    "attention_mask": [1, 1, 1, 1, 1, 1],    "labels": 1}
```

`DataCollatorWithPadding` 将多个样本堆叠为 Batch，并将 `label` 整理为 `labels`。例如二分类输入为 `(2, 8)`，模型返回的 `logits` 为 `(2, 2)`：

```text
logits = tensor([    [1.2, 3.1],    [2.8, 0.5]])
```

每行对应一个样本，每列对应一个类别；按行取最大值分别得到类别 `1`、`0`。六条样本、每批两条、训练三轮，在单设备、无梯度累积且无额外步数限制时，共更新参数 9 次。六条样本仅用于说明流程，不足以获得可靠分类器。

<details markdown="1">
<summary>分类数据和初始化示例（原始片段）</summary>

原文存在代码粘连、截断或混排输出，以下仅用于对照；按规格保留围栏内原文，不作为可直接运行的脚本。

```python
from datasets import Datasetfrom transformers import (    AutoTokenizer,    AutoModelForSequenceClassification,    DataCollatorWithPadding,    TrainingArguments,    Trainer)# ===================================# 1. 准备原始数据# ===================================dataset = Dataset.from_dict({    "text": [        "I love this movie.",        "This movie is terrible.",        "What a wonderful film!",        "I hate this movie.",        "This film is amazing.",        "The movie is very boring."    ],    "label": [1, 0, 1, 0, 1, 0]})# ===================================# 2. 加载 Tokenizer# ===================================model_name = "distilbert/distilbert-base-uncased"tokenizer = AutoTokenizer.from_pretrained(    model_name)# ===================================
```

```python
def preprocess_function(examples):    return tokenizer(        examples["text"],        truncation=True    )
```

```python
tokenized_dataset = dataset.map(    preprocess_function,    batched=True,    remove_columns=["text"])
```

```python
data_collator = DataCollatorWithPadding(    tokenizer=tokenizer)
```

```python
model = AutoModelForSequenceClassification.from_pretrained(    model_name,    num_labels=2)
```

```python
training_args = TrainingArguments(    output_dir="./results",    learning_rate=2e-5,    per_device_train_batch_size=2,    num_train_epochs=3)
```

```python
trainer = Trainer(    model=model,    args=training_args,    train_dataset=tokenized_dataset,    data_collator=data_collator,    processing_class=tokenizer)
```

</details>

### 训练参数与调用

以下保留旧版参数 `evaluation_strategy`；当前文档使用 `eval_strategy`，运行时需匹配安装版本。当前 Trainer 文档使用 `processing_class` 传入 Tokenizer / Processor，旧例中也可能使用 `tokenizer` 参数。

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

上例需先准备模型和 `tokenized_datasets`，并加载指标后定义 `eval_metric`。`trainer.evaluate()` 返回评估指标字典；预测必须提供数据集，例如 `trainer.predict(tokenized_datasets["test"])`，返回包含预测、标签及指标的 `PredictionOutput`，不能照抄上例的无参数调用。

### 训练循环与损失

普通 PyTorch 训练中，DataLoader 取样并调用 Collator，随后执行 `model(**batch)`、读取 `outputs.loss`、反向传播并更新参数。Trainer 按接口组织这些操作，同时处理调度器、评估和保存。自定义模型须自行返回损失，或扩展 Trainer 的损失计算。

$$
\begin{align}
\mathcal{L}=-\frac{1}{B}\sum_{i=1}^{B}\log p_{\boldsymbol{\theta}}(y_i\mid\mathbf{x}_i)
\end{align}
$$

其中，$$B$$ 是批次大小，$$\mathbf{x}_i$$ 是第 $$i$$ 个输入，$$y_i$$ 是正确类别，$$p_{\boldsymbol{\theta}}$$ 是参数为 $$\boldsymbol{\theta}$$ 的模型给出的类别概率。

$$
\begin{align}
\mathbf{g}&=\frac{\partial\mathcal{L}}{\partial\boldsymbol{\theta}}\in\mathbb{R}^{d\times1}\\\boldsymbol{\theta}_{t+1}&=\boldsymbol{\theta}_t-\eta\mathbf{g}_t
\end{align}
$$

其中，$$\boldsymbol{\theta}_t\in\mathbb{R}^{d\times1}$$ 是第 $$t$$ 步的参数列向量，$$\mathbf{g}_t$$ 是分母布局下的损失梯度，$$d$$ 是参数数量，$$\eta$$ 是学习率。这里展示基础梯度下降，AdamW 的具体更新规则不同。

<details markdown="1">
<summary>PyTorch 训练循环（原始片段）</summary>

原文存在代码粘连、截断或混排输出，以下仅用于对照；按规格保留围栏内原文，不作为可直接运行的脚本。

```python
import torchfrom torch.utils.data import DataLoader# 1. 创建 DataLoadertrain_loader = DataLoader(    tokenized_dataset,    batch_size=2,    shuffle=True,    collate_fn=data_collator)# 2. 创建优化器optimizer = torch.optim.AdamW(    model.parameters(),    lr=2e-5)# 3. 训练model.train()for epoch in range(3):    for batch in train_loader:        # 将输入放到模型所在设备        batch = {            k: v.to(model.device)            for k, v in batch.items()        }        # 清空上一轮梯度        optimizer.zero_grad()        # 前向传播        outputs = model(**batch)
```

</details>

### Evaluate：指标的输入输出

指标接收预测类别 `predictions` 与真实类别 `references`，返回指标字典；`add_batch()` 可累积批次后统一计算。网络受限时可从本地指标目录加载。

```python
import evaluate

accuracy = evaluate.load("../metrics/accuracy")
print(accuracy)  # 打印使用方法
```

```python
results = accuracy.compute(references=[0, 1, 2, 0, 1, 2], predictions=[0, 1, 1, 2, 1, 0])
# {'accuracy': 0.5}
```

```python
accuracy = evaluate.load("../metrics/accuracy")
for refs, preds in zip([[0, 1], [0, 1]], [[1, 0], [0, 1]]):
    accuracy.add_batch(references=refs, predictions=preds)
accuracy.compute()
```

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

组合指标示例的原输出注释不准确：四条预测中三条正确，结果应为 `accuracy=0.75`、`precision=1.0`、`recall=0.5`、`f1≈0.6667`。多分类任务还需选择合适的平均方式。

传入 Trainer 的评估函数将 `logits` 沿类别维取 `argmax`，再计算指标；需先加载 `acc_metric` 和 `f1_metric`：

```python
def eval_metric(eval_predict):
    predictions, labels = eval_predict
    predictions = predictions.argmax(axis=-1)
    acc = acc_metric.compute(predictions=predictions, references=labels)
    f1 = f1_metric.compute(predictions=predictions, references=labels)
    acc.update(f1)
    return acc
```

## 不同任务的数据协议

训练目标决定模型、标签和整理器，不能把分类任务的数据格式套用于所有任务。

### 自回归语言模型

文本本身提供下一 Token 的监督目标，无需人工类别。以 `I love machine learning.` 为例：

```text
I      -> love
I love -> machine
I love machine -> learning
```

分词后的样本暂时只有 ID 和掩码：

```text
{    "input_ids": [40, 1842, 4572, 4673, 13],    "attention_mask": [1, 1, 1, 1, 1]}
```

`DataCollatorForLanguageModeling(tokenizer=tokenizer, mlm=False)` 根据输入构造 `labels`，并将填充对应的标签置为 `-100`。简化批次如下：

```text
{    "input_ids": [10, 20, 30, 40],    "labels": [10, 20, 30, 40]}
```

```text
输入位置：  10    20    30    40
预测目标：  20    30    40    ...
```

虽然 `labels` 与输入 ID 相同，GPT-2 等模型在损失计算内部将预测与标签错位对齐，第一个位置预测第二个 Token。因果注意力限制未来信息，不能理解为复制当前位置答案。

$$
\begin{align}
p_{\boldsymbol{\theta}}(x_t\mid x_1,\ldots,x_{t-1})
\end{align}
$$

其中，$$x_t$$ 是第 $$t$$ 个 Token，$$x_1,\ldots,x_{t-1}$$ 是此前的上下文，$$p_{\boldsymbol{\theta}}$$ 是语言模型的条件概率分布。

下列旧例用 `distilgpt2` 演示训练，并以 EOS 兼作 PAD。按 Token ID 屏蔽 PAD 的整理器可能同时屏蔽真实 EOS 标签，实际训练需区分二者并核对标签掩码。

<details markdown="1">
<summary>Causal LM 数据与训练（原始片段）</summary>

原文存在代码粘连、截断或混排输出，以下仅用于对照；按规格保留围栏内原文，不作为可直接运行的脚本。

```python
from datasets import Datasetdataset = Dataset.from_dict({    "text": [        "I love machine learning.",        "Transformers are powerful models.",        "Deep learning is interesting."    ]})
```

```python
from transformers import AutoTokenizermodel_name = "distilgpt2"tokenizer = AutoTokenizer.from_pretrained(    model_name)# GPT-2 默认没有专用 pad_token# 这里为了演示，临时使用 eos_token 作为 pad_tokentokenizer.pad_token = tokenizer.eos_token
```

```python
def tokenize_function(examples):    return tokenizer(        examples["text"],        truncation=True,        max_length=128    )
```

```python
tokenized_dataset = dataset.map(    tokenize_function,    batched=True,    remove_columns=["text"])
```

```python
from transformers import DataCollatorForLanguageModelingdata_collator = DataCollatorForLanguageModeling(    tokenizer=tokenizer,    mlm=False)
```

```python
from transformers import (    AutoModelForCausalLM,    Trainer,    TrainingArguments)model = AutoModelForCausalLM.from_pretrained(    model_name)training_args = TrainingArguments(    output_dir="./lm_results",    per_device_train_batch_size=2,    num_train_epochs=2,    report_to="none")trainer = Trainer(    model=model,    args=training_args,    train_dataset=tokenized_dataset,    data_collator=data_collator,    processing_class=tokenizer)trainer.train()
```

</details>

### 自定义回归模型

回归任务可直接使用数值，不需要 Tokenizer。示例目标为 $$y=2x+1$$，样本为 `(1, 3)`、`(2, 5)`、`(3, 7)`、`(4, 9)`。模型接口是 `forward(x, labels=None)`，单条数据与批次如下：

```text
{    "x": 1.0,    "labels": 3.0}
```

```text
{    "x": tensor([1.0, 2.0]),    "labels": tensor([3.0, 5.0])}
```

组批后 `x` 和 `labels` 为 `(B,)` 浮点张量；模型内部 reshape 为 `(B, 1)`，线性层给出预测，并在有标签时计算 MSE。输出应包含 `logits`，训练时还应包含标量 `loss`。固定形状数值可以使用 `default_data_collator`。下方原模型片段在返回字典处截断，不能直接运行。

<details markdown="1">
<summary>回归模型和 Trainer（原始片段）</summary>

原文存在代码粘连、截断或混排输出，以下仅用于对照；按规格保留围栏内原文，不作为可直接运行的脚本。

```python
from datasets import Datasetdataset = Dataset.from_dict({    "x": [1.0, 2.0, 3.0, 4.0],    "labels": [3.0, 5.0, 7.0, 9.0]})
```

```python
import torchfrom torch import nnclass MyRegressionModel(nn.Module):    def __init__(self):        super().__init__()        self.linear = nn.Linear(1, 1)        self.loss_fn = nn.MSELoss()    def forward(self, x, labels=None):        # 保证形状为 [batch_size, 1]        x = x.float().reshape(-1, 1)        # 预测结果        predictions = self.linear(x)        # 没有标签时，仅返回预测        if labels is None:            return {                "logits": predictions            }        # 计算损失        labels = labels.float().reshape(-1, 1)        loss = self.loss_fn(            predictions,            labels        )        return {            "loss": loss,
```

```python
from transformers import Trainer, TrainingArgumentsfrom transformers import default_data_collatormodel = MyRegressionModel()training_args = TrainingArguments(    output_dir="./regression",    learning_rate=0.01,    per_device_train_batch_size=2,    num_train_epochs=100,    report_to="none")trainer = Trainer(    model=model,    args=training_args,    train_dataset=dataset,    data_collator=default_data_collator)trainer.train()
```

</details>

### 自定义 Collator

Collator 只需接受样本列表并返回模型所需批次，不必继承 HF 的类。以下两个数值样本转换为浮点张量字典：

```text
samples = [    {"x": 1.0, "labels": 3.0},    {"x": 2.0, "labels": 5.0}]
```

```text
{    "x": tensor([1., 2.]),    "labels": tensor([3., 5.])}
```

<details markdown="1">
<summary>自定义整理器与使用（原始片段）</summary>

原文存在代码粘连、截断或混排输出，以下仅用于对照；按规格保留围栏内原文，不作为可直接运行的脚本。

```python
import torchdef my_data_collator(samples):    x = torch.tensor(        [sample["x"] for sample in samples],        dtype=torch.float32    )    labels = torch.tensor(        [sample["labels"] for sample in samples],        dtype=torch.float32    )    return {        "x": x,        "labels": labels    }
```

```python
trainer = Trainer(    model=model,    args=training_args,    train_dataset=dataset,    data_collator=my_data_collator)
```

</details>

多模态整理、标签构造、动态随机 Mask 或数据增强，也可在需要时由自定义 Collator 完成。

### MLM：动态构造训练目标

文本清洗、分词和截断通常放入 `map()`；依赖批次长度或需要重新随机采样的处理放在 Collator。MLM 的同一句文本可以在不同批次得到不同遮盖：

```text
I love machine learning.
```

```text
I love [MASK] learning.
```

```text
I [MASK] machine learning.
```

```python
DataCollatorForLanguageModeling(    tokenizer=tokenizer,    mlm=True,    mlm_probability=0.15)
```

`mlm=True` 与 `mlm_probability=0.15` 配置随机遮盖目标；`DataCollatorWithPadding` 只填充，不会构造 MLM 标签。

## 训练前检查：样本、批次和前向

先检查单条样本的字段、标签和预处理结果，再检查组批后的形状与类型，最后直接前向计算。比直接运行完整训练更容易定位数据接口问题。

```python
print(tokenized_dataset[0])
```

```text
{    "input_ids": [101, 200, 300, 102],    "attention_mask": [1, 1, 1, 1],    "label": 1}
```

```text
input_ids torch.Size([2, 8]) torch.int64
attention_mask torch.Size([2, 8]) torch.int64
labels torch.Size([2]) torch.int64
```

上例分类标签为 `torch.int64`；回归标签通常为浮点数。直接前向时，把批次张量移至模型所在设备，再调用 `model(**batch)`，检查 `outputs.loss` 是否为有限值及 `outputs.logits.shape` 是否符合任务。一次成功前向仅说明当前批次接口基本兼容，不代表完整训练的数值、显存或数据质量都正确。

<details markdown="1">
<summary>批次检查和直接前向（原始片段）</summary>

原文存在代码粘连、截断或混排输出，以下仅用于对照；按规格保留围栏内原文，不作为可直接运行的脚本。

```python
samples = [    tokenized_dataset[0],    tokenized_dataset[1]]batch = data_collator(samples)for key, value in batch.items():    print(key, value.shape, value.dtype)
```

```python
batch = {    k: v.to(model.device)    for k, v in batch.items()}outputs = model(**batch)print(outputs.loss)print(outputs.logits.shape)
```

</details>

验证集用于调参与评估，正式测试集应独立保留。下面的 `split["test"]` 实际承担验证集角色：

<details markdown="1">
<summary>数据划分与验证集示例（原始片段）</summary>

原文存在代码粘连、截断或混排输出，以下仅用于对照；按规格保留围栏内原文，不作为可直接运行的脚本。

```python
split = dataset.train_test_split(    test_size=0.2,    seed=42)trainer = Trainer(    model=model,    args=training_args,    train_dataset=split["train"],    eval_dataset=split["test"],    data_collator=data_collator)
```

</details>

## 编码、UTF-8 与 BPE

Token ID 是分词器词表中的编号，Unicode 码点是字符编号，UTF-8 字节则是存储表示，三者不能混为一谈。

### Python 基础

#### defaultdict 与 Counter

+ `collections.defaultdict` 继承自字典，可指定默认值工厂。`defaultdict(int)` 在访问缺失键时生成 `0`；`defaultdict(list)` 则生成空列表，便于直接调用 `append`。
+ `collections.Counter` 是字典子类，接收可迭代对象或计数映射，用于**统计元素出现次数**。例如 `Counter([1, 2, 3])` 对三个元素的计数均为 `1`。

常见操作包括 `update` 和 `subtract`，分别累加或扣减计数，可接收可迭代对象或计数映射。

#### `str.encode()` / `bytes.decode('utf-8')`

+ `str.encode("utf-8")` 将字符串编码为字节序列，`bytes.decode("utf-8")` 将其解码为字符串。

<details markdown="1">
<summary>UTF-8 原始示例（混排输出）</summary>

原代码将输出混入围栏；循环实际逐行打印 `104`、`101`、`108`、`108`、`111`，依规格保留原片段：

```python
string = 'hello'
for byte in string.encode('utf-8'):# b'hello'
    print(byte)
104 101 108 108 111
```

</details>

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

## 模型下载与本地加载

`from_pretrained()` 可接收 Hub 模型名或本地模型目录。以下保留新闻分类模型的下载与调用示例，返回类别标签和分数：

<figure><img src="/assets/img/posts/llm-huggingface-tokenization/mo-xing-fen-ci-fen-lei-mo-xing-jia-zai.png" alt="模型分词" width="362"><figcaption><p>分类模型加载示例</p></figcaption></figure>

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer, pipeline

model = AutoModelForSequenceClassification.from_pretrained('uer/roberta-base-finetuned-chinanews-chinese')
tokenizer = AutoTokenizer.from_pretrained('uer/roberta-base-finetuned-chinanews-chinese')
text_classification = pipeline('sentiment-analysis', model=model, tokenizer=tokenizer)
text_classification("北京上个月召开了两会")
```

默认 Hub 缓存目录为 `~/.cache/huggingface/hub`。也可按原笔记使用 [HuggingFace-Download-Accelerator](https://github.com/LetheSec/HuggingFace-Download-Accelerator) 下载：

```bash
python hf_download.py --model uer/roberta-base-finetuned-dianping-chinese --save_dir ./model
```

## 常见问题与参考

| 问题 | 检查重点 |
| --- | --- |
| 需要 PyTorch 张量 | `return_tensors="pt"` |
| 序列长短不一无法组批 | 按任务选择整理器，核对输入和标签长度 |
| 模型不接受某个字段 | 检查 `forward()` 签名和批次键名 |
| 本地加载失败 | 确认传入完整模型目录；区分 `load_dataset()` 与 `load_from_disk()` |
| Evaluate 加载失败 | 检查网络或使用本地指标目录 |
| GPU 利用率低 | 检查批次大小、数据加载速度和设备配置 |

训练新任务时，先确定目标和 Loss，再确定模型输入，然后设计 Dataset、预处理及 Collator，最后创建 Trainer。

参考：[Tokenizer](https://huggingface.co/docs/transformers/main_classes/tokenizer)、[Auto classes](https://huggingface.co/docs/transformers/model_doc/auto)、[Datasets](https://huggingface.co/docs/datasets/process)、[Trainer](https://huggingface.co/docs/transformers/main_classes/trainer)。
