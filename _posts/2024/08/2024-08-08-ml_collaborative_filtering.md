---
title: "机器学习·L3W2-协同过滤"
author: MayL
date: 2024-08-08
categories: ["机器学习与数据分析", "机器学习"]
tags: ["推荐系统", "机器学习", "数据分析"]
render_with_liquid: false
math: true
description: "本文围绕“机器学习·L3W2-协同过滤”整理基本原理、处理流程与实践方法，便于学习复习和数据分析参考。"
---

# 推荐算法
>推荐算法可以预测用户评分，并根据评分推荐数据
>推荐算法与其他预测算法的区别在于：**推荐算法中的数据大多都不完整，用户只对几个电影评分；而预测算法则要求数据完整，便于拟合和预测**
# 协同过滤
>评分矩阵Y，左侧索引是名称，栏目是用户名
>协同过滤的基本原理就是**利用已有的评分数据，对未有的评分数据进行预测**，根据评分大小推荐给用户

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/7bbc8812b6214036876f5462f6af4513.png){: referrerpolicy="no-referrer" }
本质上用的算法还是线性回归那套
## 计算公式

$$J({\mathbf{x}^{(0)},...,\mathbf{x}^{(n_m-1)},\mathbf{w}^{(0)},b^{(0)},...,\mathbf{w}^{(n_u-1)},b^{(n_u-1)}})= \left[ \frac{1}{2}\sum_{(i,j):r(i,j)=1}(\mathbf{w}^{(j)} \cdot \mathbf{x}^{(i)} + b^{(j)} - y^{(i,j)})^2 \right]+ \underbrace{\left[\frac{\lambda}{2}\sum_{j=0}^{n_u-1}\sum_{k=0}^{n-1}(\mathbf{w}^{(j)}_k)^2+ \frac{\lambda}{2}\sum_{i=0}^{n_m-1}\sum_{k=0}^{n-1}(\mathbf{x}_k^{(i)})^2\right]}_{regularization}
$$
The first summation in (1) is "for all $i$, $j$ where $r(i,j)$ equals $1$" and could be written:

$$
= \left[ \frac{1}{2}\sum_{j=0}^{n_u-1} \sum_{i=0}^{n_m-1}r(i,j)*(\mathbf{w}^{(j)} \cdot \mathbf{x}^{(i)} + b^{(j)} - y^{(i,j)})^2 \right]
+\text{regularization}
$$
## 代码
**本质上就是一个矩阵的运算，利用`np.sum()`化简代码**
>自定义计算函数`cofi_cost_func_v`
```python
def cofi_cost_func_v(X, W, b, Y, R, lambda_):
    """
    Returns the cost for the content-based filtering
    Vectorized for speed. Uses tensorflow operations to be compatible with custom training loop.
    Args:
      X (ndarray (num_movies,num_features)): matrix of item features
      W (ndarray (num_users,num_features)) : matrix of user parameters
      b (ndarray (1, num_users)            : vector of user parameters
      Y (ndarray (num_movies,num_users)    : matrix of user ratings of movies
      R (ndarray (num_movies,num_users)    : matrix, where R(i, j) = 1 if the i-th movies was rated by the j-th user
      lambda_ (float): regularization parameter
    Returns:
      J (float) : Cost
    """
    j = (tf.linalg.matmul(X, tf.transpose(W)) + b - Y)*R
    J = 0.5 * tf.reduce_sum(j**2) + (lambda_/2) * (tf.reduce_sum(X**2) + tf.reduce_sum(W**2))
    return J
```
>利用tensorflow求导
```python
iterations = 200
lambda_ = 1
for iter in range(iterations):
    with tf.GradientTape() as tape:

        cost_value = cofi_cost_func_v(X, W, b, Y, R, lambda_)


    grads = tape.gradient( cost_value, [X,W,b] )

    optimizer.apply_gradients( zip(grads, [X,W,b]) )

    if iter % 5 == 0:
        print(f"Training loss at iteration {iter}: {cost_value:0.1f}")
```
## 预测变量
+ 矩阵乘法：`y_pred=X@W.T+b`
+ 合并原始数据：`Y_res=R*Y+(1-R)*y_pred`
## 预测二进制变量
>原来的$f(w,b,x)\to f=sigmoid(z)$函数
>损失函数改为交叉熵即可！

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6965bd63142d4ff6985a5b28382739c4.png){: referrerpolicy="no-referrer" }
## 技巧：平均值正常化
## 模型评估
+ 不适合冷启动问题
+ 需要额外的信息，很难解释这些额外的信息的含义
+ **梯度下降速度极慢，参数太多**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/67cb9b2ab19d469f9063c393a43a07f7.png){: referrerpolicy="no-referrer" }

