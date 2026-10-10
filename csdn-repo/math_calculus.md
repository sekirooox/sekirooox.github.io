@[toc]
# 高等数学

为统一记号，标量变量一般记为 $x,y,z,t$，向量一般记为 $\mathbf{r},\mathbf{n},\mathbf{s},\mathbf{l}$。以下内容按原笔记顺序整理，并尽量保留原始表述。

## 函数凹凸性

按笔记中的记号，函数“凸”与“上凸”先用中点不等式来定义。

$$\begin{align}
f\left(\frac{x_1+x_2}{2}\right)<\frac{f(x_1)+f(x_2)}{2}
\end{align}$$

其中，$x_1,x_2$ 是两个自变量取值；按笔记记号，这对应“函数凸”。

$$\begin{align}
f\left(\frac{x_1+x_2}{2}\right)>\frac{f(x_1)+f(x_2)}{2}
\end{align}$$

其中，这对应“函数上凸”的情形。

原笔记随后给出二阶导数判别。

$$\begin{align}
f''(x)>0
\end{align}$$

其中，$f''(x)$ 是函数的二阶导数；这时函数图像对应一类“向上开”的凹凸形态。

$$\begin{align}
f''(x)<0
\end{align}$$

其中，这时函数图像对应“向下开”的凹凸形态。

$$\begin{align}
f''(x_0)=0
\end{align}$$

其中，$x_0$ 是候选点；原笔记将它与拐点联系起来，即函数在该点附近可能发生凹凸性的变化。

$$\begin{align}
f'(x_0)=0
\end{align}$$

其中，$x_0$ 是驻点；原笔记特别标注它与极小值点、极大值点有关。

> **重点**
>
> <span style="color:red">二阶导数常用来判断凹凸性，二阶导数为零时要特别留意是否发生凹凸性改变。</span>

## 泰勒展开

原笔记把泰勒展开写成以 $x_0$ 为中心的幂级数。

$$\begin{align}
f(x)=\sum_{n=0}^{\infty}\frac{f^{(n)}(x_0)}{n!}(x-x_0)^n
\end{align}$$

其中，$f^{(n)}(x_0)$ 是 $f(x)$ 在 $x=x_0$ 处的 $n$ 阶导数，$n!$ 是阶乘。

把前几项展开后可写成：

$$\begin{align}
f(x)=f(x_0)+\frac{f'(x_0)}{1!}(x-x_0)+\frac{f''(x_0)}{2!}(x-x_0)^2+\cdots+\frac{f^{(n)}(x_0)}{n!}(x-x_0)^n+o(x^n)
\end{align}$$

其中，$o(x^n)$ 表示比 $x^n$ 更高阶的小量；原笔记称这类式子为 $f(x)$ 在 $x=x_0$ 处的展开式。

# 解析几何

## 平面方程：点垂式和一般式

原笔记先从点法式写起。若平面上一点为 $P_0(x_0,y_0,z_0)$，平面的法向量为 $\mathbf{n}=(A,B,C)$，则任意点 $P(x,y,z)$ 满足

$$\begin{align}
\overrightarrow{P_0P}\cdot\mathbf{n}=0
\end{align}$$

其中，$\overrightarrow{P_0P}=(x-x_0,y-y_0,z-z_0)$ 是从点 $P_0$ 指向点 $P$ 的向量。

$$\begin{align}
\overrightarrow{P_0P}=(x-x_0,y-y_0,z-z_0),\qquad \mathbf{n}=(A,B,C)
\end{align}$$

其中，$\mathbf{n}$ 是平面的法向量。

因此一般式可写成：

$$\begin{align}
A(x-x_0)+B(y-y_0)+C(z-z_0)=0
\end{align}$$

其中，$A,B,C$ 是法向量的三个分量。

进一步整理得到：

$$\begin{align}
Ax+By+Cz=D
\end{align}$$

其中，$D$ 是常数项。

### 平面夹角

设两个平面的法向量分别为 $\mathbf{n}_1=(A_1,B_1,C_1)$ 与 $\mathbf{n}_2=(A_2,B_2,C_2)$，则夹角满足

$$\begin{align}
\cos\theta=\frac{\mathbf{n}_1^T\mathbf{n}_2}{\|\mathbf{n}_1\|_2\|\mathbf{n}_2\|_2}
=\frac{A_1A_2+B_1B_2+C_1C_2}{\sqrt{A_1^2+B_1^2+C_1^2}\sqrt{A_2^2+B_2^2+C_2^2}}
\end{align}$$

其中，$\theta$ 是两个平面的夹角。

### 点到平面的距离

若平面为 $Ax+By+Cz=D$，平面外一点为 $P_0(x_0,y_0,z_0)$，平面上一点为 $P_1(x_1,y_1,z_1)$，则距离可由投影得到。

$$\begin{align}
d=\left|\overrightarrow{P_1P_0}\right||\cos\theta|
\end{align}$$

其中，$d$ 是点到平面的距离，$\theta$ 是 $\overrightarrow{P_1P_0}$ 与法向量 $\mathbf{n}$ 的夹角。

$$\begin{align}
\cos\theta=\frac{\mathbf{n}\cdot\overrightarrow{P_1P_0}}{\|\mathbf{n}\|_2\left|\overrightarrow{P_1P_0}\right|}
\end{align}$$

其中，$\mathbf{n}=(A,B,C)$ 是平面的法向量。

于是距离公式写成

$$\begin{align}
d=\frac{|\mathbf{n}\cdot\overrightarrow{P_1P_0}|}{\|\mathbf{n}\|_2}
\end{align}$$

其中，这是点到平面的投影长度公式。

进一步化为常见坐标形式：

$$\begin{align}
d=\frac{|A(x_0-x_1)+B(y_0-y_1)+C(z_0-z_1)|}{\sqrt{A^2+B^2+C^2}}
\end{align}$$

其中，$(x_0,y_0,z_0)$ 是平面外一点，$(x_1,y_1,z_1)$ 是平面上一点。

> **重点**
>
> **点到平面的距离，本质上就是向法向量方向做投影。**

## 直线方程：参数方程，向量函数形式和对称式方程

空间直线可以看成两个平面的交线。

$$\begin{align}
p_1:A_1x+B_1y+C_1z=D_1,\qquad p_2:A_2x+B_2y+C_2z=D_2
\end{align}$$

其中，$p_1,p_2$ 是两个不重合且不平行的平面，它们的交集是一条直线。

参数方程写成

$$\begin{align}
\mathbf{r}=\mathbf{r}_0+t\mathbf{s}
\end{align}$$

其中，$\mathbf{r}_0=(x_0,y_0,z_0)^T$ 是直线上的一点，$\mathbf{s}=(s_1,s_2,s_3)^T$ 是方向向量，$t$ 是参数。

对应的坐标形式为：

$$\begin{align}
\begin{cases}
x=x_0+ts_1\\
y=y_0+ts_2\\
z=z_0+ts_3
\end{cases}
\end{align}$$

其中，$s_1,s_2,s_3$ 是方向向量 $\mathbf{s}$ 的分量。

对称式写成

$$\begin{align}
\frac{x-x_0}{s_1}=\frac{y-y_0}{s_2}=\frac{z-z_0}{s_3}
\end{align}$$

其中，这需要 $s_1,s_2,s_3$ 对应分母不为零时使用。

### 两直线夹角

若两条直线的方向向量为 $\mathbf{s}_1,\mathbf{s}_2$，则

$$\begin{align}
\cos\theta=\frac{\mathbf{s}_1^T\mathbf{s}_2}{\|\mathbf{s}_1\|_2\|\mathbf{s}_2\|_2}
\end{align}$$

其中，$\theta$ 是两直线的夹角。

### 线面夹角

若平面的法向量为 $\mathbf{n}$，直线的方向向量为 $\mathbf{s}$，则原笔记给出

$$\begin{align}
\sin\varphi=\cos\theta=\frac{\mathbf{n}^T\mathbf{s}}{\|\mathbf{n}\|_2\|\mathbf{s}\|_2}
\end{align}$$

其中，$\varphi$ 是直线与平面的夹角，$\theta$ 是方向向量与法向量的夹角。

## 空间曲线方程：参数方程和相交式

原笔记把空间曲线先分成参数式与相交式两类。

$$\begin{align}
\begin{cases}
x=f(t)\\
y=g(t)\\
z=\phi(t)
\end{cases}
\end{align}$$

其中，$t$ 是参数，$f,g,\phi$ 是关于 $t$ 的函数。

笔记中的例子是螺旋线型参数方程：

$$\begin{align}
\begin{cases}
x=\cos t\\
y=\sin t\\
z=t
\end{cases}
\end{align}$$

其中，$t$ 决定空间曲线上的位置。

另一种表示方式是把空间曲线看成两个曲面的交线：

$$\begin{align}
\begin{cases}
F_1(x,y,z)=0\\
F_2(x,y,z)=0
\end{cases}
\end{align}$$

其中，$F_1,F_2$ 分别定义两个曲面。


# 切线与法平面

## 切线和法线计算方法本质区别：一个是参数方程，一个是梯度向量


## 空间曲线的切线与法平面：本质梯度

设空间曲线写成

$$\begin{align}
\mathbf{r}(t)=(f(t),g(t),\phi(t))
\end{align}$$

其中，$\mathbf{r}(t)$ 是位置向量函数。

在点 $(x_0,y_0,z_0)$ 处的切线可写成

$$\begin{align}
\mathbf{r}=\mathbf{r}_0+k\frac{d\mathbf{r}}{dt}
\end{align}$$

其中，$\mathbf{r}_0=(x_0,y_0,z_0)^T$ 是曲线上的点，$\frac{d\mathbf{r}}{dt}$ 是切向量，$k$ 是参数。

对应坐标式为

$$\begin{align}
\begin{cases}
x=x_0+kf'(t)\\
y=y_0+kg'(t)\\
z=z_0+k\phi'(t)
\end{cases}
\end{align}$$

其中，$f'(t),g'(t),\phi'(t)$ 是各分量对参数 $t$ 的导数。

法平面满足“过该点且垂直于切向量”，因此

$$\begin{align}
\overrightarrow{P_0P}\cdot\frac{d\mathbf{r}}{dt}=0
\end{align}$$

其中，$\overrightarrow{P_0P}=(x-x_0,y-y_0,z-z_0)$。

等价写成

$$\begin{align}
f'(t)(x-x_0)+g'(t)(y-y_0)+\phi'(t)(z-z_0)=0
\end{align}$$

其中，切向量本身就是法平面的法向量。

## 曲面间交线的切线：本质划归为参数方程

原笔记把两曲面的交线写成

$$\begin{align}
\begin{cases}
F_1(x,y,z)=0\\
F_2(x,y,z)=0
\end{cases}
\end{align}$$

其中，交线可在局部转化成带参数的形式。

一种常用写法是把它视为

$$\begin{align}
\begin{cases}
x=x\\
y=f(x)\\
z=g(x)
\end{cases}
\end{align}$$

其中，$x$ 被当作局部参数。

此时切向量可写成

$$\begin{align}
\begin{bmatrix}
\frac{dx}{dx}\\
\frac{dy}{dx}\\
\frac{dz}{dx}
\end{bmatrix}
=\begin{bmatrix}
1\\
\frac{dy}{dx}\\
\frac{dz}{dx}
\end{bmatrix}
\end{align}$$

其中，$\frac{dy}{dx},\frac{dz}{dx}$ 可通过对约束方程求导得到。

笔记中的例子为

$$\begin{align}
F_1:x^2+y^2+z^2=6,\qquad F_2:x+y+z=0
\end{align}$$

其中，交线是球面与平面的交线。

对 $x$ 求导后得到

$$\begin{align}
\begin{cases}
2x+2y\frac{dy}{dx}+2z\frac{dz}{dx}=0\\
1+\frac{dy}{dx}+\frac{dz}{dx}=0
\end{cases}
\end{align}$$

其中，第一式来自 $F_1$，第二式来自 $F_2$。

原笔记解得

$$\begin{align}
\begin{cases}
\frac{dx}{dx}=1\\
\frac{dy}{dx}=\frac{z-x}{y-z}\\
\frac{dz}{dx}=\frac{x-y}{y-z}
\end{cases}
\end{align}$$

其中，这是交线在一般点处的切向量分量表达式。

在点 $(1,-2,1)$ 处，切线方向向量为

$$\begin{align}
\begin{bmatrix}
1\\
0\\
-1
\end{bmatrix}
\end{align}$$

其中，这是把点 $(1,-2,1)$ 代入上式后得到的结果。

> **重点**
>
> **交线问题常先转成“隐式带参数”的形式，再通过求导拿到切向量。**

## 曲面的切平面与法线

设曲面写成

$$\begin{align}
F(x,y,z)=c
\end{align}$$

其中，$c$ 是常数，$\nabla F$ 在曲面上给出法向量方向。

若点 $P_0(x_0,y_0,z_0)$ 在曲面上，则切平面方程为

$$\begin{align}
\frac{\partial F}{\partial x}(x-x_0)+\frac{\partial F}{\partial y}(y-y_0)+\frac{\partial F}{\partial z}(z-z_0)=0
\end{align}$$

其中，各偏导默认在点 $(x_0,y_0,z_0)$ 处取值。

若曲面写成 $z=f(x,y)$，则原笔记把它转成

$$\begin{align}
F(x,y,z)=f(x,y)-z=0
\end{align}$$

其中，把显式曲面重新写成隐式曲面后，切平面公式可以统一使用。

对应的法向量为

$$\begin{align}
\nabla F=\left(\frac{\partial F}{\partial x},\frac{\partial F}{\partial y},\frac{\partial F}{\partial z}\right)
\end{align}$$

其中，$\nabla F$ 就是曲面 $F(x,y,z)=c$ 的法向量。

对于二维等值线 $f(x,y)=c$，其法向量同样由梯度给出：

$$\begin{align}
\nabla f=\left(\frac{\partial f}{\partial x},\frac{\partial f}{\partial y}\right)
\end{align}$$

其中，$\nabla f$ 是平面曲线 $f(x,y)=c$ 的法向量。

## 方向导数：标量=梯度*归一化方向

原笔记把方向导数记成

$$\begin{align}
\left.\frac{\partial f}{\partial l}\right|_{(x_0,y_0)}
\end{align}$$

其中，$l$ 表示方向，$(x_0,y_0)$ 是求导点。

若方向由向量 $\mathbf{l}$ 给出，则方向导数公式写成

$$\begin{align}
\left.\frac{\partial f}{\partial l}\right|_{(x_0,y_0)}=\nabla f\cdot\frac{\mathbf{l}}{\|\mathbf{l}\|_2}
\end{align}$$

其中，$\nabla f$ 是梯度，$\frac{\mathbf{l}}{\|\mathbf{l}\|_2}$ 是单位方向向量。

> **重点**
>
> **方向导数是标量，等于梯度在该方向上的投影。**

笔记中还用等值线的例子说明了法向量与切向量的关系。若

$$\begin{align}
x^2+y^2=1
\end{align}$$

其中，可把它写成 $f(x,y)=x^2+y^2-1=0$。

则法向量为

$$\begin{align}
\nabla f=\left(\frac{\partial f}{\partial x},\frac{\partial f}{\partial y}\right)=(2x,2y)
\end{align}$$

其中，$\nabla f$ 垂直于该点的切线。

对等式两边求导可得

$$\begin{align}
2x+2y\frac{dy}{dx}=0
\end{align}$$

其中，$\frac{dy}{dx}$ 是切线斜率。

于是

$$\begin{align}
\begin{cases}
\frac{dx}{dx}=1\\
\frac{dy}{dx}=-\frac{x}{y}
\end{cases}
\end{align}$$

其中，这给出了曲线切向量的局部表达式。

## 拉格朗日乘子法：梯度相等

原笔记最后总结了拉格朗日乘子法。若目标函数为 $f(x,y,z)$，约束条件为 $g(x,y,z)=t$，则先写成

$$\begin{align}
g(x,y,z)=t
\end{align}$$

其中，$t$ 是常数。

在约束极值点处，有

$$\begin{align}
\nabla f=\lambda\nabla g
\end{align}$$

其中，$\lambda$ 是拉格朗日乘子。

再联立约束方程

$$\begin{align}
g(x,y,z)=t
\end{align}$$

其中，最终要一起求解未知数 $x,y,z,\lambda$。

> **重点**
>
> <span style="color:red">拉格朗日乘子法的核心是：在约束极值点，目标函数梯度与约束函数梯度平行。</span>

