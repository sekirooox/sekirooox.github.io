---
title: "机器学习和深度学习·贝叶斯优化和optuna"
author: MayL
date: 2024-08-29
categories: ["深度学习与计算机视觉", "深度学习"]
tags: ["深度学习", "学习笔记"]
render_with_liquid: false
math: true
description: "本文整理“机器学习和深度学习·贝叶斯优化和optuna”涉及的模型原理、关键方法与实践要点，便于理解和复习相关技术。"
---

# 贝叶斯优化
## 贝叶斯优化的思想
 先验：取点
 似然：**假设分布**
 取了n个点之后...
 后验：近似取得极值
## 贝叶斯优化的数学过程

在贝叶斯优化的数学过程当中，我们主要执行以下几个步骤：

- 1 定义需要估计的$f(x)$以及$x$的定义域

- 2 取出有限的n个$x$上的值，求解出这些$x$对应的$f(x)$（求解观测值）

- 3 根据有限的观测值，对函数分布进行假设（该假设被称为贝叶斯优化中的先验知识），得出该假设分布上的目标值

- 4 定义某种规则，确定下一个需要计算的观测点

并持续在2-4步骤中进行循环，直到假设分布上的目标值达到我们的标准，或者所有计算资源被用完为止。以上流程又被称为序贯模型优化（SMBO），是最为经典的贝叶斯优化方法。

在实际的运算过程当中，尤其是超参数优化的过程当中：

- 需要定义的$f(x)$一般是交叉验证的结果/损失函数的结果，而$x$就是超参数空间，$x$的定义域中是超参数的各种组合

- 有限的观测值数量是贝叶斯优化的超参数之一，该观测数量也决定了整个贝叶斯优化的迭代次数

- 在第3步根据有限的观测值、对函数分布进行假设的工具被称为**概率代理模型**，概率代理模型往往是一些强大的算法，最常见的比如高斯过程、随机森林等等。传统数学推导中往往使用高斯过程，但现在最先进、最普及的优化库中默认是使用基于**随机森林的TPE**过程。

- 在第4步中用来确定下一个观测点的规则被称为**采集函数**，最常见的主要是**概率增量**（依据概率密度函数的极值）、期望增量、信息熵等等，其中大部分优化库中默认使用**期望增量**，具体表达式如下：
# optuna
一个流行的自动调超参数的工具，拥有简单的API和实用的功能。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e53c9eea066b468384fa618faa76ae1b.png){: referrerpolicy="no-referrer" }
## 使用流程
先定义`objective`函数，params传入字典，按照**正常训练流程fit和predict**
创建学习对象`study`,调用`optimize`
```python
def objective(trial):
    params = {
        'objective': 'binary:logistic',  # 使用二分类任务的目标函数
        'random_state':1412,
        'min_samples_split':trial.suggest_int('min_samples_split', 2, 10),
        'n_estimators': trial.suggest_int('n_estimators', 1, 200),
        'max_depth': trial.suggest_int('max_depth', 3, 10),
        'subsample': trial.suggest_uniform('subsample', 0.1, 1.0),
        'colsample_bytree': trial.suggest_uniform('colsample_bytree', 0.1, 1.0),
        'learning_rate': trial.suggest_loguniform('learning_rate', 0.001, 0.1),
        'eval_metric': 'logloss',  # 使用logloss作为评价指标
        'booster': trial.suggest_categorical('booster', ['gbtree', 'gblinear', 'dart']),
    }
    xgb_model = XGBClassifier(**params)
    xgb_model.fit(X_train, Y_train)
    y_pred = xgb_model.predict_proba(X_cv)[:, 1]  # 获取正类的概率
    loss = log_loss(Y_cv, y_pred)  # 使用验证集计算log_loss
    return loss

study = optuna.create_study(direction='minimize')
study.optimize(objective, n_trials=100, show_progress_bar=False) 
study.best_params
```
### trial.suggest
这个是用于**搜索可能参数值的函数**
`trial.suggest_int`:返回整型
`trial.suggest_uniform`:返回浮点数
`trial.suggest_loguniform`:这个返回一个更大范围的浮点数
`trial.suggest_categorical('booster', ['gbtree', 'gblinear', 'dart'])`：**离散型变量**，例如SVM中kernel函数的类型
`trial.suggest_normal`:返回正态分布，特点是会返回正数
### study的属性值
`study.best_params`最佳参数，是一个**字典**，可以直接传入训练器中
`study.best_value`最优目标值
`study.trials`实验次数
