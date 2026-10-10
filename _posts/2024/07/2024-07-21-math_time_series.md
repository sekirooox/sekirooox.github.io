---
title: "数模·时间序列"
author: MayL
date: 2024-07-21
categories: ["数学基础与数学建模", "数学基础"]
tags: ["数学", "学习笔记"]
render_with_liquid: false
description: "本文整理“数模·时间序列”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

# 时间序列思维导图
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/24e8a35081ab4d5ea03e78a7f0516f0f.png){: referrerpolicy="no-referrer" }

# 时间序列分析的方法
>聚焦于趋势和季节变化

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/fbd031ab7ae34a9b9ce7454f2ccf490e.png){: referrerpolicy="no-referrer" }
# 时间序列预测模型
## 时间序列平稳性
>时间序列的平稳性是时间序列分析中的一个重要概念。一个时间序列如果是平稳的，**意味着其统计性质（如均值、方差、自相关等）不随时间变化**。
>平稳性意义在于**简化模型，方便预测**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5857a15e2d4a4542bc2542372121d2d0.png){: referrerpolicy="no-referrer" }
## 时间序列平稳性评估ACF和PACF
![](https://i-blog.csdnimg.cn/direct/6497ecb90070476d8e74c203a846bc9f.png){: referrerpolicy="no-referrer" }
> **主要看ACF和PACF的误差是否超过置信区间，如果没有超过这可以判断时间序列的预测可以接受**


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5731cda862334c78bb2981ef8870d8d0.png){: referrerpolicy="no-referrer" }
## 差分方程

>把时间序列变量转换为该变量的滞后项y，时间常数和**扰动项e**(测量误差)
>**隔开若干个数据来看**，将非平稳时间序列变为平稳，
## AR-p 自回归模型
>从滞后项的角度将**当前序列值表示为前p个序列值与扰动项之和**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/366f28d4e1f04dbfbbf750e5897d39ff.png){: referrerpolicy="no-referrer" }
## MA-q 移动平均模型
>从扰动项的角度**将当前序列值表示为前q个扰动项之和**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/151f685f521c4bb4a52f4e03524468aa.png){: referrerpolicy="no-referrer" }
## ARMA-pq
>结合了扰动项和序列项两个角度

![](https://i-blog.csdnimg.cn/direct/48d59e75986a46d496060f570f766aef.png){: referrerpolicy="no-referrer" }

# ARIMA时间序列预测模型
>p代表当前序列值的前p个滞后项
>q代表当前序列值的前q个扰动项
>**d代表将当前序列值d次差分后的结果**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/549d4d50cae946b5abc75d4a59ea739e.png){: referrerpolicy="no-referrer" }
# SARIMA
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d6b90ecee64146c0942aab20c2d1fb71.png){: referrerpolicy="no-referrer" }

## 模型评估


 
