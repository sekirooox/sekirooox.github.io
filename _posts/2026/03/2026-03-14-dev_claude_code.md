---
title: "Claude Code (vscode插件版) 常见命令"
author: MayL
date: 2026-03-14
categories: ["编程语言与工具", "开发工具"]
tags: ["开发工具", "claude-code", "编程", "工具"]
render_with_liquid: false
description: "本文整理“Claude Code (vscode插件版)…”的基础语法、常用操作与实践要点，便于快速入门和日常开发查阅。"
---

# 常见slash command
>这些命令一般**都可以加入后续指令**，例如 `/compact 请只保留与xx相关的内容`。

+ /init 生成`Claude.md`文件，这个文件包括项目结构，智能体的记忆等
+ /clear 清楚上下文
+ /compact 压缩上下文，可以跟随保存的指定内容
+ /config 会跳转到vscode的配置页面
+ /mcp 跳转到mcp配置页面
+ /memory 
+ /resume 重新读取某一会话
+ /simplify 启动三个代码审查智能体，检查代码中扫描重复出现的模式，检查是否已有工具函数处理同类逻辑。跑完了，结果合并，修复自动应用。你看一遍 diff 就行。

# vscode终端版特有命令
+ /mension 提及某个文件或者某个文件夹
+ 
