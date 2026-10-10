---
title: "Python语法基础"
author: MayL
date: 2024-07-07
categories: ["编程语言与工具", "Python"]
tags: ["python", "编程", "工具"]
render_with_liquid: false
description: "本文整理“Python语法基础”的基础语法、常用操作与实践要点，便于快速入门和日常开发查阅。"
---

# python语法
**TIPS：本文适合有一定编程语言基础的人快速复习python基本语法**
## 切片操作
+ ### 语法：``str[start:stop:step]``  默认省略step步长
+ ### 切片赋值：`lst[2:5] = [20, 30, 40]`
+ ### 提取子字符串或子列表`sub_str = s[7:12] `

## python的IO：
+ 基础input
  + `a=input()`：默认输入
+ 基础output
  + `print()`:默认输出
    + 默认换行
    + 参数`end=""`**控制字母之间的距离,可以理解为默认为换行符**，修改后就不会自动换行
---
## 字符串
+ ### 定义：`'A',''A'','''A'''`前两种没有任何区别，第三种可以换行输入字符
+ ### 字符类型：python没有字符型char
## 字符串的初始化
+ 直接初始化： `s=''abcd'' `
+ ### 乘法运算符：`str='a'*10` 
+ ### 构造函数：`str()`空串 // `**str5 = str(12345)`	**这个构造函数自带类型转换**
+ 字符串的格式化： `message="%.2f+%s"%(n1,n1)`   注意还有一个 % 作为分隔
## 类型转换
+ ### 其他类型到字符串：构造函数`str(int/float/...)`//格式化字符串`str_num = '%d' % num`
+ ### 强制转换为非字符串类型：`int(num)/float(num)` 与C++略有不同！
---
## python的运算符
+ **成员运算符**：返回bool
```python
    list=[1,2,3,4,5,6,8]
    if 7 in list:
        print("yes!")
    else:
        print("no!")
    if 7 not in list:
        print("yes!")
    else:
        print("no!")
```
+ 身份运算符 :比较数据类型，返回bool
```python
a=20
b=20#等价于C++ typeid(a)=typeid(b)
if a is b:
    print("yes!")
else:
    print("no!")
```
+ Python逻辑运算符   ``&&-and / ||-or / !-not``
```python    
if 1+1==2 and 1>2:
    print("yes!")
else:
    print("no!")
```
+ 除法运算符：
  + ``3//2=1``整除，返回整数
  + `3/2=1.5`浮点数除法，返回浮点数
---
## python循环
+ ### for和while循环
```python
for i in range(10):
    #
while(i<10):
    #
```
  + python的for和while循环可以加else语句，在不break的情况下自动执行一次
  + 其他与C++完全一致
+ ### range函数
  + 生成整数序列,可用于生成列表！
  + `range(stop)`默认是结束范围(**不包括**)
  + `range(start,stop,step)`默认左闭右开,step是步长
+ ### random函数
  + `import random`导入random包
  + 类内**静态函数**
    分别有生成随机整数和随机浮点数的静态方式
    + `random.random()`默认生成[0,1)浮点数
    + `random.randint(1,100)`生成指定范围的随机**整数**
    + `random.uniform(0.01,1e+9)`生成指定范围的随机**浮点数**
```python
print(random.random()*10)
print(random.randint(1,100))#分别生成指定的整数和浮点数
print(random.uniform(0.01,1e+9))
print(random.randrange(0,100,3))#在一个按步长递增的集合里随机选元素
  ```
--- 
## python列表
  + ### 乘法运算符：`zero_list = [0] * 10`	相当于倍增[0]10次
  + ### 循环初始化:`[i for i in range(10)]`
  + ### 方向索引：`list[-1]`
  + `list3=list1+list2`：拼接列表
  + ### `list1.append(1)`:添加元素
  + `del list1[2]`:删除元素 注意这个操作不是**类内操作，而是脚本操作**
  + `del list`:删除列表
## tuple元组
+ 类似于列表，可以是n元组，但是不可以修改元素
+ 基本操作
  + `tup=(a,b,c)`:初始化
  + `del tup`:删除元组
  + `del tup[2]`:错误的,不能够修改元素
---
## python字典
+ `key:value`:基本数据类型，**key必须是不可变对象**
+ 基本操作：
	### 初始化方式
	+ 初始化:	`dict={a:b,c:d}`	
	+ **列表+元组的形式**：`dict=dict( [('name', '小明'), ('age', 18)])`
		空字典`dict()`
  + `len(d)`:长度
   ### 索引
  + `d['name']`直接索引
  + `d.values()`：返回所有值
  + `d.clear()`：清空元素
---
## 集合
### 初始化
+ 	`s = {'a', 'b', 'c'}`直接初始化
+  `s = set(['a', 'b', 'c'])`调用set函数
### 基本操作
+ `s.add('d')`添加元素，若已有元素则不操作
+ ` s.remove('c')`
+ `s.clear()`
## 函数
> python的函数参数类型分为可变对象和不可变对象
> **可变对象默认是引用传递，不可变对象默认是值传递**
+ python的**函数参数类型推导是动态的**，所以只需要定义变量即可
可以在变量旁加上`a:int`作注释，不影响解释器
```python
  def f(n:int):
    if n==0:
        return 1
    else: 
        return n*f(n-1)
#这段代码不改变传入参数的值

    def h(list4):
        list4.append(5)
        return list4
#这段代码改变传入参数的值
 ```
 ## lambda表达式
 >lambda 参数 : 表达式
 
 + C++ `[&](x,y){x-y}`	
 + ### python:`lambda x,y:x-y`
## 模块
+ `import support`:导入python文件，类似C++的头文件
+ `import support.xxx`:导入support下具体某个方法或类
+ `from numpy import xxx`：导入numpy内下的特定文件
+ `from numpy import *`:导入numpy整个库，类似Java
## 面向对象
### 基本定义
```python
class 类名:
	属性
	...
	方法
	...
```
### 构造函数 
+ `def __init__`基本形式
+ 类中所有函数**第一个参数必须是self代表对象实例**
```python
def __init__(self,arg):
```
### 权限
+ 公有属性：**公有属性没有特殊的前缀或修饰符**
+ 私有属性：`__cid = '1'`
+ 私有方法：`def __run(self):`
### 继承
```python
class 基类(子类1, 子类2 ...):
	...
```

