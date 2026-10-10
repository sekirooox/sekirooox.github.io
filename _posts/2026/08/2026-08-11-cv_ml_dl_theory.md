---
title: "机器学习和深度学习·理论基础"
author: MayL
date: 2026-08-11
categories: ["深度学习与计算机视觉", "深度学习"]
tags: ["深度学习", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“机器学习和深度学习·理论基础”涉及的模型原理、关键方法与实践要点，便于理解和复习相关技术。"
---


# 机器学习

> 记号说明：默认 $$\mathbf{x},\mathbf{w},\mathbf{h},\mathbf{y}$$ 表示向量，$$b,\gamma,\beta,\alpha,\lambda$$ 表示标量；若写到矩阵，则显式给出维度。

## 逻辑回归

逻辑回归使用 sigmoid 将线性结果映射到 $$(0,1)$$。

$$
\begin{align}
\sigma(\mathbf{w}^{\top}\mathbf{x}+b)=\frac{1}{1+e^{-(\mathbf{w}^{\top}\mathbf{x}+b)}}
\end{align}
$$

其中 $$\mathbf{x}\in\mathbb{R}^{D\times1}$$ 是输入向量，$$\mathbf{w}\in\mathbb{R}^{D\times1}$$ 是权重向量，$$b\in\mathbb{R}$$ 是偏置，$$\sigma(\cdot)$$ 是 sigmoid 函数。

## Softmax回归

给定 $$\mathbf{z}\in\mathbb{R}^{D\times1}$$，softmax 将其映射为类别概率。

$$
\begin{align}
\mathrm{softmax}(\mathbf{z})_i=\frac{e^{z_i}}{\sum_{j=1}^{D}e^{z_j}}
\end{align}
$$

其中 $$z_i$$ 是向量 $$\mathbf{z}$$ 的第 $$i$$ 个分量，$$\mathrm{softmax}(\mathbf{z})_i$$ 是第 $$i$$ 类对应的归一化输出。

## 感知机

感知机输出类别符号，形式为 $$\mathrm{sgn}(\mathbf{w}^{\top}\mathbf{x}+b)$$。

$$
\begin{align}
\mathrm{sgn}(\mathbf{w}^{\top}\mathbf{x}+b)=
\begin{cases}
+1,&\mathbf{w}^{\top}\mathbf{x}+b>0\\
0,&\mathbf{w}^{\top}\mathbf{x}+b=0\\
-1,&\mathbf{w}^{\top}\mathbf{x}+b<0
\end{cases}
\end{align}
$$

其中 $$\mathbf{x}\in\mathbb{R}^{D\times1}$$ 是输入，$$\mathbf{w}\in\mathbb{R}^{D\times1}$$ 是权重，$$b\in\mathbb{R}$$ 是偏置。

## SVM

### 超平面：决策边界

超平面由 $$\mathbf{w}^{\top}\mathbf{x}+b=0$$ 定义。点 $$\mathbf{x}_0$$ 到超平面的距离为其在法向量方向上的投影长度。

$$
\begin{align}
d=\frac{|\mathbf{w}^{\top}\mathbf{x}_0+b|}{\|\mathbf{w}\|_2}
\end{align}
$$

其中 $$\mathbf{x}_0\in\mathbb{R}^{D\times1}$$ 是样本点，$$\mathbf{w}\in\mathbb{R}^{D\times1}$$ 是超平面法向量，$$b\in\mathbb{R}$$ 是偏置，$$d$$ 是点到超平面的欧氏距离。

当 $$D=2$$，直线 $$Ax+By+C=0$$ 的点到直线距离写作：

$$
\begin{align}
d=\frac{|Ax_0+By_0+C|}{\sqrt{A^2+B^2}}
\end{align}
$$

其中 $$(x_0,y_0)$$ 是平面中的点，$$A,B,C$$ 是直线参数。

### 线性可分：数据集可以被线性模型二分类

给定数据集

$$
\begin{align}
\mathcal{D}=\{(\mathbf{x}^{(n)},y^{(n)})\}_{n=1}^{N}
\end{align}
$$

其中 $$\mathbf{x}^{(n)}\in\mathbb{R}^{D\times1}$$ 是第 $$n$$ 个样本，$$y^{(n)}\in\{-1,+1\}$$ 是对应标签，$$N$$ 是样本数。

若存在权重 $$\mathbf{w}^{*}$$ 与偏置 $$b^{*}$$，使得

$$
\begin{align}
y^{(n)}\left((\mathbf{w}^{*})^{\top}\mathbf{x}^{(n)}+b^{*}\right)>0,\quad \forall n
\end{align}
$$

则说明预测与真实值符号一致，数据线性可分。

### 线性可分的多分类：数据集可以被线性模型多分类

对多分类数据集 $$\mathcal{D}=\{(\mathbf{x}^{(n)},y^{(n)})\}_{n=1}^{N}$$，若采用 one-vs-rest 形式，则对真实类别 $$c$$ 与任意非真实类别 $$\hat c\neq c$$，要求

$$
\begin{align}
f_c(\mathbf{x}^{(n)};\mathbf{w}^{*})>f_{\hat c}(\mathbf{x}^{(n)};\mathbf{w}^{*})
\end{align}
$$

其中 $$f_c(\mathbf{x};\mathbf{w}^{*})$$ 是类别 $$c$$ 的打分函数，$$\hat c$$ 表示非 GT 类别，$$c$$ 表示真实类别。

### 最大间隔原理

样本到分类超平面的间隔定义为

$$
\begin{align}
d_i=\frac{|f(\mathbf{x}_i)|}{\|\mathbf{w}\|_2}
\end{align}
$$

其中 $$\mathbf{x}_i$$ 是第 $$i$$ 个样本，$$f(\mathbf{x}_i)$$ 是该样本的分类函数值，$$\|\mathbf{w}\|_2$$ 是法向量范数。

最小间隔记为

$$
\begin{align}
\gamma=\min_i d_i
\end{align}
$$

其中 $$\gamma$$ 是所有样本中最小的几何间隔。

优化目标写为

$$
\begin{align}
\max_{\mathbf{w},b}\ \gamma\quad \text{s.t.}\quad \frac{y^{(n)}(\mathbf{w}^{\top}\mathbf{x}^{(n)}+b)}{\|\mathbf{w}\|_2}\ge \gamma,\ \forall n
\end{align}
$$

其中 $$\mathbf{w}\in\mathbb{R}^{D\times1}$$，$$b\in\mathbb{R}$$，$$\gamma$$ 是待最大化的间隔。

若做尺度归一化并令 $$\|\mathbf{w}\|_2\gamma=1$$，则可等价写为

$$
\begin{align}
\max_{\mathbf{w},b}\ \frac{2}{\|\mathbf{w}\|_2}\quad \text{s.t.}\quad y^{(n)}(\mathbf{w}^{\top}\mathbf{x}^{(n)}+b)\ge 1,\ \forall n
\end{align}
$$

其中两条支撑超平面为 $$\mathbf{w}^{\top}\mathbf{x}+b=1$$ 与 $$\mathbf{w}^{\top}\mathbf{x}+b=-1$$，中间的分类超平面为 $$\mathbf{w}^{\top}\mathbf{x}+b=0$$，间隔宽度为 $$\frac{2}{\|\mathbf{w}\|_2}$$。

#### 支持向量和支撑超平面：$$\mathbf{w}^{\top}\mathbf{x}+b=\pm1$$，决定最大间隔

> **重点**：支撑向量位于 $$\mathbf{w}^{\top}\mathbf{x}+b=\pm1$$ 上，它们决定最大间隔。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9743fd18b91c4cd995ff8e297b20bc4f.png){: referrerpolicy="no-referrer" }


### 核函数：原特征空间线性不可分


在线性情形中，我们希望构造参数 $$\mathbf{w}^{*},b^{*}$$，使

$$
\begin{align}
y^{(n)}\left((\mathbf{w}^{*})^{\top}\mathbf{x}^{(n)}+b^{*}\right)>0,\quad \forall n
\end{align}
$$

其中 $$\mathbf{x}^{(n)}\in\mathbb{R}^{D\times1}$$。

#### 核映射：投影到全新特征空间

考虑映射 $$\phi:\mathbb{R}^{D}\rightarrow\mathbb{R}^{M}$$，其中 $$M\ge2$$，并令

$$
\begin{align}
\phi(\mathbf{x}):\mathbb{R}^{D}\rightarrow\mathbb{R}^{M}
\end{align}
$$

其中 $$\phi(\mathbf{x})\in\mathbb{R}^{M\times1}$$ 是高维特征表示。

通过高维映射，希望满足

$$
\begin{align}
y^{(n)}\left((\mathbf{w}^{*})^{\top}\phi(\mathbf{x}^{(n)})+b^{*}\right)>0,\quad \forall n
\end{align}
$$

其中 $$\mathbf{w}^{*}\in\mathbb{R}^{M\times1}$$，$$b^{*}\in\mathbb{R}$$。

### 核技巧：不需要显式写出 $$\phi(\mathbf{x})$$ 的具体形式

注：一般不需要显式写出 $$\phi(\mathbf{x})$$ 的具体形式，常通过“核技巧”来构造。

### 软间隔与硬间隔

笔记仅做标题提示：软间隔允许少量样本越过间隔或被误分；硬间隔要求所有样本严格满足约束。

# 深度学习
## 前馈神经网络 FFN

前馈神经网络（FFN）的单层写法为

$$
\begin{align}
\mathbf{z}^{(l)}=\mathbf{W}^{(l)}\mathbf{a}^{(l-1)}+\mathbf{b}^{(l)}
\end{align}
$$

其中 $$\mathbf{a}^{(l-1)}\in\mathbb{R}^{d_{l-1}\times1}$$ 是上一层激活，$$\mathbf{W}^{(l)}\in\mathbb{R}^{d_l\times d_{l-1}}$$ 是第 $$l$$ 层权重矩阵，$$\mathbf{b}^{(l)}\in\mathbb{R}^{d_l\times1}$$ 是偏置，$$\mathbf{z}^{(l)}\in\mathbb{R}^{d_l\times1}$$ 是线性输出。

对应激活为

$$
\begin{align}
\mathbf{a}^{(l)}=\sigma(\mathbf{z}^{(l)})
\end{align}
$$

其中 $$\sigma(\cdot)$$ 表示逐元素激活函数。

### 通用近似定理：使用<span style="color:red">非线性激活函数</span>的 ANN 可以逼近任意连续函数。反过来，若<span style="color:red">不使用非线性激活</span>，则多层 ANN 等价于单层 ANN。

## 激活函数

### Logistic

$$
\begin{align}
\sigma(x)=\frac{1}{1+e^{-x}}
\end{align}
$$

其中 $$x\in\mathbb{R}$$ 是标量输入，$$\sigma(x)\in(0,1)$$。

### tanh

$$
\begin{align}
\sigma(x)=\frac{e^x-e^{-x}}{e^x+e^{-x}}
\end{align}
$$

其中 $$x\in\mathbb{R}$$ 是输入，$$\sigma(x)\in(-1,1)$$。

### ReLU

ReLU 是线性修正单元。

$$
\begin{align}
\sigma(x)=\max(0,x)
\end{align}
$$

其中 $$x\in\mathbb{R}$$ 是输入，$$\sigma(x)\ge0$$。

#### 死亡RELU问题：，梯度无法传导

$$
\begin{align}
\frac{\partial \sigma}{\partial f}=0
\end{align}
$$


若对某一输入始终有 $$f(\mathbf{z};\mathbf{w}^{*},b^{*})<0$$，则

$$
\begin{align}
\sigma(f(\mathbf{z};\mathbf{w}^{*},b^{*}))=0
\end{align}
$$

其中 $$\mathbf{z}$$ 是输入特征，$$f(\mathbf{z};\mathbf{w}^{*},b^{*})$$ 是线性部分输出。

链式求导时

$$
\begin{align}
\frac{\partial \mathcal{L}}{\partial \mathbf{w}}=\frac{\partial \mathcal{L}}{\partial \sigma(\cdot)}\cdot\frac{\partial \sigma(\cdot)}{\partial f}\cdot\frac{\partial f}{\partial \mathbf{w}}
\end{align}
$$

其中 $$\mathcal{L}$$ 是损失函数，$$f$$ 是线性输出，$$\frac{\partial \sigma(\cdot)}{\partial f}$$ 是激活对线性项的导数。

当 $$\sigma(\cdot)<0$$ 对应的 ReLU 截断区间起作用时，笔记强调 $$\frac{\partial \sigma}{\partial f}=0$$，于是参数无法更新，该单元可能“永远死记”。

### Leaky ReLU

Leaky ReLU 写为

$$
\begin{align}
\sigma(x)=
\begin{cases}
x,&x\ge0\\
\beta x,&x<0
\end{cases}
\end{align}
$$

其中 $$\beta$$ 是负半轴斜率，笔记中特别注明一般取 $$\beta=0.1$$。

它用于缓解负区间导数为零的问题，即在 $$x<0$$ 时仍有 $$\frac{\partial \sigma(x)}{\partial x}\neq0$$。

### Swish：门控激活函数

Swish 是带门控的激活函数。

$$
\begin{align}
\mathrm{Swish}(x)=x\cdot\sigma(\beta x)
\end{align}
$$

其中 $$x\in\mathbb{R}$$ 是输入，$$\beta$$ 是可调参数，$$\sigma(\beta x)\in(0,1)$$ 可视作门控。

#### SiLU

SiLU（sigmoid linear unit）在笔记中写为

$$
\begin{align}
\mathrm{SiLU}(x)=x\cdot\sigma(x)
\end{align}
$$

其中它可视作 $$\beta=1$$ 时的 Swish。

#### GELU：使用高斯分布作为门控

笔记中 GELU 写为

$$
\begin{align}
\mathrm{GELU}(x)=x\cdot\Phi(x)
\end{align}
$$

其中 $$\Phi(x)$$ 是高斯分布 $$\mathcal{N}(0,1)$$ 的累积分布函数，$$x$$ 是输入标量。

## 门控线性单元 GLU

### GLU

FFN 的改进方向之一是门控线性单元 GLU。笔记中给出的中间变量为

$$
\begin{align}
\mathbf{h}=(\mathbf{W}_1\mathbf{x})\odot \sigma(\mathbf{V}\mathbf{x})
\end{align}
$$

其中 $$\mathbf{x}\in\mathbb{R}^{D_1\times1}$$ 是输入，$$\mathbf{W}_1\in\mathbb{R}^{D_2\times D_1}$$ 与 $$\mathbf{V}\in\mathbb{R}^{D_2\times D_1}$$ 是线性映射矩阵，$$\odot$$ 是逐元素乘法，$$\sigma(\mathbf{V}\mathbf{x})$$ 是门控激活。

输出层为

$$
\begin{align}
\mathbf{o}=\mathbf{W}_2\mathbf{h}+\mathbf{b}_3
\end{align}
$$

其中 $$\mathbf{W}_2\in\mathbb{R}^{D_3\times D_2}$$，$$\mathbf{h}\in\mathbb{R}^{D_2\times1}$$，$$\mathbf{o}\in\mathbb{R}^{D_3\times1}$$，$$\mathbf{b}_3\in\mathbb{R}^{D_3\times1}$$。

对比普通 FFN，笔记中写出：

$$
\begin{align}
\mathbf{W}_1\in\mathbb{R}^{D_2\times D_1},\quad \mathbf{W}_2\in\mathbb{R}^{D_3\times D_2}
\end{align}
$$

其中通常取 $$D_2>D_1$$。

对 GLU，笔记额外强调：

$$
\begin{align}
\mathbf{V},\mathbf{W}_1\in\mathbb{R}^{D_2\times D_1},\quad \mathbf{W}_2\in\mathbb{R}^{D_3\times D_2}
\end{align}
$$

其中 $$\mathbf{V}$$ 与 $$\mathbf{W}_1$$ 分别提供门控分支与主分支。

### SwiGLU

笔记把 FFN 的门控激活替换成 Swish，写作

$$
\begin{align}
\mathrm{SwishGLU}(\mathbf{x})=\mathbf{W}_2\big((\mathbf{W}_1\mathbf{x}+\mathbf{b}_1)\odot \mathrm{Swish}(\mathbf{V}\mathbf{x}+\mathbf{b}_2)\big)+\mathbf{b}_3
\end{align}
$$

其中 $$\mathbf{x}\in\mathbb{R}^{D_1\times1}$$，$$\mathbf{W}_1,\mathbf{V}\in\mathbb{R}^{D_2\times D_1}$$，$$\mathbf{W}_2\in\mathbb{R}^{D_3\times D_2}$$，$$\mathbf{b}_1,\mathbf{b}_2\in\mathbb{R}^{D_2\times1}$$，$$\mathbf{b}_3\in\mathbb{R}^{D_3\times1}$$。

### GEGLU

对应地，GEGLU 写为

$$
\begin{align}
\mathrm{GEGLU}(\mathbf{x})=\mathbf{W}_2\big((\mathbf{W}_1\mathbf{x}+\mathbf{b}_1)\odot \mathrm{GELU}(\mathbf{V}\mathbf{x}+\mathbf{b}_2)\big)+\mathbf{b}_3
\end{align}
$$

其中各符号含义与 Swish GLU 相同，只是门控函数换为 GELU。

### Maxout


---

## 卷积神经网络

### 归纳偏置：局部性+ 平移不变性
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e50c5f4559874d03a5dd10183e663682.png){: referrerpolicy="no-referrer" }

### 卷积定义

给定序列 $$\mathbf{x}$$ 与滤波器 $$\mathbf{w}$$，输出写作 $$y=\mathbf{w}\ast\mathbf{x}$$。

若把输入记作矩阵 $$\mathbf{X}\in\mathbb{R}^{m\times n}$$，卷积核记作 $$\mathbf{W}\in\mathbb{R}^{u\times v}$$，则输出 $$\mathbf{Y}\in\mathbb{R}^{m'\times n'}$$。

卷积超参数包含步长 stride $$S_h,S_w$$，填充 padding $$P_h,P_w$$，卷积核大小 $$u\times v$$。若 $$\mathbf{X}\in\mathbb{R}^{M\times N}$$，则输出尺寸为

$$
\begin{align}
M'=\left\lfloor\frac{M-u+2P_h}{S_h}\right\rfloor+1
\end{align}
$$

其中 $$M$$ 是输入高，$$u$$ 是卷积核高，$$P_h$$ 是纵向 padding，$$S_h$$ 是纵向步长，$$M'$$ 是输出高。

$$
\begin{align}
N'=\left\lfloor\frac{N-v+2P_w}{S_w}\right\rfloor+1
\end{align}
$$

其中 $$N$$ 是输入宽，$$v$$ 是卷积核宽，$$P_w$$ 是横向 padding，$$S_w$$ 是横向步长，$$N'$$ 是输出宽。

窄卷积：$$S=1,P=0$$。宽卷积：$$S=1,P=K-1$$。等宽卷积满足 $$K=2P+1$$，此时输入与输出尺寸不变。

### CNN 结构：卷积-下采样-归一化-激活

卷积层提取局部特征，池化层汇聚不变信息。笔记中的结构图为：

<span style="color:red">输入 -&gt; 卷积 -&gt; 池化 -&gt; 规化/汇聚 -&gt; 输出</span>

其中卷积负责特征图的升降维，池化负责压缩信息，末端常带残差连接。

### 池化

局部感知中写了两类典型池化：

- \$$K\times K\times$$ mean：对局部区域做平均池化。
- <span style="color:red">global mean</span>：全局平均池化。

### 卷积种类

#### 转置卷积：卷积操作近似等价于矩阵$$C$$，输入和$$C$$的乘法降维度，输出和$$C^T$$的结果等价于升维

转置卷积被标注为“逆操作”。笔记中写为

$$
\begin{align}
\mathbf{Y}=\mathbf{W}\mathbf{X}=\mathbf{C}\mathbf{X}
\end{align}
$$

其中 $$\mathbf{X}\in\mathbb{R}^{m\times1}$$ 是输入展平向量，$$\mathbf{Y}\in\mathbb{R}^{k\times1}$$ 是输出，$$\mathbf{C}$$ 表示由卷积核诱导出的稀疏矩阵。

与之对应，转置卷积可写作

$$
\begin{align}
\mathbf{X}=\mathbf{C}^{\top}\mathbf{Y}
\end{align}
$$

其中 $$\mathbf{C}^{\top}$$ 把低分辨率特征重新映射回高分辨率空间。

#### 空洞卷积：在卷积核内部插入空洞来扩大感受野

空洞卷积通过在卷积核内部插入空洞来扩大感受野。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/c6306cb0d42149d48335faa2e22c3f4a.png){: referrerpolicy="no-referrer" }

#### 深度可分离卷积：先单独对空间域进行卷积，然后对通道域进行卷积

<span style="color:red">按照空间 + 通道</span> 两步拆分。

先做 depthwise 卷积。若输入 $$\mathbf{X}\in\mathbb{R}^{M\times N\times C}$$，则对每个通道 $$c\in\{1,\dots,C\}$$，使用核 $$\mathbf{W}\in\mathbb{R}^{K\times K\times C}$$ 分别卷积，得到

$$
\begin{align}
\mathbf{X}'\in\mathbb{R}^{M'\times N'\times C}
\end{align}
$$

其中 $$C$$ 是通道数，$$K\times K$$ 是空间卷积核，$$\mathbf{X}'$$ 是逐通道卷积后的结果。

再做 pointwise 映射。使用

$$
\begin{align}
\mathbf{W}'\in\mathbb{R}^{1\times1\times D}
\end{align}
$$

对通道进行线性组合，得到

$$
\begin{align}
\mathbf{Y}\in\mathbb{R}^{M'\times N'\times D}
\end{align}
$$

其中 $$D$$ 是输出通道数。笔记最后强调：分离的是空间域与通道域。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/bed51e57e6b148de84467f1781b78910.png){: referrerpolicy="no-referrer" }

## 循环神经网络

### 通用表示：隐状态=隐状态+输入

$$
\begin{align}
\mathbf{h}_t=\sigma(\mathbf{U}\mathbf{h}_{t-1}+\mathbf{W}\mathbf{x}_t)
\end{align}
$$

循环神经网络用于处理序列。

递推关系写为

$$
\begin{align}
\mathbf{h}_t=\sigma(\mathbf{U}\mathbf{h}_{t-1}+\mathbf{W}\mathbf{x}_t)
\end{align}
$$

其中 $$\mathbf{x}_t\in\mathbb{R}^{D_x\times1}$$ 是时刻 $$t$$ 的输入，$$\mathbf{h}_{t-1}\in\mathbb{R}^{D_h\times1}$$ 是上一时刻隐藏状态，$$\mathbf{U}\in\mathbb{R}^{D_h\times D_h}$$ 是循环权重，$$\mathbf{W}\in\mathbb{R}^{D_h\times D_x}$$ 是输入权重，$$\sigma(\cdot)$$ 是激活函数。

输出为

$$
\begin{align}
\mathbf{y}_t=\mathbf{V}\mathbf{h}_t
\end{align}
$$

其中 $$\mathbf{V}\in\mathbb{R}^{D_y\times D_h}$$，$$\mathbf{y}_t\in\mathbb{R}^{D_y\times1}$$。

理论上，给定序列 $$\mathbf{x}_1,\mathbf{x}_2,\dots,\mathbf{x}_N$$，可以递推出 $$\mathbf{h}_1,\mathbf{h}_2,\dots,\mathbf{h}_N$$，并进一步得到 $$\mathbf{y}_1,\mathbf{y}_2,\dots,\mathbf{y}_N$$。


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/fac59679becd4baa98c5c2fdf024285e.png){: referrerpolicy="no-referrer" }

### 应用

- 序列分类：\$$\mathbf{x}_{1:N}\rightarrow \mathbf{h}_{1:N}\rightarrow \mathbf{h}_N\rightarrow \mathbf{y}_N$$
- 序列标记：\$$\mathbf{x}_{1:N}\rightarrow \mathbf{h}_{1:N}\rightarrow \mathbf{y}_{1:N}$$
- 自回归：\$$\mathbf{x}_{1:N}\rightarrow \mathbf{h}_{1:N}\rightarrow y_{N+1}=x_{N+1}$$，再递推得到后续预测
- 条件生成：如条件回归、机器翻译

### 问题：梯度消失/爆炸，<span style="color:red">长期记忆能力有限</span>
> **RNN 问题**：长程依赖，以及梯度爆炸/消失。<span style="color:red">差异形式</span> 被特别标记。

## LSTM：遗忘门，输入门和输出门

LSTM 通过三门一候选内部状态控制记忆流动。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6b88aba515ca4472826aee6937738d10.png){: referrerpolicy="no-referrer" }


遗忘门：

$$
\begin{align}
\mathbf{f}_t=\sigma(\mathbf{W}_f\mathbf{x}_t+\mathbf{U}_f\mathbf{h}_{t-1}+\mathbf{b}_f)
\end{align}
$$

其中 $$\mathbf{f}_t\in\mathbb{R}^{D_h\times1}$$ 是遗忘门，$$\mathbf{W}_f\in\mathbb{R}^{D_h\times D_x}$$，$$\mathbf{U}_f\in\mathbb{R}^{D_h\times D_h}$$，$$\mathbf{b}_f\in\mathbb{R}^{D_h\times1}$$。

输入门：

$$
\begin{align}
\mathbf{i}_t=\sigma(\mathbf{W}_i\mathbf{x}_t+\mathbf{U}_i\mathbf{h}_{t-1}+\mathbf{b}_i)
\end{align}
$$

其中 $$\mathbf{i}_t\in\mathbb{R}^{D_h\times1}$$ 是输入门。

输出门：

$$
\begin{align}
\mathbf{o}_t=\sigma(\mathbf{W}_o\mathbf{x}_t+\mathbf{U}_o\mathbf{h}_{t-1}+\mathbf{b}_o)
\end{align}
$$

其中 $$\mathbf{o}_t\in\mathbb{R}^{D_h\times1}$$ 是输出门。

候选状态：

$$
\begin{align}
\tilde{\mathbf{c}}_t=\sigma(\mathbf{W}_c\mathbf{x}_t+\mathbf{U}_c\mathbf{h}_{t-1}+\mathbf{b}_c)
\end{align}
$$

其中 $$\tilde{\mathbf{c}}_t\in\mathbb{R}^{D_h\times1}$$ 是候选记忆。

内部状态更新：

$$
\begin{align}
\mathbf{c}_t=\mathbf{f}_t\odot \mathbf{c}_{t-1}+\mathbf{i}_t\odot \tilde{\mathbf{c}}_t
\end{align}
$$

其中 $$\mathbf{c}_{t-1},\mathbf{c}_t\in\mathbb{R}^{D_h\times1}$$ 分别是前一时刻和当前时刻的记忆状态。

隐藏状态更新：

$$
\begin{align}
\mathbf{h}_t=\mathbf{o}_t\odot\tanh(\mathbf{c}_t)
\end{align}
$$

其中 $$\mathbf{h}_t\in\mathbb{R}^{D_h\times1}$$ 是输出隐藏状态。

### 特点

#### 记忆长：三个门<span style="color:red">精细控制记忆/信息流动</span>，记忆较长。
#### 缓解梯度消：<span style="color:red">多个门控的输出</span>都要参与梯度，不容易因为逐层反向传播完全消失

> **重点**：长短期记忆通过遗忘门、输入门、输出门控制记忆流动。

#### 结构复杂
### GRU：重置门和更新门

笔记强调 GRU 用更简化的门控结构替代 LSTM 的部分机制，保留候选门与重置门的思路。总结写为：

- <span style="color:red">LSTM</span>：结构更复杂，表达细致。
- <span style="color:red">GRU</span>：结构更简单，训练更容易。

并注明：RNN 中隐藏状态 $$h_t$$ 随时间不断更新，容易出现梯度问题。

#### 特点：结构较为简洁，有一定记忆能力
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6445b7a3ea2a469eb1c3f1d727f0d748.png){: referrerpolicy="no-referrer" }

### BiLSTM

BiLSTM 即双向 LSTM，同时使用正向与反向序列信息。

若正向隐藏状态为 $$\overrightarrow{\mathbf{h}}_t$$，反向隐藏状态为 $$\overleftarrow{\mathbf{h}}_t$$，则输出可由两者联合构成。笔记主要保留了结构图，没有额外展开公式。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/42347f18fd534fd58c533e9aa97d1c2c.png){: referrerpolicy="no-referrer" }


### 自回归生成：教师强制

训练阶段，给定输入序列与输出序列，笔记特别标出 **教师强制（teacher forcing）**。

优点：并行、高效。  
缺点：误差累积。

笔记中用条件概率形式提示暴露偏差问题，可概括为：训练时模型依赖真实历史，而测试时依赖自身历史预测，二者分布不一致。

## 网络优化

### 批大小：线性缩放和梯度累积

小批量训练是默认设置。

<span style="color:red">mini-batch</span> 梯度下降可看成在稳定性与效率之间折中。

笔记中写到：

- 线性缩放：<span style="color:red">batch size</span> 增大时，训练更稳定，学习率也可相应增大。
- 梯度累积：把一个大 batch 拆成多个 <span style="color:red">mini-batch</span> 累加。

### 学习率

#### 余弦退火

$$
\begin{align}
\alpha_t=\frac{\cos\left(\pi\frac{t}{T}\right)+1}{2}\alpha_0
\end{align}
$$

其中 $$t$$ 是当前训练步，$$T$$ 是总调度长度，$$\alpha_0$$ 是初始学习率，$$\alpha_t$$ 是第 $$t$$ 步的学习率。

#### 热身

当 $$t<T'$$ 时，笔记中写为线性 warmup：

$$
\begin{align}
\alpha_t=\frac{t}{T'}\alpha_0,\quad \text{if } t<T'
\end{align}
$$

其中 $$T'$$ 是 warmup 持续步数。

### 初始化

- Xavier 初始化
- Kaiming 初始化

### 数据预处理

设数据集为 $$\{\mathbf{x}^{(n)}\}_{n=1}^{N}$$。

#### Z-score

$$
\begin{align}
x^{(i)\prime}=\frac{x^{(i)}-\mu}{\sigma}
\end{align}
$$

其中 $$x^{(i)}$$ 是第 $$i$$ 个特征，$$\mu$$ 是该特征的均值，$$\sigma$$ 是该特征的标准差，$$x^{(i)\prime}$$ 是标准化后的特征。

#### Min-max

$$
\begin{align}
x^{(i)\prime}=\frac{x^{(i)}-\min_n x^{(n)}}{\max_n x^{(n)}-\min_n x^{(n)}}
\end{align}
$$

其中 $$\min_n x^{(n)}$$ 与 $$\max_n x^{(n)}$$ 分别是该特征在样本维度上的最小值和最大值，笔记旁注说明它常把数据缩放到某一固定分布区间。

#### 白化：去除冗余数据，去除特征相关性

白化（whitening）用于去除冗余数据、去除特征相关性。

例：PCA 可用于保留高方差方向，同时去除冗余并做降维。

### 归一化层

#### 动机：优化地形平滑和内部协变量偏移
归一化的动机包括：

- 内部协变量偏移
- 优化曲面更平滑
- 缓解梯度爆炸
- 分布变化过大时利于收敛

给定张量 $$\mathbf{z}\in\mathbb{R}^{B\times L\times D}$$：

#### BatchNorm

$$
\begin{align}
\mathrm{BN}(\gamma,\beta)=\gamma\odot\frac{\mathbf{x}-\mu}{\sigma}+\beta
\end{align}
$$

其中 $$\mathbf{x}$$ 是输入张量，$$\mu,\sigma$$ 在 batch 维度上统计，$$\gamma,\beta$$ 是可学习的缩放与平移参数。

#### LayerNorm

$$
\begin{align}
\mathrm{LN}(\gamma,\beta)=\gamma\odot\frac{\mathbf{x}-\mu}{\sigma}+\beta
\end{align}
$$

其中 $$\mu,\sigma$$ 在特征维度上统计，笔记中特别写到“特征 $$(D)$$ 维度”。

#### RMSNorm：不需要均值的计算

$$
\begin{align}
\mathrm{RMSNorm}(\gamma)=\gamma\odot\frac{\mathbf{x}}{\|\mathbf{x}\|_2}
\end{align}
$$

其中 $$\|\mathbf{x}\|_2$$ 表示按特征维计算的二范数，$$\gamma$$ 是缩放参数。笔记总结其优点为：速度较快、效率较高。

> **技巧**：激活层后可做 <span style="color:red">pre-norm</span>；在注意力（Attn）和 FFN 前也可做 <span style="color:red">pre-norm</span>。

### 正则化

#### $$L_p$$ 正则化

正则项写为 $$\lambda\|\theta\|_p$$，用于约束参数规模。

#### 权重衰减：$$\theta_t=(1-\beta)\theta_{t-1}-\alpha_t g_t$$

$$
\begin{align}
\theta_t=(1-\beta)\theta_{t-1}-\alpha_t g_t
\end{align}
$$

其中 $$\theta_t$$ 是当前参数，$$\theta_{t-1}$$ 是上一步参数，$$g_t$$ 是当前梯度，$$\alpha_t$$ 是学习率，$$\beta$$ 是衰减系数。笔记中注明通常 $$\alpha,\beta\ll1$$，例如 $$\beta$$ 可取约 $$10^{-3}$$ 量级。

### 数据增强

普通增强方式包括：旋转、平移、缩放、噪音、抖动、色彩变化。

#### mixup：混合标签

$$
\begin{align}
\hat{\mathbf{x}}=\lambda \mathbf{x}_i+(1-\lambda)\mathbf{x}_j
\end{align}
$$

其中 $$\mathbf{x}_i,\mathbf{x}_j$$ 是两个样本输入，$$\lambda\in[0,1]$$ 是混合系数，$$\hat{\mathbf{x}}$$ 是混合后的输入。

$$
\begin{align}
\hat{\mathbf{y}}=\lambda \mathbf{y}_i+(1-\lambda)\mathbf{y}_j
\end{align}
$$

其中 $$\mathbf{y}_i,\mathbf{y}_j$$ 是对应标签向量，$$\hat{\mathbf{y}}$$ 是混合后的软标签。笔记中强调它会“混合，平滑边界”。

#### CutMix：局部替换，混合标签

CutMix 被记为“局部替换”，即把一个样本的局部区域替换为另一样本的局部区域，并同步混合标签。

### 概率校正

#### 标签平滑：防止过拟合

硬标签写为 one-hot，例如 $$[0,0,\dots,1,\dots,0]$$。软标签写为

$$
\begin{align}
\mathbf{y}_{\text{soft}}=\left[\alpha,\frac{\varepsilon}{K-1},\frac{\varepsilon}{K-1},\dots,\frac{\varepsilon}{K-1},1-\varepsilon\right]
\end{align}
$$

其中 $$K$$ 是类别数，$$\varepsilon$$ 是平滑系数，$$\alpha$$ 表示非目标类中被分配到的平滑质量，$$1-\varepsilon$$ 是目标类概率。

#### 教师蒸馏：避免过拟合

笔记中的解释是：这样可以避免过拟合，使输出不再是 0，同时不过度置信。

> **对比**：传统硬标签教网络“死题”；平滑标签更接近“考生”式的软性认知。
