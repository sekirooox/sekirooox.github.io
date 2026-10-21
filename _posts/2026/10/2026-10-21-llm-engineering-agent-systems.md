---
title: "LLM·Agent 与工具系统"
date: 2026-10-21
categories: ["大语言模型与强化学习", "大语言模型"]
tags: ["llm", "agent", "mcp", "rag", "工具调用"]
description: "整理 ReAct、Plan-Act、Function Calling、MCP、RAG、Memory、Sub-Agent 与长期任务机制。"
published: false
math: true
---
# LLM·Agent 与工具系统

本文以原始笔记 `_posts/2026/03/2026-03-10-llm_agent.md` 为基础整理，完整保留概念说明、安装命令和 21 张配图，仅对术语、逻辑表述与标题层级做小幅修订。

## LLM Agent 与工具系统

> **整合修订说明**
>
> - 基础模型产生输出；真正执行工具并回传观察的是 Agent runtime。
> - Function Calling 包含结构化 schema、模型输出协议与运行时校验，不只是“特殊提示词”。
> - MCP 是 Host/Client 与 Server 之间进行能力发现与调用的协议；Host 不等同于 Agent。
> - Workflow 是固定或半固定的编排流程；Skill、Memory、Heartbeat 等属于常见工程模式或特定框架约定。
> - 原文中的 “Crob Job” 已修正为 “Cron Job”。

### Agent：智能体
+ 基础语言模型负责生成模型输出；真正读取环境、调用工具并改变外部状态的是 Agent runtime。
+ Agent 借用了强化学习中“智能体与环境交互”的概念，通过运行时形成**感知—决策—行动—反馈**闭环。
---
<br><br><br><br>
#### ReAct：推理-执行架构
执行流程：
+ 用户首先提交任务，然后LLM进行思考并输出应该做的行动；
+ Agent程序负责接受LLM的**请求**，**然后调用对应的工具**(实现上为python函数或者API接口)，返回观察结果
+ **用户的提示词+思考过程+返回的结果都会被传入LLM作为上下文**(堆叠上下文的方式)，然后LLM又会输出新的执行。
+ 直到 Agent runtime 或模型判断任务已经完成，再返回最终答案。


<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-react-liu-cheng.png" alt="Agent 工具系统" width="1107"><figcaption><p>ReAct 交互闭环</p></figcaption></figure>
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-react-shang-xia-wen.png" alt="Agent 工具系统" width="1107"><figcaption><p>上下文堆叠</p></figcaption></figure>
#### Plan-Act：规划-执行架构
+ Plan模型负责首先提出一个朴素但完整的计划
+ 执行Agent负责执行这个计划中的特定步骤，然后返回一个观察
+ Agent主程序**拼接用户输入+上一次输入的计划+上一次输出的观察**输入给Re-Plan模型
+ Replan模型会更新新的计划：**删除已经完成的部分**，对**剩余计划进行进一步细化**或者修改。
+ 重复此流程。
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-plan-act.png" alt="Agent 工具系统" width="1081"><figcaption><p>Plan-Act 规划</p></figcaption></figure>
执行流程：
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-zhi-xing-liu-cheng.png" alt="Agent 工具系统" width="1117"><figcaption><p>计划执行流程</p></figcaption></figure>
---
<br><br><br><br>

### Function Calling：输出格式约定
+ Function Calling 约定模型可用的函数 schema 和结构化调用格式，方便运行时校验参数、解析输出并调用工具。
+ Agent 程序负责协调模型输出并**真正执行工具**；具体实现既可能依赖系统提示词，也可能使用模型原生的工具调用接口。

<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-function-calling.png" alt="Agent 工具系统" width="893"><figcaption><p>Function Calling</p></figcaption></figure>


### MCP：模型上下文协议
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-mcp-zong-ti-ji-gou.png" alt="Agent 工具系统" width="1088"><figcaption><p>MCP 总体架构</p></figcaption></figure>
#### MCP Host
+ MCP Host 是承载 MCP Client、连接 Server 并向用户或模型暴露能力的宿主应用；它可以包含 Agent，但不等同于 Agent。
+ 本质上，它是支持 MCP 协议的软件或运行环境。
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-mcp-host.png" alt="Agent 工具系统" width="1044"><figcaption><p>MCP Host</p></figcaption></figure>
#### MCPServer和Tool
+ MCP Server 是提供工具、资源或提示模板等能力的服务端程序，不限于 Python 实现。
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-mcp-server.png" alt="Agent 工具系统" width="1093"><figcaption><p>MCP Server</p></figcaption></figure>
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-mcp-tool.png" alt="Agent 工具系统" width="1079"><figcaption><p>MCP Tool</p></figcaption></figure>

### 区分
#### Function Calling vs MCP
+ Function Calling 规定模型如何表达结构化工具调用；MCP 规定 Host/Client 与 Server 如何发现、连接和调用能力。两者处于不同层次，可以组合使用。
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-function-mcp-dui-bi.png" alt="Agent 工具系统" width="1124"><figcaption><p>Function Calling 与 MCP</p></figcaption></figure>

### RAG：检索增强生成
RAG 先从外部知识库检索与问题相关的内容，再将检索结果注入上下文，由模型生成最终回答。它适合补充模型训练数据之外的知识，并能降低纯参数记忆带来的过时风险。

### Search：信息检索
Search 是 Agent 获取外部信息的入口，通常包含查询改写、候选召回、排序和结果整理，再把高相关内容交给模型继续推理。

### LangChain：程序化开发流程
LangChain 将模型、提示词、工具、检索器和记忆组件封装为可组合的链或图，便于快速搭建和调试 Agent 流程。

### Workflow：固定或半固定的编排流程
Workflow 通过预先定义的步骤、分支和重试策略约束执行过程。相比完全自主的 Agent，它更容易测试、监控和复现。

### SKILL：Tool+说明文档
+ 将**已有的程序和说明文档在对话前传入Agent**
+ 相当于把提示词换一个地方存起来，用于一个**固定位置的文档说明**。
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-skill.png" alt="Agent 工具系统" width="941"><figcaption><p>Skill 机制</p></figcaption></figure>
### Context Engineering：上下文工程

#### Context Compression
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-context-compression.png" alt="Agent 工具系统" width="1090"><figcaption><p>上下文压缩</p></figcaption></figure>
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-context-yasuo.png" alt="Agent 工具系统" width="1027"><figcaption><p>上下文摘要</p></figcaption></figure>

### Sub-Agent：子智能体
+ 将繁杂的任务模块化，分为多个subagent，**subagent之间的上下文是不影响的**。
+ 最终**将subagent的处理结果**汇集给agent，用于完成最终的任务。
+ 优势：LLM没有记忆，如果直接用agent完成繁杂的任务很可能token损耗过多，上下文窗口过大，但是如果使用subagent，**agent的上下文只有最重要的结果部分，可以节省上下文**。
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-sub-agent.png" alt="Agent 工具系统" width="1728"><figcaption><p>子智能体协作</p></figcaption></figure>

### Memory
+ Agents.md**控制Agent的基本行为：例如记忆，工具调用等行为**。
+ 主要存储于memory.md，memory/*(日记系统)
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-memory.png" alt="Agent 工具系统" width="1864"><figcaption><p>Agent 记忆</p></figcaption></figure>
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-memory-cunchu.png" alt="Agent 工具系统" width="1126"><figcaption><p>记忆文件</p></figcaption></figure>


#### 记忆的检索：RAG / 语义嵌入匹配
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-memory-rag.png" alt="Agent 工具系统" width="1131"><figcaption><p>记忆检索</p></figcaption></figure>
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-yu-yi-ji-yi.png" alt="Agent 工具系统" width="1069"><figcaption><p>语义嵌入</p></figcaption></figure>
##### 记忆的失败案例：光说不练
+ 没有写入memory/*文件夹下
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-memory-shi-bai.png" alt="Agent 工具系统" width="1169"><figcaption><p>记忆失败案例</p></figcaption></figure>
### HEARTBEAT：心跳机制
+ 简单来说就是单独写一段prompt，让Agent在指定阶段将prompt**传入给LLM作出一些事情出来**。

<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-heartbeat.png" alt="Agent 工具系统" width="1077"><figcaption><p>Heartbeat 心跳</p></figcaption></figure>

#### Cron Job 系统

### uv环境
#### uv中tool的概念
+ `uvx=uvx tool run`：临时将某个tool加载到**隔离的虚拟环境**中并且运行。
+ `uvx tool install`：将tool及其依赖安装到**隔离的环境**中，与pip install不同。 


### OpenClaw 安装步骤
#### 系统信息
+ ubuntu22.04
+ 公共服务器：**无sudo权限**。

#### 安装过程
##### 无sudo命令安装node.js 24
+ 使用**wget命令下载预编译包**，然后解压缩得到二进制包，可以直接使用。
<figure><img src="/assets/img/llm-code-and-training-principles/agent-gong-ju-xi-tong-node-an-zhuang.png" alt="Agent 工具系统" width="1296"><figcaption><p>Node.js 安装</p></figcaption></figure>


+ 对于~/.bashrc：文件
```python
export PATH=/home/a2023102747/node-v24.14.0-linux-x64/bin:$PATH
```

---

## 资源完整性说明

- 原文 21 张图片均已本地化到 `/assets/img/llm-code-and-training-principles/`，正文不再依赖 CSDN 外链。
- 原文没有其他需要复制的本地附件。

