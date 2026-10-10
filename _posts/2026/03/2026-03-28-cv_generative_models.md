---
title: "深度学习·生成式模型"
author: MayL
date: 2026-03-28
categories: ["深度学习与计算机视觉", "深度学习"]
tags: ["深度学习", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“深度学习·生成式模型”涉及的模型原理、关键方法与实践要点，便于理解和复习相关技术。"
---

@[toc]
# 生成模型
+ 生成模型的本质是让模型学习到输入的概率分布$p(x)$。然而，这个**概率分布非常复杂**，无法**形式化表示出来**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/293c1fddf9c74359809a2f8c696b0412.png){: referrerpolicy="no-referrer" }

# 可变分自编码器 (VAE)
+ 将图像编码为**潜向量**
+ 约束前向量分布为
## 编码过程
+ 就是将一个图像编码为**潜在变量$z\in \mathbb{R}^{B\times D}$**，表示图像的各个细节：
+ 同时约束潜在变量z的**分布尽量符合标准正态分布**(确保后续采样的时候，大多数点都是有意义的，可以还原出合理图像)
$$p(z)=\mathcal{N}(0,I)$$

+ 为了保证z向量符合标准正态分布，**编码器一般输出mu和logvar**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b2d0d6ba457446178fc86c0fa0c9dc47.png){: referrerpolicy="no-referrer" }

## 重参数化技巧

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/bee48dad1be145aeb1a98ff5c70206f6.png){: referrerpolicy="no-referrer" }

## 解码过程 
+ 输入隐变量
+ 还原出图像
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5198f3f442bd4f3c82ba26bec96f2c31.png){: referrerpolicy="no-referrer" }



## 模型架构 
+ 简单来说就是Unet型的架构
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/287d1346289d4c708067732f9cae4c64.png){: referrerpolicy="no-referrer" }

## 模型损失

+ 重建损失：$L_{rec}$，表示为**重建图像的常见MSE损失**。
+ KL散度损失：$L_{KL}$：$q(z\mid x)$和$p(z)$的损失，其中**q表示编码过程**，p表示多源标准正态分布。**通常来说，这个很难计算，将其转换为其他损失**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/eb9b61901f574dde9d97eb8b483a59f7.png){: referrerpolicy="no-referrer" }
### 原始优化目标
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/dbc0423e66fa46729fc7ecc3a8e9839f.png){: referrerpolicy="no-referrer" }
### ELBO优化目标：重建损失-KL散度
+ 使用ELBO方法得到另一个优化形式
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2df5358d60324305b408ea70bfc3e8bb.png){: referrerpolicy="no-referrer" }

### 重建损失改写：MSE损失
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3fb1eb39cfcc4a6ba0905fe8ea187c0f.png){: referrerpolicy="no-referrer" }
### KL散度改写：均值和方差损失
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2787d856f4ef4c20a77b5c6cb1d6fe8e.png){: referrerpolicy="no-referrer" }





![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3cddfe8e6eb44329a34c3a3afd13ce9f.png){: referrerpolicy="no-referrer" }



# DDPM

## 加噪过程
+ 从$x_0$开始，经过单步加噪得到破坏后的图像，并且**确保最终图像是均值为0，方差为1的高斯噪声图像**。
+ $\bar{\alpha}_t$等价于从t=1开始，噪声扰动强度的**连乘**，其中**任意一步$\alpha_t$都保证小于介于[0,1)之间**，当t区域无穷时，可以证明上述假设成立。
$$
x_t = \sqrt{\bar{\alpha}_t}x_0 + \sqrt{1-\bar{\alpha}_t},\epsilon,\quad \epsilon \sim \mathcal{N}(0,I)
$$

## 降噪过程
### 公式变形
+ $q(x_{t-1}\mid x_{t})$表示我们的降噪过程，可以经过贝叶斯公式展开为：
+ 其中$q(x_{t-1})$和$q(x_{t})$表示特定步数下图像的分布情况，这是很难预测的。
+ 因此**引入$x_0$的信息来简化去噪过程**。
$$
\begin{align}
 & q(x_{t-1}\mid x_{t})=\frac{q(x_{t}\mid x_{t-1})q(x_{t-1})}{q(x_{t})} \\
 & q(x_{t-1}\mid x_{t},x_{0})=\frac{q(x_{t}\mid x_{t-1},x_{0})q(x_{t-1}\mid x_{0})}{q(x_{t}\mid x_{0})} \\
 & q(x_{t-1}\mid x_{t},x_{0})=\frac{q(x_{t}\mid x_{t-1})q(x_{t-1}\mid x_{0})}{q(x_{t}\mid x_{0})}
\end{align}
$$
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9ceffaf37b0a4042984f833a82a9a74c.png){: referrerpolicy="no-referrer" }
+ **模型能从不同的$x_0$中学习到有意义的去噪过程**，例如从下面三种不同的输入中，学习到三种截然不同的眼睛重建方式。
+ 这可以**改善生成模型的模态覆盖**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/dfdc6a4cc697403b9a7b003b5582ac96.png){: referrerpolicy="no-referrer" }

### 目标函数：MLE
+ MLE的核心思想：**给定观察结果**，我们需要对模型的参数进行估计，**使得概率模型输出与观察结果最接近**。
+ DDPM：给定输入图像，我们需要找到对应的参数，**使得生成模型的重建结果与给定图像最接近**。
+ ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/25fa1d6b1958445f937dd4de4170080d.png){: referrerpolicy="no-referrer" }
### 目标函数的优化：MLE->KL散度
+ 将最大化MLE这种比较抽象的目标转换为实际的KL散度目标：
+ 公式的含义：从前向加噪过程中学习NN的去噪方法，最小化两种方式的KL散度。
$$
L=\sum_{t=2}^{T}\mathbb{E}_{q(x_{t}\mid x_{0})}[D_{KL}(q(x_{t-1}\mid x_{t},x_{0})\mathbin{\|\!\|}p_{\theta}(x_{t-1}\mid x_{t}))]
$$
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b818bec8225f405397536cda1994188c.png){: referrerpolicy="no-referrer" }
### 去噪公式
$$
\mu=\frac{1}{\sqrt{\alpha_{t}}}\left(x_{t}-\frac{1-\alpha_{t}}{\sqrt{1-\overline{\alpha}_{t}}}\cdot\epsilon\right)
\\\sigma^{2}=\frac{(1-\alpha_{t})(1-\overline{\alpha}_{t-1})}{1-\overline{\alpha}_{t}}
$$
+ 现在我们就是求解：$q(x_{t-1}\mid x_t,x_0)$
+ 基本理论：**先验概率是正态分布，后验概率也是正态分布。**
+ 求解这一步的均值和方差。


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/87e7033d799241fda19f7504f41ec3fb.png){: referrerpolicy="no-referrer" }
+ 我们得到了网络需要预测的均值和方差。**发现$\alpha_t，x_t，\bar{\alpha_t}$都是已知道的**，只有施加的正态分布不可知，**网络需要的学习参数就是这个未知的高斯正态分布噪声！**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/14f1b991ded543c5930e8c6785c20b81.png){: referrerpolicy="no-referrer" }


### 训练过程
+ 前面已经将抽象的MLE过程简化为网络**预测每一步的高斯分布扰动**，那么网络训练就很简单了，直接预测每一个时间步的高斯噪音即可。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a675a9c14dfa4f988999bc1e39917faa.png){: referrerpolicy="no-referrer" }
### 推理过程
+ 预测每一步的高斯噪声后，利用**去噪公式**进行重建即可。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/acaa5da64eb943a796ac11bcbf5e74e4.png){: referrerpolicy="no-referrer" }


<br><br>

---

### 其他过程

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/28541034b96640a5b8a209b4e20ed2e3.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e257b144cea94185be89cce8ba98ae42.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/636834881f63434d9bb29c60d202dd19.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/965c5c8c196d40bc984e32e90fc5f32a.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/7a938cff11c7476fa5fb388b82db5eef.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/34e4e099e7534564a7d2f9da05dd93b8.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c68de85de058432894f149a7c848bb7b.png){: referrerpolicy="no-referrer" }
