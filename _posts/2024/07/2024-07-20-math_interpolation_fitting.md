---
title: "数模·插值和拟合算法"
author: MayL
date: 2024-07-20
categories: ["数学基础与数学建模", "数学建模"]
tags: ["数学建模", "插值", "曲线拟合", "数学"]
render_with_liquid: false
description: "本文整理“数模·插值和拟合算法”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

# 插值
将离散的点连成曲线或者线段的一种方法
>**题目中有"任意时刻任意的量"时使用插值，因为插值一定经过样本点**
## 插值函数的概念
> **插值函数与样本离散的点一一重合**
> 插值函数往往有多个区间，多个区间插值函数样态不完全一样，**简单来说就是个分段插值**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/246bc1c9b52c41e087c43b3cce42c9ee.png){: referrerpolicy="no-referrer" }
## 插值的应用
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/89f46b361d124b629748266353745fce.png){: referrerpolicy="no-referrer" }
---
<br><br><br><br>

# 插值的算法
## 牛顿法和拉格朗日法
>一般不使用，忽略了原函数的状态，插值函数不光滑，甚至是线段函数
## 样条插值法spline
>**每一个区间上是多项式**，**且插值函数在每一个区间上m-1阶连续可导**，这样可以保证插值函数尽可能光滑

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a068d32359804bde8f056f6d8a2bdd0c.png){: referrerpolicy="no-referrer" }

### 代码如下
>**以下算法均传入一个插值区间，返回一个列表表示y值**
```matlab
%% 三次埃尔米特插值法
%以下对lnx进行差值
clear;clc;
x=0.01:0.5:10;
y=log(x);
new_x=0.5:0.01:10;
plot(x,y,'o');
hold on;
p=pchip(x,y,new_x);
plot(new_x,p,'b-');
```

## 埃尔米特插值法
> 要求多阶导数相同

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/2033f56632b5488cb6d3f575a0418b2a.png){: referrerpolicy="no-referrer" }
### 代码如下
```matlab
%% 样条差值法
clear;clc;
x=0.01:1:10;
y=log(x);
new_x=0.01:0.01:10;
plot(x,y,'r-');
hold on;
p=spline(x,y,new_x);
plot(new_x,p,'b-');
hold on;
```


<br><br><br><br>
# 拟合
将离散的点连成曲线或者线段的一种方法
>**预测模型+最好已知模型**：人口增长、SIS模型等
## 拟合的原理：最小二乘法
> 证明太复杂了，不写了
+ 四种基本的拟合函数
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/4f7c2e89e38d4cf98f700b40ad8cd994.png){: referrerpolicy="no-referrer" }
+ 傅里叶拟合：傅里叶级数
+ 高斯拟合：高斯函数
## 拟合算法的评估
>**拟合函数的系数ai如果都是线性看R-square，否则看SSE**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ecaee0bdc0a24484b8b15c74a270cc58.png){: referrerpolicy="no-referrer" }
# matlab绘图
