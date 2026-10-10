---
title: "计算机基础·cs336-assignment5"
author: MayL
date: 2026-03-06
categories: ["大语言模型与强化学习", "大语言模型"]
tags: ["人工智能", "学习笔记"]
render_with_liquid: false
math: true
description: "本文围绕“计算机基础·cs336-assignment5”梳理核心概念、算法思路与实践要点，便于系统学习和后续查阅。"
---

@[toc]
# 参考文献
[cs336-代码实现和翻译](https://blog.csdn.net/weixin_43807749/article/details/156726594)
# 前置代码知识
## `jsonl`文件
jsonl文件格式中每一行元素都是一个json风格的**字符串**，**json库中所有以s结尾的方法都在处理这种字符串**。例如读取jsonl和保存为jsonl格式的文件。
+ `json.loads()`:读取json风格的字符串，常用jsonl文件。
+ `json.dumps()`：保存为json风格的字符串，常用于保存jsonl文件。
+ 读取`jsonl`文件，使用`f.readlines`读取每一行，然后每一行调用`json.loads()`
### 读取jsonl文件
```python
def load_json(json_path: str) -> Iterable[Dict]:
    with open(json_path, 'r', encoding='utf-8') as f:
        # 一行一个 JSON，适用于 jsonl 格式
        for line in f:
            line = line.strip()
            yield json.loads(line)
```
---
### 保存为jsonl文件
```python
with open(output_path, 'w', encoding='utf-8') as f:
   for item in formatted_files:
       line = json.dumps(item, ensure_ascii=False)
       f.write(line + '\n')
```
---
<br><br><br><br><br><br>
# 前置知识
## 学习率和batch_size的线性缩放原则
+ 假设当前学习率为10，batch_size=2，如果batch_size增加为4，学习率也要线性缩放为20。
+ **batch_size增大， 学习率也要线性增大**，不然多出来的几个样本意义就不大了。
## 梯度累积（Gradient Accumulation）
尽管使用了 bfloat16 和 FlashAttention-2，即使在 80GB 显存的 GPU 上，也难以支持合理的批大小。为此，可采用梯度累积技术：**不在每个 batch 后立即更新权重，而是累积多个 batch 的梯度后再执行一次优化器步。**
+ 假设当前显存不支持256的batch_size，我们可以拆分为分128次的batch_size=2的计算，梯度累积设定为128。
+ 直观理解：若 GPU 足够大，一次性计算 32 个样本的梯度，与分 16 次每次 2 个样本再平均，结果应一致。

---
<br><br><br><br><br><br>
# 0 数据处理
+ 同一将math和gsm8k数据集转换为{question,cot,answer}的格式，方便套用模板：
```python
def convert2template(
    files: Iterable[Dict],
    mode: Literal['gms8k', 'math'] = 'gsm8k'
) -> List[Dict[str, str]]:
    """
    将原始数据转换为统一的 ri-zero 模板格式：
    {
        "question": 问题,
        "cot": 思考过程/解题步骤,
        "answer": 最终答案
    }

    :param files: 原始样本的可迭代对象（如 load_json 的返回值）
    :param mode: 数据集类型，'gms8k' 或 'math'
    :return: 格式化后的样本列表
    """
    formatted_files: List[Dict[str, str]] = []
    for file in files:
        if mode == 'gsm8k':
            # gsm8k: answer 字段格式为 "cot 文本\n#### 最终答案"
            raw_answer: str = file['answer']
            # 以 '\n####' 分割为 推理过程 + 最终答案
            parts = raw_answer.split('\n####', maxsplit=1)
            if len(parts) == 2:
                cot_part = parts[0].strip()
                ans_part = parts[1].strip()
            else:
                # 兜底：如果没有按预期分割，就把整个当作 cot，答案留空
                cot_part = raw_answer.strip()
                ans_part = ""

            formatted_files.append({
                'question': file['question'],
                'cot': cot_part,
                'answer': ans_part,
            })

        elif mode == 'math':
            # math 数据集字段名不同
            formatted_files.append({
                'question': file['problem'],
                'cot': file['solution'],
                'answer': file['answer'],
            })
        else:
            raise NotImplementedError(f"Unsupported mode: {mode}")
    return formatted_files
```
+ 数据预先处理代码：
```python
def preprocess_data(
    json_dir: str,
    mode: str,
    out_dir: str,
) -> None:
    """
    读取目录下所有 jsonl 文件，按给定 mode 转换为 r1-zero 模板，
    然后将所有格式化后的样本写入 jsonl 文件（每行一个 JSON）。

    :param json_dir: 原始 jsonl 文件所在目录
    :param mode: 数据集类型，'gms8k' 或 'math'
    :param out_dir: 输出的 jsonl 文件所在目录
    """
    # 确保输出目录存在
    os.makedirs(out_dir, exist_ok=True)

    for json_name in os.listdir(json_dir):
        json_path = os.path.join(json_dir, json_name)

        # 只处理 .jsonl 文件（根据需要可调整）
        if not json_name.endswith('.jsonl'):
            continue

        # 使用生成器逐行读取原始 jsonl
        data_iter = load_json(json_path)
        # 转为统一模板
        formatted_files = convert2template(data_iter, mode=mode)

        # 输出仍然是同名的 .jsonl 文件
        output_path = os.path.join(out_dir, json_name)

        # 逐条写入到输出 jsonl：一条样本一行
        with open(output_path, 'w', encoding='utf-8') as f:
            for item in formatted_files:
                line = json.dumps(item, ensure_ascii=False)
                f.write(line + '\n')
```
## 预期格式

```python
{
  "question": "Natalia sold clips to 48 of her friends in April, and then she sold half as many clips in May. How many clips did Natalia sell altogether in April and May?", 
  "cot": "Natalia sold 48/2 = <<48/2=24>>24 clips in May.\nNatalia sold 48+24 = <<48+24=72>>72 clips altogether in April and May.\n</think> <answer>72</answer>", 
  "answer": "72"
}
```
# 1 作业概述
# 2 语言模型的推理能力
# 3 Measuring Zero-Shot MATH Performance




## 3.1 使用 vLLM 进行离线语言模型推理
### vllm.generate函数
+ `outputs = vllm.generate(prompts, sampling_params)`
+ outputs的类型为`List[RequestOutput]`对象
### RequestOutput
+ RequestOutput对象包含**outputs，prompt等其他对象**
+ RequestOutput.outputs中**包含模型多个回答**(LLM的回答是不确定的，可能有多个)
+ RequestOutput还包含模型输出token的logprob，但是**数量有上限**(最多20个)。
### 获取vllm回答的函数
```python
def generate_responses(
    vllm: LLM,
    prompts: Union[str, List[str]],
    sampling_params: SamplingParams
) -> List[str]:
    """
    使用vLLM生成响应
    """    
    # 生成响应
    outputs = vllm.generate(prompts, sampling_params)
    responses = [output.outputs[0].text for output in outputs]
    return responses
```
### SFT任务要求的采样函数
```python
sampling_params = SamplingParams(
            temperature=self.temperature,
            top_p=self.top_p,
            max_tokens=self.max_tokens,
            stop=self.stop,
            seed=self.seed,
            include_stop_str_in_output=self.include_stop_str_in_output
)
```
## 3.2 零样本 MATH 基线 - Zero-shot MATH Baseline
###  r1_zero prompt 函数的用法
+ 只接受**不带有cot的答案**
+ 对于格式输入很敏感，检查 $</think> <answer>$ 是否在response中（**注意中间有空格**）

```python
def r1_zero_reward_fn(
response:list[str], 
ground_truth:list[str], # only answer is required 
fast=True
):
    """
    这个奖励函数预期传入的是纯答案
    格式检查：检查 "</think> <answer>" 是否在response中（注意中间有空格）
    答案提取：如果格式正确，提取 <answer> 和 </answer> 之间的内容
    答案比对：使用 grade() 函数比对模型答案和 ground truth
    """
    # We are strict about format to evaluate our models.
    if "</think> <answer>" in response and "</answer>" in response:
        model_answer = response.split("<answer>")[-1].replace("</answer>", "")
        if "\\boxed" in model_answer:
            model_answer = extract_answer(model_answer)
            if model_answer is None:
                return {
                    "format_reward": 1.0,
                    "answer_reward": 0.0,
                    "reward": 0.0
                }
        if isinstance(ground_truth, float) or isinstance(ground_truth, int):
            ground_truth = str(ground_truth)
        if isinstance(ground_truth, str):
            is_correct = grade(model_answer, ground_truth, fast)
        elif isinstance(ground_truth, list):
            is_correct = False
            for gt in ground_truth:
                is_correct |= grade(model_answer, gt, fast)
        if is_correct:
            return {
                "format_reward": 1.0,
                "answer_reward": 1.0,
                "reward": 1.0
            }
        else:
            # Formatted but wrong answer; no format reward to avoid hacking.
            return {
                "format_reward": 1.0,
                "answer_reward": 0.0,
                "reward": 0.0
            }
    else:
        # Unformatted.
        return {
            "format_reward": 0.0,
            "answer_reward": 0.0,
            "reward": 0.0
        }
```
### 问题（math_baseline）：4 分
(a) 编写一个脚本，用于评估 Qwen 2.5 Math 1.5B 模型在 MATH 数据集上的零样本（zero-shot）性能。该脚本应：

从 /data/a5-alignment/MATH/validation.jsonl 加载 MATH 验证集样本；
使用 r1_zero 提示模板将样本格式化为语言模型可接受的字符串提示；
为每个样本生成模型输出；
计算评估指标；
将样本、模型生成结果及对应的评估分数序列化保存到磁盘，供后续问题分析使用。
为便于实现，建议你包含一个名为 evaluate_vllm 的方法，其参数如下所示，以便后续复用：

```python
@torch.no_grad()
def evaluate_vllm(
    vllm:LLM,
    prompts:List[str],
    ground_truths:List[str],
    sampling_params:SamplingParams,
    reward_fn:Callable,# defined in drgrpo_grader.py 
)->Dict[str,int]:
    responses = generate_responses(vllm, prompts, sampling_params)
    rewards = [reward_fn(response, ground_truth) for response,ground_truth in zip(responses,ground_truths)]
    overview = {
        "sample_size": len(rewards),
        "answer_correct": 0,
        "format_correct": 0,
        "total_correct": 0,
        "format_correct_but_answer_wrong": 0,
        "answer_correct_but_format_wrong": 0,
        "total_wrong": 0,
        "accuracy": 0.0,
        'wrong_rate': 0.0,
        'contradictory_samples': 0,
    }

    for reward_dict in rewards:
        # 统计格式正确
        if reward_dict['format_reward'] == 1.0:
            overview['format_correct'] += 1
            
        # 统计答案正确
        if reward_dict['answer_reward'] == 1.0:
            overview['answer_correct'] += 1
        
        # 统计完全正确
        if reward_dict['reward'] == 1.0:
            overview['total_correct'] += 1
        
        # 统计格式正确但答案错误
        if reward_dict['format_reward'] == 1.0 and reward_dict['answer_reward'] == 0.0:
            overview['format_correct_but_answer_wrong'] += 1
        
        # 统计答案正确但格式错误
        if reward_dict['answer_reward'] == 1.0 and reward_dict['format_reward'] == 0.0:
            overview['answer_correct_but_format_wrong'] += 1

        if reward_dict['format_reward'] == 0.0 and reward_dict['answer_reward'] == 0.0:
            overview['total_wrong'] += 1

        # 统计自相矛盾的样本数
        if reward_dict['reward']==1.0 and (reward_dict['format_reward'] == 0.0 or reward_dict['answer_reward'] == 0.0):
            overview['contradictory_samples'] += 1

    # 计算准确率
    overview['accuracy'] = overview['total_correct'] / overview['sample_size']
    overview['wrong_rate'] = overview['total_wrong'] / overview['sample_size']
    return overview
```
(b) 在 Qwen 2.5 Math 1.5B 上运行你的评估脚本。统计模型生成结果分别属于以下哪几类：

格式正确且答案正确（格式奖励 = 1，答案奖励 = 1）；
格式正确但答案错误（格式奖励 = 1，答案奖励 = 0）；
格式错误（格式奖励 = 0，答案奖励 = 0）。
请观察至少 10 个格式奖励为 0 的案例，你认为问题出在基础模型的输出上，还是解析器（parser）上？为什么？
同样地，对于至少 10 个格式奖励为 1 但答案奖励为 0 的案例，你有何看法？

交付物：对模型与奖励函数表现的评述，包括每种类别的示例。
### 评估结果
+ gsm8k：2.3%的准确率
+ math：3%的准确率


# 4. 对 MATH 数据集的监督微调（Supervised Finetuning, SFT ）
## 4.2 SFT 辅助方法
+ 采样一组数据
+ 然后最大化标签的负数似然比，$\max \log\pi_{\theta}(a_t\mid x_t)$
+ 反向传播和梯度更新即可
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8007908011204c01a80137e9d2b6f363.png){: referrerpolicy="no-referrer" }


### 问题（tokenize_prompt_and_output）：提示与输出的分词（2 分）

交付物：实现一个 tokenize_prompt_and_output 方法，分别对问题和输出字符串进行分词、拼接，并构建 response_mask。推荐接口如下：

分析：
+ LLM的预先练任务本质是预测下一个token，输入为$x_{1:n}$，预测标签为$x_{2:n+1}$.
+ SFT需要**将输入和输出拼在一起**，以同步预训练任务中这一形式
+ 同时我们需要对所有的输入进行填充，确保它们可以被batch处理，**填充的部分需要填充掩码**。
+ 我们不关心prompt部分的预测结果，因此**prompt的部分需要prompt掩码**。

实现：
+ 填充掩码很容易实现：先获取最大长度，然后使用`[0]*(max_len-cur_len)`填充即可
+ prompt掩码在一开始拼接输入和输出时就可以构建，然后使用同样的方式处理填充的部分即可。
+ **注意padding_token不一定是0！！！**，例如`pad_id = tokenizer.pad_token_id`指的是155xxx。
```python
def tokenize_prompt_and_output(prompt_strs, output_strs, tokenizer):
    """
    对提示和输出字符串进行分词，并构建一个掩码，标记响应 token（值为 1），其余（提示或填充）为 0。

    Args:
        prompt_strs: List[str] —— 提示字符串列表。
        output_strs: List[str] —— 输出字符串列表。
        tokenizer: PreTrainedTokenizer —— 用于分词的分词器。

    Returns:
        dict[str, torch.Tensor]：
            设 prompt_and_output_lens 为各拼接后序列的长度列表，
            返回字典包含以下键：
            - input_ids: shape (batch_size, max(prompt_and_output_lens) - 1)
                         拼接后的 token 序列（去掉最后一个 token）
            - labels: shape 同 input_ids，为 input_ids 右移一位（即去掉第一个 token）
            - response_mask: shape 同 input_ids，响应 token 对应位置为 True，其余为 False
    """
    """
    需要注意的点:
    1. tokenizer(prompt)+tokenizer(output)!=tokenizer(prompt+output)
    2. response_mask是针对labels的,需要右移
    3. 所有掩码一律使用二进制, 填充的token要使用pad_id(0可能是有用的token)
    """
    # 填充要填充指定的pad_id,掩码中1代表有用的token,0代表无用的token
    prompt_ids = tokenizer(prompt_strs, 
        add_special_tokens=False,
        padding=False,
        truncation=False,
        return_attention_mask=False,).input_ids
    output_ids = tokenizer(output_strs,
        add_special_tokens=False,
        padding=False,
        truncation=False,
        return_attention_mask=False,).input_ids
    input_ids = []
    prompt_masks = []

    # 拼接输入和输出,获得prompt_masks
    for p, o in zip(prompt_ids, output_ids):
        input_ids.append(p + o)
        prompt_masks.append([0] * len(p) + [1] * len(o))

    # 获取最长长度
    max_length = max([len(ids) for ids in input_ids])

    # 获取padding_mask b ? -> b l
    padding_masks = []
    pad_id = tokenizer.pad_token_id
    for i in range(len(input_ids)):
        # [1,1,0]
        padding_masks.append([1] * len(input_ids[i]) + [0] * (max_length - len(input_ids[i])))
        # [0 1 0]
        prompt_masks[i] = prompt_masks[i] + [0] * (max_length - len(prompt_masks[i]))
        # [x x y]
        input_ids[i] = input_ids[i] + [pad_id] * (max_length - len(input_ids[i]))
    
    padding_masks = torch.tensor(padding_masks)
    prompt_masks = torch.tensor(prompt_masks)
    input_ids = torch.tensor(input_ids)
    mask = (padding_masks & prompt_masks).bool()
    return {
        'input_ids': input_ids[:,:-1],# 去掉最后一个token(no label)
        'labels': input_ids[:, 1:].clone(), 
        'response_mask': mask[:,1:]# b l
    }
```
### 问题（compute_entropy）：Per-token entropy (1 point)

实现一个名为 compute_entropy 的方法，用于计算每个 token 的下一个 token 预测熵。建议采用以下接口：
```python
def compute_entropy(logits: torch.Tensor) -> torch.Tensor:
	"""
	功能：获取下一个 token 预测的熵（即在词汇表维度上的熵）。
	
	参数：
	- logits: torch.Tensor，形状为 (batch_size, sequence_length, vocab_size)，包含未归一化的 logits。
	
	返回值：
	- torch.Tensor，形状为 (batch_size, sequence_length)，表示每个下一个 token 预测的熵。
	"""
	log_probs = torch.log_softmax(logits,dim=-1)
	probs = torch.exp(log_probs)
	entropy = - log_probs * probs
	return entropy.sum(dim=-1)
```

### 问题（get_response_log_probs）：响应对数概率（及熵）（2分）

交付要求 实现get_response_log_probs方法，用于从因果语言模型中获取逐token条件对数概率（基于前文token），并可选返回模型下一个token分布的熵。推荐接口：
+ 使用`torch.gather`即可
```python
def get_response_log_probs(
    model: AutoModelForCausalLM,
    input_ids: torch.Tensor,
    labels: torch.Tensor,
    return_token_entropy: bool = False,
) -> dict[str, torch.Tensor]:
    """参数:
    - model:PreTrainedModel,用于评分的HuggingFace模型（若无需计算梯度,需放置在正确设备上并处于推理模式）。
    - input_ids:torch.Tensor,形状为（batch_size, sequence_length）,由分词方法生成的拼接后的提示词+响应token。
    - labels:torch.Tensor,形状为（batch_size, sequence_length）,由分词方法生成的标签。
    - return_token_entropy:bool,若为True,通过调用`compute_entropy`额外返回逐token熵。

    返回值:
    - dict[str, torch.Tensor]:
    - "log_probs":形状为（batch_size, sequence_length）,条件对数概率\(log p_{\theta}(x_t | x_{<<t})\)。
    - "token_entropy"（可选）:形状为（batch_size, sequence_length）,每个位置的逐token熵（仅当return_token_entropy=True时存在）。
    """
    logits = model(input_ids).logits  # b l v
    log_probs_all = torch.log_softmax(logits, dim=-1)  # b l v
    
    log_probs = torch.gather(
        log_probs_all, 
        dim=-1, 
        index=labels.unsqueeze(-1)
    ).squeeze(-1)  # b l
    
    if return_token_entropy:
        entropy = compute_entropy(logits)  # b l
        return {
            "log_probs": log_probs,
            "token_entropy": entropy,
        }
    else:
        return {
            "log_probs": log_probs,
            "token_entropy": None,
        }
```

### 问题（masked_normalize）：掩码归一化（1分）

实现masked_normalize方法，在考虑布尔掩码的前提下，对张量元素求和并通过常数进行归一化。

```python
def masked_normalize(
    tensor: torch.Tensor,
    mask: torch.Tensor,
    normalize_constant: float,
    dim: int | None = None,
) -> torch.Tensor:
    """
    对指定维度求和并通过常数归一化，仅考虑掩码中值为1的元素。
    sum(tensor)/constant

    参数：
    - tensor：torch.Tensor，需求和并归一化的张量。
    - mask：torch.Tensor，与tensor形状相同；值为1的位置会被纳入求和范围。
    - normalize_constant：float，用于归一化的除数常数。
    - dim：int | None，归一化前要求和的维度；若为None，对所有维度求和。

    返回值：
    - torch.Tensor，归一化后的和，其中掩码元素（mask == 0）不参与求和。
    """
    masked_tensor = tensor * mask
    summed = masked_tensor.sum(dim=dim,keepdim=True)
    norm = summed / normalize_constant
    return norm.sum(dim=dim)
```

### 问题（sft_microbatch_train_step）：Microbatch train step (3 points)

实现监督微调（SFT）的单个微批次更新，包括交叉熵损失计算、掩码求和及梯度缩放。
实现提示 需在该函数中调用loss.backward()，确保根据梯度累积进行调整。

```python
def sft_microbatch_train_step(
    policy_log_probs: torch.Tensor,
    response_mask: torch.Tensor,
    gradient_accumulation_steps: int,
    normalize_constant: float = 1.0,
) -> tuple[torch.Tensor, dict[str, torch.Tensor]]:
    """
    对微批次执行前向传播和反向传播。
	
	参数：
	- policy_log_probs：形状为（batch_size, sequence_length），来自待训练监督微调（SFT）策略的逐token对数概率。
	- response_mask：形状为（batch_size, sequence_length），响应token对应位置为1，提示词/填充token对应位置为0。
	- gradient_accumulation_steps：每个优化器步骤对应的微批次数量。
	- normalize_constant：用于除法归一化的常数，默认设为1.0即可。
	
	返回值：
	- tuple[torch.Tensor, dict[str, torch.Tensor]]：
	  - loss：标量张量，微批次损失（已根据梯度累积进行调整），返回该值用于日志记录。
	  - metadata：字典，包含底层损失调用的元数据及其他需记录的统计信息。
    """
    # SFT的目标函数:-log(y|x)

    loss = - masked_normalize(
        tensor = policy_log_probs,
        mask = response_mask,
        normalize_constant = normalize_constant,
        dim=-1,
    ).mean()
    scaled_loss = loss / gradient_accumulation_steps
    scaled_loss.backward()
    
    return scaled_loss,{
        'loss': scaled_loss,
        'unscaled_loss': loss,
    }
```

### 问题（log_generations）：生成结果日志记录（1分）
实现log_generations函数，用于记录模型的生成结果。建议为每个示例至少记录以下内容：
+ 输入提示词。
+ 监督微调（SFT）/强化学习（RL）模型生成的响应。
+ 真实答案。
+ 奖励信息，包括格式、答案及总奖励。
+ 响应的平均token熵。
+ 平均响应长度、正确响应的平均长度及错误响应的平均长度。
---
+ 注意**entropy和loss损失的计算要考虑掩码**，不要把掩码部分也包括。
+ 可以考虑使用`masked_normalize`计算损失总和。
```python
@torch.no_grad()
def log_generation(
    prompts: list[str],
    ground_truths: list[str],
    reward_fn: Callable,
    model: AutoModelForCausalLM,
    tokenizer:AutoTokenizer,
    vllm:LLM,
    sampling_params,
):
    device = next(model.parameters()).device
    responses = generate_responses(
        vllm,
        prompts,
        sampling_params,
    )

    reward_dicts = [reward_fn(resp, gt) for resp, gt in zip(responses, ground_truths)]

    total_rewards = torch.tensor([float(d["reward"]) for d in reward_dicts])
    fmt_rewards = torch.tensor([float(d["format_reward"]) for d in reward_dicts])
    ans_rewards = torch.tensor([float(d["answer_reward"]) for d in reward_dicts])
    correct = total_rewards == 1.0

    # 必须使用model来生成token_entropy,因为vllm不支持返回所有词表的logprobs
    inputs = tokenize_prompt_and_output(
        prompts,
        responses,
        tokenizer,
    )
    input_ids, labels, response_mask = inputs["input_ids"], inputs["labels"], inputs["response_mask"]

    # 获得logprobs:
    model.eval()
    out = get_response_log_probs(
        model,
        input_ids=input_ids.to(device),
        labels=labels.to(device),
        return_token_entropy=True,
    )
    ent = out["token_entropy"].cpu()

    res_len = response_mask.sum(dim=1).type_as(total_rewards)  # Number of response tokens per sample
    avg_ent = (ent * response_mask.type_as(ent)).sum(dim=1) / res_len # b l-> b

    rows = [
        {
            "prompt": p,
            "response": r,
            "true_answer": gt,
            "total_reward": float(tr.item()),
            "format_reward": float(fr.item()),
            "answer_reward": float(ar.item()),
            "is_correct": bool(c.item()),
            "response_length": int(rl.item()),
            "avg_token_entropy": float(ae.item()),
        }
        for p, r, gt, tr, fr, ar, c, rl, ae in zip(
            prompts,
            responses,
            ground_truths,
            total_rewards,
            fmt_rewards,
            ans_rewards,
            correct,
            res_len,
            avg_ent,
        )
    ]

    summary = {
        "avg_reward": float(total_rewards.float().mean().item()),
        "avg_token_entropy": float(avg_ent.mean().detach().cpu().item()),
        "avg_resp_len": float(res_len.float().mean().item()),
        "avg_len_correct": float(res_len[correct].float().mean().item()) if correct.any() else 0.0,
        "avg_len_wrong": float(res_len[~correct].float().mean().item()) if (~correct).any() else 0.0,
        "n_examples": len(prompts),
    }

    model.train()
    return {"summary": summary, "rows": rows}
```
## 4.3 SFT Experiment

利用上述模块，现在将实现完整的监督微调（SFT）流程（算法1），在MATH数据集上微调Qwen 2.5 Math 1.5B Base模型。/data/a5-alignment/MATH/sft.jsonl中的每个示例包含 formatted prompt 和 target response，其中 target response 包括思维链推理过程和最终答案。具体而言，每个示例是一个JSON元素，格式为{"prompt": str, "response": str}。

为跟踪模型在训练过程中的进度，需定期在MATH验证集上评估模型。运行脚本时需使用2块GPU：一块用于策略模型，另一块用于vLLM实例以评估策略。以下是初始化vLLM并在每次rollout阶段前将策略权重加载到vLLM实例的 starter 代码：

### 问题（sft_experiment）：在MATH数据集上运行监督微调（SFT）（2分）（2个H100小时）

使用Qwen 2.5 Math 1.5B基础模型，在推理型监督微调（SFT）示例（路径：/data/a5-alignment/MATH/sft.jsonl）上运行监督微调（SFT），监督微调（SFT）的唯一示例数量在{128, 256, 512, 1024}范围内变化，同时也使用完整数据集。调整学习率和批次大小，确保使用完整数据集时验证准确率至少达到15%。
交付要求：不同数据集大小对应的验证准确率曲线。
过滤推理型监督微调（SFT）示例，仅保留能产生正确答案的示例。在（完整的）过滤后数据集上运行监督微调（SFT），报告过滤后数据集的大小及达到的验证准确率。
交付要求：报告数据集大小及验证准确率曲线，并与之前的监督微调（SFT）实验结果进行对比。

### 数据集代码
+ 返回类型：`List[str]`
+ 通过`sft_collate_fn`函数转换为id和tensor。

```python
def sft_collate_fn(batch: List[Tuple[str, str]], tokenizer: AutoTokenizer) -> Dict[str, Any]:
    """
    用于SFT数据集的批处理函数，将一批样本整理成模型输入格式。
    Example:
        >>> batch = [("What is 2+2?", "4"), ("What is capital of France?", "Paris")]
        >>> model_inputs = sft_collate_fn(batch, tokenizer)
        >>> print(model_inputs.keys())
        dict_keys(['input_ids', 'attention_mask', 'labels'])
    """
    # 解压批次数据，将prompts和ground_truths分开
    prompts, ground_truths = zip(*batch)
    
    # 将文本列表转换为模型输入格式
    return tokenize_prompt_and_output(
        prompt_strs=list(prompts),
        output_strs=list(ground_truths),
        tokenizer=tokenizer
    )

class SFTDataset(Dataset):
    """
    监督微调（Supervised Fine-Tuning）数据集类。
    """
    def __init__(
        self,
        json_path: str,
        prompt_template_path: str,
    ) -> None:
        self.json_path = json_path
        self.template = load_template(prompt_template_path)
        
        # 从JSON文件加载并格式化prompts和ground_truths
        self.prompts = get_r1_prompts(self.json_path, self.template)

        # 用于训练的ground_truths
        self.ground_truths = get_r1_ground_truths_with_template(self.json_path)

        # 用于验证的ground_truths（仅包含答案）
        self.answers = get_r1_ground_truths(self.json_path)
        
        # 确保数据长度一致
        assert len(self.prompts) == len(self.ground_truths), \
            f"Prompts length ({len(self.prompts)}) does not match ground_truths length ({len(self.ground_truths)})"
    
    def __len__(self) -> int:
        return len(self.prompts)
    
    def __getitem__(self, idx: int) -> Tuple[str, str]:
        """
        Example:
            >>> prompt, ground_truth = dataset[0]
            Prompt: Question: What is the capital of France?\nAnswer:
            Ground truth: Paris
        """
        return self.prompts[idx], self.ground_truths[idx]
```

### cosine学习率函数

```python
def get_lr_cosine_schedule_with_warmup(
    it: int,
    max_lr: float,
    min_lr: float,
    warmup_iters: int,
    cosine_schedule_iters: int,
) -> float:
    """
    带有预热（warmup）的余弦退火学习率调度函数。
    该函数实现了一个三段式的学习率调度策略：
    1. Warmup阶段：学习率从0线性增加到max_lr
    2. Cosine decay阶段：学习率按照余弦函数从max_lr下降到min_lr
    3. 退火结束后：保持min_lr不变
    """
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

### SFTTrainer的定义

```python
class SFTTrainer:
    def __init__(
        self,
        model: AutoModelForCausalLM,
        tokenizer : AutoTokenizer,
        optimizer : torch.optim.Optimizer,
        config: SFTConfig, 
        vllm: LLM = None,
    ):
        # AutoModelFromPretrained:训练模型
        self.model = model
        self.tokenizer = tokenizer
        self.optimizer = optimizer
        self.config =  config
        
        # vllm：离线推理模型
        self.vllm = vllm

        # Dataset
        self.train_dataset =  SFTDataset(
            json_path = config.train_dataset_path,
            prompt_template_path=config.prompt_template_path,
        )

        self.test_dataset = SFTDataset(
            json_path = config.test_dataset_path,
            prompt_template_path=config.prompt_template_path,
        )
        # 将train_dataset保存为内存中,使用sft_collate_fn加载到GPU中
        # 非循环迭代器
        self.dataloader = DataLoader(
            dataset = self.train_dataset,
            batch_size = config.batch_size ,
            shuffle = True,
            drop_last = False,
            collate_fn= lambda batch: sft_collate_fn(batch,self.tokenizer)
        )
        # 变成循环迭代器
        self.data_iter = itertools.cycle(self.dataloader)
```

### 采样函数
+ 注意：采样的是answer，纯答案。
+ **奖励函数只支持纯答案作为ground_truth!**

```python
    @torch.no_grad()
    def sample_responses(self)->tuple[List[str],List[str]]:
        assert len(self.test_dataset.prompts) == len(self.test_dataset.answers), \
    f"数据集长度不匹配: prompts {len(self.test_dataset.prompts)} vs answers {len(self.test_dataset.answers)}" 
        indices = range(len(self.test_dataset.prompts))
        sampled_indices = random.sample(indices,self.config.sample_size)
        sampled_prompts = [self.test_dataset.prompts[idx] for idx in sampled_indices]
        sampled_answers = [self.test_dataset.answers[idx] for idx in sampled_indices]
        return sampled_prompts,sampled_answers
```
### SFTTrainer.train和SFTTrainer.train_step方法
+ 进行梯度累积的函数，注意更新学习率和梯度裁剪

```python
def train_step(self)->dict[str:float,str:float]:
    # 每一个梯度累积算一次step
        # eval metrics
        total_batch_loss = 0.0
        total_batch_entropy = 0.0
        total_valid_tokens = 0.0

        for step in range(self.config.gradient_accumulation_steps):
            inputs = next(self.data_iter)
            input_ids = inputs['input_ids'].to(self.model.device)
            labels = inputs['labels'].to(self.model.device)
            response_mask = inputs['response_mask'].to(self.model.device)

            # 有效的tokens数量: 用于计算平均token熵

            
            log_probs_entropy = get_response_log_probs(
                model = self.model,
                input_ids = input_ids,
                labels = labels,
                return_token_entropy= True,
            )

            policy_log_probs = log_probs_entropy['log_probs']

            with torch.no_grad():
                valid_tokens = response_mask.sum().item()
                entropy = log_probs_entropy['token_entropy'] # b l
                masked_entropy = entropy * response_mask

            scaled_loss,metadata = sft_microbatch_train_step(
                policy_log_probs= policy_log_probs,
                response_mask = response_mask,
                gradient_accumulation_steps= self.config.gradient_accumulation_steps,
                normalize_constant=self.config.normalize_constant,
            )# 已经反向传播
            # TODO
            # # eval metrics
            total_batch_loss += scaled_loss.item()
            total_batch_entropy += masked_entropy.sum().item()# b l -> 1
            total_valid_tokens += valid_tokens
            del input_ids,labels,response_mask,log_probs_entropy,policy_log_probs,masked_entropy

        avg_batch_loss = total_batch_loss / (self.config.gradient_accumulation_steps)
        avg_batch_entropy = total_batch_entropy / (total_valid_tokens+1e-6)
        
        torch.nn.utils.clip_grad_norm_(
                self.model.parameters(),
                max_norm = self.config.max_grad_norm,
                norm_type=2
            )
        self.optimizer.step()
        self.optimizer.zero_grad(set_to_none=True)

        return {
            'avg_batch_entropy':avg_batch_entropy,
            'avg_batch_loss':avg_batch_loss,
        }
```

```python
    def train(self):
        print(f"🚀 Starting training from iteration {self.config.start_iters} to {self.config.max_iters}")
        print(f"📊 Training configuration: batch_size={self.config.batch_size}, gradient_accumulation_steps={self.config.gradient_accumulation_steps}")
        print(f"💾 Checkpoints will be saved every {self.config.save_interval} steps to {self.config.save_dir}")
        print(f"📈 Evaluation will be performed every {self.config.eval_interval} steps\n")
        log_dict = {}
        for it in range(self.config.start_iters,self.config.max_iters):
            self.model.train()
            self.update_lr(it,self.optimizer)
            train_step_log = self.train_step()

            if it % 10 == 0:  # 每10步打印一次训练状态
                current_lr = self.optimizer.param_groups[0]['lr']
                print(f"⏱️  Iteration {it}/{self.config.max_iters} | Loss: {train_step_log['avg_batch_loss']:.4f} | Entropy: {train_step_log['avg_batch_entropy']:.4f} | LR: {current_lr:.2e}")

            log_dict ['train_avg_loss'] = train_step_log['avg_batch_loss']
            log_dict ['train_avg_token_entropy'] = train_step_log['avg_batch_entropy']


            if it % self.config.eval_interval == 0 or it == self.config.max_iters-1:
                # 必须部署vllm
                load_policy_into_vllm_instance(self.model,self.vllm)
                sampled_prompts, sampled_answers = self.sample_responses()

                # 对于sampled的结果进行输出
                sampled_overview = log_generation(
                    sampled_prompts,
                    sampled_answers,
                    self.config.reward_fn,
                    self.model,
                    self.tokenizer,
                    self.vllm,
                    self.config.sampling_params,
                )
                sampled_summary = sampled_overview['summary']

                log_dict['sampled_avg_reward'] = sampled_summary['avg_reward']
                log_dict['sampled_avg_token_entropy'] = sampled_summary['avg_token_entropy']
                log_dict['sampled_avg_resp_len'] = sampled_summary['avg_resp_len']
                log_dict['sampled_avg_len_correct'] = sampled_summary['avg_len_correct']
                log_dict['sampled_avg_len_wrong'] = sampled_summary['avg_len_wrong']
                print(f"✨ Sampled responses summary: Avg Reward={sampled_summary['avg_reward']:.4f}, Avg Resp Len={sampled_summary['avg_resp_len']:.2f}")
                print(sampled_overview)

                print(f"🧪 Running full test evaluation...")
                test_overview = self.evaluate()
                log_dict['eval_answer_correct'] = test_overview['answer_correct']
                log_dict['eval_format_correct'] = test_overview['format_correct']
                log_dict['eval_total_correct'] = test_overview['total_correct']
                log_dict['eval_format_correct_but_answer_wrong'] = test_overview['format_correct_but_answer_wrong']
                log_dict['eval_answer_correct_but_format_wrong'] = test_overview['answer_correct_but_format_wrong']
                log_dict['eval_total_wrong'] = test_overview['total_wrong']  
                log_dict['eval_accuracy'] = test_overview['accuracy']
                log_dict['eval_wrong_rate'] = test_overview['wrong_rate']
                print(f"📊 Test results - Accuracy: {test_overview['accuracy']:.2%}, Correct: {test_overview['total_correct']}, Wrong: {test_overview['total_wrong']}")
                print(test_overview)
                wandb.log(log_dict,step=it)
            
            if it > 0 and (it % self.config.save_interval == 0 or it == self.config.max_iters-1):
                print(f"\n💾 Saving checkpoint at iteration {it}...")
                os.makedirs(self.config.save_dir,exist_ok=True)
                save_it_dir = os.path.join(self.config.save_dir,f'checkpoint_{it}')
                os.makedirs(save_it_dir,exist_ok=True)
                self.save_checkpoint(save_it_dir)
                print(f"✅ Checkpoint saved to {save_it_dir}\n")
                
        wandb.finish()
```

### SFT的最终训练代码

```python
from torch.utils.data import Dataset,DataLoader
from typing import Tuple, List, Dict, Any, Optional
from transformers import AutoModelForCausalLM, AutoTokenizer
import itertools
from utils import load_template,get_r1_prompts,get_r1_ground_truths_with_template,get_device,seed_everything
from dataclasses import dataclass
import torch
from vllm import LLM,SamplingParams
from vllm_utils import init_vllm,load_policy_into_vllm_instance,log_generation,evaluate_vllm
import random
from sft import *
import wandb
import os
from drgrpo_grader import r1_zero_reward_fn
from sft_trainer import SFTTrainer
from sft_config import SFTConfig
os.environ["WANDB_API_KEY"] = 'wandb_xxx'
import argparse
def parse():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--json_path",
        type=str,
        help="json path of the SFTConfig",
    )
    args = parser.parse_args()
    return args

# 使用args进行解析
args = parse()

# 配置config
config = SFTConfig.from_json(args.json_path)

# seed
seed = seed_everything(config.seed)

# wandb
import wandb
wandb.login()
wandb.init(
    project = config.project_name,
    name = config.name,
    config = config,
)


# 设备
device1 = get_device(0)
device2 = get_device(1)


# 训练模型
model_name ='model/Qwen2.5-Math-1.5B'
model = AutoModelForCausalLM.from_pretrained(
        pretrained_model_name_or_path=model_name,
        torch_dtype=torch.bfloat16,
        attn_implementation="flash_attention_2",
        device_map=device1,# device 1
)
tokenizer = AutoTokenizer.from_pretrained(model_name)
optimizer = torch.optim.AdamW(model.parameters(), lr=config.max_lr, weight_decay=config.weight_decay, betas = config.betas, eps = config.eps)

# vllm离线推理模型
vllm = init_vllm(model_name,device=device2,seed=config.seed)

# trainer
trainer = SFTTrainer(
    model,
    tokenizer,
    optimizer,
    config,
    vllm)



trainer.train()
wandb.finish()

```



### 实验结果
+ 最高eval准确率约为38%
+ format格式正确率超过90%
+ train_loss的对比其实不公平，数据集的数量和难度不一致。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/223e67fad33e4aa08e6277a5edfb3802.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/24b522d8df754ad7afd9012d9abfcb69.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/114bfcf4b57b49e39f82181e1f9f2cb8.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2154c037700b4ef7b1640d136ec2a209.png){: referrerpolicy="no-referrer" }

### 实验结论
+ 数据集不是越大越好。仅保留少量样本的数据集在评估准确率上远远高于完整的数据集。
+ 使用原先就正确的示例进行训练，效果优于完整数据集。

# 5 MATH数据集的专家迭代
在上一节中，我们发现通过从监督微调（SFT）数据中过滤掉不良示例，可以提升监督微调（SFT）模型的性能。本节将进一步优化：将该过滤流程应用于基础模型自身生成的推理轨迹。这一过程在文献中被称为专家迭代（expert iteration）[Anthony et al., 2017]，在语言模型领域，Cobbe et al. [2021b]、Zelikman et al. [2022]、Dohan et al. [2022]、Gulcehre et al. [2023] 等学者已对此进行了探索。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0016fc26dbc540c28d709074b78c17d6.png){: referrerpolicy="no-referrer" }

接下来，我们将在MATH数据集上运行专家迭代。
小提示, 需为vLLM的SamplingParams传入min_tokens参数，确保不会生成空字符串（否则可能导致后续实现中出现NaN值）。具体设置如下：
与监督微调（SFT）相同，需使用梯度裁剪，裁剪值设为1.0。

### 问题（expert_iteration_experiment）：在MATH数据集上运行专家迭代（2分）（6个H100小时）
无需尝试所有超参数组合，只需进行足够多的实验以对每个超参数的影响得出合理结论即可。在训练过程中，请记录模型生成回答response的熵（entropy）变化情况。此外，请确保使用 vLLM 进行推理时，在遇到第二个答案标签 </answer> 时终止生成，这一处理方式应与监督微调（SFT）部分保持一致。

实验中需调整以下超参数：
+ 每个问题的 rollout 数量 (G)；
+ 监督微调（SFT）步骤中使用的训练轮数（epochs）；
+ 每次专家迭代步骤中的batch_size（即D的大小），在 {512, 1024, 2048} 中选择。

交付成果：
+ 不同滚动配置对应的验证准确率曲线。至少尝试2种不同的滚动次数和轮数。
+ 在MATH数据集上验证准确率至少达到15%的模型。
+ 简要的两句话讨论：对比SFT的性能，以及不同EI（专家迭代）步骤下的性能。
+ 训练过程中模型响应熵值的图表。

### EI专用的采样参数
+ **关键要设置`n>1`**，这样vllm会对同一prompt进行多轮推理，采样多个回答。

```python
self.ei_sampling_params = SamplingParams(
temperature=self.ei_temperature,
top_p=self.ei_top_p,
stop=self.ei_stop,
seed=self.seed,
include_stop_str_in_output=self.ei_include_stop_str_in_output,
max_tokens=self.ei_max_tokens,
min_tokens=self.ei_min_tokens,
n=self.rollout_size,
)
```
### EIConfig的定义
+ 基本继承自SFTConfig，**采样参数进行EI专有化处理**。

```python
@dataclass
class EIConfig(SFTConfig):
    """
    EI（Expert Iteration）配置类。

    在 SFTConfig 的基础上增加 EI 相关的配置：
    - ei_iterations: 进行多少轮 Expert Iteration
    - rollout_size:  每个 prompt 进行多少次 rollout 采样
    - 其余字段（batch_size / lr / dataset 路径 / sampling_params / reward_fn 等）
      完全复用 SFTConfig 的定义和 __post_init__。
    """

    # EI 相关配置
    ei_iterations: int = 3       # Expert Iteration 的外层循环次数
    rollout_size: int = 4        # 每个 prompt 的 rollout 次数（vllm 采样次数）
    sft_sample_size: int = 128 

    # EI 专用采样配置（与 SFTConfig 中的 sampling 参数区分开）
    ei_temperature: float = 1.0
    ei_top_p: float = 1.0
    ei_max_tokens: int = 1024
    ei_stop: list = None
    ei_include_stop_str_in_output: bool = True
    ei_min_tokens: int = 32

    # 说明：sample_size(SFT评估阶段采样) vs sft_sample_size(SFT训练阶段样本数)
    # sampling_params参数不能继承SFTConfig, 采样需求不同
    

    # 其余字段全部从 SFTConfig 继承：
    def __post_init__(self) -> None:
        """
        重写版本：在 SFTConfig.__post_init__ 的基础上，使用 EIConfig 中的
        采样参数字段重新创建 sampling_params。
        """
        # 先执行父类逻辑：包括 seed、reward_fn 等初始化
        super().__post_init__()

        # 基于 EIConfig 的字段重新构造 SamplingParams，用于 EI 采样
        self.ei_sampling_params = SamplingParams(
            temperature=self.ei_temperature,
            top_p=self.ei_top_p,
            stop=self.ei_stop,
            seed=self.seed,
            include_stop_str_in_output=self.ei_include_stop_str_in_output,
            max_tokens=self.ei_max_tokens,
            min_tokens=self.ei_min_tokens,
            n=self.rollout_size,
        )
        # reward_fn 仍由 SFTConfig.__post_init__ 按 reward_fn_name 构造，
        # 比如默认为 r1_zero_reward_fn，不做修改。
```

### 生成rollout的函数
```python
def generate_rollouts(
    vllm:LLM,
    prompts:List[str],
    sampling_params:SamplingParams,
)->List[List[str]]:
    """
    对每个prompt生成多条响应（rollout）
    """
    outputs = vllm.generate(prompts, sampling_params)
    rollouts = [[o.text for o in output.outputs] for output in outputs]
    return rollouts
```


### EIDataset
+ **只在训练集中进行采样**，所以不包含测试集数据。
+ 基本可以继承自SFTDataset，同时定义`get_ei_batch`函数，**从训练集中采样n个条数据，每个数据采样m个回答，实现rollout**。

```python
# EIDataset: 在训练阶段用于替换SFTDataset
class EIDataset(SFTDataset):
    def __init__(
        self,
        vllm:LLM ,
        sampling_params: SamplingParams,# 温度不应该为1.0,需要有一定随机性
        reward_fn : Callable,
        json_path:str,# only training set
        prompt_template_path:str,
        sft_sample_size:int ,
    ):
        super().__init__(json_path,prompt_template_path)
        # vllm
        self.vllm = vllm
        self.sampling_params = sampling_params

        # rollout size is defined in sampling_params.n
        self.sft_sample_size = sft_sample_size
        self.reward_fn  = reward_fn
    def __len__(self):
        return super().__len__()
    def __getitem__(self, index):
        return super().__getitem__(index)
    
    @torch.no_grad()
    def sample_responses(self)->tuple[List[str],List[str]]:
        assert len(self.prompts) == len(self.answers), \
    f"数据集长度不匹配: prompts {len(self.prompts)} vs answers {len(self.answers)}" 
        indices = range(len(self.prompts))
        sampled_indices = random.sample(indices,self.sft_sample_size)
        sampled_prompts = [self.prompts[idx] for idx in sampled_indices]
        sampled_answers = [self.answers[idx] for idx in sampled_indices]
        return sampled_prompts,sampled_answers
    
    @torch.no_grad()
    def get_ei_batch(
        self,
    )->tuple[List[str],List[str],List[str]]:
        sampled_questions,sampled_answers = self.sample_responses()
        rollouts: List[List[str]] = generate_rollouts(self.vllm, sampled_questions, self.sampling_params)
        
        rollout_prompts = []
        rollout_ground_truths = []
        rollout_answers = []

        for i in range(len(rollouts)):
            # ith prompt,ith answer
            for response in rollouts[i]:
                reward_dict = self.reward_fn(response,sampled_answers[i],fast=True)
                if reward_dict['reward'] == 1.0:
                    rollout_prompts.append(sampled_questions[i])
                    rollout_ground_truths.append(response)
                    rollout_answers.append(sampled_answers[i])
        return rollout_prompts, rollout_ground_truths, rollout_answers
        
      
```

### EITrainer
+ 注重对于SFTTrainer的复用，因此我们需要在每一轮epoch中初始化SFTTrainer
+ 定义两个辅助函数`SFTDataset.from_prompts_and_ground_truths`和`SFTTrainer.from_ei_trainer`
+ 注意学习率使用的是**全局步数调度**，wandb也使用了**全局步数记录**。
+ 训练流程：进行EI epoch迭代，每一个迭代使用EIDataset中rollout出来的数据集**构造SFTTrainer的训练集**，然后复用SFTTrainer.train的方法。
```python
class SFTDatset:
	...
    @classmethod
    def from_prompts_and_ground_truths(cls,
        prompts:List[str],
        ground_truths:List[str],
        answers: List[str]
    ):
        assert len(prompts) == len(ground_truths) == len(answers), (
            f"Length mismatch: prompts={len(prompts)}, "
            f"ground_truths={len(ground_truths)}, answers={len(answers)}"
        )

        dummy = cls.__new__(cls)  # 空实例,跳过构造函数
        dummy.json_path = "<from_lists>"
        dummy.template = "<from_lists>"
        dummy.prompts = prompts
        dummy.ground_truths = ground_truths
        dummy.answers = answers
        return dummy
        
class SFTTrainer:
    ....
    @classmethod
    def from_ei_trainer(
        cls,
        ei_trainer,# EI Trainer
        train_dataset: SFTDataset,# from prompts and ground_truths
    ):
        dummy = cls.__new__(cls)  # 空实例,跳过构造函数
        dummy.model = ei_trainer.model
        dummy.tokenizer = ei_trainer.tokenizer
        dummy.optimizer = ei_trainer.optimizer
        dummy.config = ei_trainer.config
        dummy.vllm = ei_trainer.vllm

        # 初始化数据集
        dummy.train_dataset = train_dataset
        dummy.test_dataset = SFTDataset(
            json_path = dummy.config.test_dataset_path,
            prompt_template_path=dummy.config.prompt_template_path,
        )

        dummy.dataloader = DataLoader(
            dataset = dummy.train_dataset,
            batch_size = dummy.config.batch_size ,
            shuffle = True,
            drop_last = False,
            collate_fn= lambda batch: sft_collate_fn(batch,dummy.tokenizer)
        )
        # 变成循环迭代器
        dummy.data_iter = itertools.cycle(dummy.dataloader)
        return dummy

class EITrainer:
    def __init__(
        self,
        model: AutoModelForCausalLM,
        tokenizer : AutoTokenizer,
        optimizer : torch.optim.Optimizer,
        config: EIConfig, 
        vllm: LLM,
    ):
        # 模型和优化器配置
        self.model = model
        self.tokenizer = tokenizer
        self.optimizer = optimizer
        self.config =  config
        
        # vllm：离线推理模型
        self.vllm = vllm
        self.ei_dataset =  EIDataset(
            vllm = vllm,
            sampling_params = self.config.ei_sampling_params,
            reward_fn = self.config.reward_fn,
            json_path = self.config.train_dataset_path,
            prompt_template_path=self.config.prompt_template_path,
            sft_sample_size = self.config.sft_sample_size
        )
    def train(self):
        global_start_step = 0
        for iteration in range(self.config.ei_iterations):
            load_policy_into_vllm_instance(self.model,self.vllm)# \theta_old
            rollout_prompts, rollout_ground_truths, rollout_answers = self.ei_dataset.get_ei_batch()# sample_responses -> vllm evaluate
            if len(rollout_prompts) == 0:
                print(f"Iteration {iteration+1}: No valid samples obtained for SFT training. Skipping this iteration.")
                continue

            print(f"Iteration {iteration+1}: obtained {len(rollout_prompts)} valid samples for SFT training.")

            # 从现有prompt和ground_truths中构建一个新的SFT数据集
            train_dataset = SFTDataset.from_prompts_and_ground_truths(
                prompts=rollout_prompts,
                ground_truths=rollout_ground_truths,
                answers=rollout_answers,
            )

            sft_trainer = SFTTrainer.from_ei_trainer(
                ei_trainer=self,
                train_dataset=train_dataset,
            )
            
            sft_trainer.train(global_start_step)
            global_start_step += self.config.max_iters # +=60

            # 缓存清理
            clear_gpu_memory()

            # 只保存最后一个迭代的模型
            if iteration == self.config.ei_iterations-1:
                # 显示调用save_checkpoint. train函数中save_interval设置为无穷大
                os.makedirs(self.config.save_dir, exist_ok=True)
                save_it_dir = os.path.join(self.config.save_dir,f'EI_iteration_{iteration+1}')
                os.makedirs(save_it_dir, exist_ok=True)
                sft_trainer.save_checkpoint(path=save_it_dir)
```
###  最终训练代码
+ 与SFT训练代码一致。


```python
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch
from vllm import LLM,SamplingParams
from vllm_utils import *
from utils import *
from ei_config import EIConfig
from sft_config import SFTConfig
import os
from sft import *
from sft_trainer import *
from drgrpo_grader import r1_zero_reward_fn
import wandb
os.environ["WANDB_API_KEY"] = 'wandb_xxxx'

import argparse
def parse():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--json_path",
        type=str,
        help="json path of the EIConfig",
    )
    args = parser.parse_args()
    return args
# 使用args进行解析
args = parse()

# 配置config
config = EIConfig.from_json(args.json_path)

seed = seed_everything(config.seed)

# wandb
import wandb
wandb.login()
wandb.init(
    project = config.project_name,
    name = config.name,
    config = config,
)

# 设备
device1 = get_device(1)
device2 = get_device(2)

# 训练模型
model_name ='model/Qwen2.5-Math-1.5B'
model = AutoModelForCausalLM.from_pretrained(
        pretrained_model_name_or_path=model_name,
        torch_dtype=torch.bfloat16,
        attn_implementation="flash_attention_2",
        device_map=device1,# device 1
)
tokenizer = AutoTokenizer.from_pretrained(model_name)
optimizer = torch.optim.AdamW(model.parameters(), lr=config.max_lr, weight_decay=config.weight_decay, betas = config.betas, eps = config.eps)

# vllm离线推理模型 GPU利用率不能太高
vllm = init_vllm(model_name,device=device2,seed=config.seed,gpu_memory_utilization=0.6)

trainer = EITrainer(
    model,
    tokenizer,
    optimizer,
    config,
    vllm,
)

trainer.train()
wandb.finish()
```
### 实验基本配置
+ **迭代总次数是一致的**
+ EI的epoch是5
+ 学习率和批次大小等超参数完全一致
+ **只改变了rollout大小和sft_sample_size**

```python
{
    "seed": 42,
    "project_name": "cs336-assignment5",
    "name": "EI-training-math-full-bs2-s512-r4",
    "batch_size": 2,
    "gradient_accumulation_steps": 64,
    "max_iters": 40,
    "start_iters": 0,
    "weight_decay": 1e-5,
    "betas": [
        0.9,
        0.98
    ],
    "eps": 1e-06,
    "max_lr": 5e-5,
    "min_lr": 5e-6,
    "warmup_iters": 20,
    "cosine_schedule_iters": 200,
    "max_grad_norm": 1.0,
    "normalize_constant": 1.0,
    "train_dataset_path": "preprocessed/math/train.jsonl",
    "test_dataset_path": "preprocessed/math/test.jsonl",
    "prompt_template_path": "cs336_alignment/prompts/r1_zero.prompt",
    "eval_interval": 10,
    "sample_size": 4,
    "save_interval": 500,
    "save_dir": "checkpoints/ei/math-full-bs2-s512-r4",
    "temperature": 1.0,
    "top_p": 1.0,
    "max_tokens": 1024,
    "stop": [
        "</answer>"
    ],
    "include_stop_str_in_output": true,
    "reward_fn_name": "r1_zero_reward_fn",
    "ei_iterations": 5,
    "rollout_size": 4,
    "sft_sample_size": 512,
    "ei_temperature": 0.8,
    "ei_top_p": 0.9,
    "ei_max_tokens": 1024,
    "ei_stop": [
        "</answer>"
    ],
    "ei_include_stop_str_in_output": true,
    "ei_min_tokens": 32
}
```

### 实验结果
+ 最高评估准确率约为42%，比SFT训练最好结果高5%左右
+ 格式正确率至少有95%，基本上不存在格式错误。
+ 熵值比较低，说明模型生成的多样性一般，**存在过拟合问题**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/72b2fa228f684d27a2cda735fb842ad8.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/53f1408f1b5d4cc5a4281f46f42817b9.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8397c01209024fc6b1ef221d8eace879.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/90484a4739914fd8a3f80b853ebc5bbc.png){: referrerpolicy="no-referrer" }

### 实验结论
+ 目前模型应该**存在严重的过拟合现象**，熵的值过低。
+ **增大sft_sample_size和rollout_size可以显著提高样本的多样性，增强模型的泛化性**，减少过拟合。例如增大sft_sample_size和rollout_size后llm的性能有提高。


# GRPO

## 问题（compute_grpo_clip_loss）：GRPO-Clip损失（2分）

+ 注意：我们一般得到的是`log_prob`，对于$\rho(\frac{a}{b})$的计算，使用**exp(loga-logb)** 的技巧
+ 原始的GRPO算法**还有一个KL散度的公式**，作为惩罚项。一般使用逐token的方式近似模型的**KL散度差别**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ce3715e10987429f826cb2c12779648e.png){: referrerpolicy="no-referrer" }

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a260f0dfccf14250b50cd9dbf278bc33.png){: referrerpolicy="no-referrer" }

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5c9ce2c795a24d03a3e155a487b658b2.png){: referrerpolicy="no-referrer" }



```cpp
def compute_grpo_clip_loss(
    advantages: torch.Tensor,
    policy_log_probs: torch.Tensor,
    old_log_probs: torch.Tensor,
    cliprange: float,
) -> tuple[torch.Tensor, dict[str, torch.Tensor]]:
    """    
    参数：
        advantages: 形状为(batch_size, 1)的张量，每个样本的优势值A
        policy_log_probs: 形状为(batch_size, sequence_length)的张量，待训练策略的逐token对数概率
        old_log_probs: 形状为(batch_size, sequence_length)的张量，旧策略的逐token对数概率
        cliprange: 裁剪参数ε（例如0.2）
    
    返回：
        tuple[torch.Tensor, dict[str, torch.Tensor]]:
            loss: 形状为(batch_size, sequence_length)的张量，逐token裁剪损失
            metadata: 需记录的元数据（建议记录每个token是否被裁剪，即min函数右侧的裁剪后损失是否小于左侧）
    """

    # ratio
    ratio = torch.exp(policy_log_probs - old_log_probs) # shape: b l

    # unclipped
    unclipped_part = ratio * advantages # b l

    # clipped 
    clipped_ratio = torch.clamp(ratio, 1.0 - cliprange, 1.0 + cliprange) # b l
    clipped_part = clipped_ratio * advantages # b l

    loss = -torch.min(unclipped_part, clipped_part) # b l

    is_clipped = (clipped_part > unclipped_part).float() # b l
    is_clipped_ratio = is_clipped.sum() / is_clipped.numel()
    metadata = {
        'is_clipped': is_clipped,# b l: float
        'is_clipped_ratio': is_clipped_ratio.item(), # 记录被裁剪的比例
    }
    return loss, metadata
```


## 问题（grpo_microbatch_train_step）：微批次训练步骤（3分）
+ 注意：调用`masked_mean`函数，计算**带掩码的平均损失**(先求和后除以有效元素)。

```cpp
def grpo_microbatch_train_step(
    policy_log_probs: torch.Tensor,
    response_mask: torch.Tensor,
    gradient_accumulation_steps: int,
    loss_type: Literal["no_baseline", "reinforce_with_baseline", "grpo_clip"],
    raw_rewards: torch.Tensor | None = None,
    advantages: torch.Tensor | None = None,
    old_log_probs: torch.Tensor | None = None,
    cliprange: float | None = None,
    normalize_by_length: True = True,
    normalize_constant: float = 1.0,
) -> tuple[torch.Tensor, dict[str, torch.Tensor]]:
    loss, metadata = compute_policy_gradient_loss(
        policy_log_probs=policy_log_probs,
        loss_type=loss_type,
        advantages=advantages,
        raw_rewards=raw_rewards,
        old_log_probs=old_log_probs,
        cliprange=cliprange,
    )

    # 这一步与标准的PPO/GRPO实现不同,\sum{i=1}^T log \pi(a_i|s_i)
    if normalize_by_length:
        masked_loss = masked_normalize(
            tensor = loss,
            mask = response_mask,
            normalize_constant = normalize_constant,
            dim = -1
        ).mean() # b -> 1
    else:
        masked_loss = masked_mean(
            tensor = loss,
            mask = response_mask,
            dim = -1,
        ).mean() # b -> 1

    # 梯度累积和反向传播
    scaled_loss = masked_loss / gradient_accumulation_steps
    scaled_loss.backward()
    
    metadata.update({
        'scaled_loss': scaled_loss.item(),# 1
        'loss': masked_loss.item(),# 1
    })
    return scaled_loss, metadata
```

## Off-policy的train_step函数
+ `rollout_size`：总共包含多个采样样本(包括重复的prompt)
+ `micro_batch_size`：**实际训练时的batch_size**，控制显存占用
+ 首先是**离线采样**：采用vllm采样多个回答，**要求这些回答的相对优势不能都为0**。采样到指定数量后，分`micro_batch_size`计算相对优势和对数概率`old_log_prob`(不需要梯度)。
+ 然后分每个`micro_bacth_size`计算`log_prob`，然后调用`grpo_microbatch_train_step`进行梯度累积。**每累积到一定次数的梯度时，进行梯度更新**。
+ 在线更新：遍历两边我们的离线采样样本，**然后在线更新策略模型**。很显然，我们的样本是VLLM中的示例采样得到的，但是**我们的策略模型一直在利用该样本进行更新**，因此我们的策略是**Off-policy的**。

```cpp
def train_step(self,global_it:int)->dict[str:float,str:float]:
        # eval metrics
        total_batch_loss = 0.0
        total_batch_entropy = 0.0
        gradient_update_step: int = 0

        # old policy model
        load_policy_into_vllm_instance(self.model, self.vllm)

        # get rollout_batch List[str]: rollout_batch_size
        rollout_prompts, rollout_responses, rollout_answers = self.train_dataset.get_rollout_batch()

        # 总共需要迭代的次数 32 = 256 // 8
        n_micro_batch = self.config.rollout_batch_size // self.config.micro_batch_size
        
        # 获得所有old_log_probs的列表 on CPU 
        old_log_probs_list: List[torch.tensor] = []
        input_ids_list: List[torch.tensor] = []
        labels_list: List[torch.tensor] = []
        response_mask_list: List[torch.tensor] = []
        advantages_list: List[torch.tensor] = []
        rewards_list: List[torch.tensor] = []

        # 预先获得所有microbatch
        for i in range(n_micro_batch):
            start_idx = i * self.config.micro_batch_size
            end_idx = start_idx + self.config.micro_batch_size
            micro_batch_prompts = rollout_prompts[start_idx:end_idx]
            micro_batch_responses = rollout_responses[start_idx:end_idx]
            micro_batch_answers = rollout_answers[start_idx:end_idx]

            micro_batch_advantages, micro_batch_raw_rewards , _ = compute_group_normalized_rewards(
                reward_fn=self.config.reward_fn,
                rollout_responses=micro_batch_responses,
                repeated_ground_truths=micro_batch_answers,
                group_size=self.config.group_size,
                advantage_eps=self.config.advantage_eps,
                normalize_by_std=self.config.normalize_by_std,
            )
            micro_batch_advantages = micro_batch_advantages.to(self.model.device)
            micro_batch_raw_rewards = micro_batch_raw_rewards.to(self.model.device)

            # input_ids, labels, response_mask
            inputs = tokenize_prompt_and_output(
                micro_batch_prompts, micro_batch_responses, self.tokenizer
            )
            input_ids = inputs['input_ids'].to(self.model.device)
            labels = inputs['labels'].to(self.model.device)
            response_mask = inputs['response_mask'].to(self.model.device)


            # old_log_probs
            with torch.inference_mode():# fast inference, no_grad
                old_log_probs_token_entropy = get_response_log_probs(# require_grad == False
                    model= self.model,
                    input_ids = input_ids,
                    labels = labels,
                    return_token_entropy=False)
                # 去除计算图
            
            # NOTE: 不需要常驻GPU
            micro_batch_advantages = micro_batch_advantages.to('cpu')
            micro_batch_raw_rewards = micro_batch_raw_rewards.to('cpu')
            advantages_list.append(micro_batch_advantages)
            rewards_list.append(micro_batch_raw_rewards)
            input_ids = input_ids.to('cpu')
            labels = labels.to('cpu')
            response_mask = response_mask.to('cpu')
            input_ids_list.append(input_ids)
            labels_list.append(labels)
            response_mask_list.append(response_mask)
            old_log_probs = old_log_probs_token_entropy['log_probs'].detach().to('cpu')
            old_log_probs_list.append(old_log_probs)
            
        clear_gpu_memory()

        for epoch in range(self.config.n_train_steps_per_rollout_batch):
            for i in range(n_micro_batch):
                input_ids = input_ids_list[i].to(self.model.device)
                labels = labels_list[i].to(self.model.device)
                response_mask = response_mask_list[i].to(self.model.device)
                advantages = advantages_list[i].to(self.model.device)
                raw_rewards = rewards_list[i].to(self.model.device)
                old_log_probs = old_log_probs_list[i].to(self.model.device)

                # policy_log_probs: torch.tensor: b*g l
                policy_log_probs_token_entropy = get_response_log_probs(
                    model= self.model, 
                    input_ids = input_ids,
                    labels = labels,
                    return_token_entropy=False# save GPU memory   
                )
                policy_log_probs = policy_log_probs_token_entropy['log_probs'].to(self.model.device)
                
                # 函数包含反向传播, 更新策略模型 
                scaled_loss,loss_metadata = grpo_microbatch_train_step(
                    policy_log_probs = policy_log_probs,
                    response_mask = response_mask,
                    gradient_accumulation_steps=self.config.gradient_accumulation_steps,
                    loss_type = self.config.loss_type,
                    raw_rewards = raw_rewards,
                    advantages = advantages,
                    old_log_probs = old_log_probs,
                    cliprange= self.config.clip_range,
                    # 长度归一化 Dr.GRPO
                    normalize_by_length= self.config.normalize_by_length,
                    normalize_constant = self.config.normalize_constant
                )
                total_batch_loss += scaled_loss.item()
                gradient_update_step += 1

                # 每隔 gradient_accumulation_steps步进行一次梯度更新
                if gradient_update_step % self.config.gradient_accumulation_steps ==0:
                    # 梯度累积更新
                    torch.nn.utils.clip_grad_norm_(
                        self.model.parameters(),
                        max_norm = self.config.max_grad_norm,
                        norm_type=2
                    )
                    self.optimizer.step()
                    self.optimizer.zero_grad(set_to_none=True)  
                del input_ids, labels, response_mask, advantages, raw_rewards
                del old_log_probs, policy_log_probs, policy_log_probs_token_entropy
                # clear_gpu_memory()# -6k
        
        avg_batch_loss = total_batch_loss 
        avg_batch_entropy = total_batch_entropy / self.config.gradient_accumulation_steps
        # 缓存清理
        clear_gpu_memory()
        return {
            'avg_batch_entropy':avg_batch_entropy,
            'avg_batch_loss':avg_batch_loss,
        }

```



