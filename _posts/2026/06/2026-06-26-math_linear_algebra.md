---
title: "数理基础·线性代数及其应用"
author: MayL
date: 2026-06-26
categories: ["数学基础与数学建模", "数学基础"]
tags: ["线性代数", "数学", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“数理基础·线性代数及其应用”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---


# 线性变换
## 矩阵乘法
### 公式理解：线性组合，矩阵乘法划归为矩阵*向量
+ Ax=b：等价于对于A中的列向量进行**线性组合**。

$$
\begin{align}
Ax&=b \\
&=a_1x_1+a_2x_2+\cdots+a_nx_n
\end{align}
$$

+ AX=B：等价于利用X的列向量对于A中每一个列向量进行**线性组合**。

$$
\begin{align}
AX&=A[x_1,x_2,\cdots,x_n]\\
&=[Ax_1,Ax_2,\cdots,Ax_n]
\end{align}
$$

## 几何意义：坐标基的变换
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f7b802f4fd1b48d09beed171eb7f4cf7.png){: referrerpolicy="no-referrer" }

## 旋转变换
+ 坐标基旋转一定角度。
+ **面积，周长保持不变**。
+ **坐标基仍然保持正交**。

$$
\begin{align}
A=
\begin{bmatrix}
\cos\theta & -\sin\theta \\
\sin\theta & \cos\theta
\end{bmatrix}
\end{align}
$$

## 剪切变换
+ **平行性质不变**：原先平行，剪切变换后仍然保持平行。
+ **面积变换**：变换后面积发生变换。
+ **坐标基不再正交**

$$
\begin{align}
A=
\begin{bmatrix}
1 & k \\
0 & 1
\end{bmatrix}
\end{align}
$$


# 行列式
## 几何意义：线性变换后对于<span style="color:red">坐标基</span>所围成的<span style="color:red">体积</span>的缩放程度
+ 2D：面积的缩放
+ 3D：体积的缩放

## $$\det(A)=0$$：维度坍缩=不可逆
+ det不等于0：说明会对体积进行缩放，但是不会出现维度坍缩。
+ det等于0：面积退化为一条线，体积退化为面积或者线，**出现了不可逆的信息损失**，维度坍缩。

## 余子式
### 定义
+ 去除$A_{ij}$表示**去除矩阵A中 i 行 j 列**所有的元素得到的子矩阵。

$$
\begin{align}
A=
\begin{bmatrix}
1 & 2 & 3 \\
4 & 5 & 6 \\
7 & 8 & 9
\end{bmatrix}
\end{align}
$$

+ 余子式$M_{11}:$

$$
\begin{align}
M_{11}=
\begin{vmatrix}
5 & 6 \\
8 & 9
\end{vmatrix}
\end{align}
$$

## 代数余子式
+ 计算行列式时，第 i 行 j 列的余子式需要乘以$(-1)^{i+j}$
+ 假设有代数余子式$M_{11}:$

$$
\begin{align}
M_{11}= +
\begin{vmatrix}
5 & 6 \\
8 & 9
\end{vmatrix}
\end{align}
$$

+ 假设有代数余子式$M_{12}:$

$$
\begin{align}
M_{12}= -
\begin{vmatrix}
5 & 6 \\
8 & 9
\end{vmatrix}
\end{align}
$$

# 逆矩阵
## 矩阵可逆的意义：线性变换后没有出现降维或者信息压缩
## 矩阵可逆的条件
+ 行列式不等于0：$\det(A)\neq0$
+ 矩阵满秩：$R(A)=\min(n,m)$


# 线性空间
## 线性空间的定义：元素满足线性运算规则的<span style="color:red">集合</span>
+ 集合元素**简称向量**，但**不一定指代一般含义的向量**。
+ **向量空间是一种特殊的线性空间**，其中的元素满足加法/数乘封闭。

$$
\begin{align}
\mathbb{R}^2=\left\{
\begin{bmatrix}
x\\
y
\end{bmatrix}
\mid x,y\in \mathbb{R}
\right\}
\end{align}
$$

+ 多项式空间：

$$
\begin{align}
P_2=\{a+bx+cx^2 \mid a,b,c\in \mathbb{R}\}
\end{align}
$$

## 性质1：封闭性
+ 加法和数乘封闭

$$
\begin{align}
u,v\in V \Rightarrow u+v\in V
\end{align}
$$

$$
\begin{align}
u\in V,\ c\in F \Rightarrow cu\in V
\end{align}
$$

## 性质2：定义完整
+ 包含**零元素**：

$$
\begin{align}
\exists 0\in V,\quad \forall v\in V,\quad v+0=v
\end{align}
$$

+ 加法存在**逆元**：

$$
\begin{align}
\forall v\in V,\quad \exists -v\in V,\quad v+(-v)=0
\end{align}
$$

## 性质3：符合运算律

+ 满足**交换律，结合率和分配律**

$$
\begin{align}
u+v=v+u
\end{align}
$$

$$
\begin{align}
(u+v)+w=u+(v+w)
\end{align}
$$

$$
\begin{align}
c(u+v)=cu+cv
\end{align}
$$

## 与向量空间的关系：向量空间是一种特殊的线性空间
# 向量空间

## 向量空间的定义：由<span style="color:red">向量</span>组成的<span style="color:red">集合</span>
## 向量空间的维度：向量空间中<span style="color:red">线性无关向量</span>的个数
+ 向量空间的维度$\dim$ 指的是**向量空间中线性无关向量的个数**。

$$
\begin{align}
\dim \operatorname{Null}(A)=1
\end{align}
$$

## 向量空间的基
### 定义：找出n个<span style="color:red">线性无关</span>的向量可以<span style="color:red">张成</span>该空间
+ 性质1：找出n个向量**可以张成空间V**：

$$
\begin{align} \mathbf{v}_1,\mathbf{v}_2,\cdots,\mathbf{v}_n \end{align}
$$

$$
\begin{align} V=\operatorname{span}\{\mathbf{v}_1,\mathbf{v}_2,\cdots,\mathbf{v}_n\} \end{align}
$$

+ 性质2：任意一个向量都**与其他向量线性无关**：

$$
\begin{align} k_1\mathbf{v}_1+k_2\mathbf{v}_2+\cdots+k_n\mathbf{v}_n=\mathbf{0}\Rightarrow k_1=k_2=\cdots=k_n=0 \end{align}
$$

## 列空间
### 定义：矩阵A的<span style="color:red">列向量</span>所<span style="color:red">张成</span>的向量空间
+ A的列空间指的是由**A的列向量所组成的向量空间**。
+ 假设有如下矩阵$A$：

$$
\begin{align}
A=
\begin{bmatrix}
1 & 2 \\
2 & 4 \\
3 & 6
\end{bmatrix}
\end{align}
$$

+ A的列空间就是两个列向量**张成的向量空间**。

$$
\begin{align}
\operatorname{Col}(A)=
\operatorname{span}
\left\{
\begin{bmatrix}
1 \\
2 \\
3
\end{bmatrix},
\begin{bmatrix}
2 \\
4 \\
6
\end{bmatrix}
\right\}
\end{align}
$$

+ 等价于：

$$
\begin{align}\operatorname{Col}(A)=
\left\{
c_1
\begin{bmatrix}
1 \\
2 \\
3
\end{bmatrix}
+
c_2
\begin{bmatrix}
2 \\
4 \\
6
\end{bmatrix}
\mid
c_1,c_2\in \mathbb{R}
\right\}
\end{align}
$$


## 零空间

### 定义：在矩阵A作用下<span style="color:red">会变成零向量的向量</span>所<span style="color:red">张成</span>的向量空间
+ 给定矩阵A：

$$
\begin{align}
A=
\begin{bmatrix}
1 & 2 \\
2 & 4
\end{bmatrix}
\end{align}
$$

+ 零空间的定义为：

$$
\begin{align}
\operatorname{Null}(A)
=
\left\{
\mathbf{x}\mid A\mathbf{x}=\mathbf{0}
\right\}
\end{align}
$$

+ 最终得到的零空间具体定义为：

$$
\begin{align}
\operatorname{Null}(A)
=
\left\{
t
\begin{bmatrix}
-2 \\
1
\end{bmatrix}
\mid
t\in\mathbb{R}
\right\}
\end{align}
$$

+ 含义：经过矩阵A的作用后，$t[-2, 1]$**这个方向的信息都会被丢失(坍缩为零向量)**。

# 线性方程组

## 线性方程组有解的条件：矩阵A的秩等于<span style="color:red">增广矩阵</span>[A b]的秩

$$
\begin{align}
\operatorname{rank}(A)=\operatorname{rank}([A\ b])
\end{align}
$$

### 线性方程组有惟一解的条件：满秩 / 可逆
### 线性方程组有无穷个解的条件：不满秩 / 不可逆
# 秩
## 含义：经过线性变换后保留<span style="color:red">多少维度的信息</span>
+ **线性无关的方向/向量数**
+ 非零子式最高阶数

## 性质
### 行秩等于列秩
### 秩-零定理：可以表达的向量空间的维度+丢失的向量空间的维度=全部的维度
+ 列空间的维数+零空间的维数=n

$$
\begin{align}
\operatorname{rank}(A)+\operatorname{nullity}(A)=\min(n,m)
\end{align}
$$

+ 这里的**维数指的是向量空间的维度(dim)**，等价于线性无关组的数量,Null(A)=1

$$
\begin{align}
\operatorname{Null}(A)
=
\operatorname{span}
\left\{
\begin{bmatrix}
1\\
-2\\
1
\end{bmatrix}
\right\}
\end{align}
$$

# 向量运算
## 内积
### 内积的定义：向量的<span style="color:red">相似程度</span>

$$
\begin{align} \mathbf{a}\cdot\mathbf{b}=\|\mathbf{a}\|\|\mathbf{b}\|\cos\theta \end{align}
$$

## 叉乘
### 叉乘的定义：向量所围成的<span style="color:red">体积</span>，使用<span style="color:red">行列式</span>表示
+ 在2D向量中：**a和b**的叉乘表示向量a和b围成的**平行四边形的面积**，使用**行列式**计算

$$
\begin{align}
\|\mathbf{a}\times \mathbf{b}\|=\|\mathbf{a}\|\|\mathbf{b}\|\sin\theta
\end{align}
$$

+ 在3D向量中：a，b和c的叉乘结果表示三个向量所围成的**平行四面体的体积**，使用**行列式**计算。
+ 对于3D向量：a和b的叉乘表示的是**平面的法向量**

$$
\begin{align}
\mathbf{a}\times \mathbf{b}
=\begin{vmatrix}
\mathbf{i} & \mathbf{j} & \mathbf{k} \\
a_1 & a_2 & a_3 \\
b_1 & b_2 & b_3
\end{vmatrix}
\end{align}
$$

## 正交向量：向量内积为0

$$
\begin{align} \mathbf{a}\perp\mathbf{b}\Longleftrightarrow \mathbf{a}\cdot\mathbf{b}=0 \end{align}
$$


# 矩阵论

## 伴随矩阵

原笔记给出了伴随矩阵的结构写法。

$$
\begin{align}
\operatorname{adj}(A)_{n\times n}=
\begin{bmatrix}
C_{11}&C_{12}&\cdots&C_{1n}\\
C_{21}&C_{22}&\cdots&C_{2n}\\
\vdots&\vdots&\ddots&\vdots\\
C_{n1}&C_{n2}&\cdots&C_{nn}
\end{bmatrix}
\end{align}
$$


其中，$$\operatorname{adj}(A)$$ 是 $$A$$ 的伴随矩阵，$$C_{ij}$$ 是余子式对应的代数余子式。

$$
\begin{align}
C_{ij}=(-1)^{i+j}\det(M_{ij})
\end{align}
$$


其中，$$M_{ij}$$ 表示删去第 $$i$$ 行第 $$j$$ 列后得到的子式矩阵，$$\det(M_{ij})$$ 是它的行列式。

## 对称矩阵
### 定义：$$A=A^T$$
### 性质1：对称矩阵的特征值一定存在
### 性质2：不同特征值对应的特征向量一定相互正交

设 (u,v) 是 (A) 的两个特征向量，对应不同特征值 ($$\lambda$$,$$\mu$$)：

$$
\begin{align}
Au=\lambda u,\quad Av=\mu v,\quad \lambda\neq \mu
\end{align}
$$


考虑内积 (u^TAv)。由 (Av=\mu v)，有：

$$
\begin{align}
u^TAv=u^T(\mu v)=\mu u^Tv
\end{align}
$$

另一方面，由于 (A=A^T)，有：

$$
\begin{align}
u^TAv=(A^Tu)^Tv=(Au)^Tv
\end{align}
$$


再由 (Au=\lambda u)，得到：

$$
\begin{align}
(Au)^Tv=(\lambda u)^Tv=\lambda u^Tv
\end{align}
$$

因此：

$$
\begin{align}
\lambda u^Tv=\mu u^Tv
\end{align}
$$

移项：

$$
\begin{align}
(\lambda-\mu)u^Tv=0
\end{align}
$$


因为：

$$
\begin{align}
\lambda\neq \mu
\end{align}
$$


所以只能有：

$$
\begin{align}
u^Tv=0
\end{align}
$$

这说明 (u) 和 (v) 正交。

### 性质3：实对称矩阵一定可以进行正交相似化
+ 原因：特征值存在，且特征向量之间相互正交，足够构成**特征空间的基**：

$$
\begin{align} Q=\begin{bmatrix}\mathbf{q}_1 & \mathbf{q}_2 & \cdots & \mathbf{q}_n\end{bmatrix} \end{align}
$$

+ 并且**正交矩阵一定可逆**。


## 正交矩阵
### 定义：由<span style="color:red">单位正交向量</span>所组成的矩阵

$$
\begin{align} Q=\begin{bmatrix}\mathbf{q}_1 & \mathbf{q}_2 & \cdots & \mathbf{q}_n\end{bmatrix} \end{align}
$$


### 性质：正交矩阵的转置=正交矩阵的逆
+ 满足**自己转置和自己相乘**为单位阵的矩阵。

$$
\begin{align} Q^TQ=I \end{align}
$$

+ 等价于：

$$
\begin{align} Q^{-1}=Q^T \end{align}
$$


## 正定矩阵

### 定义：使得任意<span style="color:red">非零向量</span>在<span style="color:red">A下叉乘</span>结果大于0的对称矩阵

$$
\begin{align} \mathbf{x}^TA\mathbf{x}>0,\quad \mathbf{x}\neq \mathbf{0} \end{align}
$$

### 性质1：特征值一定存在且大于0

$$
\begin{align} A\mathbf{v}=\lambda \mathbf{v},\quad \mathbf{v}\neq \mathbf{0} \end{align}
$$


### 性质2：一定可逆，$$\det(A)>0$$
+ 行列式的结果等于特征值的乘积：

$$
\begin{align} \det(A)=\lambda_1\lambda_2\cdots\lambda_n \end{align}
$$


## 相似矩阵
如果存在一个矩阵P，使得矩阵P 的逆乘矩阵A 乘矩阵P 等于矩阵B，那么矩阵A 相似于矩阵B。相似矩阵A 和B 它们的特征值相同
### 定义：<span style="color:red">作用效果相似</span>的矩阵
+ A和B相似，指的是存在可逆矩阵P，使得：

$$
\begin{align} B=P^{-1}AP \end{align}
$$

$$
\begin{align} A\sim B \end{align}
$$

### 相似对角化：相似于对角化矩阵
+ A和B相似，如果B是一个对角化矩阵，那么这个过程称为：**相似对角化**


### 意义1：同一个线性变换在<span style="color:red">新基</span>下的矩阵表示

$$
\begin{align} \mathbf{y}_{\text{new}}=P^{-1}A P\mathbf{x}_{\text{new}} \end{align}
$$

### 意义2：对于矩阵<span style="color:red">作用效果的分解</span>

### 性质1：相似矩阵具有相同的秩、迹、行列式、<span style="color:red">特征值</span>
+ 理解：**作用效果一致，只是坐标基不同**，因此特征值(缩放程度)，行列式和秩(信息量)不会出现丢失。

### 性质2：相似矩阵可能具有<span style="color:red">不同的特征向量</span>
+ 不同坐标系下的基向量不一样，所以**对应的特征向量也不同**。**例如旋转90度的坐标基**。

### 作用：简化幂函数的运算

$$
\begin{align} A^k=PD^kP^{-1} \end{align}
$$


# 特征向量和特征值
## 前提

$$
\begin{align}\det(\lambda I-A)=0\end{align}
$$


## 结论1：不是所有的矩阵都有实特征值和特征向量

$$
\begin{align}\det(\lambda I-A)=\begin{vmatrix}\lambda&1\\-1&\lambda\end{vmatrix}=\lambda^2+1=0\end{align}
$$


## 结论2：对称方阵一定有特征值和特征向量

# 矩阵分解
## 相似对角化：特征值分解

### 定义：特征方程的变形，$$AV=V\Lambda\Leftrightarrow A=V\Lambda V^{-1}$$
+ A有n个线性无关的向量，则A可以分解为以下形式：

$$
\begin{align} A=P\Lambda P^{-1} \end{align}
$$

+ 其中：

$$
\begin{align} P=\begin{pmatrix}v_1&v_2&\cdots&v_n\end{pmatrix} \end{align}
$$

$$
\begin{align} \Lambda=\begin{pmatrix}\lambda_1&0&\cdots&0\\0&\lambda_2&\cdots&0\\\vdots&\vdots&\ddots&\vdots\\0&0&\cdots&\lambda_n\end{pmatrix} \end{align}
$$


### 条件：对于 n×n 矩阵，需要有 n 个线性无关特征向量
+ 对于 n×n 矩阵，需要有 n 个线性无关特征向量：

$$
\begin{align} A\in\mathbb{R}^{n\times n} \end{align}
$$

$$
\begin{align} A\text{ 可特征值分解}\Longleftrightarrow A\text{ 有 }n\text{ 个线性无关特征向量} \end{align}
$$


#### 结论1：<span style="color:red">对称矩阵</span>一定可以特征值分解

$$
\begin{align} A=A^T \end{align}
$$

$$
\begin{align} A=Q\Lambda Q^T \end{align}
$$


#### 结论2：对于非方阵，<span style="color:red">不可以特征值分解</span> (不符合特征向量的定义)

### 定理：<span style="color:red">不同特征值</span>对应的特征向量一定线性无关
可对角化常用的充分条件是存在 $$n$$ 个线性无关的特征向量；而有 $$n$$ 个不同的特征值时，这个条件自动满足。

$$
\begin{align}
\lambda_1\neq\lambda_2\Longrightarrow \mathbf{v}_1,\mathbf{v}_2\text{ 线性无关}
\end{align}
$$


其中，$$\mathbf{v}_1,\mathbf{v}_2$$ 分别是特征值 $$\lambda_1,\lambda_2$$ 对应的特征向量。
### 意义1：同一个线性变换在<span style="color:red">单位正交特征向量基</span>下的矩阵表示
+ 观察：分解后的矩阵形式**只和中间的对角矩阵有关**。

$$
\begin{align} A^k=P\Lambda^kP^{-1} \end{align}
$$

$$
\begin{align} \Lambda^k=\operatorname{diag}(\lambda_1^k,\lambda_2^k,\dots,\lambda_n^k) \end{align}
$$


### 意义2：<span style="color:red">分解矩阵</span>的作用效果 $$\rightarrow$$ 切换坐标系-缩放坐标基-切回原坐标系
+ 对于矩阵的效果进行分解。

$$
\begin{align} \text{换到特征向量坐标系}\rightarrow \text{按特征值缩放}\rightarrow \text{换回原坐标系} \end{align}
$$


## SVD分解：非方阵的相似对角化
### 定义
#### 动机：广义特征方程的变形

$$
\begin{align}
AV=U\Sigma \Leftrightarrow A=U\Sigma V^{-1} \Leftrightarrow A=U\Sigma V^{T}
\end{align}
$$

+ **动机**：给定**单位**向量$v\in \mathbb{R}^{m \times 1}$，使得$\lVert Av\rVert_2$的值最大，含义为经过A投影后，投影向量的**伸长程度最大**。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/928008db942b4ca58606015bef5ad85b.png){: referrerpolicy="no-referrer" }
+ **转换**：$\lVert Av\rVert_2$的值最大，等价于$v^TA^TAv$的值最大，其中$A^TA$一定可以进行特征分解，等价于$v^T\lambda v$。因此得到$\lVert Av\rVert_2=\sqrt{\lambda}$。最大投影长度为$\lambda$。
+ **形式化表示**：$Av=\sqrt{\lambda}u$，其中$u \in \mathbb{R}^{n \times 1}$，表示为投影后的空间中，单位的**方向向量**。

#### 形式化定义
+ 对于$A^TA$矩阵解特征方程，计算奇异值和右特征向量。
+ 其中奇异值表示在新的特征空间下(表示为向量维度**会发生变化**)，**哪些向量的伸长程度**最大，这些向量记为$U\in \mathbb{R}^{n \times n}$，奇异值对应**这些向量的拉伸程度**。
+ **左奇异向量**满足广义特征方程：$Av_i=\sigma_iu_i$。


$$
\begin{align} A=U\Sigma V^T \end{align}
$$

$$
\begin{align} U^TU=I \end{align}
$$

$$
\begin{align} \Sigma=\begin{pmatrix}\sigma_1&0&\cdots&0\\0&\sigma_2&\cdots&0\\\vdots&\vdots&\ddots&\vdots\end{pmatrix} \end{align}
$$

$$
\begin{align} V^TV=I \end{align}
$$

+ 注意：**奇异值是排序过的**


### 特点：任意<span style="color:red">实矩阵</span>都可以做 SVD 分解
### 含义：<span style="color:red">矩阵效果的分解</span>：输入方向旋转 + 各方向缩放 + 输出方向旋转

### 作用：理解重要信息和进行<span style="color:red">信息压缩</span>

$$
\begin{align} A\approx \sigma_1u_1v_1^T+\sigma_2u_2v_2^T+\cdots+\sigma_ku_kv_k^T \end{align}
$$

#### 作用1：PCA
#### 作用2：低rank近似

$$
\begin{align} A\approx U_k\Sigma_kV_k^T \end{align}
$$


## 特征值分解vs奇异值分解
| 对比点    | 特征值分解 EVD           | 奇异值分解 SVD                                  |
| ------ | ------------------- | ------------------------------------------ |
| 分解形式   | (A=P\Lambda P^{-1}) | (A=U\Sigma V^T)                            |
| 适用对象   | 只适用于方阵              | 任意矩阵，包括非方阵                                 |
| 是否一定存在 | 不一定存在               | 一定存在                                       |
| 核心条件   | 方阵有足够多线性无关特征向量      | 任意矩阵都可以                                    |
| 中间矩阵含义 | (\Lambda) 是特征值矩阵    | (\Sigma) 是奇异值矩阵                            |
| 数值性质   | 特征值可能为负数、复数         | 奇异值一定非负实数                                  |
| 方向含义   | 找到变换后方向不变的特征向量      | 找到输入空间和输出空间中的主要拉伸方向                        |
| 几何解释   | 在特征向量方向上缩放          | 旋转/反射 (\rightarrow) 缩放 (\rightarrow) 旋转/反射 |
| 正交性    | 一般 (P) 不一定正交        | (U,V) 都是正交矩阵                               |
| 稳定性    | 对一般矩阵不一定稳定          | 数值计算中通常更稳定                                 |
| 常见用途   | 对角化、矩阵幂、线性系统稳定性分析   | 降维、PCA、图像压缩、推荐系统、低秩近似


# 基变换

## 坐标的定义：基向量的线性组合

$$
\begin{align}
[\mathbf{x}]_B=
\begin{bmatrix}
c_1\\
c_2\\
\vdots\\
c_n
\end{bmatrix}
\Longleftrightarrow
\mathbf{x}=c_1\mathbf{b}_1+c_2\mathbf{b}_2+\cdots+c_n\mathbf{b}_n
\end{align}
$$


## 坐标基变换：用新基表示旧基
### 例 1

已知 $$\mathbf{x}$$ 在基 $$B$$ 下的坐标，以及基向量 $$\mathbf{b}_1,\mathbf{b}_2$$ 用基 $$C$$ 表示的形式，求 $$[\mathbf{x}]_C$$。

$$
\begin{align}
[\mathbf{x}]_B=\begin{bmatrix}3\\1\end{bmatrix},\qquad\mathbf{b}_1=4\mathbf{c}_1+\mathbf{c}_2,\qquad\mathbf{b}_2=-6\mathbf{c}_1+\mathbf{c}_2
\end{align}
$$


其中，$$B=\{\mathbf{b}_1,\mathbf{b}_2\}$$，$$C=\{\mathbf{c}_1,\mathbf{c}_2\}$$ 都是二维空间的基。

由列坐标可直接写出从 $$B$$ 到 $$C$$ 的换基矩阵。

$$
\begin{align}
P_{C\leftarrow B}=\begin{bmatrix}4&-6\\1&1\end{bmatrix}
\end{align}
$$


其中，第一列是 $$\mathbf{b}_1$$ 在基 $$C$$ 下的坐标，第二列是 $$\mathbf{b}_2$$ 在基 $$C$$ 下的坐标。

$$
\begin{align}
[\mathbf{x}]_C=P_{C\leftarrow B}[\mathbf{x}]_B=
\begin{bmatrix}
4&-6\\
1&1
\end{bmatrix}
\begin{bmatrix}
3\\
1
\end{bmatrix}=
\begin{bmatrix}
6\\
4
\end{bmatrix}
\end{align}
$$


其中，最终得到的是 $$\mathbf{x}$$ 在基 $$C$$ 下的坐标。

### 例 2

原笔记给了一组二维向量，要求写出 $$C\to B$$ 与 $$B\to C$$ 的换基矩阵。

$$
\begin{align}
\mathbf{b}_1=
\begin{bmatrix}
1\\
-3
\end{bmatrix},\qquad
\mathbf{b}_2=
\begin{bmatrix}
-2\\
4
\end{bmatrix},\qquad
\mathbf{c}_1=
\begin{bmatrix}
-7\\
9
\end{bmatrix},\qquad
\mathbf{c}_2=
\begin{bmatrix}
-5\\
7
\end{bmatrix}
\end{align}
$$


其中，四个向量都在 $$\mathbb{R}^{2\times1}$$ 中。

先把 $$\mathbf{c}_1,\mathbf{c}_2$$ 用基 $$B$$ 展开。

$$
\begin{align}
\mathbf{c}_1=a\mathbf{b}_1+b\mathbf{b}_2,\qquad
\mathbf{c}_2=c\mathbf{b}_1+d\mathbf{b}_2
\end{align}
$$


其中，$$a,b,c,d$$ 是待求系数。

由代入计算，笔记中得到

$$
\begin{align}
a=5,\qquad b=6,\qquad c=3,\qquad d=4
\end{align}
$$


其中，$$\mathbf{c}_1=5\mathbf{b}_1+6\mathbf{b}_2$$，$$\mathbf{c}_2=3\mathbf{b}_1+4\mathbf{b}_2$$。

因此，

$$
\begin{align}
P_{B\leftarrow C}=
\begin{bmatrix}
5&3\\
6&4
\end{bmatrix}
\end{align}
$$


其中，矩阵的两列分别是 $$[\mathbf{c}_1]_B$$ 与 $$[\mathbf{c}_2]_B$$。

再取逆即可得到反向换基矩阵。

$$
\begin{align}
P_{C\leftarrow B}=P_{B\leftarrow C}^{-1}=
\begin{bmatrix}
2&-\frac{3}{2}\\
-3&\frac{5}{2}
\end{bmatrix}
\end{align}
$$


其中，$$P_{C\leftarrow B}$$ 把基 $$B$$ 下的坐标转换为基 $$C$$ 下的坐标。

# 正交集和二次型

## 正交集与投影

### 向量到任意正交集的投影

设 $$W=\operatorname{span}\{\mathbf{u}_1,\mathbf{u}_2,\ldots,\mathbf{u}_n\}$$，且 $$\{\mathbf{u}_1,\ldots,\mathbf{u}_n\}$$ 是一组两两正交的向量。原笔记记投影向量为 $$\hat{\mathbf{y}}$$。

$$
\begin{align}
\mathbf{y}-\hat{\mathbf{y}}\perp W
\end{align}
$$


其中，$$\hat{\mathbf{y}}$$ 是 $$\mathbf{y}$$ 在子空间 $$W$$ 上的正交投影。

$$
\begin{align}
\hat{\mathbf{y}}=c_1\mathbf{u}_1+c_2\mathbf{u}_2+\cdots+c_n\mathbf{u}_n
\end{align}
$$


其中，$$c_i$$ 是投影系数。

$$
\begin{align}
c_i=\frac{\mathbf{y}^T\mathbf{u}_i}{\mathbf{u}_i^T\mathbf{u}_i}
\end{align}
$$


其中，$$c_i$$ 可以理解为 $$\mathbf{y}$$ 在 $$\mathbf{u}_i$$ 方向上的投影系数。

> **重点**
>
> **正交基下，投影系数可以逐项直接算，不需要联立方程。**
## 施密特正交化：构造任意空间的正交基

这一部分的原笔记是在“构造任意子空间正交基的方法”下写的。设

$$
\begin{align}
V=\operatorname{span}\{\mathbf{v}_1,\mathbf{v}_2,\ldots,\mathbf{v}_n\}
\end{align}
$$


其中，$$V$$ 是由 $$\mathbf{v}_1,\ldots,\mathbf{v}_n$$ 张成的子空间。

第一步先取第一个方向。

$$
\begin{align}
\mathbf{x}_1=\frac{\mathbf{v}_1}{\|\mathbf{v}_1\|_2}
\end{align}
$$


其中，$$\mathbf{x}_1$$ 是单位化后的第一个正交向量；原笔记也注明“不标准化亦不影响整体思路”。

第二步把 $$\mathbf{v}_2$$ 在 $$\mathbf{x}_1$$ 方向上的投影去掉。

$$
\begin{align}
\mathbf{x}_2'=\mathbf{v}_2-\operatorname{proj}_{\mathbf{x}_1}\mathbf{v}_2,\qquad
\mathbf{x}_2=\frac{\mathbf{x}_2'}{\|\mathbf{x}_2'\|_2}
\end{align}
$$


其中，$$\operatorname{proj}_{\mathbf{x}_1}\mathbf{v}_2$$ 表示 $$\mathbf{v}_2$$ 在 $$\mathbf{x}_1$$ 上的投影。

## 最小二乘法：线性方程组的近似解

原笔记把最小二乘放在“方程无解时怎么办”的语境下讨论。

$$
\begin{align}
A\mathbf{x}=\mathbf{b}
\end{align}
$$


其中，若该方程组无解，则改求使残差最小的近似解。

$$
\begin{align}
\hat{\mathbf{x}}=\arg\min_{\mathbf{x}\in\mathbb{R}^{n\times1}}\|\mathbf{b}-A\mathbf{x}\|_2
\end{align}
$$


其中，$$\hat{\mathbf{x}}$$ 是最小二乘解，$$\|\cdot\|_2$$ 是二范数。

几何上，残差 $$\mathbf{b}-A\hat{\mathbf{x}}$$ 与列空间正交，原笔记最后落到法方程：

$$
\begin{align}
A^T\mathbf{b}=A^TA\hat{\mathbf{x}}
\end{align}
$$


其中，$$A^TA$$ 是法方程中的系数矩阵，$$\hat{\mathbf{x}}$$ 是对应的最小二乘解。

## 正交对角化

### 定理：对称矩阵不同特征值的向量一定相互正交

原笔记先区分一般相似对角化与正交对角化，再强调对称矩阵的重要性。

$$
\begin{align}
A=A^T
\end{align}
$$


其中，$$A$$ 是实对称矩阵。

$$
\begin{align}
A=Q\Lambda Q^T
\end{align}
$$


其中，$$Q\in\mathbb{R}^{n\times n}$$ 是正交矩阵，满足 $$Q^TQ=QQ^T=I$$；$$\Lambda$$ 是对角矩阵。

原笔记还强调：对称矩阵的不同特征值对应的特征向量一定正交；若有重根，也可以在对应特征子空间内继续取成正交基。

> **重点**
>
> <span style="color:red">对称矩阵可以正交对角化。</span>

## 二次型

二次型部分先用矩阵形式给出定义，再讨论它的几何意义。

$$
\begin{align}
Q(\mathbf{x})=\mathbf{x}^TA\mathbf{x}
\end{align}
$$


其中，$$A\in\mathbb{R}^{n\times n}$$，$$\mathbf{x}\in\mathbb{R}^{n\times1}$$；当 $$n=2$$ 时，它对应平面上的二次曲线。

二维情形在原笔记中写成

$$
\begin{align}
Q(\mathbf{x})=
\begin{bmatrix}
x_1&x_2
\end{bmatrix}
\begin{bmatrix}
a_{11}&a_{12}\\
a_{21}&a_{22}
\end{bmatrix}
\begin{bmatrix}
x_1\\
x_2
\end{bmatrix}
\end{align}
$$


其中，$$a_{11}x_1^2$$ 与 $$a_{22}x_2^2$$ 是平方项，$$a_{12},a_{21}$$ 会带来交叉项。

### 变量代换：正交对角化

原笔记把“化掉交叉项”的关键步骤写成了正交变换。

$$
\begin{align}
\mathbf{x}=P\mathbf{y}
\end{align}
$$


其中，$$P\in\mathbb{R}^{n\times n}$$ 是正交矩阵，$$\mathbf{y}\in\mathbb{R}^{n\times1}$$ 是新坐标。

$$
\begin{align}
Q(\mathbf{x})=(P\mathbf{y})^TAP\mathbf{y}=\mathbf{y}^TP^TAP\mathbf{y}
\end{align}
$$


其中，$$P^TAP$$ 是在新坐标系下的矩阵表示。

若 $$A$$ 是对称矩阵，可选取正交矩阵 $$P$$ 使它对角化。

$$
\begin{align}
P^TAP=\Lambda
\end{align}
$$


其中，$$\Lambda$$ 是对角矩阵，这意味着二次型被化成不含交叉项的规范形式。

$$
\begin{align}
Q(\mathbf{x})=\mathbf{y}^T\Lambda\mathbf{y}
\end{align}
$$


其中，右端就是原笔记所说的“不含交叉项”的形式。

## 二次型的正定性

最后一页主要在总结二次型的正定、负定与半正定判别。

$$
\begin{align}
Q(\mathbf{x})=\mathbf{x}^TA\mathbf{x}
\end{align}
$$


其中，以下讨论默认 $$A$$ 是实对称矩阵。

$$
\begin{align}
Q(\mathbf{x})>0,\ \forall \mathbf{x}\neq\mathbf{0}
\end{align}
$$


其中，若该条件成立，则称 $$Q(\mathbf{x})$$ 正定，也称 $$A$$ 为正定矩阵。

$$
\begin{align}
Q(\mathbf{x})<0,\ \forall \mathbf{x}\neq\mathbf{0}
\end{align}
$$


其中，若该条件成立，则称 $$Q(\mathbf{x})$$ 负定。

$$
\begin{align}
Q(\mathbf{x})\ge 0,\ \forall \mathbf{x}\neq\mathbf{0}
\end{align}
$$


其中，若该条件成立，则称 $$Q(\mathbf{x})$$ 半正定。

### 定理：正交对称矩阵的特征值一定为正
原笔记在这里给出了一条核心结论：对称矩阵的正定性可直接看特征值。

$$
\begin{align}
A=P\Lambda P^T,\qquad
Q(\mathbf{x})=\mathbf{y}^T\Lambda\mathbf{y}=\lambda_1y_1^2+\lambda_2y_2^2+\cdots+\lambda_ny_n^2
\end{align}
$$


其中，$$\mathbf{x}=P\mathbf{y}$$，$$\lambda_1,\ldots,\lambda_n$$ 是 $$A$$ 的特征值。

$$
\begin{align}
Q(\mathbf{x})\text{ 正定}\Longleftrightarrow \lambda_1,\lambda_2,\ldots,\lambda_n>0
\end{align}
$$


其中，这条等价关系只在实对称矩阵情形下使用。


# 范数
## 注意：范数中对于<span style="color:red">每一个元素的计算都大于0</span>
## 向量的范数
### 范数p
+ 元素的p次方求和，最后取根号
## 矩阵范数
+ 行范数：每一行的绝对值求和，然后取最大值
+ 列范数：每一列的绝对值求和，然后取最大值
+ F范数：类似向量的norm-2范数
+ 谱范数
