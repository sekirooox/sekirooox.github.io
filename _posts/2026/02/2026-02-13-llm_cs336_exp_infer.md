---
title: "计算机基础·cs336·实验与推理"
author: MayL
date: 2026-02-13
categories: ["大语言模型与强化学习", "大语言模型"]
tags: ["人工智能", "学习笔记"]
render_with_liquid: false
math: true
description: "本文围绕“计算机基础·cs336·实验与推理”梳理核心概念、算法思路与实践要点，便于系统学习和后续查阅。"
---

@[toc]
# 模型架构实验
+ 包括现代LM的一些设计细节
+ 是否norm，是否pre-norm，是否使用RMSNorm，是否使用门控FFN
## 脚本

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
## 实验结果
+ 代码有一些bug，仅供娱乐

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/05fdf1bd128b417486e5351e1abf222a.png){: referrerpolicy="no-referrer" }

# 学习率实验
## 脚本
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
## 结果
+ 6e-3是当前实验条件下最优的最大学习率。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/99d79e946110406682137ebe82f50a08.png){: referrerpolicy="no-referrer" }
---
<br><br><br><br>
# 推理
## 不同方式的推理结果
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
## 推理代码

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

