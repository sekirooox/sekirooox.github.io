---
title: "数模·微分方程"
author: MayL
date: 2024-07-21
categories: ["数学基础与数学建模", "数学建模"]
tags: ["数学建模", "微分方程", "数学", "学习笔记"]
render_with_liquid: false
description: "本文整理“数模·微分方程”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

# 微分方程
## 核心概念
>含导数的方程或方程组
>通解和特解的区别：有初值条件的通解称作特解
>解析解和数值解的：解析解是通过代数或解析方法得到的精确解。它通常以**闭式表达式或公式**的形式存在；数值解是通过**数值方法（如迭代算法）得到的近似解**。
# matlab中求解析解
>定义syms y(x) 符号变量，
>**注意符号变量顾名思义就是一个符号，不代表任何一个变量或者向量**
>使用eq表示微分方程，**注意等号==**
>选择性提供初值

![定义](https://i-blog.csdnimg.cn/direct/835630cd2ca744ae9d9f1d35ab170ec9.png){: referrerpolicy="no-referrer" }
## 一阶微分方程
```matlab
%% 微分方程1
clear;clc;
syms y(x)%定义符号常量
%y-y'=2x
eq=y-diff(y,x)==2*x;%等号
dsolve(eq)
dsolve(eq,y(0)==3)
```
## 二阶微分方程
>等价的写法`diff(dy,x)==diff(diff(y,x))`
> **不支持`diff(y,x)(0)`的初值形式**
```matlab
%% 微分方程2 二阶处理
clear;clc;
syms y(x)
%y''+4y'+29y=0
dy=diff(y,x);
eq=diff(dy,x)+4*diff(y,x)+29*y==0;
dsolve(eq)
dsolve(eq,[y(0)==0 dy(0)==1])%不支持diff(y,x)(0)
```
## 微分方程组--参数方程
>使用列表作为参数
```matlab
%% 微分方程3 多个微分方程组x(t),y(t)
clear;clc;
syms x(t) y(t)%不能有逗号
%x'(t)=y;y'(t)=-x;
eq1=diff(x,t)==y;
eq2=diff(y,t)==-x;
[xSol(t) ySol(t)]=dsolve([eq1,eq2],[x(0)==1 y(0)==1])

```
# matlab数值解
>一般使用ode45或ode15这个函数求解
>注意传入参数不再是符号变量而是**函数**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b3f33b347d45425586925b23e201f6fb.png){: referrerpolicy="no-referrer" }
## matlab匿名函数
+ ### 匿名函数的语法`odefun1=@(x,y)-exp(x);`
+ ### 匿名函数就是`odefun1=返回值`类似的语法
## ode45函数
>**不支持高阶微分方程**
>利用线代解微分方程组的方法，换元构造新的微分方程组降低阶数
>### 将换元想象为列向量（分块矩阵）
>ode45的返回值是自变量x和**多个因变量组成的解矩阵**
```matlab
clear;clc;
odefun3=@(t,Y)[-2*Y(1)-5*(Y(2))+sin(t);Y(1)];
[x,y]=ode45(odefun3,[-2,2],[1;1]);%列向量形式
plot(x,y);
```


