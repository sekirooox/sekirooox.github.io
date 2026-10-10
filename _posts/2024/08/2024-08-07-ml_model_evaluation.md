---
title: "机器学习·L2W3-模型评估"
author: MayL
date: 2024-08-07
categories: ["机器学习与数据分析", "机器学习"]
tags: ["机器学习", "数据分析"]
render_with_liquid: false
math: true
description: "本文围绕“机器学习·L2W3-模型评估”整理基本原理、处理流程与实践方法，便于学习复习和数据分析参考。"
---

# 模型评估
## 划分数据集为训练集、验证集、测试集
60%训练集、20%测试集和验证集
```python
x_train,x_,y_train,y_=train_test_split(X_train,y_train,test_size=0.4)
x_cv,x_test,y_cv,y_test=train_test_split(x_train,y_train,test_size=0.5)
```

## 交叉验证-模型选择
>使用交叉验证计算模型的损失$J_{cv}(w,b)$来评估和选择表现最好的模型。
>**不能使用测试集来选择模型：因为测试集是对模型效果的乐观估计！**
## 模型选择
# 偏差和方差
回归问题：不是从预测数据和原始数据来看，而主要指的是**训练集和验证集的损失**
分类问题：**分类错误的比例**
>偏差和方差客观反映了模型的拟合情况：**欠拟合和过拟合**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f19e6dfc021640c1926a1580a89e66f3.png){: referrerpolicy="no-referrer" }

## 高偏差bias
$J_{train}=J_{cv}$，且 $J_{train}$ 较大
>大小上训练集和验证集差不多，但是训练集的损失较大
## 高方差variance
$J_{train}\ll J_{cv}$
>验证集与训练集的损失有较大出入，且验证集明显大于训练集
## 正则化
>正则化系数$\lambda$越大，**拟合曲线就越趋于平缓，偏差越大。**
## 学习曲线
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2665825ffa0846e0a79faad806d39081.png){: referrerpolicy="no-referrer" }
# 模型改进
>模型改进主要思路是：**高偏差就改进拟合的模型，高方差就增多训练集**
## 高偏差
+ **增加训练集大小无用，模型欠拟合**
+ 增加更多特征：多项式化数据
+ 减小正则化参数$\lambda$
## 高方差
+ **增加训练集大小**有效减少过拟合情况
+ 减小特征大小
+ 增大正则化参数$\lambda$
# 神经网络的改进
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8c1038e7ba7044e3aaf4534a18f01d90.png){: referrerpolicy="no-referrer" }

## 高偏差
+ 更大的神经网络
## 高方差
+ 更多的训练集
# 迁移学习
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/80f08dc6adcd42deb41ee70397b99470.png){: referrerpolicy="no-referrer" }

>套用别人训练的参数，改进自己的输出层，可以在自己的数据量小的情况下有良好表现
>**要求输入层特征数二者保持一致，输出层可以改变**
# *分类评估指标
## 准确率Accuracy
略
## 精确率precision和召回率recall
>精确率表征的是**预测的准确性**
>召回率表征的是**实际的准确性**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/21ca976c88f54bb4949f7a38b5d017e8.png){: referrerpolicy="no-referrer" }
## F1-score
>一种准确率和召回率的权衡方法，**用于评估不同分类模型的效果**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6c00737d6c9c4cec8516e016667bf893.png){: referrerpolicy="no-referrer" }
