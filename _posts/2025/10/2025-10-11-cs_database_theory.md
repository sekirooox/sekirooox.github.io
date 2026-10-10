---
title: "计算机基础·数据库系统原理"
author: MayL
date: 2025-10-11
categories: ["计算机系统与开发", "数据库"]
tags: ["数据库", "计算机基础", "开发笔记"]
render_with_liquid: false
description: "本文整理“计算机基础·数据库系统原理”的核心知识、常用方法与实践注意事项，便于学习复习和开发查阅。"
---

# E-R 关系图
> 实体用**方框/双线方框**，属性要用椭圆形，关系用棱形(**单线棱形/双线棱形**)
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/86a4716e700144e788df8bf2fb730c64.png){: referrerpolicy="no-referrer" }

## 实体Enitity
+ 实体由**属性，领域**组成![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/b5303852889a40c09b12100afde4dd19.png){: referrerpolicy="no-referrer" }

+ 理解：**实体就是类**，**领域就是属性的数据类型**
## 实体集
+ 实体集**就是一个表格**，其中**每一行**都是一个**实体**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e4735cd7fb7d48ac854b3f83101138f0.png){: referrerpolicy="no-referrer" }
## 关系
+ 一对一：互相箭头
+ 多对多：横线，不需要箭头
+ 多对一：单方面箭头
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/1c3936016968454da2b7d2b1dad91b9c.png){: referrerpolicy="no-referrer" }
+ 经典的错误：**箭头只能指向实体**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/86780545f24f487ca6c369c176667eed.png){: referrerpolicy="no-referrer" }
+ 其他用法：标记单一实体的不同角色
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/a5adb2669e294a56874af4e1cdacc736.png){: referrerpolicy="no-referrer" }
+ 其他用法：使用**横线+标记数量** (1,N,M)代表多对多等复杂关系。
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/f76a1a0a569c4eddafa8fb6b6c68d186.png){: referrerpolicy="no-referrer" }
+ 自关系：使用**同一实体 不同标签 表示不同角色**
+ ![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d35c3d67e6cd4b078aeaef531af40165.png){: referrerpolicy="no-referrer" }
## 约束
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/47f725a6610748dfa74dc7f3f945f9b7.png){: referrerpolicy="no-referrer" }
## E-R图中的键定义
+ 键是一个**属性的集合**，用于标识**唯一的实体**
+ 超键：可以**唯一标识实体的属性集合**
+ 键：**最小化**的超键
+ 候选键：ER图中**下划线/被选择的键**


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/6a01415fdb864ccf91aaac72637a7b1c.png){: referrerpolicy="no-referrer" }

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/d181378080bd4b019236dcf224023a0e.png){: referrerpolicy="no-referrer" }


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ba11c3cfcd644e32b0385088f81c7888.png){: referrerpolicy="no-referrer" }

### 参与约束
+ 单横线：实体可以参与/不参与关系
+ 参与约束：用双横线表示，表示**所有实体必须参与关系**，例如**所有学生必须有一个专业，对应一个系**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/69f1b4996dfd4869aba5172a45516295.png){: referrerpolicy="no-referrer" }
### 弱实体集
+ 使用**双线方框表示弱实体集**：**自己没有键，需要依赖其他实体**唯一表示。例如，楼层没有任何键(楼号)唯一标识
+ **双线棱形表示依赖关系**。

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5b4fe21f6e004fb4bac2ccad2190806b.png){: referrerpolicy="no-referrer" }

# RM 关系模型
+ 要点：**关系 就是表格**，**元组就是每一行**

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/69d0f902269e4752af4f59ec978a9da3.png){: referrerpolicy="no-referrer" }





![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/ad2b8e93f4ab494e93865d20ff830cda.png){: referrerpolicy="no-referrer" }

+ **关系模型的示例就是数据库，一些列表格**
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/5175ad9c495a40b9ad155fd4fc090d1a.png){: referrerpolicy="no-referrer" }
# E-R关系图 转 RM 模型
## 方法1：关系单独作为一个表，使用相关实体集的键 + 自己的属性
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/e5e4d102983b49f3b5f40990c812a0b2.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/29a67b2d7dee436496e005a7f9a5d1d4.png){: referrerpolicy="no-referrer" }


## 方法2：使用外键，融入到普通实体集中


![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/259aacb494844716b8a8c7440b8f2e6a.png){: referrerpolicy="no-referrer" }
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/3e0ba044db9a4f3aa3b2893cbd8cee8b.png){: referrerpolicy="no-referrer" }

## 属性重命名

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/951b3ec5fcc345c4bcaecb4846025d5b.png){: referrerpolicy="no-referrer" }
## NULL值
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/7c00c2799f90426da65c42ece2098607.png){: referrerpolicy="no-referrer" }


## ISA转RM模型
### 方法1：子类和父类一样，使用相同的RM模型，包括所有键
![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/4c3519310bcf4f47886ccbd1605f48cc.png){: referrerpolicy="no-referrer" }

## 方法2：子类只包括父类的主键和自己的属性

![在这里插入图片描述](https://i-blog.csdnimg.cn/direct/62b6b5383fd84d4b8c053e5c2dfb4b04.png){: referrerpolicy="no-referrer" }



