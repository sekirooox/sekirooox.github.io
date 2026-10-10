---
title: "数学建模·非线性规划"
author: MayL
date: 2024-07-13
categories: ["数学基础与数学建模", "数学建模"]
tags: ["数学建模", "非线性规划", "数学", "学习笔记"]
render_with_liquid: false
description: "本文整理“数学建模·非线性规划”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

# 整型规划
> 适用于一个变量或多个变量的值只能是整型的情况
## 整形规划的分类
### 0-1背包问题
> 对于一个物品来说，只有选和不选两种情况
> 表现为单下标，单变量问题

 例：建设学校问题
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a1ff831fc8084675beba844e3aeb5ea2.png){: referrerpolicy="no-referrer" }
+ > 对于每个学校来说只有选和不选两种情况，在数学上我们用0-1变量来表示
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/919e68e50cd94a71b12bf2f0b2872fcd.png){: referrerpolicy="no-referrer" }
+ > 约束条件如下
		>例如对于A1来说，至少从x1，x2，x3中选择至少建设一所，反映在数学上就是0-1变量和>=1
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/423460fdffbb4b89840e05edd591ee67.png){: referrerpolicy="no-referrer" }
### 蒙特卡洛模拟代码
```matlab
%% 蒙特卡洛建校问题
clear;clc;
n=10000;
res_min=+inf;
rex_x=0;
for i=1:n
   x=randi([0,1],1,6);
   if x(1)+x(2)+x(3)>=1&x(4)+x(5)>=1&x(3)+x(5)>=1&x(2)+x(4)>=1&x(5)+x(6)>=1&x(1)>=1
       if sum(x)<res_min
           res_min=sum(x);
           res_x=x;
       end
   end
end
disp("最终结果为");
disp(res_x);
disp(res_min);
```

### 指派问题
例：工厂的设备分配问题
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/249e87e65d184298a2b4203d81fb5710.png){: referrerpolicy="no-referrer" }

>拥有两个对象，将i指派给j，所以是双下标问题
>类似于0-1背包问题，我们用带两个下标0-1向量表示问题
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/748a963ce9584e25b3c74a22f42b15d4.png){: referrerpolicy="no-referrer" }
### 代码如下

```matlab
%% 蒙特卡洛工厂分配问题
clear;clc;
n=10000;
c=[4,2,3,4;6 4 5 5; 7 6 7 6; 7 8 8 6;7 9 8 6;7 10 8 6];
res_x=0;
res=0;
for i=1:n
    flag=1;
    x=randi([1,4],1,6);
    for j=1:4
        if ismember(j,x)==0
            flag=0;
            break;
        end
    end
    sum=0;
    if flag==1
        for k=1:6
        sum=sum+c(k,x(k));
        end
        if sum>res
            res=sum;
            res_x=x;
        end
    end
end
disp("结果如下");
disp(res);
disp(res_x);
        
```

## 具体步骤
+ matlab具体函数求解
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/be0ef49ef8474e588280b52f07afd1d8.png){: referrerpolicy="no-referrer" }
+ 蒙特卡洛模拟
> 本质上是使用随机数不断模拟逼近最优解的形式
>具体问题具体分析

# 非线性规划
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/cd9ab0cb0f3a4dfab5ebc6d908720b20.png){: referrerpolicy="no-referrer" }
## 具体定义
> 对于目标函数或约束条件不是线性的情况求极值
## 具体步骤
>步骤如下，基本上就是填参数
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/31a9ee5568c94339897d0a2350cee20f.png){: referrerpolicy="no-referrer" }
## 代码模板
> 唯一要注意的点是f和nonlfun函数中的格式：
+ f函数
>参数可以理解为x作为行向量，**直接用行向量表示目标函数最后返回就行！**
```matlab
function[f]=f(x)
    %x一般指行向量,f是指函数
    f=x(1)^2+x(2)^2+x(3)^2+8;
end
```
+ nonlfun函数
>这里有两个返回值ciq和ceq，第一个是不等式，第二个是等式
**注意都要化为 =右侧为0的形式！**
```matlab
function[ciq,ceq]=nonlfun(x)%c是非线性不等式，ceq是等式
%等式或者不等式右侧必须都是0
    ciq=[x(1)+x(2)^2+x(3)^3-20];
    ceq=[-x(1)-x(2)^2+2];
end
```
+ 总模板如下
```matlab
%% 非线性规划模板
clear;clc;
%matlab中的非线性规划只能解决最小值问题
%约束条件缺失用[]代替
%约束不等式Ax<=b


disp("现在开始进行非线性规划，请按照要求输入");
%disp("以下对应矩阵的维度均与原公式相同");
disp("请提前定义好非线性函数f和非线性约束nonlfun!")
x0=input("请以行向量形式输入初值\n");
A=input("请输入线性不等式的系数矩阵A\n");
b=input("请输入线性常向量b\n");
Aeq=input("请输入线性等式的系数矩阵Aeq\n");
beq=input("请输入线性等式的常向量beq\n");
lb=input("请以列向量形式输入对应的下界\n");
ub=input("请以列向量形式输入对应的上界\n");
[x,val]=fmincon(@f,x0,A,b,Aeq,beq,lb,ub,@nonlfun);
display(x);
display(val);

```

