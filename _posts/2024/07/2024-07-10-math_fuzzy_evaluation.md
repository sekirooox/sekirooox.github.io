---
title: "数学建模·模糊评价法"
author: MayL
date: 2024-07-10
categories: ["数学基础与数学建模", "数学建模"]
tags: ["数学建模", "模糊评价", "数学", "学习笔记"]
render_with_liquid: false
description: "本文整理“数学建模·模糊评价法”涉及的基本原理、计算方法与应用思路，便于学习复习和建模参考。"
---

# 模糊评价法
>一种解决评价问题或者得出最佳方案的方法
>>主观性仍比较强
## 具体定义
>三集：因素集，评语集和权重集，通过模拟矩阵的处理得到最合理的评语
	
# 具体步骤
 ## 因素集
>因素集的确定不难，难在对分级评价时，对因素集的分级有技巧

 ## 评语集
 >评语集合既可以是真正意义上的"评语",又可以是不同方案(这时问题就转变为最佳方案)
 >**评语集是数据时，使用TOPSIS确定**
 ### 模糊集合
>模糊集合不是非此即彼，没有互相排斥的属性，只能反映相关性，如年轻与年老。	 

![请添加图片描述](https://i-blog.csdnimg.cn/direct/a98ff0d5852049c88cca5699f826b18d.png){: referrerpolicy="no-referrer" }
 ### 隶属函数
>对于一个元素的隶属函数，本质上是从评语集中的元素到区间[0,1]的一个映射，越接近于１隶属程度越强
	
### 以下是常见隶属函数
>分类的确定有几个技巧：
	从越多(少)越容易导致成为这个评级入手，可以直接推断出极小型和极大型，中间的就是中间型
+ 分为极小型，中间型，极大型
+ 注意极小型靠近０的这一侧隶属程度**接近１说明隶属关系强**，以此类推想象
	
![请添加图片描述](https://i-blog.csdnimg.cn/direct/67a89742eb6e455db2fb825abe319a5c.png){: referrerpolicy="no-referrer" }
### 隶属函数的确定
+ 模糊统计法：
![请添加图片描述](https://i-blog.csdnimg.cn/direct/efcfb1df7212445892f57436a11e8062.png){: referrerpolicy="no-referrer" }
+ F分布:
	
![请添加图片描述](https://i-blog.csdnimg.cn/direct/cae56193613b4be3b371fb6a1903883f.png){: referrerpolicy="no-referrer" }
### 例题
>隶属函数如果有数据，优先使用F分布确定，没有数据可以采用模糊评价

![请添加图片描述](https://i-blog.csdnimg.cn/direct/f7ffc996bbb147b3ad250c7333bf58d8.png){: referrerpolicy="no-referrer" }确定隶属函数分布类型：
频率越高越容易确定为快，所以是极大型；频率越小越容易确定为慢，所以是极小型，**注意从多(少)对于程度判断的相关程度考虑**
![请添加图片描述](https://i-blog.csdnimg.cn/direct/f275922e5b0d441f9fd282e6e0ff8049.png){: referrerpolicy="no-referrer" }

---
## 权重集
>权重集是对每一个因素基所占权重的判断。多重评价中每一个因素集都有对应权重集
+ 层次分析法
+ 熵权法
## 模糊矩阵
>矩阵列是因素集，行是评价集，还有对应因素集的权重集

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1e596f0991534a49a13128a959c10b0f.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f80f6e79fc7940589a34dde183b1abde.png){: referrerpolicy="no-referrer" }
	
最后得到的结果是综合类所有因素集得到的最终评价集
	

## 多级评价体系
>不断综合低级因素集，生成高级评价集，最终生成最终评价集

![请添加图片描述](https://i-blog.csdnimg.cn/direct/9b4676bd3fa5499ab5b73c6363287999.png){: referrerpolicy="no-referrer" }

![请添加图片描述](https://i-blog.csdnimg.cn/direct/935e8c4762a54d32ab9c0b4f2e3f09f4.png){: referrerpolicy="no-referrer" }

# 核心步骤
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3effe242eb9146ee8c41dd937aa64900.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/88aee975c4c248c6b959efc95bf60549.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1d4010615d39495eb50ec4d13fb3b8cd.png){: referrerpolicy="no-referrer" }


# 个人总结：
>关键是理解因素集，评价集和权重集的关系和作用：
>>权重集的确定分为：层次分析或者熵权法
	评语集的确定分为：模糊统计和模拟集合
	因素集的划分：多级模糊综合评价，本质上理解完下面这点，就是一个简单的递归过程
	>模拟矩阵*权重集合的意义：综合因素集所有元素后的最佳评价集合


 	

