---
title: "机器学习·L2W4-决策树"
author: MayL
date: 2024-08-08
categories: ["机器学习与数据分析", "机器学习"]
tags: ["决策树", "机器学习", "数据分析"]
render_with_liquid: false
math: true
description: "本文围绕“机器学习·L2W4-决策树”整理基本原理、处理流程与实践方法，便于学习复习和数据分析参考。"
---

# 决策树
- 从根节点的所有示例开始
- 计算所有可能特征的分割信息增益，并选择信息增益最高的特征
- 根据所选特征分割数据集，并创建树的左分支和右分支
- 不断重复分割过程，直到满足停止条件
## 信息增益
>也可以理解为信息熵的减少
>$p$是结果为positive的概率

$$\text{Information Gain} = H(p_1^\text{node})- \left(w^{\text{left}}H\left(p_1^\text{left}\right) + w^{\text{right}}H\left(p_1^\text{right}\right)\right),$$
## 划分依据
### 信息熵
>与逻辑回归的SparseCategoricalCrossentropy函数定义一致

$$H(p_1) = -p_1 \text{log}_2(p_1) - (1- p_1) \text{log}_2(1- p_1)$$
### 基尼指数

## 多标签分类
+ 一次性编码：将多个标签的分类划分为多个0-1变量
+ **不进行操作，决策树也能运行**：只需要更改信息熵计算公式即可！


# 回归树
树划分的标准为：

$\max\left\{\operatorname{var}_{root}-\left(w_{left}\operatorname{var}_{left}+w_{right}\operatorname{var}_{right}\right)\right\}$

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8310aface75247c8aa82d0813de79d3c.png){: referrerpolicy="no-referrer" }
输出的结果为**数据集的均值**
# 随机森林
>随机森林每次从n个样本中抽取$\sqrt{n}$个特征作为划分的标准，可以避免形成对于特定特征局部一致的决策树

决策树模型中的所有超参数也将存在于此算法中，因为随机森林是许多决策树的集合。
+ 随机森林的另一个超参数称为 n_estimators，它是组成随机森林的决策树的数量。
请记住，对于随机森林，我们随机选择特征子集并随机选择训练示例子集来训练每棵树。

+ 按照讲座，如果n是特征数量，我们将随机选择 $\sqrt{n}$这些特征来训练每棵树。请注意，您可以通过设置 max_features 参数来修改它。
+ 您还可以使用另一个参数 n_jobs 加快训练作业的速度。
由于每棵树的拟合彼此独立，因此可以并行拟合多棵树。
因此，将 n_jobs 设置得更高将增加其使用的 CPU 核心数。

```python
model=RandomForestClassifier(min_samples_split=min_samples).fit(X_train,Y_train)
    y_train=model.predict(X_train)
    y_cv=model.predict(X_cv)
    
    accuracy_train=accuracy_score(y_train,Y_train)
    accuracy_cv=accuracy_score(y_cv,Y_cv)
    
    accuracy_list_train.append(accuracy_train)
    accuracy_list_cv.append(accuracy_cv)
```

# XGBOOST
>核心思想：**刻意**挑选哪些训练效果不好(分类或者预测效果差)的样本用于**训练**决策树

梯度提升模型，称为 XGBoost。提升方法训练多棵树，但它们彼此之间不再互不相关，而是一棵树接一棵树地拟合，以最小化误差。

该模型具有与决策树相同的参数，加上学习率。

学习率是梯度下降法的步骤大小，XGBoost 在内部使用该方法来最小化每个训练步骤中的误差。

XGBoost 的一个有趣之处在于，在拟合过程中，它可以采用形式为 (X_val,y_val) 的评估数据集。

在每次迭代中，它都会测量评估数据集上的成本（或评估指标）。
一旦成本（或指标）在一定轮次（称为 early_stopping_rounds）内停止下降，训练就会停止。
迭代次数越多，估计量就越多，而估计量越多，则会导致过度拟合。
```python
from xgboost import callback
early_stopping = callback.EarlyStopping(rounds=20, save_best=True, maximize=False)
#%%
xgb_model=XGBClassifier(n_estimators=500,learning_rate=0.1)
xgb_model.fit(X_train,Y_train,eval_set=[(X_cv,Y_cv)])
```
# 剪枝
## 预剪枝
>采用贪心策略，**划分时分别计算划分前后的验证集的准确度，决定是否划分特征**
>不一定有更好的泛化性能
## 后剪枝
>建立完整个决策树后才剪枝，一般**泛化性能更强，但是时间开销更大**
# 连续与缺失
## 连续值-二分法
>设定一个阈值，用于划分左右子树，**该阈值使得信息增益最大化。**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3d913506ae1b4598b01862095163ba5b.png){: referrerpolicy="no-referrer" }
## 缺失值处理
>决策树可以很好的处理数据有缺失值的情况，**基本的原理就是给每一个数据加权重**，划分时将缺失数据全部加入到所有类别的子集中，修改权重

 公式如下：

# 更新日记
+ 8.9：更新了周志华机器学习一书中第四章的部分内容。
