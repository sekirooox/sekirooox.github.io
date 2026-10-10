---
title: "数模·聚类分析"
author: MayL
date: 2024-07-22
categories: ["数学基础与数学建模", "数学基础"]
tags: ["聚类", "数学", "学习笔记"]
render_with_liquid: false
description: "本文整理“数模·聚类分析”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

# 聚类分析的原理
>**聚类简单来说就是将样本点进行分类**
>分类的原则：根据样本点的**距离**，选择合适中心点来进行分类
>样本距离：欧氏距离和切比雪夫距离等
# 聚类分析常用图像
+ 散点图
>散点图上样本点的距离很好的显示了其聚类程度

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a79bb43188d44b6892d6c108d783e8ab.png){: referrerpolicy="no-referrer" }

## 谱系图
>怎么看spss的谱系图？从纵轴聚类距离(有数字那块)作垂线，**接触多少条边产生多少个交点就分为多少类**
>理解为**把下图的每一个方框叠加在一起了**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/52fb9e0811134e7bb80041d9eb498302.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/93adefa820554804977e42384bd28b7e.png){: referrerpolicy="no-referrer" }

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/696c8fb3e706467599e09ab77a182a9c.png){: referrerpolicy="no-referrer" }
## 样本距离和类间距离
>核心概念：类间距离是基于样本点距离进行计算；类间距离不同于样本点距离
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6f058c51d5c54b8abb49f80f06741560.png){: referrerpolicy="no-referrer" }
## 类间距离计算公式
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b92e53534d9d4f99b052052192472bee.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/fb41a6edd4a44e21bba896ae44bd61e0.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8fb3b02934534699bb7cb816171530da.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5f85cda1b0ab4b85844ad42c6da4e826.png){: referrerpolicy="no-referrer" }
# 聚类分析算法
## 最短样本距离法
>反复使用类距离中的最短距离法聚类

+ 一个样本点就是一个类
+ 选类间距离最小者，将其样本点聚为一类
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f90030c72cc84598a8faea60f7ac1f29.png){: referrerpolicy="no-referrer" }
+ 重新计算类间距离
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/10361b1e246c4174aa086b1295c78a06.png){: referrerpolicy="no-referrer" }
## Kmean聚类算法
>说人话就是**提前给定类簇**(簇理解为一个群体)的中心点，然后**计算每一个类簇(一开始每一个样本点就是一个类簇)的平均距离**，分配样本点，然后重新分配新的中心点，直到中心点不再变化或者达到指定的迭代次数
>
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/438fd6485b97452db9702544c163d855.png){: referrerpolicy="no-referrer" }

# Kmean++聚类算法
>特征：**初值来源于已有样本点**
>聚类中心距离要求尽可能远，且从样本点中选取

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0c3b3f1c40954fab8e8487b582394b57.png){: referrerpolicy="no-referrer" }
# DBSCAN算法
>根据密度，不需要确定中心点，类簇数量不定

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/900ab7b9e9904f2290da2d27ac548478.png){: referrerpolicy="no-referrer" }
# SPSS
## 分析-分类-K均值或者系统聚类
>spss不支持DBSCAN算法
>系统聚类包含最短距离聚类

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8034d18d400249f6b5d53a7c484f59f8.png){: referrerpolicy="no-referrer" }

## 导入数据后应该进行数据处理
>**正向化和标准化！！！**
## 谱系图的分析
+ ### 怎么看spss的谱系图
见上
+ ### 聚类分析的指标：聚合系数
>**类中的样本点到对应聚类中心的距离之和**成为聚合系数
>聚类指标函数的放缓点决定了聚类K值的选取原则

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b517e6f008484e9a88f96105da2fb6bb.png){: referrerpolicy="no-referrer" }


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/9ea6e7f7a4fc4d919328c5cdbaaf0220.png){: referrerpolicy="no-referrer" }
# 制图
>选择模型和变量
>id标签就是每个样本点的身份，**要勾选组/点 ID标签后才能出现，需要手动设置**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b4fd573ab10841af82ca6a547c9a7661.png){: referrerpolicy="no-referrer" }




