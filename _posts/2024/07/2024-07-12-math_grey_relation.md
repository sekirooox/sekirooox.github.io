---
title: "数学建模·灰色关联度"
author: MayL
date: 2024-07-12
categories: ["数学基础与数学建模", "数学建模"]
tags: ["数学建模", "灰色关联", "数学", "学习笔记"]
render_with_liquid: false
description: "本文整理“数学建模·灰色关联度”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

# 灰色关联分析
## 基本原理
> 灰色关联分析可以确定一个系统中哪些因素是主要因素，哪些是次要因素；
>>灰色关联分析也可以用于综合评价，但是由于数据预处理的方式不同，导致结果 有较大出入 ，故一般不采用![](https://i-blog.csdnimg.cn/direct/d8428606608c460b96cdb64ecc812385.png){: referrerpolicy="no-referrer" }
## 具体步骤
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/afe2e81866a14e6986bdd98c44ed7319.png){: referrerpolicy="no-referrer" }

### 数据预处理
>处理方式一般有正向化和标准化，下图采用求均值的方法
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ca2ef15ad08947579a1b4bfa0fa9df32.png){: referrerpolicy="no-referrer" }
### 确定母序列和子序列
>简单理解为母序列就是因变量，我们现在的目的是探究谁是主要因素，那么子序列就是对应于因变量的几个自变量。
>>结婚率收到多个因素影响，所以是母序列![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ff803bc29eca4d188d871b346742280c.png){: referrerpolicy="no-referrer" }
### 计算两级最小差和两级最大差
>计算公式如下
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f8561fc55a1d48c29b6a8584e2470735.png){: referrerpolicy="no-referrer" }
>注意第二个max和miin符号表示**表格里的最大最小值**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a78490a9bfbb44b3ac22e80c1ceeea26.png){: referrerpolicy="no-referrer" }
### 确定灰色关联系数
>利用公式计算
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a2eb1586815b4982a75a03da5c541fdf.png){: referrerpolicy="no-referrer" }
>最后求均值![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d9da163969e34f80bc0753207d38ff65.png){: referrerpolicy="no-referrer" }
### 结论
>灰色关联度的大小反映了因变量"年轻人不愿意结婚"与女性婚后失业有极大相关性
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/43cb04e3b84d446194f0876554df2a60.png){: referrerpolicy="no-referrer" }
## EXCEL表格实操
>原始数据
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3fc0cac9f8e64d3293896793ba9b80c6.png){: referrerpolicy="no-referrer" }
>处理后
>![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e6a343fc40da429db9fea8f1adef6ae5.png){: referrerpolicy="no-referrer" }
