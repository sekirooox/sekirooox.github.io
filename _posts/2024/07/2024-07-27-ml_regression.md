---
title: "机器学习·回归"
author: MayL
date: 2024-07-27
categories: ["机器学习与数据分析", "机器学习"]
tags: ["回归", "机器学习", "数据分析"]
render_with_liquid: false
math: true
description: "本文围绕“机器学习·回归”整理基本原理、处理流程与实践方法，便于学习复习和数据分析参考。"
---

# 线性回归
## 损失函数


$$J(w,b)=\frac{1}{2m}\sum_{i=1}^{m}\left({f^{(i)}(w_1,w_2,\ldots,w_j,b)-y^{(i)}} \right)^2
$$
## 梯度下降方法
$$w_i=w_i-\alpha\frac{1}{m}\sum_{i=1}^{m}({f^{(i)}(w_1,w_2,\ldots,w_j,b)-y^{(i)}})w_i
$$
$$b=b-\alpha\frac{1}{m}\sum_{i=1}^{m}({f^{(i)}(w_1,w_2,\ldots,w_j,b)-y^{(i)}})
$$
$$i=1,2,\ldots,m\ 表示m组数据集\\j=1,2,\ldots,p\ 表示p个w_i\\\alpha\ 表示学习率，随着变量增多不宜过大
$$
# 线性回归代码
+ 损失函数两层循环，一层针对$\Sigma$一层针对所有$w_j$
+ **时间复杂度：O($n^2m$)**	m是迭代次数
## 一元线性回归代码

```python
def cost(x,y,w,b):
    cost=0
    m=x.shape[0]# 第一行的维度 numpy默认对行操作
    for i in range(m):
        cost+=(y[i]-w*x[i]-b)**2
    cost/=2*m
    return cost
def gradient(x,y,w,b):
    m=x.shape[0]
    dj_dw_total=0
    dj_db_total=0
    for i in range(m):
        dj_dw=(w*x[i]+b-y[i])*x[i]
        dj_db=(w*x[i]+b-y[i])
        dj_dw_total+=dj_dw
        dj_db_total+=dj_db
    dj_dw_total/=m
    dj_db_total/=m
    return dj_dw_total,dj_db_total
def gradient_descent(x,y,w0,b0,alpha,iteration,cost,gradient):
    J=[]
    parameter=[]
    w=w0
    b=b0

    for i in range(iteration):
        dj_dw,dj_db=gradient(x,y,w,b)
        w-=alpha*dj_dw
        b-=alpha*dj_db

        J.append(cost(x,y,w,b))
        parameter.append([w,b])

        if i % math.ceil(iteration / 10) == 0:
            print(f"Iteration {i:4}: Cost {J[-1]:0.2e} ",
                  f"dj_dw: {dj_dw: 0.3e}, dj_db: {dj_db: 0.3e}  ",
                  f"w: {w: 0.3e}, b:{b: 0.5e}")

    print('现在为你绘制损失函数')
    plt.figure(figsize=(12, 6))
    plt.subplot(1,2,1)
    plt.plot(J[:100])
    plt.ylabel('cost')
    plt.xlabel('迭代次数')

    plt.subplot(1, 2, 2)
    plt.plot(np.arange(100,len(J)),J[100:])
    plt.ylabel('cost')
    plt.xlabel('迭代次数')
    plt.show()



    return w,b,J,parameter

```
## 多元线性回归

```python
def multi_cost(X,Y,w,b):
    m=X.shape[0]
    cost=np.sum((X@w+b-Y)**2)
    return cost
def multi_gradient(X,Y,w,b):
    m,n=X.shape
    dj_dw=np.zeros((n,))
    dj_db=0
    for i in range(m):
        temp=X[i]@w+b-Y[i]
        for j in range(n):
            dj_dw[j]+=temp*X[i,j]
        dj_db+=temp
    dj_dw=dj_dw/m
    dj_db=dj_db/m
    return dj_dw,dj_db
def mutil_gradient_descent(X,Y,w0,b0,alpha,iteration,multi_cost,multi_gradient):

    J=[]
    parameter=[]
    w=w0
    b=b0
    J.append(multi_cost(X,Y,w,b))
    parameter.append([w,b])
    for i in range(iteration):
        dj_dw,dj_db=multi_gradient(X,Y,w,b)
        w-=alpha*dj_dw
        b-=alpha*dj_db

        if i < 100000:  # prevent resource exhaustion
            J.append(multi_cost(X, Y, w, b))
            parameter.append([w,b])

        # Print cost every at intervals 10 times or as many iterations if < 10
        if i % math.ceil(iteration / 10) == 0:
            print(f"Iteration {i:4d}: Cost {J[-1]:8.2f}   ")

    print('现在为你绘制损失函数')
    plt.figure(figsize=(12, 6))
    plt.subplot(1, 2, 1)
    plt.plot(J[:len(J)//2])
    plt.ylabel('cost')
    plt.xlabel('迭代次数1')

    plt.subplot(1, 2, 2)
    plt.plot(np.arange(len(J)//2, len(J)), J[len(J)//2:])
    plt.ylabel('cost')
    plt.xlabel('迭代次数2')
    plt.show()

    return J,parameter
```
# 特征工程
>提升梯度下降的性能
## 多项式函数
>本质上也是线性回归
## 归一化
$$
\frac{x_i-\mu}{x_{max}-x_{min}}
$$
## z-score标准化
$$
\frac{x_i-\mu}{\sigma}
$$
其中：$\mu$ 是均值，$\sigma$ 是方差
# 逻辑回归
>使用线性函数预测连续值，映射到概率函数sigmoid，然后选择决策阈值即可判断**0-1问题**
## Sigmoid函数
>输出为0-1之间的**概率函数**，具有良好性质
$$f(x)=\frac{1}{1+e^{-x}}
$$
## 逻辑回归的损失函数
>为了保证梯度下降法的准确性，我们必须保证损失函数是一个凸函数或者凹函数。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/dcde73a393f74de993a3e67ea34dde16.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/89fc7b68783047578e60475ac72229f6.png){: referrerpolicy="no-referrer" }
## 梯度
与线性回归一致，但是注意这里的$f_{w,b}(x^{(i)})$已经改为了上述的概率**sigmoid函数**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5619141df7fd40ab84fcfe1f700e566e.png){: referrerpolicy="no-referrer" }
# 过拟合
>在训练集表现良好，但在预测上表现糟糕
>特征是**较高的方差**
# 正则化
>正则化是对复杂的拟合函数进行惩罚的一种方式，正则项的公式如下：
$$\frac{\lambda}{2m}\sum_{i=0}^{m-1}w_i^2
$$
>注意**训练集、测试集、交叉验证集计算损失时不需要考虑正则项。**
---
# sklearn.processing
`from sklearn.preprocessing import StandardScaler,PolynomialFeatures`
## 标准化工具
`fit_transform(X_train)`会**储存中均值，方差的信息**，并利用这些信息标准化对象
```python
scaler=StandardScaler()# 构造函数
x_norm=scaler.fit_transform(X_train)
X_norm=scaler.transform(X_train)
```
## 多项式工具
>机器学习中，多项式仍被视为一种线性回归
作用是：将数据$x_1,x_2\to x_1,x_2,x_1x_2,x_1^2,x_2^2$

`poly.fit_transform(x_train)`仍会储存多项式信息
```python
poly = PolynomialFeatures(degree, include_bias=False)
X_train_mapped = poly.fit_transform(x_train)
```
