---
title: "强化学习·贝尔曼方程"
author: MayL
date: 2026-02-23
categories: ["大语言模型与强化学习", "强化学习"]
tags: ["强化学习", "bellman-ford", "人工智能", "学习笔记"]
render_with_liquid: false
math: true
description: "本文围绕“强化学习·贝尔曼方程”梳理核心概念、算法思路与实践要点，便于系统学习和后续查阅。"
---

@[toc]
# Return回报
## Return的意义
+ **Return是沿着某一路径的累积折扣奖励**
+ Return的作用：**可用于评估当前策略的价值**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1161cf02ae89457c8c55ac360cab6dce.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5c07032e43674db993e10591e3d91418.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/20a8b5aae4bc45c69ff505c4f9cd0c6a.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f0167a6575e44bc1803f956f6b741d9d.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5bf4ffec580c40dfa70bc75958d48fce.png){: referrerpolicy="no-referrer" }
## Return的计算公式
+ 注意：**全是随机变量**，意味着可以使用期望消去
+ **$R_t$与$R_{t+1}$都可以表示t时刻采取行动获得的即刻奖励**，习惯使用后者。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/15100a81374b4115b7342d115c94fefe.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/19cad53e0a144f4d845f829ab46aecab.png){: referrerpolicy="no-referrer" }
# State-value function状态价值函数
+ 状态价值函数：给定当前状态，其**平均回报**是什么？(**不知道当前动作和未来的状态和动作**)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a0b22167d36649d5ab09d44a7e746fd9.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2459d8cd6ca24bfbac80fbf41337500f.png){: referrerpolicy="no-referrer" }

# Bellman Equation贝尔曼方程
+ 使用期望的加法性质拆分G_t
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/617f36b5638d407bb34c6f7ae9fd6808.png){: referrerpolicy="no-referrer" }
+ 使用**全概率公式**分别计算两项
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ffe4727a51264c9898082a41a3ce6d12.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/fdd593c775bd421ba43e8102cfd0170f.png){: referrerpolicy="no-referrer" }


+ 最终形式：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9f1543e890924dd180ca0205dab3b74c.png){: referrerpolicy="no-referrer" }
## 贝尔曼方程的理解
+ 这是一种**自举(bootstrapping)的方法**，**自己推导自己**
+ 对于所有的状态都适用，这一点很重要。
+ 简化：**如果所有策略都是确定性的，那么所有的求和符合都可以消去，只有一条轨迹。**


## 贝尔曼方程的求解
+ 特别的性质：**贝尔曼方程对于所有状态都适用**，如果我们知道策略，对于所有者状态都列举方程，**可以通过求解线性方程组的形式求解贝尔曼方程**。

### 贝尔曼方程的简化方式
+ 当前状态的期望奖励和未来状态的期望奖励的总和。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9e3a53fae987452480c66459f91db478.png){: referrerpolicy="no-referrer" }
+ 当前状态的期望奖励和状态转移概率可以提前计算出来
+ $r_{\pi}(s)$代表状态s下的**期望即刻奖励**，注意没有确定动作。
+ **$P_{\pi}$代表当前状态转移矩阵**，维度为nxn。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6f3b2fa685ed4ec79203e9078a905d36.png){: referrerpolicy="no-referrer" }
### 数值例子
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5aa452c883444a65bc8a14ada50a98fd.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5b8ff3cb29cf45c2a1370e5fcf2bef73.png){: referrerpolicy="no-referrer" }
+ 通常求解线性方程组或者迭代方式可以求解

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/54530dbb5a9d4354ab94418b81d6b44e.png){: referrerpolicy="no-referrer" }
## 策略评估
+ 贝尔曼方程可以用于策略评估
+ 对于好策略，状态价值函数的值普遍较大，
![1](https://i-blog.csdnimg.cn/direct/b132563821024a3497a5a4842af61a55.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c4b140d85ddc49a49cc64c6eeeb78682.png){: referrerpolicy="no-referrer" }


# Action-value function动作价值函数
+ 核心思想与状态价值函数一致：都是未来期望的累积折扣奖励，在此基础上**给定了某个状态和采取的动作**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1d0ddeb4fd45486080ad9788b01db836.png){: referrerpolicy="no-referrer" }
## 贝尔曼方程，状态价值函数和动作价值函数的关系
+ 贝尔曼方程的右半部分等价于动作价值函数$Q_{\pi}(s,a)$

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/035d4171662e484b83c6eaa4beb770e2.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/96713fc7076c4455aefd3da0fa9edbde.png){: referrerpolicy="no-referrer" }

# BOE最优贝尔曼公式
## 最优策略的定义
+ 这个策略得到了**每一个状态价值函数**都比其他策略要高
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/cdee8b7e065a422482e5c0a555cfd37c.png){: referrerpolicy="no-referrer" }
## 最优贝尔曼公式的定义
+ 就是要求出最优的策略，就是$\max_{\pi}$
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b812c509dbf74b27afdf37c477da69dd.png){: referrerpolicy="no-referrer" }

+ 向量形式：
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/69248893f65b4f70979c10ec80d98e70.png){: referrerpolicy="no-referrer" }
## 最优贝尔曼公式的求解



![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/78db9ba3e43149368503b25fb96ad4f9.png){: referrerpolicy="no-referrer" }
### 最优策略
+ 简单来说，最优策略就是**选择使Q-value最大时的动作**。
+ 原因很简单，贝尔曼方程可以简化为Q-value的加权和，**我们只需要让Q-value最大的权重为1就能实现最优策略($\pi(a\mid s)=1 \text{ when }Q(s,a) \text{ is maximum}$)**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/79920cd46b2b41d0976596337ea92b0f.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ac2ca51f5cf344aeb56286fb3239ba75.png){: referrerpolicy="no-referrer" }
## 求解最优贝尔曼公式
+ 简单来说满足求解以下公式的不动点
+ **通过迭代的形式求解不动点**。

### 算法原理
+ **前提：状态转移函数，奖励函数已知。**
+ 初始化Q-value为0和策略为随机
+ 首先根据初始策略计算Q-value，
+ **然后根据Q-value更新策略和V-value**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/479014a9b48b43818796aa92e5e46ab0.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6ff9d4098e414e7f9a7ee864d2ec17a7.png){: referrerpolicy="no-referrer" }
