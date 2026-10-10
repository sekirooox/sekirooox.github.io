---
title: "论文精读·Crowd Comparative Reasoning: Unlocking Comprehensive Evaluations for LLM-as-a-Judge"
author: MayL
date: 2025-10-05
categories: ["论文阅读与科研", "大模型评测"]
tags: ["大模型评测", "llm", "llm-as-a-judge", "论文阅读"]
render_with_liquid: false
description: "本文记录“论文精读·Crowd Comparative…”的研究问题、主要方法与实验结论，便于理解论文并开展后续研究。"
---

这篇论文题为 **《Crowd Comparative Reasoning: Unlocking Comprehensive Evaluations for LLM-as-a-Judge》**（Zhang et al., ACL 2025）。以下是其研究动机、研究方法与主要贡献的系统概括：

---

# 研究动机

近年来，“**LLM-as-a-Judge**” 已成为自动化评估生成式AI输出（如回答质量、对齐度）的重要框架。它依赖大型语言模型通过**链式思维（CoT, Chain-of-Thought）**推理生成判断。然而，作者指出目前存在两个核心问题：

1. **CoT推理缺乏全面性与深度**：模型往往只关注部分细节，导致评估结果片面或不完整。
2. **现有改进方法不足**：

   * **多数投票（majority voting）** 虽能增加推理多样性，但代价高且被动。
   * **评价准则扩展（criteria expansion）** 可引导模型考虑更多维度，但缺乏针对具体响应的适应性。

这些限制使得LLM-as-a-Judge的判断仍不如人工评估可靠。因此，论文的动机是：

> **如何让模型在评估时进行更细致、更全面的比较推理，以提升自动评估的可靠性与一致性？**

---

# 研究方法
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e9b528e2dd6e4a398f66e16e1e5490d5.png){: referrerpolicy="no-referrer" }


论文提出一种新框架 **Crowd-based Comparative Evaluation（CCE）**，核心思想是引入“群众响应（crowd responses）”来扩展评估视角，让模型像人类一样通过与更多样的参考答案比较来获得更深层的理解。其流程如图1与图2（第1–4页）所示：

1. **生成群众响应（Crowd Response Generation）**

   * 给定任务指令 (x)，利用多个LLM（如Qwen、Mistral等）和不同温度参数生成多样化的响应集合。
   * 这些“crowd responses”作为评估锚点，用以揭示候选响应（A/B）中更多隐含细节。

2. **生成群众判断（Crowd Judgment Generation）**

   * 对每个crowd response，分别与候选响应A/B成对比较，得到若干初步的“群众判断”（CoT推理文本）。

3. **群众判断筛选与处理（Selection & Processing）**

   * 提出“**Criticizing Selection**”策略：保留A或B在比较中**失败的判断**，因为批评性的CoT通常更详细。
   * 再通过“**Outcome Removal**”移除判断结论部分，**减少偏见**。

4. **上下文增强推理（Context-augmented Inference）**

   * 将处理后的群众判断**作为上下文提**示，输入LLM以生成更全面、更深层的最终CoT评估。

---
## CCE
+ 作者提出的CCE方法不针对某个模型，是一种Prompt技巧，需要多个LLM生成群众响应，然后与候选响应两两比较，选择候选输的情况作为上下文。作者所使用的LLM如下(**用于生成群众响应，要求保持多样性**)：
+ 使用vanilla LLM来评审群众和候选相应
+ ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/cc57e6f7038b45c4b0f7cd7d2a7c4f25.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b594334705f64382854434eb62740753.png){: referrerpolicy="no-referrer" }
+ 作者也是选用了5个基准测试，分别对于5个模型应用CCE技术。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/844fdd4886244f698dc633c0aac6be0d.png){: referrerpolicy="no-referrer" }

CCE技术还扩展到蒸馏和微调两个场景：
## **Judge Distillation**：

+ 利用**CCE的COT** 蒸馏出更小的评估模型。
+ 与使用**Vanilla的LLM生成的COT**进行蒸馏的LLM作为对比。基准测试保持不变、
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a378cd7bd87c45c1a058086ca65e51c3.png){: referrerpolicy="no-referrer" }

## Crowd Rejection Sampling：
+ 改进SFT（监督微调）中的拒绝采样，筛选出更优质的训练样本。
+ 其中SFT中的拒绝采样指的是从多个LLM模型：GPT-4o, DeepSeek-v3, Claude-3.5-Sonnet, and Qwen 2.572B-Instruct.的回答中两两比较，挑选**胜率最大的回答作为标签**。
+ 在此基础上，作者将**胜率最低的两个LLM**作为群众回答，按照CCE的步骤，获得4个模型中最优的回答。
+ 可见作者是在llama3.1 8B和Qwen 2.5 7B上作为基础模型，**剩余模型作为群众模型**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/873ecf7ae94249ad8feda74451667986.png){: referrerpolicy="no-referrer" }

---

# 主要贡献（Main Contributions）

论文的核心贡献体现在三个方面：

1. **提出创新性框架 CCE**

   * 首次将“群众比较推理”引入LLM评估过程，通过多样化比较上下文增强CoT的全面性和细腻度。
   * 模仿人类评估中的“对比-反思”机制，让模型自动挖掘响应中的深层细节。

2. **显著提升评估可靠性与泛化能力**

   * 在五个公开基准（RewardBench、HelpSteer2、MTBench-Human、JudgeBench、EvalBias）上平均提升 **6.7%** 准确率。
   * 生成的CoT更长、更全面，细节覆盖率显著提高（见图3与图4）。

3. **拓展应用与可扩展性**

   * 蒸馏实验显示：CCE生成的CoT使小型Judge模型（如Qwen2.5-7B）精度提升约 **4.5–5.6%**。
   * crowd rejection sampling 能有效提升SFT训练效率与结果质量。
   * 分析表明CCE在推理计算扩展时性能随之提升，具备良好的**scaling特性**。



