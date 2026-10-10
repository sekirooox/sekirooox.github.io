---
title: "数理基础·概率论与数理统计"
author: MayL
date: 2026-06-27
categories: ["数学基础与数学建模", "数学基础"]
tags: ["概率论", "数学", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“数理基础·概率论与数理统计”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

@[toc]
# 概率论


## 随机变量 vs 变量
+ **取值不确定的变量**叫做随机变量

## 联合概率
+ 推广到**多个随机变量**的情况。设有随机变量：

$$
X_1,X_2,\cdots,X_n
$$






### 离散型随机变量：单点有效

如果 (X_1,X_2,\cdots,X_n) 都是离散型随机变量，那么它们的**概率质量函数pmf**为：

$$
P(X_1=x_1,X_2=x_2,\cdots,X_n=x_n)
$$
也可以简写为：

$$
P(x_1,x_2,\cdots,x_n)
$$





### 连续型随机变量：区域面积有效

如果 (X_1,X_2,\cdots,X_n) 是连续型随机变量，通常讨论联合**概率密度函数pdf**：

$$
f(x_1,x_2,\cdots,x_n)
$$

此时，某个区域 (D) 内的**联合概率**为：

$$
P((X_1,\cdots,X_n)\in D)=\int_D f(x_1,\cdots,x_n),dx_1\cdots dx_n
$$

因此连续型情况下主要**看“区间”或“区域”的概率**。

## 边缘概率：忽略不感兴趣的变量

+ 边缘概率表示：**只关心其中一部分随机变量，忽略其它随机变量。**

### 离散型随机变量

+ 一般地，若有 $X_1,\cdots,X_n$，**只保留前 $k$ 个变量**，则：

$$
P(x_1,\cdots,x_k)=\sum_{x_{k+1}}\cdots\sum_{x_n}P(x_1,\cdots,x_k,x_{k+1},\cdots,x_n)
$$
这就是离散型变量的**边缘化**。
### 连续型随机变量

如果 (X,Y,Z) 是连续型随机变量，联合密度为：

$$
f_{X,Y,Z}(x,y,z)
$$


那么 (X) 的边缘密度为：

$$
f_X(x)=\int_{-\infty}^{+\infty}\int_{-\infty}^{+\infty}f_{X,Y,Z}(x,y,z),dy,dz
$$

如果只消去 (Z)，保留 (X,Y)，则：

$$
f_{X,Y}(x,y)=\int_{-\infty}^{+\infty}f_{X,Y,Z}(x,y,z),dz
$$

## 条件概率：在部分变量已知时，另一些变量的概率

+ 条件概率表示：**已知某些随机变量的取值后，另一些随机变量取某些值的概率。**
### 离散型随机变量
更一般地，若把变量分成两组：

$$
X=(X_1,\cdots,X_k),\quad Y=(Y_1,\cdots,Y_m)
$$


则：

$$
P(X=x\mid Y=y)=\frac{P(X=x,Y=y)}{P(Y=y)}
$$

其中：

$$
P(Y=y)=\sum_x P(X=x,Y=y)
$$



### 连续型随机变量

连续型变量中，对应的是**条件密度**。

如果有联合密度：

$$
f_{X,Y}(x,y)
$$


那么条件密度为：

$$
f_{X\mid Y}(x\mid y)=\frac{f_{X,Y}(x,y)}{f_Y(y)}
$$


其中：

$$
f_Y(y)=\int_{-\infty}^{+\infty}f_{X,Y}(x,y),dx
$$

如果有三个连续变量 (X,Y,Z)，则：

$$
f_{X\mid Y,Z}(x\mid y,z)=\frac{f_{X,Y,Z}(x,y,z)}{f_{Y,Z}(y,z)}
$$


其中：

$$
f_{Y,Z}(y,z)=\int_{-\infty}^{+\infty}f_{X,Y,Z}(x,y,z),dx
$$

## 条件概率公式：条件 = 联合 / 边缘

## 概率论的链式法则

一般地，对于 (n) 个随机变量，有链式法则：

$$
P(X_1,\cdots,X_n)=P(X_1\mid X_2,\cdots,X_n)P(X_2\mid X_3,\cdots,X_n)\cdots P(X_{n-1}\mid X_n)P(X_n)
$$

也常写成另一种顺序：

$$
P(X_1,\cdots,X_n)=P(X_1)\prod_{i=2}^{n}P(X_i\mid X_1,\cdots,X_{i-1})
$$

## 贝叶斯公式
### 含义1：条件-联合-边缘概率转换公式
$$\begin{align}P(\mathbf{X}\mid\mathbf{Y})=\frac{P(\mathbf{X},\mathbf{Y})}{P(\mathbf{Y})}\end{align}$$

### 含义2：先验和后验公式
$$\begin{align}
P(\mathbf{X}=\mathbf{x}\mid \mathbf{Y}=\mathbf{y})
=\frac{
P(\mathbf{Y}=\mathbf{y}\mid \mathbf{X}=\mathbf{x})P(\mathbf{X}=\mathbf{x})
}{
P(\mathbf{Y}=\mathbf{y})
}
\end{align}$$


### 情景：根据证据纠正信念
+ 先验：我们认为**一个人感冒的概率为0.1**
+ 似然：在此先验下，我们认为感冒的情况下，**观测到咳嗽(证据)的概率为0.8**
+ 后验：根据咳嗽可以修复我们对这个人感冒的认识，**该人感冒的概率为0.9**
#### 先验：对X的原始信念
$$\begin{align}P(\mathbf{X}=\mathbf{x})\end{align}$$
#### 似然：在先验概率下观察到证据的概率
$$\begin{align}P(\mathbf{Y}=\mathbf{y}\mid \mathbf{X}=\mathbf{x})\end{align}$$


#### 后验：对于X信念的修正
$$\begin{align}P(\mathbf{X}=\mathbf{x}\mid \mathbf{Y}=\mathbf{y})\end{align}$$
## 全概率公式

### 含义：联合概率转换为边缘概率
+ 注意：X和Y都是向量
$$\begin{align}
P(\mathbf{Y}=\mathbf{y})
=\sum_{\mathbf{x}}
P(\mathbf{Y}=\mathbf{y},\mathbf{X}=\mathbf{x})
\end{align}$$
+ 对多个变量进行积分：
$$\begin{align}
f_{\mathbf{Y}}(\mathbf{y})
=\int
f_{\mathbf{Y}\mid \mathbf{X}}(\mathbf{y}\mid \mathbf{x})f_{\mathbf{X}}(\mathbf{x})
\,d\mathbf{x}
\end{align}$$


## 概率分布


| 分布             | 记号                | 随机变量含义              | 分布列 / 密度函数                                                                                | 期望                  | 方差                              |
| -------------- | ----------------- | ------------------- | ------------------------------------------------------------------------------------------- | ------------------- | ------------------------------- |
| 0-1 分布 / 伯努利分布 | $b(1,p)$          | 一次试验是否成功            | $P(X=k)=p^k(1-p)^{1-k},\ k=0,1$                                                             | $p$                 | $p(1-p)$                        |
| 二项分布           | $b(n,p)$          | $n$ 次独立重复试验中成功的次数   | $P(X=k)=\binom{n}{k}p^k(1-p)^{n-k}$                                                         | $np$                | $np(1-p)$                       |
| **泊松分布**           | $P(\lambda)$      | 单位时间或单位区域内事件发生的次数   | $P(X=k)=\frac{\lambda^k}{k!}e^{-\lambda}$                                                   | $\lambda$           | $\lambda$                       |
| 超几何分布          | $h(n,N,M)$        | 不放回抽样中某类物品被抽到的件数    | $P(X=k)=\frac{\binom{M}{k}\binom{N-M}{n-k}}{\binom{N}{n}}$                                  | $n\frac{M}{N}$      | $\frac{nM(N-M)(N-n)}{N^2(N-1)}$ |
| 几何分布           | $Ge(p)$           | 第一次成功出现时所需的试验次数     | $P(X=k)=(1-p)^{k-1}p,\ k=1,2,\cdots$                                                        | $\frac{1}{p}$       | $\frac{1-p}{p^2}$               |
| 负二项分布          | $Nb(r,p)$         | 第 $r$ 次成功出现时所需的试验次数 | $P(X=k)=\binom{k-1}{r-1}(1-p)^{k-r}p^r$                                                     | $\frac{r}{p}$       | $\frac{r(1-p)}{p^2}$            |
| 均匀分布           | $U(a,b)$          | 在区间 $(a,b)$ 内等可能取值  | $f(x)=\frac{1}{b-a},\ a<x<b$                                                                | $\frac{a+b}{2}$     | $\frac{(b-a)^2}{12}$            |
| 正态分布           | $N(\mu,\sigma^2)$ | 大量随机因素共同作用下的连续变量    | $f(x)=\frac{1}{\sqrt{2\pi}\sigma}\exp\left\{-\frac{(x-\mu)^2}{2\sigma^2}\right\}$           | $\mu$               | $\sigma^2$                      |
| 指数分布           | $Exp(\lambda)$    | 等待某事件第一次发生所需的时间     | $f(x)=\lambda e^{-\lambda x},\ x\ge 0$                                                      | $\frac{1}{\lambda}$ | $\frac{1}{\lambda^2}$           |


### 正态分布
#### 归一化
+ 将区域的概率分布情况转换为**标准正态概率分布**来计算
+ Φ**标识标准正态分布的累计概率**，可以查表得到。
$$
\begin{align}
P(a<X<b)=&P(a-\mu/\sigma<Z<b-\mu/\sigma)\\
=&Φ(b-\mu/\sigma)-Φ(a-\mu/\sigma)
\end{align}
$$
#### $Z_{\alpha}$：右尾部分的面积为$\alpha$的分位点
+ 用途计算标准正太

### 泊松分布的含义：$X$表示一段时间内`事件发生的次数`
$$\begin{align}P(X=k)=\frac{\lambda^k}{k!}e^{-\lambda},\quad k=0,1,2,\cdots\end{align}$$
+ 随机变量X表示：**1h内**公交车**到站次数**，**1h事件**的**发生次数**
+ $\lambda$：1h公交车平均到站次数。
+ 假设平均到站次数为3个电话，那么1h内到站次数为5的概率为：
$$\begin{align}P(X=5)=\frac{3^5}{5!}e^{-3}\end{align}$$

### 指数分布的含义：$X$表示下一次事件的发生时间
$$\begin{align}X\sim Exp(\lambda)\end{align}$$
$$\begin{align}P(X>x)=e^{-\lambda x}\end{align}$$
其中$x\geq0$，随机变量X表示：公交车到站的等待事件，排队的等待时间
+ 假设排队的平均等待时间为$1/\lambda$，那么等待时间不超过15的概率为：
$$\begin{align}P(X\le x)=1-e^{-\lambda x}\end{align}$$


## 随机变量和随机向量


$$\begin{align}
x=
\begin{bmatrix}
x_1\\
x_2\\
\vdots\\
x_n
\end{bmatrix}
\in \mathbb{R}^n
\end{align}$$

### 随机变量 / 向量的期望
$$\begin{align}
\mathbb{E}[x]=
\begin{bmatrix}
\mathbb{E}[x_1]\\
\mathbb{E}[x_2]\\
\vdots\\
\mathbb{E}[x_n]
\end{bmatrix}
\end{align}$$

### 随机变量的方差和协方差
| 概念      | 公式                      |          维度 | 含义                         |
| ------- | ----------------------- | ----------: | -------------------------- |
| 随机向量期望  | (\mathbb{E}[x])         | (n\times 1) | 随机向量的平均位置                  |
| 自协方差矩阵  | (\mathrm{Cov}(x,x))     | (n\times n) | 描述 (x) **内部分量之间**的波动和相关关系      |
| 交叉协方差矩阵 | (\mathrm{Cov}(x,y))     | (m\times n) | **描述 (x) 的分量与 (y) 的分量**之间的交叉关系 |
| 对角线元素   | (\mathrm{Cov}(x_i,x_i)) |          标量 | 第 (i) 个变量自己的方差             |
| 非对角线元素  | (\mathrm{Cov}(x_i,x_j)) |          标量 | 两个变量之间的协方差                 |


$$\begin{align}
\mathrm{Var}(x)=\mathbb{E}\left[(x-\mathbb{E}[x])^2\right]
\end{align}$$

### 随机向量的方差和协方差：`随机向量`之间`不同分量组合`的相关程度
+ 元素表示每一个随机变量之间的**关联程度** / **波动程度**：
+ 注意：协方差矩阵为**nxn**的，所以是**列向量乘以行向量**
$$\begin{align}
\mathrm{Cov}(x,x)=
\mathbb{E}\left[(x-\mathbb{E}[x])(x-\mathbb{E}[x])^T\right]
\end{align}$$

$$\begin{align}
\mathrm{Cov}(x,x)
=\begin{bmatrix}
\mathrm{Cov}(x_1,x_1) & \mathrm{Cov}(x_1,x_2) & \cdots & \mathrm{Cov}(x_1,x_n)\\
\mathrm{Cov}(x_2,x_1) & \mathrm{Cov}(x_2,x_2) & \cdots & \mathrm{Cov}(x_2,x_n)\\
\vdots & \vdots & \ddots & \vdots\\
\mathrm{Cov}(x_n,x_1) & \mathrm{Cov}(x_n,x_2) & \cdots & \mathrm{Cov}(x_n,x_n)
\end{bmatrix}
\end{align}$$

不同随机向量的协方差矩阵：

$$\begin{align}
\mathrm{Cov}(x,y)
=\mathbb{E}\left[(x-\mathbb{E}[x])(y-\mathbb{E}[y])^T\right]
\end{align}$$

### 协方差矩阵 $\Sigma_x$：随机变量`不同分量`的波动程度和相关性
+ 不同分量：例如身高，体重的相关程度和波动。

$$\begin{align}
\Sigma_x
=\mathrm{Cov}(x)=
\mathrm{Cov}(x,x)
\end{align}$$


### 期望和方差/协方差的性质：多个随机变量$X_1,X_2,\cdots,X_n$`线性组合`

#### 期望的线性组合性质：`无条件`
$$
\begin{align}
\mathbb{E}[Ax+By+c]
=A\mathbb{E}[x]+B\mathbb{E}[y]+c
\end{align}
$$




#### 协方差的线性组合性质：`通用`和`独立`版本




设随机向量 (x_1,\dots,x_m) 与 (y_1,\dots,y_n) 二阶矩存在，(A_i,B_j) 是确定矩阵，(a,b) 是确定向量：

$$
\begin{align}
u=\sum_{i=1}^{m}A_i x_i+a,
\quad
v=\sum_{j=1}^{n}B_j y_j+b
\end{align}
$$

则：

$$
\begin{align}
\mathrm{Cov}(u,v)
=\sum_{i=1}^{m}\sum_{j=1}^{n}
A_i\mathrm{Cov}(x_i,y_j)B_j^T
\end{align}
$$

这就是协方差矩阵在线性组合下的**通用公式**。


#### 高斯分布的线性组合仍然是`高斯分布`
+ 给定n个**不同参数的高斯分布**：$X_1,X_2,\cdots,X_n$，其中$X_i$服从均值为$\mu_i$，方差为$\sigma_i^2$的高斯分布。
+ 高斯分布的线性组合$a_1X_1+a_2X_2+\cdots a_nX_n$**仍然服从均值为$\sum{a_i\mu_i}$，方差为$\sum{a_i^2\sigma_i^2}$的高斯分布**。

## 独立与相关
+ X和Y相互独立的定义
$$
\begin{align}
\mathbf{X} \perp\!\!\!\perp \mathbf{Y}
\end{align}
$$
### 标准定义
+ 与变量Y无关
$$
\begin{align}
P(X|Y)=P(X)
\end{align}
$$

### 推论
$$
\begin{align}
P(X)P(Y)=P(X,Y)
\end{align}
$$
### 独立vs相关：独立必不相关，`线性相关`不一定独立



# 数理统计

## 方向1：样本分布推断总体分布

### 样本与总体：`共享`参数，参数未知
总体和样本来自同一个分布，并**共享同一组总体参数**；只是这些**总体参数未知**，需要通过样本来估计
### 大数定律：$\bar{X}$的均值 / 估计未知均值$\mu=\bar{X}$

大数定律回答的问题是：

**样本平均值在样本量很大时，会不会接近总体均值？**

设 (X_1,X_2,\dots,X_n) 是独立同分布随机变量，并且：

$$
E(X_i)=\mu
$$

样本均值为：

$$
\bar X=\frac{1}{n}\sum_{i=1}^n X_i
$$

大数定律说明：

$$
\bar X \to \mu
$$


**重复试验次数足够多时，随机波动会被平均掉，样本平均值会稳定在总体均值附近。**




---

### 中心极限定理：样本均值$\bar{X}$的分布，均值和方差

中心极限定理回答的问题是：

**样本均值的误差大致服从什么分布？**

仍然设：

$$
X_1,X_2,\dots,X_n
$$

独立同分布，且：

$$
E(X_i)=\mu,\quad Var(X_i)=\sigma^2
$$

样本均值为：

$$
\bar X=\frac{1}{n}\sum_{i=1}^n X_i
$$

中心极限定理说明，当 (n) 足够大时：

$$
\frac{\bar X-\mu}{\sigma/\sqrt n}\approx N(0,1)
$$

也就是说：

$$
\bar X\approx N\left(\mu,\frac{\sigma^2}{n}\right)
$$

通俗理解是：

**不管原始数据本身是不是正态分布，只要样本量足够大，样本均值的分布通常会近似正态分布。**


#### 应用：置信区间
它说明：

$$
\bar X\approx N\left(\mu,\frac{\sigma^2}{n}\right)
$$

因此我们可以构造置信区间：

$$
\bar X \pm z_{\alpha/2}\frac{\sigma}{\sqrt n}
$$

也可以进行假设检验。

也就是说，中心极限定理提供了统计推断的**分布基础**。





## 参数估计：已知分布估计参数



### 矩估计方法
+ 原理：样本的k阶矩等于总体的k阶矩：
$$
\begin{align}
E[X^k]&=\sum_{i=1}^{k}X_i^k 
\end{align}
$$
通过一阶矩和二阶矩可以很好估计**总体分布的均值和方差**。
例如一阶情况：
$$
\begin{align}
E[X]&=\sum_{i=1}^{k}X_i=\mu 
\end{align}
$$
例如二阶情况：
$$
\begin{align}
E[X^2]&=\sum_{i=1}^{k}X_i^2 \\
&=Var[X]+E[X]^2
\end{align}
$$


### 最大对数似然估计MLE
#### 似然函数：所有样本概率的累乘 $L(x_1,x_2,\cdots,x_n;\theta)==\prod_{i=1}^{n} p(x_i;\theta)$
+ 似然：<font color='red'>**未定参数**</font>下证据发生的概率。
+ 给定样本$x_1,x_2 \cdots x_n$，独立同分布。似然函数为：
$$
\begin{align}
L(\theta)
&=L(x_1,x_2,\cdots,x_n;\theta) \\
&=\prod_{i=1}^{n} p(x_i;\theta),
\qquad \theta\in\Theta
\end{align}
$$
+ 最大化似然函数。
$$
\begin{align}
L(x_1,x_2,\cdots,x_n;\hat{\theta})
=\max_{\theta\in\Theta}
L(x_1,x_2,\cdots,x_n;\theta)
\end{align}
$$

#### 最大化对数似然函数：$\max_{\theta\in\Theta}\log L(x_1,x_2,\cdots,x_n;\theta)$
+ 最大对数似然函数：找到使得事件发生概率最大的参数 $\theta$，使得**出现证据的可能性最大，以符合证据的观察**。
$$
\begin{align}
\log L(x_1,x_2,\cdots,x_n;\hat{\theta})
=\max_{\theta\in\Theta}
\log L(x_1,x_2,\cdots,x_n;\theta)
\end{align}
$$
#### 例题：均匀分布函数的参数估计
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ae74528097544061a8f7b26126ebf354.png){: referrerpolicy="no-referrer" }


### 评价指标
#### 无偏性
+ 如果重复抽样很多次，所有估计值的平均等于真实参数
$$
E[\hat{\theta}]=\theta
$$

#### 有效性
+ 参数值的估计**方差越小越好**。
$$
V[\hat{\theta_1}]<V[\hat{\theta_2}]
$$

#### 一致性
+ 对于参数量的估计，在采样数很多时，**需要趋近真实值**。


## 假设检验
### 基本流程：两个假设+p值+显著性水平$\alpha$

* 原假设：通常表示“没有显著差异 / 没有显著变化 / 某个参数等于某个值”的假设
* 备择假设：表示与原假设相反，通常是研究者希望获得证据支持的假设
* p值的含义：在原假设成立的前提下，**观察到当前样本结果**或比**当前结果更极端结果**的概率。
* 显著性水平：事先设定的拒绝原假设的错误风险，通常记为$\alpha$，例如$0.05$。

#### 例子

* 假设我们想检验总体均值是否为10，则：
  $$\begin{align} H_0:\mu =10 \end{align}$$
  $$\begin{align} H_1:\mu\neq10 \end{align}$$

* 如果得出$p=0.01$，结论为：在原假设$H_0:\mu=10$成立的前提下，得到当前样本均值或比当前结果更极端结果的概率为$0.01$。

* 我们事先设定的显著性水平$\alpha$为$0.05$。

* 因为$p<\alpha$，所以认为当前样本结果在原假设成立时较少发生，因此拒绝原假设。



