---
title: "数学建模·熵权法"
author: MayL
date: 2024-07-11
categories: ["数学基础与数学建模", "数学建模"]
tags: ["数学建模", "熵权法", "数学", "学习笔记"]
render_with_liquid: false
description: "本文整理“数学建模·熵权法”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

# 熵权法
>一种计算评价指标之间权重的方法。熵权法是一种客观的方法，没有主观性，比较可靠。
## 具体定义
>熵权法的核心在于计算信息熵，信息熵反映了一个信息的紊乱程度，体现了信息的可靠性
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/8147550551c040ae9016ebc511ec437f.png){: referrerpolicy="no-referrer" }
## 具体步骤
### Step1正向化处理
>将所以评价指标转换为极大型，目的是将数据进一步转变为概率
+ #### 将极小型转换为极大型
	极小型是指评价指标越小越好
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/dfd63c9caeff4d098d0c76e32f56e373.png){: referrerpolicy="no-referrer" }
+ 代码如下：注意矩阵X可以是列向量
```matlab
function[res]=Min2Max(X)
    res=max(X)-X;
end
```
---
+ #### 将中间型转换为极大型
>中间型是指评价指标越接近最佳值越好，其中最佳值是给出的
	![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/0d65107a5a6849d6ab60b9b4de2cda58.png){: referrerpolicy="no-referrer" }
	
+ 代码如下
```matlab
function[res]=Mid2Max(X,best)
     M=max(abs(X-best));
     res=1-abs(X-best)/M;
end
```
---
+ #### 将区间型转换为极大型
>区间型是指评价指标在区间内最好，在区间外欠佳
 ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5dc4b1409d414f609dc147efc512a57d.png){: referrerpolicy="no-referrer" }
+ 代码如下

```matlab
function[res]=interval2Max(X,a,b)
    M=max(a-min(X),max(X)-b);
    for i=1:size(X)
        if X(i)>=a&&X(i)<=b
            X(i)=1;
        elseif X(i)<a
            X(i)=1-(a-X(i))/M;
        else
            X(i)=1-(X(i)-b)/M;
        end
    end
    res=X;
end
```
---
### Step2标准化
>标准化是将每一列的每一个元素除以每一列的元素平方的求和
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/aa2bbeb732314e21b8c85413ddc3be64.png){: referrerpolicy="no-referrer" }
>标准化的意义：消除计量单位不同造成的影响
### 概率矩阵
>如果说正向化使每个数据是是不是好事的程度，这时候归一化就可以得到好事放生的概率
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/39d450f8f4254ebc8aec6d89aba26e0d.png){: referrerpolicy="no-referrer" }
### Step3利用信息熵计算权重集
>注意信息熵的计算公式里有对数，所以应该适当修改概率矩阵值为0的项
	这个公式本质上也是对每一列中所有元素按照公式求和，最后除以ln n归一化处理
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f03c18db25d64264909377be2413a723.png){: referrerpolicy="no-referrer" }
## 主体代码

```matlab
%% 读取数据
X=xlsread('blind date.xlsx');
disp("成功读取！")
%% 正向化
disp("现在进行正向化操作，请按照提示操作")
vec_col=input("请输入需要正向化的列数，以数组的形式输入\n");
for i=1:size(vec_col,2)%1是行数2是列数
flag = input(['第' num2str(vec_col(i)) '列是哪类数据(【1】:极小型 【2】：中间型 【3】：区间型)，请输入序号：\n']);
    if flag==1
        X(:,vec_col(i))=Min2Max(X(:,vec_col(i)));
    elseif flag==2
        best=input("请你传入最佳值\n");
        X(:,vec_col(i))=Mid2Max(X(:,vec_col(i)),best);
    else
        arr=input("请你输入区间的左右端点，以数组的形式\n");
        X(:,vec_col(i))=Interval2Max(X(:,vec_col(i)),arr(1),arr(2));
    end
end
disp("正向化完成！");

%% 标准化
[n,m]=size(X);
Square_X=X.*X;
Sum_X=sum(Square_X).^0.5;
Stand_X=X./repmat(Sum_X,n,1);
disp("标准化完成！")
%% 概率矩阵P
P=Stand_X./repmat(sum(Stand_X),n,1);
for i=1:n
    for j=1:m
        if P(i,j)==0
            P(i,j)=0.000001
        end
    end
end
H=sum(-P.*log(P));
e=H./log(n);
d=1-e;
d=d./sum(d);
disp("计算完成,下面是正向矩阵、标准矩阵和计算得出的权重矩阵");
disp(X);
disp(Stand_X);
disp(d);
```
